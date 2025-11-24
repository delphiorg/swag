unit ScrolLbl;
(********************************************************************
  TScrollLabel Component FOR Delphi.

  It Is A "Special" Label-Component Developed For
  Allow To Scroll A Single Lined Caption Text
  Of A Label.
  For Correct Function You Should Be Switch The
  AutoSize Property To False After Building Your Form.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free TO Use AND Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes,
  Graphics, Controls, ExtCtrls, StdCtrls;

type
  TScrlDir=(sdLeft,sdRight);

type
  TScrollLabel = class(TCustomLabel)
  private
    { Private declarations }
    FRunned,
    FRunTxt:String;
    FTimer:TTimer;
    FInterval:Word;
    FRunning:Boolean;
    FTxtScroll:TScrlDir;
    FBigO,
    FMaxChar:Integer;
    procedure SetScrlDir(Sd:TScrlDir);
    function GetRunTxt:String;
    procedure SetRunTxt(S:String);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShiftLabelText(Sender: TObject);
    function GetInterval:Word;
    procedure SetInterval(W:Word);
    function GetRunning:Boolean;
    procedure SetRunning(R:Boolean);
    procedure TxtRestore;
  published
    { Published declarations }
    property ScrollDirection: TScrlDir read FTxtScroll write SetScrlDir;
    property RunText: String read GetRunTxt write SetRunTxt ;
    property Interval: Word read GetInterval write SetInterval Default 200;
    property Running: Boolean read GetRunning write SetRunning Default False;
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Transparent;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
 end;

procedure Register;

implementation

constructor TScrollLabel.Create;
 begin
  Inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  Caption:=FRunTxt;
  FTimer:=TTimer.Create(Self);
  FInterval:=200;
  FTxtScroll:=sdLeft;
  Alignment:=taCenter;
  AutoSize:=True;
  ParentFont:=False;
  Transparent:=False;
  WordWrap:=False;
  With Font do
   begin
    Color:=clBlack;
    Name:='Arial';
    Pitch:=fpDefault;
    Size:=10;
    Style:=[fsBold];
   end;
  FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
  If FTimer<>NIL then
   begin
    FTimer.OnTimer := ShiftLabelText;
    FTimer.Interval := FInterval;
    FTimer.Enabled :=FRunning;
   end;
 end;

destructor TScrollLabel.Destroy;
 begin
  FTimer.Free;
  inherited Destroy;
 end;

procedure TScrollLabel.SetScrlDir(Sd:TScrlDir);
 begin
  FTxtScroll:=Sd;
 end;

procedure TScrollLabel.SetInterval(W:Word);
 begin
  FInterval:=W;
  FTimer.Interval := FInterval;
 end;

function TScrollLabel.GetInterval:Word;
 begin
  Result:=FInterval;
 end;

procedure TScrollLabel.SetRunning(R:Boolean);
  begin
   FRunning:=R;
   FTimer.Enabled:=FRunning;
   if not R then TxtRestore;
  end;

function TScrollLabel.GetRunning:Boolean;
  begin
   Result:=FRunning;
  end;

procedure TScrollLabel.SetRunTxt(S:String);
 begin
  FRunned:=S;
  FRunTxt:=S;
  Caption:=FRunTxt;
 end;

function TScrollLabel.GetRunTxt:String;
 begin
  Result:=FRunTxt;
 end;

procedure TScrollLabel.ShiftLabelText(Sender: TObject) ;
   var
    TxtL:integer;
    Pc:PChar;
   begin
    FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
    FMaxChar:=Width div FBigO;
    TxtL:=Length(FRunned);
    Case FTxtScroll of
    sdLeft:
     begin
      FRunned:=FRunned+FRunned[1]+#0;
      Pc:=@FRunned[2];
      FRunned:=StrPas(Pc);
     end;
    sdRight:
     begin
      FRunned:=FRunned[TxtL]+FRunned;
     {$IFDEF WIN32}
      SetLength (FRunned,TxtL);
     {$ELSE}
      FRunned[0]:=Chr(TxtL);
     {$ENDIF}
     end;
    end;
{Set the textlength to scrolling region of label}
    if (TxtL*FBigO) > (FMaxChar * FBigO)
     then
      Caption:=Copy(FRunned,1,FMaxChar-1)
     else
      Caption:=FRunned;
  end;

procedure TScrollLabel.TxtRestore;
 begin
  FRunned:=FRunTxt;
  Caption:=FRunned;
 end;

 {This allows font changes to be detected so the label might be adjusted}
procedure TScrollLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  FBigO:=Canvas.TextWidth('OWQTEKSZY\')div 10;
end;

procedure Register;
begin
  RegisterComponents('MyComps', [TScrollLabel]);
end;

end.

{------------------------- snip, snip ----------------------------}

ENCODED SCROLLBL.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.