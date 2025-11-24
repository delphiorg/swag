unit ShdLabel;
(********************************************************************
  TShadowedLabel Component For Delphi.

  It Is A "Special" Label-Component Developed For
  Allow To Shadow A Single Lined Caption Text
  Of A Label.
  For The Correct Draw of Text The Properties Transparent
  And WordWrap Are Set False And Hidden.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free To Use And Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;
type
  TShadowType=(shdULeft,shdDLeft,shdURight,shdDRight);
type
  TShadowedLabel = class(TCustomLabel)
  private
    { Private declarations }
    FShadColor:TColor;
    FShadSolid:Boolean;
    FShadLeft,
    FShadDown:Word;
    TxtH,TxtW:Word;
    FShadowType:TShadowType;
  protected
    { Protected declarations }
    Function GetShadLeft:Word;
    procedure SetShadLeft(Sl:Word);
    Function GetShadDown:Word;
    procedure SetShadDown(Sd:Word);
    Function GetShadColor:TColor;
    procedure SetShadColor(Sc:TColor);
    procedure SetShadSolid(B:Boolean);
    procedure SetShadowType(St:TShadowType);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  published
    { Published declarations }
    Function TxtHeight:Word;
    Function TxtWidth:Word;
    property ShadowType:TShadowType read FShadowType write SetShadowType;
    property SolidShadow:Boolean read FShadSolid write SetShadSolid;
    property ShadowColor:TColor read GetShadColor Write SetShadColor;
    property ShadowDown:Word read GetShadDown Write SetShadDown;
    property ShadowLeft:Word read GetShadLeft Write SetShadLeft;
    property Caption;
    property Align;
    property Alignment;
    property AutoSize;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
 end;

procedure Register;

implementation

Function WMax(A,B:Word):Word;
 begin
  if a>=b then WMax:=a else WMax:=b;
 end;


constructor TShadowedLabel.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
  Parent := TWinControl(AOwner);
  AutoSize:=True;
  FShadSolid:=True;
  FShadColor:=clWhite;
  FShadowType:=shdDLeft;
  FShadLeft:=2;
  FShadDown:=2;
  Transparent:=False;
  WordWrap:=False;
  Alignment:=taLeftJustify;
  ParentFont:=False;
  With Font do
   begin
    Color:=clBlack;
    Name:='Arial';
    Pitch:=fpDefault;
    Size:=10;
    Style:=[];
   end;
 end;

destructor TShadowedLabel.Destroy;
 begin
  inherited Destroy;
 end;

procedure TShadowedLabel.Paint;
 const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
 var
  LabRect1,LabRect2:TRect;
  Flags:Word;
  Text: array[0..255] of Char;
  FC:TColor;
  TxtPt:TPoint;
  I:Integer;
 begin
  inherited Paint;
  GetTextBuf(Text, SizeOf(Text));
  StrPCopy(Text, Caption);
  TxtH:=Canvas.TextHeight(Caption);
  TxtW:=Canvas.TextWidth(Caption);
  If ShowAccelChar and (Pos('&',Caption)<>0)
   then TxtW:=TxtW-Canvas.TextWidth('&');
  TxtPt.y:=ClientRect.Top;
  Flags:=Alignments[Alignment];
  case Flags of
   DT_LEFT:TxtPt.x:=ClientRect.Left+FShadLeft-1;
   DT_RIGHT:TxtPt.x:=ClientRect.Right-TxtW-1;
   DT_CENTER:TxtPt.x:=ClientRect.Left+(ClientRect.Right-TxtW) div 2+2;
  end;
  Flags:=(DT_EXPANDTABS or DT_WORDBREAK)or Alignments[Alignment];
  if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;

 With LabRect1 do
   begin
     case FShadowType of
      shdULeft:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH;
       end; {Uleft}
      shdDLeft:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end;    {Dleft}
      shdDRight:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end; {DRight}
      shdURight:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH;
       end; {URight}
     end;{Case in Labrect1}
   end; {With Labrect1}

 With LabRect2 do
   begin
     case FShadowType of
      shdULeft:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end;{Uleft}
      shdDLeft:
       begin
        Left:=TxtPt.x;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW;
        Bottom:=TxtPt.y+TxtH;
       end; {Dleft}
      shdDRight:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH;
       end; {DRight}
      shdURight:
       begin
        Left:=TxtPt.x-FShadLeft;
        Top:=TxtPt.y+FShadDown;
        Right:=TxtPt.x+TxtW-FShadLeft;
        Bottom:=TxtPt.y+TxtH+FShadDown;
       end; {URight}
     end;  {Case in Labrect2}
   end;   {With Labrect2}

 if AutoSize then
  begin
   case Align of
    alTop, alBottom:
     if ClientHeight<>TxtH+FShadDown then ClientHeight:=TxtH+FShadDown;
    alLeft, alRight:
     if ClientWidth<>TxtW+FShadLeft then ClientWidth:=TxtW+FShadLeft;
    alNone:
     begin
      if ClientHeight<>TxtH+FShadDown then ClientHeight:=TxtH+FShadDown;
      if ClientWidth<>TxtW+FShadLeft then ClientWidth:=TxtW+FShadLeft;
     end;
   end;
  end;

 with Canvas do
  begin
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
  end;
  Fc:=Canvas.Font.Color ;

  Canvas.Font.Color :=FShadColor;
  if not Enabled then Canvas.Font.Color := clWhite;
{  if not FShadSolid then}
   DrawText(Canvas.Handle, Text, StrLen(Text), LabRect1, Flags);
  if FShadSolid then
  begin
  for I:=0 to WMax(FShadLeft,FShadDown) do
   begin
    case FShadowType of
     shdULeft:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-FShadLeft+I;
         LabRect1.Right:=TxtPt.x+TxtW-FShadLeft+I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+I;
         LabRect1.Bottom:=TxtPt.y+TxtH+I;
        end;
      end; {ULeft}
     shdDLeft:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-FShadLeft+I;
         LabRect1.Right:=TxtPt.x+TxtW-FShadLeft+I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+FShadDown-I;
         LabRect1.Bottom:=TxtPt.y+TxtH+FShadDown-I;
        end;
      end; {DLeft}
     shdDRight:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-I;
         LabRect1.Right:=TxtPt.x+TxtW-I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+FShadDown-I;
         LabRect1.Bottom:=TxtPt.y+TxtH+FShadDown-I;
        end;
      end; {DRight}
     shdURight:
      begin
       if I<=FShadLeft then
        begin
         LabRect1.Left:=TxtPt.x-I;
         LabRect1.Right:=TxtPt.x+TxtW-I;
        end;
       if I<=FShadDown then
        begin
         LabRect1.Top:=TxtPt.y+I;
         LabRect1.Bottom:=TxtPt.y+TxtH+I;
        end;
      end; {URight}
     end; {Case}
    DrawText(Canvas.Handle, Text, StrLen(Text), LabRect1, Flags);
   end;  {for}
  end; {if FShadSolid}

  Canvas.Font.Color :=Fc;
  if not Enabled then Canvas.Font.Color := clGray;
  DrawText(Canvas.Handle, Text, StrLen(Text), LabRect2, Flags);
  Canvas.Font.Color :=Fc;
 end;

function TShadowedLabel.GetShadColor:TColor;
begin
 Result:=FShadColor;
end;

procedure TShadowedLabel.SetShadColor(Sc:TColor);
begin
 if FShadColor<>Sc then
  begin
   FShadColor:=Sc;
   Invalidate;
  end;
end;

Function TShadowedLabel.GetShadLeft:Word;
begin
 Result:=FShadLeft;
end;

procedure TShadowedLabel.SetShadLeft(Sl:Word);
begin
 if FShadLeft<>sl then
  begin
   FShadLeft:=sl;
   Invalidate;
  end;
end;

Function TShadowedLabel.GetShadDown:Word;
begin
 Result:=FShadDown;
end;

procedure TShadowedLabel.SetShadDown(Sd:Word);
begin
 if FShadDown<>sd then
 begin
  FShadDown:=sd;
  Invalidate;
 end;
end;

procedure TShadowedLabel.SetShadSolid(B:Boolean);
begin
 if FShadSolid<>B then
  begin
   FShadSolid:=B;
   Invalidate;
  end;
end;

procedure TShadowedLabel.SetShadowType(St:TShadowType);
begin
 if FShadowType<>St then
  begin
   FShadowType:=St;
   Invalidate;
  end;
end;


function TShadowedLabel.TxtHeight:Word;
begin
 Result:=TxtH;
end;
function TShadowedLabel.TxtWidth:Word;
begin
 Result:=TxtW;
end;

procedure Register;
begin
  RegisterComponents('MyComps', [TShadowedLabel]);
end;

end.

{------------------------- snip, snip ----------------------------}

ENCODED SHDLABEL.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.