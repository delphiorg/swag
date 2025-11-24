
{ CODE LOCATED AT THE END !! }

HereI are the steps to add a wallpaper to the client area of of a
MDI parent form:

1) Create a new project
2) Set the form's FormStyle to fsMDIForm
3) Drop an image on the form and select a bitmap into it.
4) Find the { Private Declarations } comment in the form's
   definition and add these lines right after it:

   FClientInstance,
   FPrevClientProc : TFarProc;
   PROCEDURE ClientWndProc(VAR Message: TMessage);

5) Find the "implementation" line and the {$R *.DFM} line that
   follows it. After that line, enter this code:

PROCEDURE TForm1.ClientWndProc(VAR Message: TMessage);
VAR
  MyDC : hDC;
  Ro, Co : Word;
begin
  with Message do
    case Msg of
      WM_ERASEBKGND:
        begin
          MyDC := TWMEraseBkGnd(Message).DC;
          FOR Ro := 0 TO ClientHeight DIV Image1.Picture.Height DO
            FOR Co := 0 TO ClientWIDTH DIV Image1.Picture.Width DO
              BitBlt(MyDC, Co*Image1.Picture.Width, Ro*Image1.Picture.Height,
                Image1.Picture.Width, Image1.Picture.Height,
                Image1.Picture.Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
          Result := 1;
        end;
    else
      Result := CallWindowProc(FPrevClientProc, ClientHandle, Msg, wParam, lParam);
    end;
end;

6) Start an OnCreate method for the form and put these lines in it:

   FClientInstance := MakeObjectInstance(ClientWndProc);
   FPrevClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));
   SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FClientInstance));

7) Add a new form to your project and set its FormStyle to
   fsMDIChild.

Now you have a working MDI project with "wallpaper". The image
component is not visible, but its bitmap is replicated to cover
the MDI form's client area.

There is still one problem; when you minimize the child window its
icon will be drawn against a gray rectangle.

{------------------------- snip, snip ----------------------------}

ENCODED MDI.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
