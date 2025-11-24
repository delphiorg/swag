{
Hello again!

I send to You a toolbar button component, which looks like the Explorer
3.0's toolbar button. Resource file and a number of button images are included.
These need to extracted using XX3402.  See below for more information.

This component made under Delphi 2.0, and NOT tested with Delphi 1.0 (but I
think it works under 1.0).

Kind regards
        Matthew Csulik
        matthew-c@usa.net

---------------------------------------------------------
-                                                       -
-  ToolButton.pas                                       -
-  **************                                       -
-  This component and it's bitmaps are completely FREE. -
-                                                       -
---------------------------------------------------------

{usage:                                                                        }
{ just assign three bitmap (included) to the Color, Disabled, and Mono bitmaps;}
{ set the right color for transparentcolor;                                    }
{ and USE IT!                                                                  }

unit Toolbutton;

interface

{ written by Matthew }
{ matthew-c@usa.net  }

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls;

type
   TToolButtonState = (tbsUp, tbsDown);
   TToolButtonStyle = (tstTextBitmap, tstBitmap);
   TMouseState = (msIn, msOut);

   TToolButton = class(TGraphicControl)
   private
      State: TToolButtonState;
      MouseState: TMouseState;
      FStyle: TToolButtonStyle;
      FColorBitmap, FMonoBitmap, FDisabledBitmap: TBitmap;
      FTransparentColor: TColor;
      procedure SetColorBitmap(Value: TBitmap);
      procedure SetMonoBitmap(Value: TBitmap);
      procedure SetDisabledBitmap(Value: TBitmap);
      procedure SetStyle(Value: TToolButtonStyle);
      procedure SetTransparentColor(Value: TColor);
      procedure CMMouseEnter(var Message: TMessage);
         message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage);
         message CM_MOUSELEAVE;
      procedure CMEnabledChanged(var Message: TMessage);
         message CM_ENABLEDCHANGED;
      procedure CMSysColorChange(var Message: TMessage);
      	 message CM_SYSCOLORCHANGE;
      procedure CMTextChanged(var Message: TMessage);
      	 message CM_TEXTCHANGED;
   protected
      procedure Paint; override;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure Click; override;
      procedure DblClick; override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
         X, Y: integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer);
         override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
         X, Y: integer); override;
   published
      property Caption;
      property ColorBitmap: TBitmap read FColorBitmap write SetColorBitmap;
      property DisabledBitmap: TBitmap read FDisabledBitmap write
SetDisabledBitmap;
      property MonoBitmap: TBitmap read FMonoBitmap write SetMonoBitmap;
      property TransparentColor: TColor read FTransparentColor write
SetTransparentColor default clOlive;
      property Style: TToolButtonStyle read FStyle write SetStyle;
      property Enabled;
      property ParentShowHint;
      property ShowHint;
      property Visible;
      property OnClick;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
   end;

procedure Register;

implementation

constructor TToolButton.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FTransparentColor:= clOlive;
   FColorBitmap:= TBitmap.Create;
   FMonoBitmap:= TBitmap.Create;
   FDisabledBitmap:= TBitmap.Create;
   Caption:= Name;
   State:= tbsUp;
   Style:= tstTextBitmap;
   MouseState:= msOut;
end;

destructor TToolButton.Destroy;
begin
   FColorBitmap.Free;
   FMonoBitmap.Free;
   FDisabledBitmap.Free;
   inherited Destroy;
end;

procedure TToolButton.Paint;
var
   CX,CY: integer;
begin
   CX:= Width div 2;
   CY:= Height div 2;
   if csDesigning in ComponentState then
   begin
      with inherited Canvas do
      begin
         Pen.Style := psDash;
         Brush.Style := bsClear;
         Rectangle(0, 0, Width, Height);
         Brush.Color:= clBtnFace;
	 FillRect(Rect(0,0,Width,Height));
         if Style = tstTextBitmap then
         begin
            BrushCopy(Rect(CX-(MonoBitmap.Width div 2),CY-(MonoBitmap.Height
div 2)-10,
	       CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)-10),
	          MonoBitmap, Rect(0,0,MonoBitmap.Width,MonoBitmap.Height),
TransparentColor);
	    Font.Color:= clBlack;
	    Font.Name:= 'MS Sans Serif';
	    Font.Size:= 8;
	    Font.Style:= [];
	    TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
         end
         else
         begin
            BrushCopy(Rect(CX-(MonoBitmap.Width div 2),CY-(MonoBitmap.Height
div 2),
	       CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)),
	       MonoBitmap, Rect(0,0,MonoBitmap.Width,MonoBitmap.Height),
TransparentColor);
         end;
      end;
   end
   else
   begin
      with inherited Canvas do
      begin
         Brush.Style := bsClear;
         Brush.Color:= clBtnFace;
	 FillRect(Rect(0,0,Width,Height));
      end;
      if Enabled then
      begin
         if (State = tbsUp) and (MouseState = msOut) then
         begin
            with Canvas do
            begin
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(MonoBitmap.Width div
2),CY-(MonoBitmap.Height div 2)-10,
                     CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div
2)-10),
                        MonoBitmap,
Rect(0,0,MonoBitmap.Width,MonoBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
 	       end
               else
               begin
                  BrushCopy(Rect(CX-(MonoBitmap.Width div
2),CY-(MonoBitmap.Height div 2),
                     CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)),
                        MonoBitmap,
Rect(0,0,MonoBitmap.Width,MonoBitmap.Height), TransparentColor);
               end;
            end;
         end
         else if (State = tbsUp) and (MouseState = msIn) then
         begin
            with Canvas do
            begin
	       FillRect(Rect(0,0,Width,Height));
	       Pen.Color:= clbtnHighlight;
               Polyline([Point(Width-1,0),Point(0,0),Point(0,Height-1)]);
               Pen.Color:= clbtnShadow;
               Polyline([Point(Width-1,1),Point(Width-1,Height-1),Point(1,He
ight-1)]);
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2),CY-(ColorBitmap.Height div 2)-10,
                     CX+(ColorBitmap.Width div 2),CY+(ColorBitmap.Height div
2)-10),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
	       end
               else
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2),CY-(ColorBitmap.Height div 2),
                     CX+(ColorBitmap.Width div 2),CY+(ColorBitmap.Height div
2)),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
               end;
            end;
         end
         else if (State = tbsDown) and (MouseState = msIn) then
         begin
            with Canvas do
            begin
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       FillRect(Rect(0,0,Width,Height));
	       Pen.Color:= clbtnShadow;
               Polyline([Point(Width-1,0),Point(0,0),Point(0,Height-1)]);
               Pen.Color:= clbtnHighlight;
               Polyline([Point(Width-1,1),Point(Width-1,Height-1),Point(1,He
ight-1)]);
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2)+1,CY-(ColorBitmap.Height div 2)-9,
                     CX+(ColorBitmap.Width div 2)+1,CY+(ColorBitmap.Height
div 2)-9),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2)+1,CY+6,Caption);
	       end
               else
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2)+1,CY-(ColorBitmap.Height div 2)+1,
                     CX+(ColorBitmap.Width div 2)+1,CY+(ColorBitmap.Height
div 2)+1),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
               end;
            end;
         end;
      end
      else
      begin		               {Disabled}
         with Canvas do
         begin
	    Brush.Style:= bsClear;
            Brush.Color:= clBtnFace;
	    FillRect(Rect(0,0,Width,Height));
	    if Style = tstTextBitmap then
            begin
               BrushCopy(Rect(CX-(FDisabledBitmap.Width div
2),CY-(FDisabledBitmap.Height div 2)-10,
                  CX+(FDisabledBitmap.Width div
2),CY+(FDisabledBitmap.Height div 2)-10),
                     FDisabledBitmap,
Rect(0,0,FDisabledBitmap.Width,FDisabledBitmap.Height), TransparentColor);
               Font.Name:= 'MS Sans Serif';
               Font.Size:= 8;
               Font.Style:= [];
               Font.Color:= clbtnHighlight;
               TextOut(CX-(TextWidth(Caption) div 2)+1,CY+6,Caption);
               Font.Color:= clbtnShadow;
               TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
	    end
            else
            begin
               BrushCopy(Rect(CX-(FDisabledBitmap.Width div
2),CY-(FDisabledBitmap.Height div 2),
                  CX+(FDisabledBitmap.Width div
2),CY+(FDisabledBitmap.Height div 2)),
                     FDisabledBitmap,
Rect(0,0,FDisabledBitmap.Width,FDisabledBitmap.Height), TransparentColor);
            end;
         end;
      end;
   end;
end;

procedure TToolButton.Click;
begin
   inherited Click;
end;

procedure TToolButton.DblClick;
begin
   inherited Click;
end;

procedure TToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
   inherited MouseDown(Button, Shift, X, Y);
   if (Button = mbLeft) and Enabled then
   begin
      if State <> tbsDown then
      begin
         State:= tbsDown;
         Invalidate;
      end;
   end;
end;

procedure TToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseMove(Shift, X, Y);
end;

procedure TToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
   inherited MouseUp(Button, Shift, X, Y);
   State:= tbsUp;
   Invalidate;
end;

procedure TToolButton.CMMouseEnter(var Message: TMessage);
begin
   MouseState:= msIn;
   if Enabled then
      Invalidate;
end;

procedure TToolButton.CMMouseLeave(var Message: TMessage);
begin
   if State = tbsDown then
   begin
      State:= tbsUp;
      Invalidate;
   end;
   MouseState:= msOut;
   if Enabled then
      Invalidate;
end;

procedure TToolButton.CMEnabledChanged(var Message: TMessage);
begin
   Invalidate;
end;

procedure TToolButton.CMSysColorChange(var Message: TMessage);
begin
   Invalidate;
end;

procedure TToolButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TToolButton.SetColorBitmap(Value: TBitmap);
begin
   if FColorBitmap <> Value then
   begin
      FColorBitmap.Assign(Value);
      Invalidate;
   end;
end;

procedure TToolButton.SetMonoBitmap(Value: TBitmap);
var
   x,y: integer;
begin
   if FMonoBitmap <> Value then
   begin
      FMonoBitmap.Assign(Value);
      FDisabledBitmap.Height:= FMonoBitmap.Height;
      FDisabledBitmap.Width:= FMonoBitmap.Width;
      for x:= 0 to FDisabledBitmap.Width do
      begin
         for y:= 0 to FDisabledBitmap.Height do
         begin
            if FMonoBitmap.Canvas.Pixels[x,y] = clWhite then
               FDisabledBitmap.Canvas.Pixels[x,y]:= clbtnHighlight;
            if FMonoBitmap.Canvas.Pixels[x,y] = clGray then
               FDisabledBitmap.Canvas.Pixels[x,y]:= clbtnShadow;
         end;
      end;
      Invalidate;
   end;
end;

procedure TToolButton.SetDisabledBitmap(Value: TBitmap);
const
  ROP_DSPDxax = $00E20746;
var
   MonoBmp, TmpImage: TBitmap;
   IRect: TRect;
   IWidth,IHeight: integer;
begin
   if FDisabledBitmap <> Value then
   begin
      FDisabledBitmap.Assign(Value);
      IWidth:= FDisabledBitmap.Width;
      IHeight:= FDisabledBitmap.Height;
      IRect:= Rect(0,0,IWidth,IHeight);
      TmpImage:= TBitmap.Create;
      MonoBmp:= TBitmap.Create;
      TmpImage.Width:= FDisabledBitmap.Width;
      TmpImage.Height:= FDisabledBitmap.Height;
      MonoBmp.Width:= FDisabledBitmap.Width;
      MonoBmp.Height:= FDisabledBitmap.Height;
      with MonoBmp do
      begin
         Assign(FDisabledBitmap);
         Canvas.Brush.Color := clBlack;
         if Monochrome then
         begin
            Canvas.Font.Color := clWhite;
            Monochrome := False;
            Canvas.Brush.Color := clWhite;
         end;
         Monochrome := True;
      end;
      with TmpImage.Canvas do
      begin
         Brush.Color := clBtnFace;
         FillRect(IRect);
         Brush.Color := clBtnHighlight;
         SetTextColor(Handle, clBlack);
         SetBkColor(Handle, clWhite);
         BitBlt(Handle, 1, 1, IWidth, IHeight,
         MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
         Brush.Color := clBtnShadow;
         SetTextColor(Handle, clBlack);
         SetBkColor(Handle, clWhite);
         BitBlt(Handle, 0, 0, IWidth, IHeight,
         MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
      end;
      FDisabledBitmap.Assign(TmpImage);
      TmpImage.Free;
      MonoBmp.Free;
      Invalidate;
   end;
end;

procedure TToolButton.SetStyle(Value: TToolButtonStyle);
begin
   if FStyle <> Value then
   begin
      FStyle:= Value;
      Invalidate;
   end;
end;

procedure TToolButton.SetTransparentColor(Value: TColor);
begin
   if FTransParentColor <> Value then
   begin
      FTransparentColor:= Value;
      Invalidate;
   end;
end;

procedure Register;
begin
   RegisterComponents('Matthew', [TToolButton]);
end;

end.

{{------------------------- snip, snip ----------------------------}

ENCODED TBBMPS.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{{------------------------- snip, snip ----------------------------}

ENCODED TBRES.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
