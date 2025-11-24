{
The Following code is a little cheeze example of getting around the ye ol'
retrace and flicker problem. To do this all writes are made to a vitual
screen and then the whole thing is moved at once. This code has quite a
nice effect even though it almost all in pure pascal.
Enjoy: Swag ready. [g]

- IMPORTANT : Use XX3402 to get the needed PCX files
              ( Last part of the program ).

  1) Cut from line 192 to the end and save as SPACEPCX.XX
  2) Run : XX3402 D SPACEPCX.XX ( It generates SPACEPCX.ZIP )
  3) Run : PKUNZIP SPACEPCX.ZIP ( It generates two PCX files )
  4) Compile and Run this program.
  5) XX3402.EXE is found in the SWAG Directory.
}

{$q-,r-,d-,b-}

PROGRAM SPACE_Sprites;
{ - Slow game-sprites-example, by Bas van Gaalen, Holland, PD
    12/20/94 }
{ - Modified and completely rewritten by Mr. Krinkle : Cameron Clark }
{ - Basicly is the same program from Cameron; I have only add some
    sprites from SPRITELIB to make it more spectacular. Hugo Rozas :
    <hrm@mail.cosapidata.com.pe>
    07/12/97 }
USES crt;
CONST  maxSpr=144;                         {Reduce, if program runs slugish}
       ScrSze=64000;
TYPE a_scrn= ARRAY [1..ScrSze] OF byte;
     sprite= RECORD
             xCOR,  yCOR   : word;
             width, height : byte;
             vVEL,  hVEL   : word;
             it: ARRAY[1..188]  OF byte;   {bitmap}
     END;
VAR sprites : ARRAY[1..MaxSpr] OF sprite;
    point1 : Pointer;
    point2 : ^a_scrn; {Used for screen math}
    i,j,k  : word;
    c      : Char;
    a : byte;
    Pic:Array [0..35999] Of Byte;
    Pcx:File;
    Read_Result:Integer;


{
 This nice load pcx procedure is
 from : Alan Bang Andersen
}
Procedure Load_Pcx(Name:String);
begin
   Asm
     Mov  AL, 0
     Mov  DX, 03C8h
     Out  DX, AL
     Inc  DX
     Mov  CX, 1023
@l1: Out  DX, AL
     Loop @l1
  End;
  Assign(PCX, name);
  Reset(PCX, 1);
  BlockRead(PCX, Pic, SizeOf(Pic), Read_Result);
  Close(PCX);
  Asm
     Cld
     Mov  AX, 0A000h
     Mov  ES, AX
     Lea  BX, Pic
     Add  BX, 128
     Xor  DI, DI
     Xor  DX, DX
     Xor  AX, AX
     Xor  CX, CX
@l2: Mov  AL, [BX]
     Inc  BX
     Cmp  AL, 0C0h
     Ja   @r1
     Stosb
     Inc  DX
     Jmp  @r3
@r1: Sub  AL, 0C0h
     Mov  CL, AL
     Add  DX, AX
     Mov  AL, [BX]
     Inc  BX
 Rep Stosb
@r3: Cmp  DX, 64000
     Jnz  @l2
     Inc  BX
     Mov  DX, 03C8h
     Mov  AL, 00h
     Out  DX, AL
     Inc  DX
     Mov  CX, 255
@r4: Mov  AL, [BX]
     Shr  AL, 2
     Out  DX, AL
     Mov  AL, [BX+1]
     Shr  AL, 2
     Out  DX, AL
     Mov  AL, [BX+2]
     Shr  AL, 2
     Out  DX, AL
     Add  BX, 3
     Loop @r4
  End;
End;

PROCEDURE SpriteData( nSprite : Word );
VAR
 i,d,x,y,Px,Py : Word;
BEGIN
   Px := 1 + ( ( ( nSprite - 1 )  MOD 18 ) * 17);
   Py := 89 + ( ( ( nSprite - 1 )  DIV 18 ) * 11 );
   i := 1;
   FOR x :=1 TO 17 DO
     FOR y := 1 TO 11 DO
       BEGIN
         d := (((Py+y) + (y DIV 18)) * 320 ) + ( Px+x );
         sprites[ nSprite ].it[I] :=  Point2^[ d ];
         Inc( i );
       END;
END;

PROCEDURE setpal(col,r,g,b : byte); assembler; ASM
  mov dx,03c8h; mov al,col; out dx,al; Inc dx; mov al,r
  out dx,al; mov al,g; out dx,al; mov al,b; out dx,al; END;

PROCEDURE putsprite( VAR spriter : sprite );
VAR i,x,y,d : word;
BEGIN {Update coordinates according to H&V velocity and virtual draw}
  WITH Spriter DO BEGIN
   IF  (xCOR + hVEL > 320 - width)  OR (xCOR + hVEL < 1) THEN
       hVEL:=hVEL * -1;
   IF  (yCOR + vVEL > 200 - height) OR (yCOR + vVEL < 1) THEN
       vVEL:=vVEL * -1;
   xCOR:=xCOR + hVEL;  yCOR:=yCOR + vVEL;
   i := 1;
   FOR x :=1 TO 17 DO
     FOR y := 1 TO 11 DO
       BEGIN
         IF ( It[ i ] <> 0 ) THEN BEGIN
            Point2^[( (((yCor+y) + (y DIV 18)) * 320 ) + ( xCor+x ) ) ] := It[ i ];
         END;
         Inc( i );
       END;
  END;
END;

BEGIN {*Skeleton*}
  ASM mov ax,13h; Int 10h; END;
 { load and save background }
  load_pcx( 'SPACESPR.PCX' );
  GetMem(Point1, ScrSze);
  GetMem(point2, ScrSze);
  Move(mem[$a000:0000], Point2^, ScrSze);
  Randomize;  { create random sprite }
  FOR J:=1 TO MaxSpr DO BEGIN
      sprites[j].xCor := random(300)+1;  {Screen Pos}
      sprites[j].yCor := random(170)+1;
      sprites[j].width := 17;  {Fixed Dimensions}
      sprites[j].height := 11;
      REPEAT
      sprites[j].hVEL := 6-random(16)+1;   {horiz. sprite displacement}
      UNTIL sprites[j].hVEL <> 0;
      REPEAT
      sprites[j].vVEL := 6-random(13)+1;   {Vert.  sprite displacement}
      UNTIL sprites[j].vVEL <> 0;
      SpriteData( J );
  END;
  load_pcx( 'SPACEBCK.PCX' );
  Move(mem[$a000:0000], Point1^, ScrSze);
  REPEAT
    Move(Point1^, Point2^, ScrSze);         {copy Background for writing on}
    FOR J :=1 TO MaxSpr DO
      putsprite( sprites[J] );             {virtual write to Point2}
    Move(point2^, mem[$a000:0000], ScrSze); {write Point2}
  UNTIL KeyPressed;                         {NO retrace needed}
  ASM mov ax,03h; Int 10h; END;
  FreeMem(Point1, ScrSze);
  FreeMem(point2, ScrSze);
END.

{
 -----------------  CUT HERE AND SAVE AS SPACEPCX.XX  ----------------------

ENCODED SPACEPCX.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.