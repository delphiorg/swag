{
   ษออออออออออออออออออออออออออออออ X L A T ออออออออออออออออออออออออออออออป
   บ                                                                     บ
   บ         Case Translation Routines for Turbo/Borland Pascal          บ
   บ                                                                     บ
   บ                            Version 1.00                             บ
   บ                                                                     บ
   บ  Copyright (c) 1994, John O'Harrow F.I.A.P. - All Rights Reserved   บ
   บ                                                                     บ
   บ  This unit provides a library of very highly optimised routines     บ
   บ  for the translating of strings into upper/lower case.              บ
   บ                                                                     บ
   บ  The majority of the routines are coded in assembler, and are       บ
   บ  contained in the file XLAT.OBJ, which is linked into this unit.    บ
   บ                                                                     บ
   บ  The file XLAT.ASM contains the full source code for all of the     บ
   บ  assembly code routines (This file is designed for assembling with  บ
   บ  TASM, but may be assembled using MASM with minor modification).    บ
   บ                                                                     บ
   ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
}
{$S-} {Disable Stack Checking to Increase Speed and Reduce Size}

UNIT XLAT;

{================================}INTERFACE{================================}

TYPE
  XlatTable = ARRAY[Char] OF Char;

VAR
  Upper, Lower : XlatTable;

  {These case translation tables are initialised according to the }
  {country code information as specified in CONFIG.SYS (DOS 4.0+).}
  {For older DOS versions, standard case conversion is used.      }
  {These tables may also be accessed directly using, for example, }
  {ResultChar := Upper['x'].  This provides the fastest possible  }
  {replacement for the standard pascal Upcase() function.         }

{-String Case Conversion Procedures-----------------------------------------}

  PROCEDURE MakeUppercase(VAR S : String);
  PROCEDURE MakeLowercase(VAR S : String);

  {These procedures should be used in preference to the equivalent}
  {functions below where speed is critical (approx 50% faster).   }

{-String Case Conversion Functions------------------------------------------}

  FUNCTION  Uppercase(CONST S : String) : String;
  FUNCTION  Lowercase(CONST S : String) : String;

{-General Purpose String Translation Procedure - ASCII/EBCDIC etc.----------}

  PROCEDURE Translate(VAR S : String; VAR Table : XlatTable);

{=============================}IMPLEMENTATION{==============================}

{$L XLAT}

  PROCEDURE MakeUppercase(VAR S : String); EXTERNAL;
  PROCEDURE MakeLowercase(VAR S : String); EXTERNAL;

  FUNCTION  Uppercase(CONST S : String) : String; EXTERNAL;
  FUNCTION  Lowercase(CONST S : String) : String; EXTERNAL;

  PROCEDURE Translate(VAR S : String; VAR Table : XlatTable); ASSEMBLER;
  ASM
    LES   DI,S        {ES:DI => S}
    MOV   CL,ES:[DI]  {Get Length(S)}
    AND   CX,00FFh    {CX = Length(S), ZF Set if Null String}
    JZ    @@Finish    {Finished if S is a Null String}
    MOV   DX,DS       {Save DS}
    LDS   BX,Table    {DS:BX => Translation Table}
    INC   DI          {ES:DI => S[1]}
    TEST  DI,1        {Is ES:DI on a Word Boundary?}
    JZ    @@Even      {Yes - Ok}
    MOV   AL,ES:[DI]  {No  - Translate 1st Char}
    XLAT
    MOV   ES:[DI],AL
    DEC   CX
    INC   DI
  @@Even:             {ES:DI now Alligned on a Word Boundary}
    SHR   CX,1        {CX = Characters Pairs to Translate}
    JZ    @@Last      {Skip if no Character Pairs}
    PUSHF             {Save Carry Flag - Set of Odd Char Left}
  @@Loop:
    MOV   AX,ES:[DI]  {Translate Next 2 Characters}
    XLAT
    XCHG  AL,AH
    XLAT
    XCHG  AL,AH
    MOV   ES:[DI],AX
    ADD   DI,2
    DEC   CX
    JNZ   @@Loop      {Repeat for each Pair of Chars}
    POPF              {Restore Carry Flag}
  @@Last:
    JNC   @@Done      {Finished if No Odd Char to Translate}
    MOV   AL,ES:[DI]  {Translate Last Char}
    XLAT
    MOV   ES:[DI],AL
  @@Done:
    MOV   DS,DX       {Restore Saved DS}
  @@Finish:
  END; {Translate}

{=Non Interfaced Routines (Used in Unit Initialisation)=====================}

  FUNCTION DosMajorVersion : Byte;
    {-Return DOS Major Version Number}
  INLINE(
    $B4/$30/    {mov ah,$30}
    $CD/$21);   {int $21}

  PROCEDURE SetCountrySpecificUppercase;
    {-Translate 'Upper' into its country specific uppercase equivalent}
  INLINE(
    $BA/>Upper/ {mov dx,Upper}
    $B9/>256/   {mov cx,256}
    $B8/>$6521/ {mov ax,$6521}
    $CD/$21);   {int $21}

  PROCEDURE InitialiseCaseConversion;
  VAR
    C : Char;
  BEGIN
    ASM {Fast/Small Replacement for:- FOR C := #0 TO #255 DO Upper[C] := C;}
      MOV SI,Offset Upper
      XOR BX,BX
    @@Loop:
      MOV [SI+BX],BL
      INC BL
      JNZ @@Loop
    END;
    IF DosMajorVersion < 4 THEN
      FOR C := #0 TO #255 DO
        Upper[C] := System.UpCase(C) {Use Standard Case Conversion}
    ELSE
      SetCountrySpecificUppercase; {Use International Case Conversion}
    FOR C := #255 DOWNTO #0 DO
      IF C <> Upper[C] THEN {Set Lowercase conversion Table from Uppercase}
        Lower[Upper[C]] := C;
  END; {InitialiseCaseConversion}

{=Unit Initialisation=======================================================}

BEGIN
  InitialiseCaseConversion;
END.

{XLAT.ASM (Cut here and Assemble using TASM) -------------------------------}

          .MODEL TPASCAL

          LOCALS @@

          EXTRN  Upper ;ARRAY[Char] OF Char (Uppercase Translation Table)
          EXTRN  Lower ;ARRAY[Char] OF Char (Lowercase Translation Table)

          .CODE

          .8086

          PUBLIC MakeUppercase, Uppercase
          PUBLIC MakeLowercase, Lowercase

;----------------------------------------------------------------------------
;PROCEDURE MakeLowercase(VAR S : String);
;----------------------------------------------------------------------------
MakeLowercase PROC FAR
          MOV   AX,Offset Lower  ;Select Case Table
          JMP   SHORT CaseProc
MakeLowercase ENDP

;----------------------------------------------------------------------------
;PROCEDURE MakeUppercase(VAR S : String);
;----------------------------------------------------------------------------
MakeUppercase PROC FAR
          MOV   AX,Offset Upper  ;Select Case Table and Drop into CaseProc
MakeUppercase ENDP

;----------------------------------------------------------------------------
;Translate String using conversion table at Offset AX in Data Segment
;----------------------------------------------------------------------------
CaseProc  PROC  FAR
          MOV   BX,SP
          LES   DI,SS:[BX+4]     ;ES:DI => String
          MOV   CL,ES:[DI]       ;CL = Length(S)
          AND   CX,00FFh         ;CX = Length(S)
          JZ    @@Done           ;Done if Null String
          MOV   BX,AX            ;DS:BX => Translation Table
          INC   DI               ;ES:DI => S[1]
          JMP   SHORT Translate  ;Exit Via Translate Procedure
@@Done:   RET   4
CaseProc  ENDP

;----------------------------------------------------------------------------
;FUNCTION LowerCase(S : String) : String;
;----------------------------------------------------------------------------
LowerCase PROC  FAR
          MOV   AX,Offset Lower  ;Select Case Table
          JMP   SHORT CaseFunc
LowerCase ENDP

;----------------------------------------------------------------------------
;FUNCTION UpperCase(S : String) : String;
;----------------------------------------------------------------------------
UpperCase PROC  FAR
          MOV   AX,Offset Upper  ;Select Case Table and Drop into CaseFunc
UpperCase ENDP

;----------------------------------------------------------------------------
;Translate String using conversion table at Offset AX in Data Segment
;----------------------------------------------------------------------------
CaseFunc  PROC  FAR
          MOV   DX,DS            ;Save DS
          MOV   BX,SP
          LDS   SI,SS:[BX+4]     ;DS:SI = String Address
          LES   DI,SS:[BX+8]     ;ES:DI = Result Address
          MOV   BX,AX            ;BX = Offset of Translation Table
          CLD
          LODSB                  ;Get String Length Byte
          STOSB                  ;Store Result Length
          AND   AX,00FFh         ;AX = Length(S)
          JZ    @@Done           ;Exit if Null String
          MOV   CX,AX            ;CX = Length(S)
          PUSH  DI               ;Save Offset of Result[1]
          TEST  DI,1             ;Destination Address Even?
          JZ    @@CWord          ;Yes - Skip Odd Byte Move
          MOVSB                  ;No - Move Odd Byte
          DEC   CX               ;Decrement Count
@@CWord:  SHR   CX,1             ;CX = Words to Copy, Set CF if Odd Byte Left
          REP   MOVSW            ;Copy CX Words
          JNC   @@Copied         ;Skip if No Odd Byte to Copy
          MOVSB                  ;Copy the Odd Byte
@@Copied: POP   DI               ;ES:DI => Result[1]
          MOV   DS,DX            ;Restore DS, DS:BX => Translation Table
          MOV   CX,AX            ;CX = String Length
          JMP   SHORT Translate  ;Exit Via Translate Procedure
@@Done:   RET   4
CaseFunc  ENDP

;----------------------------------------------------------------------------
;Translate CX Chars at ES:DI using XLAT Table as DS:BX (Common Exit Proc)
;----------------------------------------------------------------------------
Translate PROC  FAR
          TEST  DI,1             ;Is ES:DI on a Word Boundary?
          JZ    @@Even           ;Yes - Ok
          MOV   AL,ES:[DI]       ;No - Translate 1st Char
          XLAT
          MOV   ES:[DI],AL
          DEC   CX
          INC   DI               ;ES:DI now on a Word Boundary
@@Even:   SHR   CX,1             ;CX = Characters Pairs to Translate
          JZ    @@Last           ;No Character Pairs
          PUSHF                  ;Save Flags - CF Set of Odd Char Left
@@Loop:   MOV   AX,ES:[DI]       ;Translate Next 2 Characters
          XLAT
          XCHG  AL,AH
          XLAT
          XCHG  AL,AH
          MOV   ES:[DI],AX
          ADD   DI,2
          DEC   CX
          JNZ   @@Loop           ;Repeat for each Pair of Chars
          POPF                   ;Restore CF
@@Last:   JNC   @@Done           ;Finished if No Odd Char to Translate
          MOV   AL,ES:[DI]       ;Translate Last Char
          XLAT
          MOV   ES:[DI],AL
@@Done:   RET   4
Translate ENDP


CODE      ENDS
          END

{ --------------------------------------------------------------------- }
{------------------------- snip, snip ----------------------------}

ENCODED XLAT.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.