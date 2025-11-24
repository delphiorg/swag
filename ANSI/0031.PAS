
{
JW>I would be interested in such code - and a BP7 version is hardly needed,
JW>since I am happily working with TP4.0.

  Well the problem is mainly keeping my code confidential, and I
  don't have a TP4 compiler, I no longer have a TP5.x compiler,
  either.

  Fortunately, the "top secret" stuff is all in .asm, and I can send
  you the .obj file without any complications. The .pas "wrapper"
  for the .TPU is very simple.

  A couple of caveats:

  - there are a couple of minor bugs in the implementation, it
    works fine, but occasionally the output will get *slightly*
    mangled.

  - This code writes *directly* to the video buffer, bypassing all
    CRT or SYSTEM unit calls. This makes it generally incompatible
    with windowing routines. (This is one reason I want badly to
    upgrade it to BP7 - I pretty much have to support TurboVision to
    be of any future use) The plus side: all CRT variables are
    updated, and so calls to HANSI can be intermixed with calls to
    normal CRT unit functions.

  - *Only* ANSI codes relating to the CRT are translated, keyboard
    redefinition, etc, is ignored. (ie, eaten by the emulator)

  - ALWAYS USE THE CALLS THE WAY I SET THEM UP! The functions
    internal to the .obj file are NEAR calls, and will not work
    correctly when called externally to the .TPU.

  - Use care to make sure you do not pass strings longer than 256
    characters to the HANSI unit - longer strings will be truncated,
    and do strange things to your output.

{------------------------ snip, snip ----------------------------}

Unit HANSI;

{$F+,A+}
INTERFACE

Uses
   CRT;

TYPE
   CURS_COORD = RECORD
                   x, y : byte;
                END;

   BUF_STRUCT = array[0..127] of byte;

VAR
   temp : byte;
   loop     : word;
   cpr_buf  : array[0..8] of char;  { 8 dup (0), '[' }

   input_buf        : string;      { input buffer for ansi proc }
   str_ofs, str_seg : word; { seg and offset parts to point to input_buf }
   attr_parm        : integer;

   cur          : CURS_COORD;
   ansi_params  : BUF_STRUCT;
   saved_coords : word;

   brkkeybuf,      { db  3  control C }
   fnkeybuf,       { db  0  holds second byte of fn key codes }
   driver_init,
   max_x, max_y, ega_rows,
   wrap_flag, attrib,
   string_term, recurse, cur_page                  : byte;

   crt_cols, crt_len, columns, lines,
   buf_size, cur_parm_ptr, video_mode, escvector   : word;

   crt_disp_mode : byte ABSOLUTE $0040:$0049;
   crt_page      : byte ABSOLUTE $0040:$0062;
   crt_curs_mode : word ABSOLUTE $0040:$0060;
   crt_curs_pos  : array[0..8] of word ABSOLUTE $0040:$0050;
   crt_EGA_rows  : byte ABSOLUTE $0040:$0084;

Procedure Bip;

Procedure A_Write(buf:string);

Procedure A_WriteLn(buf:string);

IMPLEMENTATION

Procedure Bip;
   BEGIN
      Sound(1100);
      Delay(5);
      NoSound;
   END;

Procedure Init_Ansi; external; { defined for NEAR calls - do not
                                 call directly! }

Procedure AnsiWrite; external; { defined for NEAR calls - do not
                                 call directly! }
{$L hansi.obj}

Procedure ANSI_init;
   BEGIN
      if driver_init = 0 then
         Init_Ansi;
   END;

Procedure A_Write(buf:string);
   BEGIN
      if buf<> '' then
      BEGIN
         input_buf := buf;
         ega_rows := crt_EGA_rows;
         AnsiWrite;
      END;
   END;

Procedure A_WriteLn(buf:string);
   BEGIN
      input_buf := buf+#13+#10;
      ega_rows := crt_EGA_rows;
      AnsiWrite;
   END;

Function CurrentMode:byte;
   BEGIN
      CurrentMode := crt_disp_mode;
   END;

Function MaxRows:byte;
   BEGIN
      MaxRows := crt_EGA_rows;
   END;

BEGIN   { init all EXTRN's req'd by the asm module }
   Lines   := Hi(WindMax)+1;
   Columns := Lo(WindMax)+1;
   driver_init := 0; buf_size := 127;
   escvector := 0;   wrap_flag := 1;
   video_mode := LastMode;
   string_term := 0; cur_page := crt_page;
   crt_cols := columns;
   recurse := 0; brkkeybuf := 3; fnkeybuf := 0;
   ega_rows  := crt_EGA_rows;
   str_ofs := OFS(input_buf);
   str_seg := SEG(input_buf);
   Writeln;
   ANSI_Init;
   Writeln;
END.

{------------------------- snip, snip ----------------------------}

ENCODED HANSI.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.