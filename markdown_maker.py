import os
import re
import glob
import hashlib
import sys

# Configuration
# Set this to "." to search the current directory and all subdirectories
ROOT_DIR = "." 
OUTPUT_BASE = "./output" # Markdown files will go here, mirroring structure

# Pascal keyword triggers to detect code blocks
PASCAL_TRIGGERS = [
    r'^\s*unit\s+', r'^\s*program\s+', r'^\s*interface\s*', 
    r'^\s*implementation\s+', r'^\s*uses\s+', r'^\s*type\s*', 
    r'^\s*const\s*', r'^\s*var\s*', r'^\s*procedure\s+', 
    r'^\s*function\s+', r'^\s*begin\s*', r'^\s*\{\$'
]
TRIGGER_REGEX = re.compile('|'.join(PASCAL_TRIGGERS), re.IGNORECASE)
END_REGEX = re.compile(r'^\s*end\.\s*', re.IGNORECASE)

# Regex to parse the dir.txt lines
REGEX_WITH_AUTHOR = re.compile(
    r'^(?P<filename>[\w\d]+\.PAS)\s+'
    r'(?P<date>[\d-]+)\s+'
    r'(?P<time>[\d:]+)\s+'
    r'(?P<description>".*?")\s+by\s+'
    r'(?P<contributor>.*)$', 
    re.IGNORECASE
)

REGEX_NO_AUTHOR = re.compile(
    r'^(?P<filename>[\w\d]+\.PAS)\s+'
    r'(?P<date>[\d-]+)\s+'
    r'(?P<time>[\d:]+)\s+'
    r'(?P<description>.*)$', 
    re.IGNORECASE
)

def log(msg):
    print(f"[LOG] {msg}")

def sanitize_filename(text):
    if not text: return ""
    text = text.replace('"', '').replace("'", "")
    text = text.replace(' ', '_').replace('/', '-').replace('\\', '-')
    text = re.sub(r'[^a-zA-Z0-9_.-]', '', text)
    return text

def get_file_stats(filepath):
    if not os.path.exists(filepath):
        return 0, "0 bytes", ""
    size = os.path.getsize(filepath)
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return size, f"{size:,} bytes", sha256_hash.hexdigest().upper()

def parse_dir_file(directory):
    """
    Looks for a *_dir.txt file in the given directory.
    Returns (Category Name, Slug, Metadata Dictionary)
    """
    # Find any file ending in dir.txt (case insensitive usually matches on Windows)
    # We use glob to be sure.
    search_path = os.path.join(directory, "*dir.txt")
    files = glob.glob(search_path)
    
    if not files:
        # Try finding uppercase DIR.TXT or similar if case sensitivity is an issue
        files = [f for f in os.listdir(directory) if f.lower().endswith("dir.txt")]
        if files:
            files = [os.path.join(directory, files[0])]
    
    if not files:
        log(f"⚠️  No *_dir.txt file found in {directory}. Skipping metadata scan.")
        return None, None, {}

    dir_file = files[0]
    log(f"Found index file: {os.path.basename(dir_file)}")

    metadata = {}
    category_name = "Unknown Category"

    try:
        with open(dir_file, 'r', encoding='cp437', errors='replace') as f:
            lines = f.readlines()
            
        if lines:
            first_line = lines[0].strip()
            if "SWAG Title:" in first_line:
                category_name = first_line.split("SWAG Title:")[1].strip()
            else:
                category_name = first_line

        # Default slug is directory name if category is weird, otherwise first word of category
        dir_name = os.path.basename(os.path.normpath(directory))
        category_slug = dir_name.lower()
        
        # Parse content
        count = 0
        for line in lines:
            line = line.strip()
            if not line: continue
            
            # Try Author match
            match = REGEX_WITH_AUTHOR.match(line)
            if match:
                fname = match.group('filename')
                metadata[fname] = {
                    'date': f"{match.group('date')}  {match.group('time')}",
                    'description': match.group('description'),
                    'contributor': match.group('contributor'),
                    'has_author': True
                }
                count += 1
                continue

            # Try No-Author match
            match = REGEX_NO_AUTHOR.match(line)
            if match:
                fname = match.group('filename')
                if "SWAG Title" in line: continue
                metadata[fname] = {
                    'date': f"{match.group('date')}  {match.group('time')}",
                    'description': match.group('description'),
                    'contributor': None,
                    'has_author': False
                }
                count += 1
        
        log(f"Parsed {count} entries from {os.path.basename(dir_file)}")
        return category_name, category_slug, metadata

    except Exception as e:
        log(f"❌ Error reading {dir_file}: {e}")
        return None, None, {}

def read_file_content(filepath):
    try:
        with open(filepath, 'r', encoding='cp437') as f:
            content = f.read()
        return content.rstrip('\x1a')
    except Exception as e:
        log(f"Error reading content of {filepath}: {e}")
        return ""

def generate_markdown(filename, content, meta, category_name, category_slug, file_stats, new_filename):
    lines = content.splitlines()
    markdown_output = []
    
    description = meta.get('description', filename)
    contributor = meta.get('contributor', 'Unknown')
    date = meta.get('date', 'Unknown')
    has_author = meta.get('has_author', False)
    
    # 1. Header
    title_line = f"# {description}"
    if has_author:
        title_line += f" by {contributor}"
    
    header = f"""{title_line}

* Original date: `{date}`
* Listed as: `{filename}`

## From [{category_name}](https://delphi.org/swag/{category_slug}/)

"""
    markdown_output.append(header)

    # 2. Content Sandwich
    state = "HEADER"
    
    # Strip initial comment start if present
    if lines and lines[0].strip().startswith('{') and not lines[0].strip().startswith('{$'):
        lines[0] = lines[0].replace('{', '', 1) 
        
    for line in lines:
        if state == "HEADER":
            if TRIGGER_REGEX.match(line):
                state = "CODE"
                markdown_output.append("\n```pascal\n")
                markdown_output.append(line)
            else:
                if '}' in line and not '{' in line: 
                     line = line.replace('}', '')
                markdown_output.append(line)

        elif state == "CODE":
            markdown_output.append(line)
            if END_REGEX.match(line):
                markdown_output.append("```\n")
                state = "FOOTER"

        elif state == "FOOTER":
            markdown_output.append(line)

    if state == "CODE":
        markdown_output.append("\n```\n")

    # 3. Footer
    size_bytes, size_fmt, sha256 = file_stats
    
    footer = f"""
---
Part of [delphi.org/swag](https://delphi.org)

_Metadata:_

* filename: [`{filename}`](https://delphi.org/swag/{category_slug.lower()}/{filename})
* category: `{category_slug.upper()}`
* description: `{description}`
"""
    if has_author:
        footer += f"* contributor: `{contributor}`\n"
        
    footer += f"""* date/time: `{date}`
* size: `{size_fmt}`
* encoding: `CP437`
* SHA256: `{sha256}`
* permalink: <https://delphi.org/swag/{category_slug.lower()}/{new_filename}>

↪️End of File↩️
"""
    markdown_output.append(footer)
    return "\n".join(markdown_output)

def process_directory(directory, output_root):
    log(f"📂 Scanning directory: {directory}")
    
    # Check for .PAS files first
    pas_files = glob.glob(os.path.join(directory, "*.PAS"))
    if not pas_files:
        # log(f"   No .PAS files found in {directory}. Skipping.")
        return

    # Try to get metadata
    cat_name, cat_slug, metadata = parse_dir_file(directory)
    
    if not cat_name:
        log(f"⚠️  Skipping folder {directory} (Could not determine category).")
        return

    # Create output folder
    # We want output/CATEGORY/file.md
    out_dir = os.path.join(output_root, cat_slug)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    processed_count = 0
    for filepath in pas_files:
        filename = os.path.basename(filepath)
        
        # Get content & stats
        content = read_file_content(filepath)
        stats = get_file_stats(filepath)
        
        # Get Meta
        file_meta = metadata.get(filename, {})
        description = file_meta.get('description', filename)
        contributor = file_meta.get('contributor', '')
        has_author = file_meta.get('has_author', False)
        
        # Name Gen
        new_name_parts = [cat_slug]
        id_part = os.path.splitext(filename)[0]
        new_name_parts.append(id_part)
        clean_desc = sanitize_filename(description)
        new_name_parts.append(clean_desc)
        if has_author and contributor:
            clean_author = sanitize_filename(contributor)
            new_name_parts.append(f"by_{clean_author}")
            
        new_filename = "-".join(new_name_parts) + ".md"
        
        # Write
        md_content = generate_markdown(filename, content, file_meta, cat_name, cat_slug, stats, new_filename)
        
        final_out_path = os.path.join(out_dir, new_filename)
        with open(final_out_path, 'w', encoding='utf-8') as f:
            f.write(md_content)
            
        processed_count += 1
    
    log(f"✅ Finished {directory}: Converted {processed_count} files.")

def main():
    if not os.path.exists(OUTPUT_BASE):
        os.makedirs(OUTPUT_BASE)

    # Walk through the directories
    for root, dirs, files in os.walk(ROOT_DIR):
        # Exclude the output directory itself to prevent loops
        if os.path.abspath(root).startswith(os.path.abspath(OUTPUT_BASE)):
            continue
            
        # Process the current directory
        process_directory(root, OUTPUT_BASE)

if __name__ == "__main__":
    main()