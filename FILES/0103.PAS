{$M 16000,0,0}
Program FP;
Uses
  Crt, Dos,UTILS,ALLMIX,process;  { support files are contained in the XX3402 Code below }
label 1,2;

Const
        BufSize                =        512;
        Version                =        '1.3';
        MaxError    =        7;

Const
  S = '           ';
  archive = $20;

const
    MajorVer = '1';                     { Current major version number }
    MinorVer = '95';                    { Current minor version number }
    Year     = 1991;                    { Release year }

{$IFDEF MsDos}
    fsDirectory = 64;                   { Set directory length }
    faReadOnly = ReadOnly;              { Set directory flags }
    faHidden = Hidden;
    faSysFile = SysFile;
    faVolumeID = VolumeID;
    faDirectory = Directory;
    faArchive = Archive;
    faAnyFile = AnyFile;
{$ENDIF}

{$IFDEF MsDos}
type
        TRegisters = Registers;                                { Used for DOS calls }
    TSearchRec = SearchRec;             { Used for search record }
{$ENDIF}

Type
        EDMode                        =        (EnCrypt,EnCryptPass,DeCrypt);
        String79                =        String[79];
        FilePaths                =        Array [1..2] Of String79;
        Errors                        =        1..(MaxError - 1);


Var
  List         : Array[1..200] of String[15];
  AttrList     : Array[1..200] of String[15];
  filattr      : ARRAY[1..200] OF CHAR;
  COUNT,Pos, First   : Integer;
  C            : Char;
  Cont         : Integer;
  DirInfo      : SearchRec;
  NumFiles     : Integer;
  I,J:INTEGER;
  key:char;
  lasts,LAST,pass:string[15];
  pass1:string[2];
  NEW,point:integer;
  delcount:integer;
  F: file;
  Attr: Word;
  lines:word;
  command:string[25];
 _file:filepaths;

Procedure WriteXY( X,Y : Byte; S : String79 );
Begin        (* WriteXY *)
        GotoXY(X,Y);
        Write(S);
End;        (* WriteXY *)

Procedure Rm( FileName : String79 );
Var
        F : File;

Begin        (* Rm *)
        If (FileName = '') Then Exit;
        Assign(F,FileName);
        Erase(F);
End;        (* Rm *)

Procedure Center( Y : Byte; S : String; OverWriteMode : Errors );
Var
        X : Byte;

Begin        (* Center *)
        GotoXY(1,Y);
        Case (OverWriteMode) of
                1        : For X := 2 To 78 Do WriteXY(X,WhereY,' ');
                2        : ClrEOL;
        End;        (* Case *)
        X := ((79 - Length(S)) Div 2);
        If (X <= 0) Then X := 1;
        WriteXY(X,Y,S);
End;        (* Center *)


Procedure OutError( S : String79; X,OWM : Errors );
Var
        T : String79;

Begin        (* OutError *)
        GotoXY(1, WhereY);
        Case ( X ) Of
                1        : T := ('Incorrect Number of parameters.');
                2        : T := ('Input file "'+ S +'" not found.');
                3        : T := ('Input and Output files conflict.');
                4        : T := ('User Aborted!');
                5        : T := ('Input file "'+ S +'" is corrupted!');
                6        : If (T = '') Then T := ('DOS Input/Output Failure.')
                                Else T := S;
        End;        (* Case *)
        TextColor(LightRed);
        Center(WhereY,T,OWM);
        TextColor(LightGray);
        If (OWM = 1) Then WriteLn;
        Halt(x);
End;        (* OutError *)


Procedure GetStr( Var S : String79; Prompt,FName : String79; Show : Boolean );
Var
        Max,
        Min        : Byte;
        A        : Char;
        X        : Byte;

Begin        (* GetStr *)
        If (FName = '') Then
        Begin
                Max := 54;
                Min := 0
        End Else
        Begin
                Max := 25;
                Min := 3
        End;
        TextColor(LightGray);
       WriteXY(1,WhereY,Prompt);
        Repeat
                GotoXY(Length(Prompt) + 1,WhereY);
                ClrEOL;
                If (Show) Then WriteXY(Length(Prompt) + 1,WhereY,S)
                Else For X := 1 To Length(S) Do Write(#249);
                A := (ReadKey);
                Case ( A ) of
                        #32..#126 :
                                If (Length(S) < Max) Then S := S + A
                                Else
                                Begin
                                        Sound(100);
                                        Delay(12);
                                        NoSound;
                                End;
                        #8 :
                                If (Length(S) > 0) Then
                                        Delete(S,(Length(S) ), 1);
                        #0 :
                                A := ReadKey;
                        #27:
                                Begin
                                        Rm(FName);
                                        OutError('',4,2);
                                End;
                End;        (* Case *)
        Until (A = #13) And (Length(S) >= Min);
End;        (* GetStr *)

Procedure GraphIt( Var F1, F2        : File;
                                   Var OldX                : Byte;
                                   Hour,
                                   Min,
                                   Sec,
                                   Sec100                : Word;
                                   BoxSetUp                : Boolean );
Var
        F1Size,
        F2Size        : LongInt;
        Percent,
        X,
        NewX        : Byte;
        H,
        M,
        S,
        S100        : Word;
        A,
        B,
        C,
        D,
        Temp        : String79;

Begin        (* GraphIt *)
        If (BoxSetUp) Then
        Begin
                Percent := 0;
                OldX := 1;
         {       GotoXY(1,WhereY);
                WriteLn('ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
                WriteLn('บ                                                                             บ');
                WriteLn('ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');}
            {    GotoXY(3,WhereY - 2);}
        End Else
        Begin
           textattr:=red+(16*white);
                GetTime(H,M,S,S100);
                If (Sec100 <= S100) Then Dec(S100,Sec100)
                        Else
                        Begin
                                S100 := (S100 + 100 - Sec100);
                                If (S > 0) Then Dec(S);
                        End;
                If (Sec <= S) Then Dec(S,Sec)
                        Else
                        Begin
                                S := (S + 60 - Sec);
                                If (M > 0) Then Dec(M);
                        End;
                If (Min <= M) Then Dec(M,Min)
                        Else
                        Begin
                                M := (M + 60 - Min);
                                If (H > 0) Then Dec(H);
                        End;
                If (Hour <= H) Then Dec(H,Hour)
                        Else H := (H + 12 - Hour);
                Str(H,A);
                Str(M,B);
                Str(S,C);
                Str(S100,D);
                Case (S100) of
                        0..9        : D := ('0' + D);
                End;        (* Case *)
                If (M > 0) Then
                Case (S) of
                        0..9        : C := ('0' + C);
                End;        (* Case *)
                If (H > 0) Then
                Case (M) of
                        0..9        : B := ('0' + B);
                End;        (* Case *)
                If (H = 0) Then
                Begin
                        If (M = 0) Then Temp := (Concat(C,'.',D,' sec') )
                        Else Temp := (Concat(B,' min ',C,'.',D,' sec') );
                End
                Else If (H = 1) Then Temp := (Concat(A,' hr ',B,' min ',C,'.',D,' sec') )
                                Else Temp := (Concat(A,' hrs ',B,' min ',C,'.',D,' sec') );
            F1Size := FileSize(F1);
                F2Size := FileSize(F2);
                If (F2Size <= F1Size) Then
                Percent := ((F2Size * 100) Div F1Size )
                        Else Percent := 100;
                NewX := (((Percent * 76) Div 100) + 2);
                If (NewX < 3) Then NewX := 3;
                textattr:=lightred+(16*white);   {*************************}
{**}            For X := OldX To NewX Do WriteXY(X,{WhereY}23,#249);{}
                OldX := NewX;
                textattr:=9+(16*white);
                Center({WhereY}1 + {1}23,(#181 + ' ' + Temp + ' ' + #198),5);
                GotoXY(NewX,WhereY - 1);
        End;
End;        (* GraphIt *)

Function Shrink( P : PathStr ) : String79;
Var
        D        : DirStr;
        N        : NameStr;
        E        : ExtStr;

Begin        (* Shrink *)
        FSplit(P,D,N,E);
        Shrink := N + E;
End;        (* Shrink *)

Function UpStr( S : String ) : String;
Var
        X        : Byte;

Begin        (* UpStr *)
        For X := 1 To Length(S) Do
                S[x] := (UpCase(S[x]) );
        UpStr := S;
End;        (* UpStr *)

Procedure EnCode( _File : FilePaths; Protect : Boolean );
Var
        Seed,
        PI,
        Y,
        OldX                : Byte;
        I,
        Increment        : Integer;
        Buf                        : Array [1..BufSize] of Char;
        Hour,
        Min,
        Sec,
        Sec100,
        Status                : Word;
        Temp,
        Pass                : String79;
        F1,
        F2                        : File;

Begin        (* EnCode *)
        Pass := '';
    {$I-}
        Assign(F1, _File[1]);        (* input file  *)
        Assign(F2, _File[2]);        (* output file *)
        Reset(F1,1);
        {CheckError('','Couldn''t open input file.');}
        ReWrite(F2,1);
        {CheckError(_File[2],'Couldn''t create output file.');}
        Randomize;
{**}    If (Protect) Then
        Begin
       gotoxy(61,18);
       readln(pass);
{                GetStr(Pass,'(3 Char min, 25 Char max) Enter Password: ',_File[2],False);}
                Buf[1] := Chr(Random(127) );
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        End Else
        Begin
                Buf[1] := Chr(Random(127) + 127);
                BlockWrite(F2,Buf[1],SizeOf(Buf[1]),Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        End;
        Seed := Ord(Buf[1]);
        Increment := 1;
        PI := 1;
        Y := 127;
    {TextColor(LightGray);
{        ClrEOL;}
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                {CheckError(_File[2],'Couldn''t read input file.');}
                {CheckAbort(_File[2]);}
                GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,False);
                For I := 1 To BufSize Do
                        Begin
                                If (Protect) Then
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Byte(Pass[PI]));
                                                If (PI = Length(Pass)) Then Increment := -1;
                                                If (PI = 1) Then Increment := 1;
                                                Inc(PI,Increment);
                                        End
                                Else
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Y);
                                        End;
                        End;
                BlockWrite(F2, Buf, Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        Until (Status < BufSize);
        Close(F1);
        {CheckError(_File[2],'Couldn''t close input file.');}
        Close(F2);
        {CheckError(_File[2],'Couldn''t close output file.');}
        {$I+}
(* Successful Encryption *)
        TextColor(LightGray);
        Temp := (Shrink(_File[1]) +' Encoded to '+ Shrink(_File[2]));
        If (Protect) Then Temp := (Temp + ' with Password.');
        Center(WhereY,Temp,1);
       { GotoXY(1,WhereY + 1);}
{        WriteLn;}
End;        (* EnCode *)

Procedure DeCode( _File : FilePaths );
Var
        Seed,
        PI,
        Y,
        OldX                : Byte;
        I,
        Increment        : Integer;
        Buf                        : Array [1..BufSize] of Char;
        Hour,
        Min,
        Sec,
        Sec100,
        Status                : Word;
        Temp,
        Pass                : String79;
        F1,
        F2                        : File;

Begin        (* DeCode *)
        Pass := '';
        {$I-}
        Assign(F1, _File[1]);
        Assign(F2, _File[2]);
        Reset(F1,1);
        {CheckError('','Couldn''t open input file.');}
        ReWrite(F2,1);
        {CheckError(_File[2],'Couldn''t create output file.');}
        BlockRead(F1,Buf[1],SizeOf(Buf[1]),Status);
        {CheckError(_File[2],'Couldn''t read input file.');}
        Seed := Ord(Buf[1]);
        If (Buf[1] < #127) Then (* There's a Password *)
 {               GetStr(Pass,'Enter Password: ',_File[2],False);}
       gotoxy(61,18);
       readln(pass);
        Increment := 1;
        PI := 1;
        Y := 127;
        TextColor(LightGray);
        ClrEOL;
        GetTime(Hour,Min,Sec,Sec100);
        GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,True);
        Repeat
                BlockRead(F1, Buf, BufSize, Status);
                {CheckError(_File[2],'Couldn''t read input file.');}
                GraphIt(F1,F2,OldX,Hour,Min,Sec,Sec100,False);
                {CheckAbort(_File[2]);}
                For I := 1 To BufSize Do
                        Begin
                                If (Pass <> '') Then (* There's a Password *)
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Byte(Pass[PI]));
                                                If (PI = Length(Pass)) Then Increment := -1;
                                                If (PI = 1) Then Increment := 1;
                                                Inc(PI,Increment);
                                        End
                                Else
                                        Begin
                                                Buf[I] := Char(Byte(Buf[I]) XOR Y);
                                        End;
                        End;
                BlockWrite(F2, Buf, Status);
                {CheckError(_File[2],'Couldn''t write to output file.');}
        Until (Status < BufSize);
        Close(F1);
        {CheckError(_File[2],'Couldn''t close input file.');}
        Close(F2);
        {CheckError(_File[2],'Couldn''t close output file.');}
        {$I+}
(* Successful Decryption *)
        Center(WhereY,Shrink(_File[1]) +' Decoded to '+ Shrink(_File[2]),1);
        GotoXY(1,WhereY + 1);
      {  WriteLn;}
End;        (* DeCode *)





function DeleteFile(FN : PathStr) : Boolean;
var
  Regs : Registers;
begin
  FN := FN + #0;          { Add NUL chr for DOS }
  Regs.AH := $41;
  Regs.DX := Ofs(FN) + 1; { Add 1 to bypass length byte }
  Regs.DS := Seg(FN);
  MsDos(Regs);
  DeleteFile := NOT (Regs.Flags AND $0 = $0)
end;

PROCEDURE BOX;
BEGIN
textattr:=9+(16*0);
FOR J:=1 TO 24 DO
FOR I:=1 TO 80 DO
 BEGIN
 GOTOXY(I,J);
 WRITELN('Û');
 END;
textattr:=white+(16*0);
FOR I:=1 TO 80 DO
BEGIN
GOTOXY(I,1);
WRITELN('Û');
GOTOXY(I,23);
WRITELN('Û');
END;
textattr:=black+(16*white);
GOTOXY(3,1);
WRITELN('File Protection, Encoder/Decoder Ver 1.1');
{GOTOXY(16,23);
WRITELN('E-Encode File, D-Decode File, Esc Exit Utility');

{TEXTCOLOR(WHITE);
TEXTBACKGROUND(BLACK);     }
textattr:=white+(16*9);
FOR I:=1 TO 27 DO
 BEGIN
 GOTOXY(2+I,3);
 WRITELN('ฤ');
 GOTOXY(2+I,20);
 WRITELN('ฤ');
 END;
FOR J:=1 TO 16 DO
 BEGIN
 GOTOXY(2,3+J);
 WRITELN('ณ');
 GOTOXY(29,3+J);
 WRITELN('ณ');
 END;
 GOTOXY(29,3);
 WRITELN('ฟ');
 GOTOXY(29,20);
 WRITELN('ู');
 GOTOXY(2,3);
 WRITELN('ฺ');
 GOTOXY(2,20);
 WRITELN('ภ');
textattr:=9+(16*0);
for j:=1 to 16 do
for i:=1 to 26 do
begin
gotoxy(2+i,3+j);
writeln('Û');
end;
EnableHighBgd;
textattr:=10+(16*9);
GOTOXY(4,3);
WRITELN('List');
textattr:=9+(16*9);
gotoxy(3,19);
writeln('                          ');
SHADOW(20,3,20,29);
SHADOW(3,29,20,29);
END;

PROCEDURE BOX2;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,3);
 WRITELN('ฤ');
 GOTOXY(40+I,5);
 WRITELN('ฤ');
 END;
 GOTOXY(40,4);
 WRITELN('ณ');
 GOTOXY(77,4);
 WRITELN('ณ');
 GOTOXY(77,3);
 WRITELN('ฟ');
 GOTOXY(77,5);
 WRITELN('ู');
 GOTOXY(40,3);
 WRITELN('ฺ');
 GOTOXY(40,5);
 WRITELN('ภ');
textattr:=9+(16*0);
for i:=1 to 36 do
begin
gotoxy(40+i,4);
writeln('Û');
end;
textattr:=10+(16*9);
gotoxy(42,3);
writeln('Last Modification');
gotoxy(42,4);
writeln(last);
SHADOW(3,77,4,77);
SHADOW(5,41,5,77);
END;

PROCEDURE BOX3;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,7);
 WRITELN('ฤ');
 GOTOXY(40+I,10);
 WRITELN('ฤ');
 END;
 GOTOXY(40,8);
 WRITELN('ณ');
 GOTOXY(77,8);
 WRITELN('ณ');
 GOTOXY(40,9);
 WRITELN('ณ');
 GOTOXY(77,9);
 WRITELN('ณ');
 GOTOXY(77,7);
 WRITELN('ฟ');
 GOTOXY(77,10);
 WRITELN('ู');
 GOTOXY(40,7);
 WRITELN('ฺ');
 GOTOXY(40,10);
 WRITELN('ภ');
textattr:=9+(16*9);
FOR J:=1 TO 2 DO
for i:=1 to 36 do
begin
gotoxy(40+i,7+J);
writeln('Û');
end;
textattr:=10+(16*9);
gotoxy(42,7);
writeln('User Information');
SHADOW(7,77,9,77);
SHADOW(10,41,10,77);
textattr:=lightgreen+(16*9);
GOTOXY(42,8);
WRITELN('E- Encode File');
GOTOXY(42,9);
WRITELN('D- Decode File');

GOTOXY(60,8);
WRITELN('Del- Delete File');
GOTOXY(60,9);
WRITELN('Esc -Exit');
END;


PROCEDURE DELdir;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=white+(16*9);
gotoxy(3,23);
write('Do You Wish To Remove Thise Directory And All Its Contents [y/n]');
key:=readkey;
IF (KEY='Y') OR (KEY='y') THEN
BEGIN
Assign(f,pass);
SetFAttr(f, Archive);
NukeDir (pass,true, false,false,faAnyFile,lines);
LAST:=PASS;
END
ELSE
IF (KEY='N') OR (KEY='n') THEN
BEGIN
lasts:=pass;
END;
END;



PROCEDURE MAIN;
begin
  TextBackground(Black);
  TextColor(LightGray);
{  ClrScr;}

  For Cont := 1 to 15 do
  begin
    List[Cont] := '';
    AttrList[Cont] := '';
  end;

  NumFiles := 0;
  FindFirst('*.*', AnyFile, DirInfo);    {replace here path to *.*}

  While (DosError = 0) do
  begin
    Inc(NumFiles, 1);
    List[NumFiles] := Concat(DirInfo.Name,
                      Copy(S, 1, 12 - Length(DirInfo.Name)));
    If (DirInfo.Attr = $10) Then
      AttrList[NumFiles] := '<DIR>'
    Else
      Str(DirInfo.Size, AttrList[NumFiles]);
    AttrList[NumFiles] := Concat(AttrList[NumFiles],
                          Copy(S, 1, 6 - Length(AttrList[NumFiles])));
    FindNext(DirInfo);
  end;

  First := 1;
  Pos   := 1;
END;

PROCEDURE DIRCHANGE;
BEGIN
 command:='cd..';
 SwapVectors;
 Exec(GetEnv('COMSPEC'), '/C ' + Command);
 SwapVectors;
END;

PROCEDURE DIRCHANGE1;
BEGIN
 command:='cd '+pass;
 SwapVectors;
 Exec(GetEnv('COMSPEC'), '/C ' + Command);
 SwapVectors;
END;

PROCEDURE userinf;
BEGIN
textattr:=white+(16*9);
FOR I:=1 TO 37 DO
 BEGIN
 GOTOXY(40+I,12);
 WRITELN('ฤ');
 GOTOXY(40+I,20);
 WRITELN('ฤ');
 END;
FOR I:=1 TO 7 DO
BEGIN
 GOTOXY(40,12+I);
 WRITELN('ณ');
 GOTOXY(77,12+I);
 WRITELN('ณ');
END;
 GOTOXY(77,12);
 WRITELN('ฟ');
 GOTOXY(77,20);
 WRITELN('ู');
 GOTOXY(40,12);
 WRITELN('ฺ');
 GOTOXY(40,20);
 WRITELN('ภ');
textattr:=9+(16*0);
FOR J:=1 TO 7 DO
for i:=1 to 36 do
begin
gotoxy(40+i,12+J);
writeln('Û');
end;
SHADOW(12,77,19,77);
SHADOW(20,41,20,77);

textattr:=LIGHTGREEN+(16*9);
GOTOXY(42,14);
WRITELN('Source File Name : ',pass);
_FILE[1]:=PASS;
_File[1] := (UpStr(_File[1]) );
GOTOXY(42,16);
WRITE('Target File Name : ');

GOTOXY(61,16);
WRITE('             ');
GOTOXY(61,16);
READLN(_FILE[2]);
{GetStr(_File[2],'','',True);}
_File[2] := (UpStr(_File[2]) );
GOTOXY(42,18);
WRITELN('File Password    : ');
END;


PROCEDURE CONFIRM_ENCODE;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=WHITE+(16*9);
FOR I:=1 TO 57 DO
 BEGIN
 GOTOXY(10+I,7);
 WRITELN('ฤ');
 GOTOXY(10+I,9);
 WRITELN('ฤ');
 END;
 GOTOXY(10,8);
 WRITELN('ณ');
 GOTOXY(67,8);
 WRITELN('ณ');
 GOTOXY(67,7);
 WRITELN('ฟ');
 GOTOXY(67,9);
 WRITELN('ู');
 GOTOXY(10,7);
 WRITELN('ฺ');
 GOTOXY(10,9);
 WRITELN('ภ');
textattr:=9+(16*0);
for i:=1 to 56 do
begin
gotoxy(10+i,8);
writeln('Û');
end;
textattr:=10+(16*9);
gotoxy(12,7);
writeln('Encode File Confirmation [y/n]');
gotoxy(42,4);
writeln(last);
SHADOW(7,67,8,67);
SHADOW(9,11,9,67);

textattr:=white+(16*9);
GOTOXY(12,8);
WRITELN('Do You Wish To Encode File : ',pass); {<----}
key:=readkey;
if (key='N') OR (key='n') THEN
BEGIN
END
ELSE
if (key='Y') OR (key='y') THEN
BEGIN
{MAIN CODE HERE}
userinf;
EnCode(_file,true);
END;
END;

PROCEDURE CONFIRM_DECODE;
BEGIN
lines:=0;
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];
textattr:=WHITE+(16*9);
FOR I:=1 TO 57 DO
 BEGIN
 GOTOXY(10+I,7);
 WRITELN('ฤ');
 GOTOXY(10+I,9);
 WRITELN('ฤ');
 END;
 GOTOXY(10,8);
 WRITELN('ณ');
 GOTOXY(67,8);
 WRITELN('ณ');
 GOTOXY(67,7);
 WRITELN('ฟ');
 GOTOXY(67,9);
 WRITELN('ู');
 GOTOXY(10,7);
 WRITELN('ฺ');
 GOTOXY(10,9);
 WRITELN('ภ');
textattr:=9+(16*0);
for i:=1 to 56 do
begin
gotoxy(10+i,8);
writeln('Û');
end;
textattr:=10+(16*9);
gotoxy(12,7);
writeln('Decode File Confirmation [y/n]');
gotoxy(42,4);
writeln(last);
SHADOW(7,67,8,67);
SHADOW(9,11,9,67);

textattr:=white+(16*9);
GOTOXY(12,8);
WRITELN('Do You Wish To Decode File : ',pass); {<----}
key:=readkey;
if (key='N') OR (key='n') THEN
BEGIN
END
ELSE
if (key='Y') OR (key='y') THEN
BEGIN
{MAIN CODE HERE}
userinf;
deCode(_file);
END;
END;

PROCEDURE DELFILE;
BEGIN
if pos<15 then
  pass:=list[pos]
else
pass:=list[cont-1];

textattr:=BLACK+(16*WHITE);
GOTOXY(1,23);
WRITE('Do You Wish To Delete File [y/n] : ',pass);
REPEAT
key:=READKEY;
UNTIL (KEY='N') OR (KEY='n') OR (KEY='Y') OR (KEY='y');
IF (KEY='Y') OR (KEY='y') THEN
 BEGIN
 Assign(F, pass);
 SetFAttr(F, Archive);          { For Windows: faArchive }
 DeleteFile(pass);
 LAST:=PASS;
 END
ELSE
IF (KEY='N') OR (KEY='n') THEN
 BEGIN
 END;
END;

BEGIN
2:TEXTMODE(CO80);
1:BOX;
BOX2;
BOX3;
MAIN;
  Repeat
    For Cont := First To First + 15 do
    begin
      If (Cont - First + 1 = Pos) Then
      begin
        TextBackground(Blue);
        TextColor(Yellow);
      end
      Else
      begin
      textattr:=lightgreen+(16*9);

      end;
      GotoXY(5, Cont - First + 4);
      Write(' ', List[Cont], '  ', AttrList[Cont]);
    end;
    C := ReadKey;
    If (C = #72) Then
      If (Pos > 1) Then
        Dec(Pos, 1)
      Else
      If (First > 1) Then
        Dec(First,1);

    If (C = #80) Then
      If (Pos < 15) Then
        Inc(Pos, 1)
      Else
      If (First + 15 < NumFiles) Then
        Inc(First,1);

    IF (C=#27) THEN
    begin
    textmode(co80);
    EXIT;
    end;

    IF (C='D') OR (C='d') THEN
    begin
    CONFIRM_DECODE;
    GOTO 1;
    end;

    IF (C='E') OR (C='e') THEN
    begin
    CONFIRM_ENCODE;
    GOTO 1;
    end;

    IF (C=#13) THEN
    BEGIN
    if pos<15 then
    pass1:=list[pos]
    else
    pass1:=list[cont-1];
    if pass1='..' then
     begin
     DIRCHANGE;
     goto 1;
     end
    else
     begin
     if pos<15 then
     pass:=list[pos]
     else
     pass:=list[cont-1];
     dirchange1;
     goto 1;
     end;
    END;

    IF (C=#83) THEN
    BEGIN
    if pos<15 then
    pass1:=list[pos]
    else
    pass1:=list[cont-1];
     Delfile;
     goto 1;
    END;

  Until (Ord(c) = 13);{}
END.

GetStr(_File[1],'Enter Input Path/File : ','',True);
_File[1] := (UpStr(_File[1]) );
GetStr(_File[2],'Enter Output Path/File : ','',True);
_File[2] := (UpStr(_File[2]) );
{EnCode(_file,true);}
decode(_file);

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}

ENCODED FP.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.