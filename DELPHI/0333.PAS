UNIT DrawnBtn;
(********************************************************************
  TDrawedButton Component For Delphi.
  It Is A "Blank" Component Defined For Buttons Which Have Different
  Active Shape Like Triangular Or Card Figure Caro.

  TNArrowButton Component For Delphi.
  It Was Developed According To TArrowButton Component Authoring
  Originally By Kent Miller  Frederick, MD (Compuserve: 74113,200)

  TNArrowButton Component Will Give A Similar Triangle Button As
  TArrowButton Component But It Is INHERITED From A TDrawedButton Class
  Developed For More Correct Cursor-Image Handling And Support OnMouseMove,
  PopupMenu, And Others As Left Mouse Button.

  TCaroButton Component For Delphi.
  It Will Give A Button Which Has Similar Active Shape To
  Card Figure Caro.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free To Use And Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)

INTERFACE

USES
  SysUtils, WinTypes, WinProcs, Messages, Classes,
  Graphics, Controls, Menus;

CONST
  { offset from border of control to corner of button }
  S_OFFSET = 3;

TYPE
  TDrawedButton = Class(TGraphicControl)
  PRIVATE
    { Private declarations }
  Protected
    { Protected declarations }
    FButtonColor: TColor;
    FButtonDown: Boolean;
    FRgn: HRgn;
    FInnerCursor:TCursor;
    PROCEDURE FreeRegion;
    PROCEDURE MoveButton; VIRTUAL;
    PROCEDURE SetInnerCursor(Value: TCursor);
    PROCEDURE SetButtonColor(Value: TColor);
    PROCEDURE WMLButtonDown(VAR Message: TWMLButtonDown);
                      Message WM_LBUTTONDOWN;
    PROCEDURE WMLButtonUp(VAR Message: TWMLButtonUp);
                      Message WM_LBUTTONUP;
    PROCEDURE WMRButtonDown(VAR Message: TWMRButtonDown);
                      Message WM_RBUTTONDOWN;
    PROCEDURE WMMButtonDown(VAR Message: TWMMButtonDown);
                      Message WM_MBUTTONDOWN;
    PROCEDURE WMMouseMove(VAR Message: TWMMouseMove);
                      Message WM_MOUSEMOVE;
  PUBLIC
    { Public declarations }
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;
  Published
    { Published declarations }
    Property ButtonColor: TColor Read FButtonColor Write SetButtonColor;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor:TCursor Read FInnerCursor Write SetInnerCursor;

    Property OnMouseMove;
    Property OnClick;
  END;

  TButtonDirection = (ArwUP, ArwRIGHT, ArwLEFT, ArwDOWN);

  TNArrowButton = Class(TDrawedButton)
  PRIVATE
    FDirection: TButtonDirection;
    FPnts: ARRAY[1..3] OF TPoint;
    PROCEDURE SetDirection(Value: TButtonDirection);
  Protected
    PROCEDURE Paint; Override;
    PROCEDURE DrawUpArrow;
    PROCEDURE DrawRightArrow;
    PROCEDURE DrawDownArrow;
    PROCEDURE DrawLeftArrow;
    PROCEDURE MoveButton; Override;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;
  Published
    Property ButtonColor;
    Property Direction: TButtonDirection Read FDirection Write SetDirection;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor;

    Property OnMouseMove;
    Property OnClick;
  END;

  TCaroButton = Class(TDrawedButton)
  PRIVATE
    { Private declarations }
    FPnts: ARRAY[1..4] OF TPoint;
  Protected
    { Protected declarations }
    PROCEDURE Paint; Override;
    PROCEDURE DrawCaro;
    PROCEDURE MoveButton; Override;
  PUBLIC
    { Public declarations }
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;

  Published
    { Published declarations }
    Property ButtonColor;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor;

    Property OnClick;
    Property OnMouseMove;
  END;

PROCEDURE Register;

IMPLEMENTATION

CONSTRUCTOR TDrawedButton.Create(AOwner: TComponent);
BEGIN
 INHERITED Create(AOwner);
 Parent := TWinControl(AOwner);
 FRgn := 0;
END;

DESTRUCTOR TDrawedButton.Destroy;
BEGIN
IF FRgn <> 0 THEN FreeRegion;
INHERITED Destroy;
END;

PROCEDURE TDrawedButton.SetButtonColor(Value: TColor);
BEGIN
  IF Value <> FButtonColor THEN
    BEGIN
      FButtonColor := Value;
      Invalidate;
    END;
END;

PROCEDURE TDrawedButton.FreeRegion;
BEGIN
  IF FRgn <> 0 THEN
    DeleteObject(FRgn);
  FRgn := 0;
END;

PROCEDURE TDrawedButton.MoveButton;
BEGIN
END;

PROCEDURE TDrawedButton.WMLButtonDown(VAR Message: TWMLButtonDown);
BEGIN
  { if mouse is clicked on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
  BEGIN
     SendMessage(Parent.Handle,WM_LBUTTONDOWN,0,0);
  END
 ELSE
  BEGIN
   FButtonDown := True;
   MoveButton;
   INHERITED;
  END;
END;

PROCEDURE TDrawedButton.WMLButtonUp(VAR Message: TWMLButtonUp);
BEGIN
  { if button is down and mouse is released then
    make the button appear raised }
  IF NOT FButtonDown THEN
  BEGIN
   SendMessage(Parent.Handle,WM_LButtonUp,0,0);
  END
  ELSE
  BEGIN
   FButtonDown := False;
   MoveButton;
   IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
      Cursor:=Parent.Cursor;
   INHERITED;
  END;
END;

PROCEDURE TDrawedButton.SetInnerCursor(Value: TCursor);
BEGIN
  IF Value <> FInnerCursor THEN
    BEGIN
      FInnerCursor := Value;
    END;
END;

PROCEDURE TDrawedButton.WMMouseMove(VAR Message: TWMMouseMove);
BEGIN
 {mouse move reaction only on the buttonimage}
IF NOT FButtonDown THEN
 IF PtInRegion(FRgn, Message.Xpos, Message.Ypos) THEN
  BEGIN
  {set the cursor to the one defined for buttonimage}
   Cursor:=FInnerCursor;
   INHERITED
  END
 ELSE
  BEGIN
  {set the cursor to the one defined for Parent of button}
   Cursor:=Parent.Cursor;
   SendMessage(Parent.Handle,WM_MouseMove,0,0);
  END;
END;

PROCEDURE TDrawedButton.WMRButtonDown(VAR Message: TWMRButtonDown);
BEGIN
  { if mouse is clicked by right on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
   SendMessage(Parent.Handle,WM_RButtonDown,0,0)
   ELSE
  INHERITED;
END;

PROCEDURE TDrawedButton.WMMButtonDown(VAR Message: TWMMButtonDown);
BEGIN
  { if mouse is clicked by middle on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
   SendMessage(Parent.Handle,WM_MButtonDown,0,0)
  ELSE
  INHERITED;
END;

CONSTRUCTOR TNArrowButton.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [CsClickEvents, CsCaptureMouse];
  Width := 33;
  Height := 33;
  FDirection := ArwDown;
  FButtonColor := ClBlue;
  FRgn := 0;
  FButtonDown := False;
END;

DESTRUCTOR TNArrowButton.Destroy;
BEGIN
  IF FRgn <> 0 THEN
    FreeRegion;
  INHERITED Destroy;
END;

PROCEDURE TNArrowButton.Paint;
BEGIN
  INHERITED Paint;
  FreeRegion;
  CASE FDirection OF
    ArwUP: DrawUpArrow;
    ArwRIGHT: DrawRightArrow;
    ArwDOWN: DrawDownArrow;
    ArwLEFT: DrawLeftArrow;
  END;
END;

PROCEDURE TNArrowButton.DrawUpArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  { create border region for button }
  FPnts[1] := Point(Width DIV 2, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, Height - S_OFFSET);
  { save region to capture mouse clicks }
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  { draw black border around button }
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  { create region within black border for button }
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 4);
  Dec(FPnts[2].Y, 2);
  Inc(FPnts[3].X, 3);
  Dec(FPnts[3].Y, 2);
  Canvas.Brush.Color := FButtonColor;
  { draw button }
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawRightArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height DIV 2);
  FPnts[3] := Point(S_OFFSET, Height - S_OFFSET);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Inc(FPnts[1].X, 2);
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 3);
  Inc(FPnts[3].X, 2);
  Dec(FPnts[3].Y, 3);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawDownArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(Width - S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width DIV 2, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, S_OFFSET);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Dec(FPnts[1].X, 3);
  Inc(FPnts[1].Y, 2);
  Dec(FPnts[2].Y, 3);
  Inc(FPnts[3].X, 2);
  Inc(FPnts[3].Y, 2);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawLeftArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(Width - S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, Height DIV 2);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Dec(FPnts[1].X, 2);
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 2);
  Dec(FPnts[2].Y, 2);
  Inc(FPnts[3].X, 3);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.MoveButton;
BEGIN
  INHERITED MoveButton;
  IF NOT FButtonDown THEN  { button is in up position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for raised look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := ClWhite;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END
  ELSE  { button is in down position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for sunken look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := FButtonColor;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END;
END;

PROCEDURE TNArrowButton.SetDirection(Value: TButtonDirection);
BEGIN
  IF Value <> FDirection THEN
    BEGIN
      FDirection := Value;
      Invalidate;
    END;
END;

CONSTRUCTOR TCaroButton.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [CsClickEvents, CsCaptureMouse];
  Width := 25;
  Height := 40;
  FButtonColor := ClMaroon;
  FRgn := 0;
  FButtonDown := False;
END;

DESTRUCTOR TCaroButton.Destroy;
BEGIN
  IF FRgn <> 0 THEN
    FreeRegion;
  INHERITED Destroy;
END;

PROCEDURE TCaroButton.Paint;
BEGIN
  INHERITED Paint;
  FreeRegion;
  DRawCaro;
END;

PROCEDURE TCaroButton.DrawCaro;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;

  { create border region for button }
  FPnts[1] := Point(Width DIV 2, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height DIV 2 );
  FPnts[3] := Point(Width DIV 2, Height-S_OFFSET);
  FPnts[4] := Point(S_OFFSET,Height DIV 2);

  { save region to capture mouse clicks }
  FRgn := CreatePolygonRgn(FPnts, 4, ALTERNATE);

  { draw black border around button }
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);

  { create region within black border for button }
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 3);
  Dec(FPnts[3].X, 1);
  Dec(FPnts[3].Y, 2);
  Inc(FPnts[4].X, 2);
  Inc(FPnts[4].Y, 1);
  Canvas.Brush.Color := FButtonColor;

  { draw button }
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TCaroButton.MoveButton;
BEGIN
INHERITED MoveButton;
  IF NOT FButtonDown THEN  { button is in up position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for raised look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := ClWhite;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[4].X, FPnts[4].Y);
      END
  ELSE  { button is in down position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for sunken look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[4].X, FPnts[4].Y);
        Pen.Color := FButtonColor;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END;
END;

PROCEDURE Register;
BEGIN
 RegisterComponents('MyComps', [TNArrowButton]);
 RegisterComponents('MyComps', [TCaroButton]);
END;

END.

{ ------------------------- snip, snip ----------------------------}

ENCODED DRAWNBTN.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.