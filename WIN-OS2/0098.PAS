PROGRAM Bmptblt;
{ Dieser Code beschreibt die Darstellung von Bitmaps mit "durchsichtigen" Bereichen
  (c) 1997 U. Conrad, uconrad1@gwdg.de }

{$R BMPTBLT.RES}  { see end of document .. XX34 to extract RES file}

USES OWindows,WinTypes,WinProcs,Strings;

TYPE TDemoApp=OBJECT(TApplication)
       PROCEDURE InitMainWindow; virtual;
     END;

TYPE PDemoWin = ^TDemoWin;
     TDemoWin = OBJECT(TWindow)
       PROCEDURE Paint(PaintDC : HDC;var PaintInfo : TPaintStruct); virtual;
       PROCEDURE GetWindowClass(var AWndClass : TWndClass); virtual;
     END;

{ Prozedur fuer die normale Abbildung von Bitmpas }
PROCEDURE BmpBlt(DC : HDC;x,y : integer;hbmp : HBitmap);
VAR MemDC        : HDC;
    OldBmp       : HBitmap;
    Bitmap       : TBitmap;
BEGIN
  MemDC:=CreateCompatibleDC(DC);
  OldBmp:=SelectObject(MemDC,hbmp);
  GetObject(hBmp,Sizeof(Bitmap),@Bitmap);
  BitBlt(DC,10,10,Bitmap.bmWidth,Bitmap.bmHeight,MemDC,0,0,SrcCopy);
  SelectObject(MemDC,OldBmp);
  DeleteDC(MemDC);
END;

{ Prozedur fuer die durchsichtige Darstellung }
PROCEDURE BmpTransparentBlt(hDCDest : HDC;x,y : integer;hbmp : HBitmap;rgbTransparent : TColorRef);
{ hDCDest bezeichnet den Zielkontext, x und y die obere linke Ecke der Bitmap;
  hBmp ist ein Handle zu der Bitmap und rgbTransparent bezeichnet die Farbe,
  die bei der Darstellung "durchsichtig" dargestellt werden soll }
VAR hDCSrc            : HDC;
    hDCMask           : HDC;
    Bitmap            : TBitmap;
    hbmTransMask      : HBitmap;
    OldBk             : TColorRef;
    OldCol            : TColorRef;
BEGIN
  GetObject(hBmp,SizeOf(TBitmap),@Bitmap);           { Informationen ueber Bitmap speichern }
  hDCSrc:=CreateCompatibleDC(hDCDest);               { Quellkontext erzeugen }
  hDCMask:=CreateCompatibleDC(hDCDest);              { Kontext fuer MAske erzeugen }
  hbmTransMask:=CreateBitmap(Bitmap.bmWidth,Bitmap.bmHeight,1,1,nil);
  SelectObject(hDCSrc,hbmp);                         { Bitmap im Quellkontext abbilden }
  SelectObject(hDCMask,hbmTransMask);                { }
  SetBkColor(hDCSrc,rgbTransparent);                 { Maske erzeugen }
  BitBlt(hdcMask,0,0,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SrcCopy);
  { mit Maske kombinieren }
  OldBk:=SetBkColor(hDCDest,RGB(255,255,255));
  OldCol:=SetTextColor(hDCDest,RGB(0,0,0));
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SRCInvert);
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCMask,0,0,SRCAnd);
  BitBlt(hDCDest,x,y,Bitmap.bmWidth,Bitmap.bmHeight,hDCSrc,0,0,SRCInvert);
  SetBkColor(hDCDest,OldBk);
  SetTextColor(hDCDest,OldCol);
  { Kontexte freigeben }
  DeleteDC(hDCSrc);
  DeleteDC(hDCMask);
  DeleteDC(hDCDest);
  { Objekte loeschen }
  DeleteObject(hbmTransMask);
END;

{ ================== Methoden des Fensters ===================== }
PROCEDURE TDemoWin.Paint(PaintDC : HDC;var PaintInfo : TPaintStruct);
VAR BmpTransparent   : HBitmap;
    BmpNormal        : HBitmap;
    OldMode          : integer;
BEGIN
  BmpTransparent:=LoadBitmap(hInstance,'BMP_TRANSPARENT');
  BmpNormal:=LoadBitmap(hInstance,'BMP_Normal');
  BmpBlt(PaintDC,10,10,BmpNormal);
  TextOut(PaintDC,50,15,'Normale Darstellung',StrLen('Normale Darstellung'));
  { bildet die Bitmap ganz normal ab }
  BmpTransparentBlt(PaintDC,10,60,BmpTransparent,RGB(0,0,255));
  { bildet die Bitmap ab, ohne Pixel der Farbe RGB(0,0,255) darzustellen }
  OldMode:=SetBkMode(PaintDC,transparent);
  { fuer die Textausgabe wird erst jetzt der Transparent-Modus gesetzt }
  TextOut(PaintDC,50,65,'Transparente Darstellung',StrLen('Transparente Darstellung'));
  SetBkMode(PaintDC,OldMode);
  DeleteObject(BmpTransparent);
  DeleteObject(BmpNormal);
END;

PROCEDURE TDemoWin.GetWindowClass(var AWndClass : TWndClass);
BEGIN
  inherited GetWindowClass(AWndClass);
  AWndClass.hbrBackground:=GetStockObject(LtGray_Brush);
  { fuer dieses Fenster nehmen wir einen grauen HIntergrund, um den
    Effekt sichtbar zu machen }
END;

{ ================== Methoden der Applikation ===================== }
PROCEDURE TDemoApp.InitMainWindow;
BEGIN
  MainWindow:=New(PDemoWin,Init(nil,'Durchsichtige Darstellung von Bitmaps'));
END;

{ *****************   Programm ******************* }

VAR DemoApp  : TDemoApp;

BEGIN
  DemoApp.Init('DemoApp');
  DemoApp.Run;
  DemoApp.Done;
END.

END.

{ {------------------------- snip, snip ----------------------------}

ENCODED BMPTBLT.RES FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
