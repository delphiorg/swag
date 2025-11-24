
{ SEE BELOW FOR ENTIRE PROJECT USING THIS INTERFACE }
(* DLL can be found at: http://quest.jpl.nasa.gov/Info-ZIP/             *)

UNIT WizUnZip;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 05/17/1996 *)
(* ENVIRONMENT: Borland Pascal V7.0+/Delphi V1.02+                      *)
(*                                                                      *)
(* Unit that defines the interface into the wizunzip dll.               *)
(* NOTE: File names are case-sensitive.                                 *)
(*                                                                      *)
(* To use:                                                              *)
(*  VAR _DCL  : PDCL;                                                   *)
(*      Fils  : PACHAR; {pointer to array or pchars}                    *)
(*      ZipFn : ARRAY[0..144] OF CHAR;                                  *)
(*      FilNm : ARRAY[0..xx] OF CHAR;                                   *)
(*    { TT    : THANDLE; }                                              *)
(*       ...                                                            *)
(*  StrCopy(FilNm,'case sensitive file name (could incl wildcards)');   *)
(*  GetMem(Fils,SizeOf(PCHAR)); {only allocating for single file}       *)
(*   {or}                                                               *)
(*   {should use this method in Delphi - seems to prevent GPFs}         *)
(*   { TT := GlobalAlloc(GHnd,SizeOf(PCHAR)); }                         *)
(*   { Fils := GlobalLock(TT); }                                        *)
(*  Fils^[0] := @FilNm;                                                 *)
(*  StrCopy(ZipFn,'C:\UNZIP52.ZIP');                                    *)
(*  WZInitADCL(_DCL,HInstance,MWnd,LWnd); {create/initialize struct}    *)
(*  WITH _DCL^ DO                                                       *)
(*   BEGIN {setup rest of parameters for unzip}                         *)
(*    WITH lpUMB^ DO                                                    *)
(*     StrCopy(szUnzipToDirName,'some dir'); {only dir that is used}    *)
(*    {set flags wanted (all set to false from init)}                   *)
(*    OverWrite := TRUE; {example}                                      *)
(*    ArgC := 1; {set equal to number of files submitting}              *)
(*    lpszZipFN := @ZipFn;                                              *)
(*    FNV := Fils;                                                      *)
(*   END; {with}                                                        *)
(*  I := WZ_UnZip(_DCL); {run unzip proc}                               *)
(*  WZDestroyDCL(_DCL); {release control block}                         *)
(*  FreeMem(Fils,SizeOf(PCHAR)); {free file list}                       *)
(*   {or}                                                               *)
(*   { GlobalUnlock(TT); }                                              *)
(*   { GlobalFree(TT); }                                                *)
(*  IF I <> wze_OK THEN {problem with unzip};                           *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 07/30/1996 - Per suggestions from Brad Clarke               *)
(*                       (bclarke@cyberus.ca), added listing constants  *)
(*                       and changed nzFlag to integer.                 *)
(*                                                                      *)

INTERFACE

 USES WinTypes, WinProcs, CommDlg;

 CONST LibName = 'wizunz16';
       wzl_WizUnzip_Max_Path  = 127; {128}
       wzl_Options_Buffer_Len = 255; {256}
       wzl_None               = 0;   {no listing}
       wzl_Short              = 1;   {short listing}
       wzl_Long               = 2;   {long listing}
       wze_OK                 = 0;
       wze_Warning            = 1;
       wze_Err                = 2;
       wze_BadErr             = 3;
       wze_Mem                = 4;
       wze_Mem2               = 5;
       wze_Mem3               = 6;
       wze_Mem4               = 7;
       wze_Mem5               = 8;
       wze_NoZip              = 9;
       wze_Param              = 10;
       wze_Find               = 11;
       wze_Disk               = 50;
       wze_EOF                = 51;

 TYPE PUMB = ^TUMB;
      TUMB = RECORD
              {fully qualified archive name (OEM chars)}
              szFileName          : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {directory with archive (ANSI chars)}
              szDirName           : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {extraction directory "unzip to" (ANSI chars)}
              szUnzipToDirName    : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {temp extraction dir "unzip to" (ANSI chars)}
              szUnzipToDirNameTmp : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {extraction directory "unzip from" (ANSI chars)}
              szUnzipFromDirName  : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {text for totals of zip archive}
              szTotalsLine        : ARRAY[0..79] OF CHAR;
              {scratch buffer}
              szBuffer            : ARRAY[0..wzl_Options_Buffer_Len] OF CHAR;
              {wave file name for sound}
              szSoundName         : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {password for encrypted files}
              szPassword          : ARRAY[0..80] OF CHAR;
              {pointer to szpassword}
              lpPassword          : PCHAR;
              {archive open file name struct (commdlg)}
              ofn                 : TOPENFILENAME;
              {wave file open file name struct (commdlg)}
              wofn                : TOPENFILENAME;
              {???}
              msg                 : TMSG;
              {archive open file struct}
              _of                 : TOFSTRUCT;
              {wave file open file struct}
              wof                 : TOFSTRUCT;
             END;
      TDLLPRNT = FUNCTION{(VAR F : FILE; Len : WORD; S : PCHAR)} : WORD; {CEDCL;}
      TDLLSND  = PROCEDURE; {CEDCL;}
      PACHAR   = ^TACHAR;
      TACHAR   = ARRAY[0..8187] OF PCHAR;
      PDCL = ^TDCL;
      TDCL = RECORD
              PrintFunc         : TDLLPRNT; {ptr to appl print routine}
              SoundProc         : TDLLSND;  {prt to appl sound routine}
              StdOut            : POINTER;  {stdout/ptr to C FILE struct}
              lpUMB             : PUMB;
              hWndList          : HWND;     {list box to disp zip contents in}
              hWndMain          : HWND;     {appl main window}
              hInst             : THANDLE;  {appl instance}
              ExtractOnlyNewer  : BOOL;     {true = extract only newer}
              OverWrite         : BOOL;     {true = always overwrite}
              SpaceToUnderscore : BOOL;     {true = convert space to underscore}
              PromptToOverwrite : BOOL;     {true = prompt on overwrite}
              ncFlag            : BOOL;     {true = write to stdout}
              ntFlag            : BOOL;     {true = test zip file}
              nvFlag            : INTEGER;  {0=no list, 1=short list, 2=long list}
              nuFlag            : BOOL;     {true = update extraction}
              nzFlag            : BOOL;     {true = display zip file comment}
              ndFlag            : BOOL;     {true = extract w/stored directories}
              noFlag            : BOOL;     {true = extract all files}
              naFlag            : BOOL;     {true = ascii-ebcdic/eoln translate}
              ArgC              : INTEGER;  {count of files to extract}
              lpszZipFN         : PCHAR;    {zip file name}
              FNV               : PACHAR;   {list of files to extract}
             END;

(************************************************************************)

 PROCEDURE WZInitADCL(VAR _DCL : PDCL; PInst : THANDLE; MainW, ListW : HWND);
     (* procedure used to alloc and init a dcl struct with zeros *)

 PROCEDURE WZDestroyDCL(VAR _DCL : PDCL);
     (* procedure used to free a dcl allocated by prior call to initadcl *)

 FUNCTION  WZDummyPrint{(VAR FH : INTEGER; Len : WORD; S : PCHAR)} : WORD; {CEDCL;}
     (* procedure that can be used as a dummy print routine for dll *)
     (* - C call back, parameters ignored in dummy                  *)

 PROCEDURE WZDummySound; {CEDCL;}
     (* procedure that can be used as a dummy sound routine for the dll *)

 FUNCTION  WZRetErrorString(ErrC : INTEGER) : STRING;
     (* function used to return error as a string *)

 FUNCTION  WZ_UnZip(_DCL : PDCL) : INTEGER;
     (* wrapper function to handle switching to choosen unzip to directory *)

 (* dll functions ----------------------------------------------------- *)
 FUNCTION  DLLProcessZipFiles(_DCL : PDCL) : INTEGER;
     (* function to run the unzip routine *)

 PROCEDURE GetDLLVersion(VAR Ver : LONGINT);
     (* procedure to return the current dll version of wizunzip *)
     (*   hiword(ver) = major . loword(ver) = minor             *)

(************************************************************************)

IMPLEMENTATION

{$IFDEF VER80}
 USES SysUtils;
{$ELSE}
 USES Strings;
{$ENDIF}

(************************************************************************)

 PROCEDURE WZInitADCL(VAR _DCL : PDCL; PInst : THANDLE; MainW, ListW : HWND);

  BEGIN (*wzinitadcl*)
   GetMem(_DCL,SizeOf(TDCL));
   FillChar(_DCL^,SizeOf(TDCL),0);
   _DCL^.PrintFunc := WZDummyPrint;
   _DCL^.SoundProc := WZDummySound;
   GetMem(_DCL^.lpUMB,SizeOf(TUMB));
   FillChar(_DCL^.lpUMB^,SizeOf(TUMB),0);
   _DCL^.lpUMB^.lpPassword := @_DCL^.lpUMB^.szPassword;
   _DCL^.hWndMain := MainW;
   _DCL^.hWndList := ListW;
   _DCL^.hInst    := PInst;
  END; (*wzinitadcl*)

(************************************************************************)

 PROCEDURE WZDestroyDCL(VAR _DCL : PDCL);

  BEGIN (*wzdestroydcl*)
   IF _DCL = NIL THEN Exit;
   FreeMem(_DCL^.lpUMB,SizeOf(TUMB));
   FreeMem(_DCL,SizeOf(TDCL));
   _DCL := NIL;
  END; (*wzdestroydcl*)

(************************************************************************)

 FUNCTION WZDummyPrint{(VAR F : FILE; Len : WORD; S : PCHAR)} : WORD;
    VAR Len : WORD;
  BEGIN (*wzdummyprint*)
   ASM
    MOV AX,[BP+8] {pass back len as return}
   END;
  END; (*wzdummyprint*)

(************************************************************************)

 PROCEDURE WZDummySound;
    VAR I : INTEGER;
  BEGIN (*wzdummysound*)
   {do nothing}
   I := 1; {so that optimizations do not remove proc}
  END; (*wzdummysound*)

(************************************************************************)

 FUNCTION WZRetErrorString(ErrC : INTEGER) : STRING;

    VAR T : STRING[80];
        N : STRING[5];

  BEGIN (*wzreterrorstring*)
   T := '';
   CASE ErrC OF
    wze_OK      : ;
    wze_Warning : T := 'Warning, zip may have error!';
    wze_Err     : T := 'Error in zipfile!';
    wze_BadErr  : T := 'Critical error in zipfile!';
    wze_Mem     : T := 'Insufficient memory!';
    wze_Mem2    : T := 'Insufficient memory (2)!';
    wze_Mem3    : T := 'Insufficient memory (3)!';
    wze_Mem4    : T := 'Insufficient memory (4)!';
    wze_Mem5    : T := 'Insufficient memory (5)!';
    wze_NoZip   : T := 'Not a zip file/zip file not found!';
    wze_Param   : T := 'Invalid parameters specified!';
    wze_Find    : T := 'No files found!';
    wze_Disk    : T := 'Disk full error!';
    wze_EOF     : T := 'Unexpected EOF encountered!';
    ELSE BEGIN {other error}
          Str(ErrC,N);
          T := 'Other error during zip operation - Error code = '+N;
         END; {else}
   END; {case}
   WZRetErrorString := T;
  END; (*wzreterrorstring*)

(************************************************************************)

 FUNCTION WZ_UnZip(_DCL : PDCL) : INTEGER;
    VAR S1, S2 : STRING[144];
        W      : WORD;
  BEGIN (*wz_unzip*)
   W := SetErrorMode($8001); S1 := '';
   GetDir(0,S1); S2 := StrPas(_DCL^.lpUMB^.szUnzipToDirName);
   IF S2[Length(S2)] = '\'
    THEN BEGIN {remove '\'?}
          IF (Length(S2) > 1) AND (S2[Length(S2)-1] <> ':')
           THEN Delete(S2,Length(S2),1); {not 'c:\'}
          IF Length(S2) = 1 THEN S2 := '';
         END; {then}
   IF S2 <> ''
    THEN {$I-} ChDir(S2) {$I+}
   ELSE S1 := '';
   IF IOResult <> 0
    THEN BEGIN {error in ch dir}
          MessageBeep(mb_OK);
          MessageBox(_DCL^.hWndMain,'Could not set "unzip-to" directory!',NIL,
                     mb_OK OR mb_IconStop);
          S1 := '';
         END; {then}
   SetErrorMode(W);
   WZ_UnZip := DLLProcessZipFiles(_DCL);
   IF S1 <> '' THEN ChDir(S1);
  END; (*wz_unzip*)

(************************************************************************)

 FUNCTION DLLProcessZipFiles(_DCL : PDCL) : INTEGER;
  EXTERNAL LibName INDEX 1;

 PROCEDURE GetDLLVersion(VAR Ver : LONGINT);
  EXTERNAL LibName INDEX 3;

(************************************************************************)

END. (*of unit*)

{ {------------------------- snip, snip ----------------------------}

ENCODED TESTDLL.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
