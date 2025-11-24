{ NOTE DCR AND DEMO located at the END of this unit }

{-----------------------------------------------------------------------------}
{ A component to wrap the Win95 PageSetupDlg common dialog API function.      }
{ Borland seems to have forgotten this new common dialog in Delphi 2.0.       }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                         }
{ This component can be freely used and distributed in commercial and private }
{ environments, provided this notice is not modified in any way and there is  }
{ no charge for it other than nominal handling fees.  Contact me directly for }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at bstowers@pobox.com or 72733,3374 on CompuServe.                          }
{ The lateset version will always be available on the web at:                 }
{   http://www.pobox.com/~bstowers/delphi/                                    }
{-----------------------------------------------------------------------------}
{ Date last modified:  08/27/96                                               }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TPageSetupDialog v1.00                                                      }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A component to wrap the PageSetupDlg API function that Borland forgot.    }
{   It is a common dialog available on the Win95 platform, so it can not be   }
{   used with Delphi 1.0.                                                     }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  + Initial release.                                                   }
{ ----------------------------------------------------------------------------}

unit PgSetup;

interface

{$IFNDEF WIN32}
  ERROR!  This unit only available for Delphi 2.0!!!
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CommDlg, DsgnIntf;

type
  TPageSetupOption = (
       poDefaultMinMargins, poDisableMargins, poDisableOrientation,
       poDisablePagePainting, poDisablePaper, poDisablePrinter, poNoWarning, poShowHelp
     );
  TPageSetupOptions = set of TPageSetupOption;
  TPSPaperType = (ptPaper, ptEnvelope);
  TPSPaperOrientation = (poPortrait, poLandscape);
  TPSPrinterType = (ptDotMatrix, ptHPPCL);
  TPSPaintWhat = (pwFullPage, pwMinimumMargins, pwMargins,
                  pwGreekText, pwEnvStamp, pwYAFullPage);

  TPSMeasurements = (pmMillimeters, pmInches);
  TPSPrinterEvent = procedure(Sender: TObject; Wnd: HWND) of object;

  { PPSDlgData is simply redeclared as PPageSetupDlg (COMMDLG.PAS) to prevent compile }
  { errors in units that have this event.  They won't compile unless you add CommDlg  }
  { to their units.  This circumvents the problem.                                    }
  PPSDlgData = ^TPSDlgData;
  TPSDlgData = TPageSetupDlg;
  { PaperSize: See DEVMODE help topic, dmPaperSize member. DMPAPER_* constants. }
  TPSInitPaintPageEvent = function(Sender: TObject; PaperSize: short;
              PaperType: TPSPaperType; PaperOrientation: TPSPaperOrientation;
              PrinterType: TPSPrinterType; pSetupData: PPSDlgData): boolean of object;
  TPSPaintPageEvent = function(Sender: TObject; PaintWhat: TPSPaintWhat;
              Canvas: TCanvas; Rect: TRect): boolean of object;


  TPageSetupDialog = class(TCommonDialog)
  private
    FOptions: TPageSetupOptions;
    FCustomData: LPARAM;
    FPaperSize: TPoint;
    FMinimumMargins: TRect;
    FMargins: TRect;
    FMeasurements: TPSMeasurements;
    FOnPrinter: TPSPrinterEvent;
    FOnInitPaintPage: TPSInitPaintPageEvent;
    FOnPaintPage: TPSPaintPageEvent;

    function DoPrinter(Wnd: HWND): boolean;
    function DoExecute(Func: pointer): boolean;
  protected
    function Printer(Wnd: HWND): boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: boolean; virtual;
    { It is the user's responsibility to clean up this pointer if necessary. }
    property CustomData: LPARAM
        read FCustomData
        write FCustomData;

    { These should be published, but need Property Editors for TPoint and TRect.  As }
    { best I can tell, there is no way to do that, since they need RTTI, and that is }
    { not available for record types.  Bummer.                                       }
    { Also, all of these rects return sizes that need to be divided by 1000.  For    }
    { example, PaperSize.X would be 8500 for 8.5 inch paper.  Maybe I should make a  }
    { TSingleRect and TSinglePoint and return the actual single value, but the API   }
    { returns them to me that way, and I'm lazy by default. :)                       }
    property PaperSize: TPoint
        read FPaperSize
        write FPaperSize;
    property MinimumMargins: TRect
        read FMinimumMargins
        write FMinimumMargins;
    property Margins: TRect
        read FMargins
        write FMargins;

  published
    property Options: TPageSetupOptions
        read FOptions
        write FOptions
        default [poDefaultMinMargins, poShowHelp];
    property Measurements: TPSMeasurements
        read FMeasurements
        write FMeasurements
        default pmInches;

    { Events }
    property OnPrinter: TPSPrinterEvent
        read FOnPrinter
        write FOnPrinter;
    property OnInitPaintPage: TPSInitPaintPageEvent
        read FOnInitPaintPage
        write FOnInitPaintPage;
    property OnPaintPage: TPSPaintPageEvent
        read FOnPaintPage
        write FOnPaintPage;
  end;

procedure Register;

implementation

uses Printers;

const
  IDPRINTERBTN = $0402;

{ Private globals }
var
  HelpMsg: Integer;
  HookCtl3D: boolean;


{ Center the given window on the screen }
procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
begin
  GetWindowRect(Wnd, Rect);
  SetWindowPos(Wnd, 0,
    (GetSystemMetrics(SM_CXSCREEN) - Rect.Right + Rect.Left) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - Rect.Bottom + Rect.Top) div 3,
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }
function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  case Msg of
    WM_INITDIALOG:
      begin
        if HookCtl3D then
        begin
          Subclass3DDlg(Wnd, CTL3D_ALL);
          SetAutoSubClass(True);
        end;
        CenterWindow(Wnd);
        Result := 1;
      end;
    WM_DESTROY:
      if HookCtl3D then SetAutoSubClass(False);
  end;
end;

var
  PageSetupDialog: TPageSetupDialog;

function PageSetupDialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM;
                             LParam: LPARAM): UINT; stdcall;
const
  PagePaintWhat: array[WM_PSD_FULLPAGERECT..
                       WM_PSD_YAFULLPAGERECT] of TPSPaintWhat = (
    pwFullPage, pwMinimumMargins, pwMargins,
    pwGreekText, pwEnvStamp, pwYAFullPage
  );
  PRINTER_MASK = $00000002;
  ORIENT_MASK  = $00000004;
  PAPER_MASK   = $00000008;
var
  PaperData: word;
  Paper: TPSPaperType;
  Orient: TPSPaperOrientation;
  Printer: TPSPrinterType;
  PaintRect: TRect;
  PaintCanvas: TCanvas;
begin
  if (Msg = WM_COMMAND) and (LongRec(WParam).Lo = IDPRINTERBTN) and
     (LongRec(WParam).Hi = BN_CLICKED) then begin
    // if hander is assigned, use it.  If not, let system do it.
    Result := ord(PageSetupDialog.DoPrinter(Wnd));
  end else begin
    if assigned(PageSetupDialog.FOnInitPaintPage) and
           assigned(PageSetupDialog.FOnPaintPage) then begin
      case Msg of
        WM_PSD_PAGESETUPDLG:
          begin
            PaperData := HiWord(WParam);
            if (PaperData AND PAPER_MASK > 0) then
              Paper := ptEnvelope
            else
              Paper := ptPaper;
            if (PaperData AND ORIENT_MASK > 0) then
              Orient := poPortrait
            else
              Orient := poLandscape;
            if (PaperData AND PAPER_MASK > 0) then
              Printer := ptHPPCL
            else
              Printer := ptDotMatrix;
            Result := Ord(PageSetupDialog.FOnInitPaintPage(PageSetupDialog,
                LoWord(WParam), Paper, Orient, Printer, PPSDlgData(LParam)));
          end;
        WM_PSD_FULLPAGERECT,
        WM_PSD_MINMARGINRECT,
        WM_PSD_MARGINRECT,
        WM_PSD_GREEKTEXTRECT,
        WM_PSD_ENVSTAMPRECT,
        WM_PSD_YAFULLPAGERECT:
          begin
            if LParam <> 0 then
              PaintRect := PRect(LParam)^
            else
              PaintRect := Rect(0,0,0,0);
            PaintCanvas := TCanvas.Create;
            PaintCanvas.Handle := HDC(WParam);
            try
              Result := Ord(PageSetupDialog.FOnPaintPage(PageSetupDialog,
                                   PagePaintWhat[Msg], PaintCanvas, PaintRect));
            finally
              PaintCanvas.Free;   { This better not be deleting the DC! }
            end;
          end;
      else
        Result := DialogHook(Wnd, Msg, wParam, lParam);
      end;
    end else
      Result := DialogHook(Wnd, Msg, wParam, lParam);
  end;
end;


constructor TPageSetupDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [poDefaultMinMargins, poShowHelp];
  FOnPrinter := NIL;
  FOnInitPaintPage := NIL;
  FOnPaintPage := NIL;
  FCustomData := 0;
  FPaperSize := Point(0,0);
  FMinimumMargins := Rect(0,0,0,0);
  FMargins := Rect(1000,1000,1000,1000);
  FMeasurements := pmInches;
end;

destructor TPageSetupDialog.Destroy;
begin
  inherited Destroy;
end;


procedure GetPrinter(var DeviceMode, DeviceNames: THandle);
var
  Device, Driver, Port: array[0..79] of char;
  DevNames: PDevNames;
  Offset: PChar;
begin
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
  if DeviceMode <> 0 then
  begin
    DeviceNames := GlobalAlloc(GHND, SizeOf(TDevNames) +
     StrLen(Device) + StrLen(Driver) + StrLen(Port) + 3);
    DevNames := PDevNames(GlobalLock(DeviceNames));
    try
      Offset := PChar(DevNames) + SizeOf(TDevnames);
      with DevNames^ do
      begin
        wDriverOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Driver) + 1;
        wDeviceOffset := Longint(Offset) - Longint(DevNames);
        Offset := StrECopy(Offset, Device) + 1;
        wOutputOffset := Longint(Offset) - Longint(DevNames);;
        StrCopy(Offset, Port);
      end;
    finally
      GlobalUnlock(DeviceNames);
    end;
  end;
end;

procedure SetPrinter(DeviceMode, DeviceNames: THandle);
var
  DevNames: PDevNames;
begin
  DevNames := PDevNames(GlobalLock(DeviceNames));
  try
    with DevNames^ do
      Printer.SetPrinter(PChar(DevNames) + wDeviceOffset,
        PChar(DevNames) + wDriverOffset,
        PChar(DevNames) + wOutputOffset, DeviceMode);
  finally
    GlobalUnlock(DeviceNames);
    GlobalFree(DeviceNames);
  end;
end;

function CopyData(Handle: THandle): THandle;
var
  Src, Dest: PChar;
  Size: Integer;
begin
  if Handle <> 0 then
  begin
    Size := GlobalSize(Handle);
    Result := GlobalAlloc(GHND, Size);
    if Result <> 0 then
      try
        Src := GlobalLock(Handle);
        Dest := GlobalLock(Result);
        if (Src <> nil) and (Dest <> nil) then Move(Src^, Dest^, Size);
      finally
        GlobalUnlock(Handle);
        GlobalUnlock(Result);
      end
  end
  else Result := 0;
end;

function TPageSetupDialog.DoExecute(Func: pointer): boolean;
const
  PageSetupOptions: array [TPageSetupOption] of DWORD = (
      PSD_DEFAULTMINMARGINS, PSD_DISABLEMARGINS, PSD_DISABLEORIENTATION,
      PSD_DISABLEPAGEPAINTING, PSD_DISABLEPAPER, PSD_DISABLEPRINTER,
      PSD_NOWARNING, PSD_SHOWHELP
    );
  PageSetupMeasurements: array [TPSMeasurements] of DWORD = (
      PSD_INHUNDREDTHSOFMILLIMETERS, PSD_INTHOUSANDTHSOFINCHES
    );
var
  Option: TPageSetupOption;
  PageSetup: TPageSetupDlg;
  SavePageSetupDialog: TPageSetupDialog;
  DevHandle: THandle;
begin
  FillChar(PageSetup, SizeOf(PageSetup), 0);
  with PageSetup do
  try
    lStructSize := SizeOf(TPageSetupDlg);
    hInstance := System.HInstance;

    Flags := PSD_MARGINS;

    if assigned(FOnPrinter) or assigned(FOnInitPaintPage) or assigned(FOnPaintPage) then begin
      Flags := Flags or PSD_ENABLEPAGESETUPHOOK;
      lpfnPageSetupHook := PageSetupDialogHook;
    end;

    for Option := Low(Option) to High(Option) do
      if Option in FOptions then
        Flags := Flags OR PageSetupOptions[Option];
    Flags := Flags OR PageSetupMeasurements[FMeasurements];
{    if not assigned(FOnPrinter) then
      Flags := Flags OR PSD_DISABLEPRINTER;}
    if assigned(FOnInitPaintPage) and assigned(FOnPaintPage) then begin
      Flags := Flags OR PSD_ENABLEPAGEPAINTHOOK;
      lpfnPagePaintHook := PageSetupDialogHook;
    end;

    hWndOwner := Application.Handle;
    GetPrinter(DevHandle, hDevNames);
    hDevMode := CopyData(DevHandle);
    HookCtl3D := Ctl3D;
    lCustData := FCustomData;
    ptPaperSize := FPaperSize;
    rtMinMargin := FMinimumMargins;
    rtMargin := FMargins;

    SavePageSetupDialog := PageSetupDialog;
    PageSetupDialog := Self;
    Result := TaskModalDialog(Func, PageSetup);
    PageSetupDialog := SavePageSetupDialog;

    if Result then begin
      FPaperSize := ptPaperSize;
      FMinimumMargins := rtMinMargin;
      FMargins := rtMargin;
      SetPrinter(hDevMode, hDevNames);
    end else begin
      if hDevMode <> 0 then GlobalFree(hDevMode);
      if hDevNames <> 0 then GlobalFree(hDevNames);
    end;
  finally
    { Nothing yet }
  end;
end;

function TPageSetupDialog.Execute: boolean;
begin
  Result := DoExecute(@PageSetupDlg);
end;

function TPageSetupDialog.Printer(Wnd: HWND): boolean;
begin
  Result :=  assigned(FOnPrinter);
  if Result then
    FOnPrinter(Self, Wnd);
end;

function TPageSetupDialog.DoPrinter(Wnd: HWND): boolean;
begin
  try
    Result := Printer(Wnd);
  except
    Result := FALSE;
    Application.HandleException(Self);
  end;
end;


procedure Register;
begin
  { You may prefer it on the Dialogs page, I like it on Win95 because it is }
  { only available on Win95.                                                }
  RegisterComponents('Win95', [TPageSetupDialog]);
end;


{ Initialization and cleanup }

procedure InitGlobals;
begin
  HelpMsg := RegisterWindowMessage(HelpMsgString);
end;

initialization
  InitGlobals;
finalization
  { Nothing }
end.

{ ------------------------- snip, snip ----------------------------}

ENCODED PGSETUP.DCR FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{------------------------- snip, snip ----------------------------}

ENCODED DEMO.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
