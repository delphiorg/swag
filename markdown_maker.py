import os
import re
import glob
import hashlib
import sys

# Configuration
SOURCE_DIR = "./"  # Current directory
OUTPUT_DIR = "./output" # Where to put the MD files

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
# Primary: 0001.PAS      05-28-93  14:09  "CLKTSR.PAS" by SWAG SUPPORT TEAM
REGEX_WITH_AUTHOR = re.compile(
    r'^(?P<filename>[\w\d]+\.PAS)\s+'
    r'(?P<date>[\d-]+)\s+'
    r'(?P<time>[\d:]+)\s+'
    r'(?P<description>".*?")\s+by\s+'
    r'(?P<contributor>.*)$', 
    re.IGNORECASE
)

# Fallback: 0001.PAS      05-28-93  14:09  Some Description Here
REGEX_NO_AUTHOR = re.compile(
    r'^(?P<filename>[\w\d]+\.PAS)\s+'
    r'(?P<date>[\d-]+)\s+'
    r'(?P<time>[\d:]+)\s+'
    r'(?P<description>.*)$', 
    re.IGNORECASE
)

def sanitize_filename(text):
    """
    Cleans up a string to be safe for filenames.
    Replaces spaces with underscores, removes quotes, etc.
    """
    if not text:
        return ""
    # Remove quotes
    text = text.replace('"', '').replace("'", "")
    # Replace common separators with dash or underscore
    text = text.replace(' ', '_').replace('/', '-').replace('\\', '-')
    # Keep only alphanumeric, dashes, underscores, dots
    text = re.sub(r'[^a-zA-Z0-9_.-]', '', text)
    return text

def get_file_stats(filepath):
    """
    Calculates size and SHA256 hash of the file.
    Returns (size_in_bytes, formatted_size_str, sha256_hex)
    """
    if not os.path.exists(filepath):
        return 0, "0 bytes", ""
        
    size = os.path.getsize(filepath)
    sha256_hash = hashlib.sha256()
    
    with open(filepath, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
            
    return size, f"{size:,} bytes", sha256_hash.hexdigest().upper()

def get_category_info(directory):
    """
    Finds the *_dir.txt file and parses it.
    Returns (category_name, category_slug, metadata_dict)
    """
    dir_files = glob.glob(os.path.join(directory, "*dir.txt"))
    # Fallback if no dir file found
    if not dir_files:
        return "Unknown Category", "unknown", {}

    dir_file = dir_files[0]
    metadata = {}
    category_name = "Unknown Category"

    with open(dir_file, 'r', encoding='cp437', errors='replace') as f:
        lines = f.readlines()
        
    # Extract Category Name
    if lines:
        first_line = lines[0].strip()
        if "SWAG Title:" in first_line:
            category_name = first_line.split("SWAG Title:")[1].strip()
        else:
            category_name = first_line

    # Generate slug (e.g. "TSR UTILITIES" -> "tsr")
    # Taking the first word is usually safe for SWAG structure
    category_slug = category_name.split()[0].lower()

    # Parse the file list
    for line in lines:
        line = line.strip()
        if not line: continue
        
        # Try finding Author first
        match = REGEX_WITH_AUTHOR.match(line)
        if match:
            fname = match.group('filename')
            metadata[fname] = {
                'date': f"{match.group('date')}  {match.group('time')}",
                'description': match.group('description'),
                'contributor': match.group('contributor'),
                'has_author': True
            }
        else:
            # Try fallback (Description only)
            match = REGEX_NO_AUTHOR.match(line)
            if match:
                fname = match.group('filename')
                # Ignore the header line itself if it matches the pattern accidentally
                if "SWAG Title" in line: continue
                
                metadata[fname] = {
                    'date': f"{match.group('date')}  {match.group('time')}",
                    'description': match.group('description'),
                    'contributor': None,
                    'has_author': False
                }
            
    return category_name, category_slug, metadata

def read_file_content(filepath):
    """
    Tries to read the file using CP437. 
    Strips the CTRL-Z character.
    """
    try:
        with open(filepath, 'r', encoding='cp437') as f:
            content = f.read()
        return content.rstrip('\x1a')
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return ""

def generate_markdown(filename, content, meta, category_name, category_slug, file_stats):
    lines = content.splitlines()
    markdown_output = []
    
    # Metadata extraction
    description = meta.get('description', filename)
    # Strip quotes for title display if they exist
    title_display = description.strip('"')
    
    contributor = meta.get('contributor', 'Unknown')
    date = meta.get('date', 'Unknown')
    has_author = meta.get('has_author', False)
    
    # --- 1. HEADER GENERATION ---
    if has_author:
        header = f"# {description} by {contributor}\n"
    else:
        header = f"# {description}\n"
        
    header += f"""
* Original date: `{date}`
* Listed as: `{filename}`

## From [{category_name}](https://delphi.org/swag/{category_slug}/)

"""
    markdown_output.append(header)

    # --- 2. CONTENT (THE SANDWICH) ---
    state = "HEADER"
    
    # Check for initial large comment block
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

    # --- 3. METADATA FOOTER ---
    size_bytes, size_fmt, sha256 = file_stats
    
    footer = f"""
---
Part of [delphi.org/swag](https://delphi.org)

_Metadata:_

* filename: `{filename}`
* category: `{category_slug.upper()}`
* description: `{description}`
"""
    if has_author:
        footer += f"* contributor: `{contributor}`\n"
        
    footer += f"""* date/time: `{date}`
* size: `{size_fmt}`
* encoding: `CP437`
* SHA256: `{sha256}`

↪️End of File↩️
"""
    markdown_output.append(footer)

    return "\n".join(markdown_output)

def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    # 1. Get info from dir.txt
    category_name, category_slug, metadata = get_category_info(SOURCE_DIR)
    print(f"Processing Category: {category_name} ({category_slug})")

    # 2. Process files
    pas_files = glob.glob(os.path.join(SOURCE_DIR, "*.PAS"))
    
    for filepath in pas_files:
        filename = os.path.basename(filepath)
        
        # Get content and stats
        content = read_file_content(filepath)
        stats = get_file_stats(filepath) # (bytes, "x bytes", hash)
        
        # Get metadata
        file_meta = metadata.get(filename, {})
        description = file_meta.get('description', filename)
        contributor = file_meta.get('contributor', '')
        has_author = file_meta.get('has_author', False)
        
        # --- NEW FILENAME GENERATION ---
        # Format: category-id-subject_by_author.md
        # 1. Category Slug
        new_name_parts = [category_slug]
        
        # 2. Original ID (0001)
        # remove extension from 0001.PAS
        id_part = os.path.splitext(filename)[0]
        new_name_parts.append(id_part)
        
        # 3. Subject/Description
        clean_desc = sanitize_filename(description)
        new_name_parts.append(clean_desc)
        
        # 4. Author (if exists)
        if has_author and contributor:
            clean_author = sanitize_filename(contributor)
            new_name_parts.append(f"by_{clean_author}")
            
        new_filename = "-".join(new_name_parts) + ".md"
        
        print(f"Converting {filename} -> {new_filename}")
        
        # Generate Markdown
        md_content = generate_markdown(
            filename, 
            content, 
            file_meta, 
            category_name, 
            category_slug,
            stats
        )
        
        # Save
        with open(os.path.join(OUTPUT_DIR, new_filename), 'w', encoding='utf-8') as f:
            f.write(md_content)

if __name__ == "__main__":
    main()