
Delphi1 & Delphi2.

This unit is to replace QuickReport's Preview Form.

Advantages:
  1. cursor keys can be used to move around the preview page.
  2. [page_up] and [page_down] keys used to move between pages
  3. [home] or [ctrl][page_up] to move to first page
  4. [end] or [ctrl][page_down] to move to last page

  5. automatically fills entire screen (except task bar)


Usage:

  1. Make sure QuickRep is in the uses clause on your MainForm.
  2. Add this Preview unit to your project.
  3. Add the following procedure to your MainForm -
	procedure TMainForm.MyPreview;
	begin
	   FmPreview.ShowModal;
	end;
  4. add -
	QRPrinter.OnPreview := MyPreview;
     to your code (or place it in FormCreate method) before calling -
	YourReport.Quickreport1.preview;


Angus Johnson
ajohnson@rpi.net.au


unit Preview;

interface

uses
  SysUtils, Classes, Controls, Forms, Quickrep, ExtCtrls, Messages,
  StdCtrls, Buttons, WinTypes, WinProcs, Dialogs, Printers,
  IniFiles;

type
  TFmPreview = class(TForm)
	 Panel1: TPanel;
	 QRPreview1: TQRPreview;
	 Label1: TLabel;
	 PrintDialog1: TPrintDialog;
	 bbPrev: TBitBtn;
	 bbNext: TBitBtn;
	 bbZoomOut: TBitBtn;
	 bbZoomW: TBitBtn;
	 bbZoomIn: TBitBtn;
	 bbPrint: TBitBtn;
    bbClose: TBitBtn;
	 procedure FormShow(Sender: TObject);
	 procedure bbZoomOutClick(Sender: TObject);
	 procedure bbZoomWClick(Sender: TObject);
	 procedure bbPrevClick(Sender: TObject);
	 procedure bbNextClick(Sender: TObject);
	 procedure bbPrintClick(Sender: TObject);
	 procedure bbZoomInClick(Sender: TObject);
	 procedure bbCloseClick(Sender: TObject);
	 procedure FormActivate(Sender: TObject);
	 procedure FormClose(Sender: TObject; var Action: TCloseAction);
	 procedure FormKeyDown(Sender: TObject; var Key: Word;
	   Shift: TShiftState);
  private
	 procedure CMDialogKey(var message: TCMDialogKey); message CM_DIALOGKEY;
  public
  end;

var
  FmPreview: TFmPreview;

implementation

uses
  Main;

{$R *.DFM}


procedure TFmPreview.FormShow(Sender: TObject);
begin
	QRPreview1.Zoom := 100; {defaults to ZoomIn}
	Label1.caption := 'Page 1 of ' +inttostr(QRPrinter.PageCount);
	if QRPrinter.PageCount = 1 then bbNext.enabled := false
	else bbNext.enabled := true;
	bbClose.setfocus;
	bbZoomIn.enabled := false;
	bbZoomW.enabled := true;
	bbZoomOut.enabled := true;
end;

procedure TFmPreview.bbZoomOutClick(Sender: TObject);
begin
	QRPreview1.ZoomToFit;
	bbZoomOut.enabled := false;
	bbZoomW.enabled := true;
	bbZoomIn.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbZoomWClick(Sender: TObject);
begin
	QRPreview1.ZoomToWidth;
	bbZoomW.enabled := false;
	bbZoomOut.enabled := true;
	bbZoomIn.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbPrevClick(Sender: TObject);
begin {Previous page}
  if QRPreview1.PageNumber > 1 then
         QRPreview1.PageNumber := QRPreview1.PageNumber-1;
  Label1.caption := 'Page ' + inttostr(QRPreview1.PageNumber)+
                        ' of ' +inttostr(QRPrinter.PageCount);
  bbNext.enabled := true;
  if QRPreview1.PageNumber = 1 then begin
	 bbPrev.enabled := false;
	 bbNext.setfocus;
  end;
end;

procedure TFmPreview.bbNextClick(Sender: TObject);
begin {Next page}
  if QRPreview1.PageNumber < QRPrinter.PageCount then
					QRPreview1.PageNumber := QRPreview1.PageNumber+1;
  Label1.caption := 'Page ' + inttostr(QRPreview1.PageNumber)+
					' of ' +inttostr(QRPrinter.PageCount);
  bbPrev.enabled := true;
  if QRPreview1.PageNumber = QRPrinter.PageCount then begin
	 bbNext.enabled := false;
	 bbPrev.setfocus;
  end;
end;

procedure TFmPreview.bbPrintClick(Sender: TObject);
begin
  {A PrintDialog component can be added to the form with an -
  if not PrintDialog1.execute then exit -
  statement placed here.}
  screen.cursor := crHourglass;
  try
	 QRPrinter.Print;
	 while tag > 1 do begin
	   QRPrinter.Print;
	   tag := tag-1;
	 end;
	 tag := 1;
  finally
	 screen.cursor := crDefault;
  end;
  close;
end;

procedure TFmPreview.bbZoomInClick(Sender: TObject);
begin
	QRPreview1.Zoom := 100;
	bbZoomIn.enabled := false;
	bbZoomW.enabled := true;
	bbZoomOut.enabled := true;
	bbClose.setfocus;
end;

procedure TFmPreview.bbCloseClick(Sender: TObject);
begin
	close;
end;

procedure TFmPreview.FormActivate(Sender: TObject);
var
  TrayHwnd: HWnd;
  Rect: TRect;
  CxFullScreen, CyFullScreen, CyCaption: integer;
begin
  {size the form to fill the screen...}
  TrayHwnd := FindWindow('Shell_TrayWnd','');
  if TrayHwnd = 0 then {not Win95 screen}
	 WindowState := wsMaximized
  else begin
	 GetWindowRect(TrayHwnd,Rect);
	 CxFullScreen    := GetSystemMetrics(SM_CXFULLSCREEN);
	 CyFullScreen    := GetSystemMetrics(SM_CYFULLSCREEN);
	 CyCaption       := GetSystemMetrics(SM_CYCAPTION);

	 {NOTE: Position must equal either poDefault or poDesigned,
	  and WindowState = wsNormal}
	 Top      := 0;
	 Left     := 0;
	 Width    := CxFullScreen;
	 Height   := CyFullScreen + CyCaption;

	 if (Rect.Top < 0) and (Rect.Left < 0) then begin
	   {Taskbar on either top or left}
	   if Rect.Right > Rect.Bottom then {Taskbar on top}
		 Top  := Rect.Bottom
	   else {Taskbar on left}
		 Left := Rect.Right;
	 end;
  end;
  bbClose.left := width - 76;
  bbPrint.left := width - 144;
end;

procedure TFmPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  QRPreview1.PageNumber := 1; {this is necessary if reopening form!!!?}
  bbPrev.enabled := false;
  QRPreview1.HorzScrollbar.Position := 0;
  QRPreview1.VertScrollbar.Position := 0;
end;

procedure TFmPreview.CMDialogKey(var message: TCMDialogKey);
begin {INTERCEPTS ARROW KEYS INORDER TO MOVE AROUND PAGE}
  with message do
	 case CharCode of
	   VK_LEFT: begin
		 with QRPreview1.HorzScrollbar do Position := Position -50;
		 exit;
		 end;
		VK_RIGHT: begin
		 with QRPreview1.HorzScrollbar do Position := Position +50;
		 exit;
		 end;
		VK_UP: begin
		 with QRPreview1.VertScrollbar do Position := Position -50;
		 exit;
		 end;
		VK_DOWN: begin
		 with QRPreview1.VertScrollbar do Position := Position +50;
		 exit;
		 end;
	 end;
  inherited;
end;

procedure TFmPreview.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin {INTERCEPTS [PG_UP],[PG_DN], [CTRL][PG_UP],[CTRL][PG_DN], [HOME],[END]}
  if (((Key = VK_NEXT) and (Shift = [ssCtrl])) or (Key = VK_END))
											and bbNext.enabled then begin
	 QRPreview1.PageNumber := QRPrinter.PageCount; {GOTO LAST PAGE}
	 Label1.caption := 'Page ' + inttostr(QRPrinter.PageCount)+
					  ' of ' +inttostr(QRPrinter.PageCount);
	 bbPrev.enabled := true;
	 bbNext.enabled := false;
	 bbPrev.setfocus;
	 end
  else if (((Key = VK_PRIOR) and (Shift = [ssCtrl])) or (Key = VK_HOME))
											 and bbPrev.enabled then begin
	 QRPreview1.PageNumber := 1; {GOTO FIRST PAGE}
	 Label1.caption := 'Page 1' +
					  ' of ' +inttostr(QRPrinter.PageCount);
	 bbPrev.enabled := false;
	 bbNext.enabled := true;
	 bbNext.setfocus;
	 end
  else if (Key = VK_NEXT) and bbNext.enabled then bbNextClick(Sender)
  else if (Key = VK_PRIOR) and bbPrev.enabled then bbPrevClick(Sender);
end;

end.

{ ------------------------- snip, snip ----------------------------}

ENCODED PREVIEW.DFM FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
