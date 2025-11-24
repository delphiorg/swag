unit Binasc;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TBinAsc = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    procedure BinToAsc(fnSource, fnDest: String);
    procedure AscToBin(fnSource, fnDest: String);
  end;

procedure Register;

implementation

procedure TBinAsc.BinToAsc(fnSource, fnDest: String);
var
  Src, Dst: File;
  OneChar: Char;
  S: String;
  Hex: Array[0..1] of Char;
  NumRead, NumWritten: Integer;
begin
  AssignFile(Src, fnSource);
  ReSet(Src, 1);
  AssignFile(Dst, fnDest);
  ReWrite(Dst, 1);
  repeat
    BlockRead(Src, OneChar, SizeOf(OneChar), NumRead);
    S:=IntToHex(Integer(OneChar), 2);
    StrPCopy(Hex, S);
    BlockWrite(Dst, Hex, SizeOf(Hex), NumWritten);
  until (NumRead = 0);
  System.CloseFile(Dst);
  System.CloseFile(Src);
end;

procedure TBinAsc.AscToBin(fnSource, fnDest: String);
var
  Src, Dst: File;
  OneChar: Char;
  S: String;
  I: Integer;
  Hex: Array[0..1] of Char;
  NumRead, NumWritten: Integer;
begin
  AssignFile(Src, fnSource);
  ReSet(Src, 1);
  AssignFile(Dst, fnDest);
  ReWrite(Dst, 1);
  repeat
    BlockRead(Src, Hex, SizeOf(Hex), NumRead);
    OneChar:=Chr(StrToInt('$'+Copy(StrPas(Hex), 1, 2)));
    BlockWrite(Dst, OneChar, SizeOf(OneChar), NumWritten);
  until (NumRead = 0);
  System.CloseFile(Dst);
  System.CloseFile(Src);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TBinAsc]);
end;

end.

{ ------------------------- snip, snip ----------------------------}

ENCODED BINASC.DCR FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.