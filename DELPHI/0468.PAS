{
DCR module located at the bottom !!

How To Use:

In the OnCreate - event of the form, put something like this:

begin
  Tiler1.Attach;
end;

and everything will work out fine...
}


unit uTiler;
//----------------------------------------------------------------------------//
// TTiler V1.0                                                                //
// By Martijn Tonies / Upscene Productions Holland                            //
// Copyright 1997 by Upscene Productions                                      //
// This code may be used, but may not be modified for commercial use.         //
//----------------------------------------------------------------------------//

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TTileMode = (tmTile, tmStretch, tmCenter);
  TTiler = class(TComponent)
  private
    Attached: Boolean;
    FActive: Boolean;
    FBitmap: TBitmap;
    FTileMode: TTileMode;

    FHandle: HWND;

    FClientInstance: TFarProc;
    FDefClientProc: TFarProc;

    procedure SetActive(Value: Boolean);
    procedure SetBitmap(Value: TBitmap);
    procedure SetTileMode(Value: TTileMode);

    procedure ClientWndProc(var Message: TMessage);
    procedure FillClientArea(DC: HDC);
    procedure Stretch(DC: HDC);
    procedure Tile(DC: HDC);
    procedure Center(DC: HDC);
    { Private declarations }
  protected
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Protected declarations }
  public
    procedure Attach;
    { Public declarations }
  published
    property Active: Boolean read FActive write SetActive stored True;
    property Bitmap: TBitmap read FBitmap write SetBitmap stored True;
    property TileMode: TTileMode read FTileMode write SetTileMode stored True;
    { Published declarations }
  end;

procedure Register;

implementation

procedure TTiler.Attach;
begin
  if FBitmap.Handle = 0
  then begin
         raise Exception.Create('TTiler can''t be attached unless you assign a bitmap to it!');
       end
  else begin
         if (Owner as TForm).FormStyle = fsMDIForm
         then FHandle := (Owner as TForm).ClientHandle
         else FHandle := (Owner as TForm).Handle;
         FClientInstance := MakeObjectInstance(ClientWndProc);
         FDefClientProc := Pointer(GetWindowLong(FHandle, GWL_WNDPROC));
         SetWindowLong(FHandle, GWL_WNDPROC, LongInt(FClientInstance));
         Attached := True;
       end;
end;

constructor TTiler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive := True;
  FBitmap := TBitmap.Create;
  Attached := False;
end;

destructor TTiler.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TTiler.ClientWndProc(var Message: TMessage);
  procedure Default;
  begin
    with Message
    do Result := CallWindowProc(FDefClientProc, FHandle, Msg, wParam, lParam);
  end;
begin
  with Message
  do begin
       case Msg of
         WM_NCHITTEST          : begin
                                   Default;
                                   if Result = HTCLIENT
                                   then Result := HTTRANSPARENT;
                                 end;
         WM_ERASEBKGND         : begin
                                   if Assigned(FBitmap) and Active
                                   then FillClientArea(TWMEraseBkgnd(Message).DC)
                                   else FillRect(TWMEraseBkgnd(Message).DC, (Owner as TForm).ClientRect, (Owner as TForm).Brush.Handle);
                                   Result := 1;
                                 end;
       else Default;
       end;
     end;
end;

procedure TTiler.FillClientArea(DC: HDC);
begin
  case FTileMode of
    tmStretch   : Stretch(DC);
    tmTile      : Tile(DC);
    tmCenter    : Center(DC);
  end;
end;

procedure TTiler.Center(DC: HDC);
var Form: TForm;
    R: TRect;
    x, y: LongInt;
    w, h: LongInt;
begin
  Form := Owner as TForm;
  R := Form.ClientRect;
  x := (R.Right div 2) - (FBitmap.Width div 2);
  y := (R.Bottom div 2) - (FBitmap.Height div 2);
  w := x + FBitmap.Width;
  h := y + FBitmap.Height;
  FillRect(DC, R, Form.Brush.Handle);
  BitBlt(DC, x, y, w, h, FBitmap.Canvas.Handle, 0, 0, SRCCOPY);

  ReleaseDC(FHandle, DC);
end;

procedure TTiler.Stretch(DC: HDC);
var Form: TForm;
    R: TRect;
begin
  Form := Owner as TForm;
  R := Form.ClientRect;
  StretchBlt(DC, R.Left, R.Top, R.Right, R.Bottom, FBitmap.Canvas.Handle, 0, 0, FBitmap.Width, FBitmap.Height, SRCCOPY);
  ReleaseDC(FHandle, DC);
end;

procedure TTiler.Tile(DC: HDC);
var x, y, bmWidth, bmHeight: Integer;
    bmHandle: Integer;
begin
  x := 0;
  bmWidth := FBitmap.Width;
  bmHeight := FBitmap.Height;
  bmHandle := FBitmap.Canvas.Handle;

  while x < (Owner as TForm).Width
  do begin
       y := 0;
       while y < (Owner as TForm).Height
       do begin
            BitBlt(DC, x, y, x + bmWidth, y + bmHeight,
                   bmHandle, 0, 0, SRCCOPY);
            BitBlt(DC, x, y + bmHeight, x + bmWidth, y + bmHeight,
                   bmHandle, 0, 0, SRCCOPY);
            BitBlt(DC, x + bmWidth, y, x + bmWidth, y + bmHeight,
                   bmHandle, 0, 0, SRCCOPY);
            BitBlt(DC, x + bmWidth, y + bmHeight, x + bmWidth, y + bmHeight,
                   bmHandle, 0, 0, SRCCOPY);
            y := y + bmHeight * 2;
          end;
       x := x + bmWidth * 2;
     end;
  ReleaseDC(FHandle, DC);
end;


procedure TTiler.SetActive(Value: Boolean);
begin
  if Value <> FActive
  then if (not Attached) and Value
       then raise Exception.Create('TTiler can''t be active unless you assign a bitmap to it!')
       else begin
              FActive := Value;
              if not (csDesigning in ComponentState)
              then if not FActive and Attached
                   then FillRect(GetDC(FHandle), (Owner as TForm).ClientRect, (Owner as TForm).Brush.Handle)
                   else if Attached and FActive
                        then FillClientArea(GetDC(FHandle));
            end;
end;

procedure TTiler.SetBitmap(Value: TBitmap);
begin
  FBitmap.Assign(Value);
end;

procedure TTiler.SetTileMode(Value: TTileMode);
begin
  if Value <> FTileMode
  then begin
         FTileMode := Value;
       end;
end;


procedure Register;
begin
  RegisterComponents('Upscene', [TTiler]);
end;

end.
------------------------- snip, snip ----------------------------}

ENCODED UTILER.DCR FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.