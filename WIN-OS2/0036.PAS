{
From: mav@dseg.ti.com (Michael Vincze)

>I am trying to put together an owner drawn list box that has it's own
>strings. (i.e. Style := Style AND NOT lbs_HasStrings) Windows never calls
>my DrawItem method. I think it may have something to do with the fact
>that I do not know how to tell windows how many items there are in the
>list box. (Maybe it thinks there are none... *shrug*)
>
>If anyone has had this problem, or has knows where I can get source
>examples of owner-drawn list boxes that have their own strings, please
>let me know.

Included is an example of an owner drawn list box.  The example is in
two parts:  "ownlist.pas", and "ownlist.res".  The resource file has
been translated with uuencode.

{ Author:   Michael Vincze  12/27/93                              }
{                                                                 }
{ Purpose:  Shows how to create an owner drawn list box.          }
{                                                                 }
{ Usage:    Simply run.                                           }

program OwnListBox;

uses
  WinCrt,
  BWCC,
  Strings,
  WinTypes,
  WinProcs,
  Objects,
  OWindows,
  ODialogs;

{$R OwnList}

const
  ApplicationName: PChar = 'Owner Draw List Box';

  wListBoxId = 200;    { ID of OwnerDrawn ListBox Control }
  wNumItems  = 12;     { Number of items added to ListBox }

type

  PODListBox = ^TODListBox;
  TODListBox = object (TListBox)
    hIcon1, hIcon2: HICON;
    constructor InitResource  (AParent: PWindowsObject; ResourceID: Integer);
    destructor  Done; virtual;
    procedure   ODADrawEntire (DrawItemStruct: PDrawItemStruct);
    procedure   ODAFocus      (DrawItemStruct: PDrawItemStruct);
    procedure   ODASelect     (DrawItemStruct: PDrawItemStruct);
    procedure   DrawEntry     (DrawItemStruct: PDrawItemStruct);
    procedure   DrawSelf      (DrawItemStruct: PDrawItemStruct);
    end;

  TTemplateApplication = object (TApplication)
    procedure InitMainWindow; virtual;
    end;

  PTemplateWindow = ^TTemplateWindow;
  TTemplateWindow = object (TDlgWindow)
    AnOwnListBox: PODListBox;
    constructor Init (AParent: PWindowsObject; ATitle: PChar);
    procedure   SetupWindow; virtual;
    function    GetClassName : PChar; virtual;
    destructor  Done; virtual;
    procedure   WMMeasureItem (var Msg: TMessage); virtual wm_First +
wm_MeasureItem;
    procedure   WMDrawItem    (var Msg: TMessage); virtual wm_First +
wm_DrawItem;
    end;

constructor TODListBox.InitResource (AParent: PWindowsObject; ResourceID:
Integer);
begin
inherited InitResource (AParent, ResourceId);
hIcon1 := LoadIcon (0, idi_Exclamation);
{
hIcon2 := LoadIcon (0, idi_Question);
}
hIcon2 := LoadIcon (hInstance, 'icon_1')
end;

destructor TODListBox.Done;
begin
inherited Done;
DestroyIcon (hIcon2);
end;

procedure TODListBox.ODADrawEntire (DrawItemStruct: PDrawItemStruct);
begin
DrawEntry (DrawItemStruct);
if (DrawItemStruct^.itemState and ods_Focus) <> 0 then
  DrawFocusRect (DrawItemStruct^.hDC, DrawItemStruct^.rcItem);
end;

procedure TODListBox.ODAFocus (DrawItemStruct: PDrawItemStruct);
begin
DrawFocusRect (DrawItemStruct^.hDC, DrawItemStruct^.rcItem);
end;

procedure TODListBox.ODASelect (DrawItemStruct: PDrawItemStruct);
begin
DrawEntry (DrawItemStruct);
if (DrawItemStruct^.itemState and ods_focus) <> 0 then
  DrawFocusRect (DrawItemStruct^.hDC, DrawItemStruct^.rcItem);
end;

procedure TODListBox.DrawSelf (DrawItemStruct: PDrawItemStruct);
begin
with DrawItemStruct^ do
  begin
  if (itemAction and oda_DrawEntire) <> 0 then
    ODADrawEntire (DrawItemStruct)
  else if (itemAction and oda_Focus) <> 0 then
    ODAFocus (DrawItemStruct)
  else if (itemAction and oda_Select) <> 0 then
    ODASelect (DrawItemStruct)
  end;
end;

procedure TODListBox.DrawEntry (DrawItemStruct: PDrawItemStruct);
var
  dwColor : Word;
  szString: array [0..100] of Char;
  TextRect: TRect;
  bkColor : LongInt;
begin
wvsprintf (szString, 'This is ListBox Entry %d', DrawItemStruct^.itemID );
dwColor := GetTextColor (DrawItemStruct^.hDC);
CopyRect (TextRect, DrawItemStruct^.rcItem);
Inc (TextRect.Left, 50);

{
Should create a logbrush that is the background and then fill
if in appropriately.

FillRect (DrawItemStruct^.hDC, DrawItemStruct^.rcItem, GetStockObject
(gray_brush));
}
if (DrawItemStruct^.itemState and ODS_SELECTED) <> 0 then
  begin
  SetTextColor (DrawItemStruct^.hDC,  RGB ($ff,0,0));
  if (hIcon1) <> 0 then
    DrawIcon (DrawItemStruct^.hDC,
              DrawItemStruct^.rcItem.left+10,
              DrawItemStruct^.rcItem.top,
              hIcon1);
  end
else
  begin
  if (hIcon2) <> 0 then
    DrawIcon (DrawItemStruct^.hDC,
              DrawItemStruct^.rcItem.left+10,
              DrawItemStruct^.rcItem.top,
              hIcon2);
  end;
DrawText (DrawItemStruct^.hDC,
          szString,
          StrLen (szString),
          TextRect,
          DT_SINGLELINE or DT_VCENTER or DT_LEFT);

SetTextColor (DrawItemStruct^.hDC, dwColor);
end;






procedure TTemplateApplication.InitMainWindow;
begin
MainWindow := New (PTemplateWindow, Init (nil, 'MainDialog'));
end;

constructor TTemplateWindow.Init (AParent: PWindowsObject; ATitle: PChar);
begin
inherited Init (AParent, ATitle);
AnOwnListBox := New (PODListBox, InitResource (@Self, wListBoxId));
end;

function TTemplateWindow.GetClassName;
begin GetClassName := 'BorDlg' end;

destructor TTemplateWindow.Done;
begin
inherited Done;
end;

procedure TTemplateWindow.SetupWindow;
var
  I: Word;
begin
inherited SetupWindow;
for I :=0 to wNumItems - 1 do
  AnOwnListBox^.AddString (MAKEINTRESOURCE( i ));
end;

procedure TTemplateWindow.WMMeasureItem (var Msg: TMessage);
var
  lpMeasureItem: PMEASUREITEMSTRUCT;
begin
lpMeasureItem := PMEASUREITEMSTRUCT (Msg.LParam);

if (lpMeasureItem^.CtlType = ODT_LISTBOX) and (lpMeasureItem^.CtlID =
wListBoxId) then
  lpMeasureItem^.itemHeight := GetSystemMetrics (SM_CYICON)
else
  DefWndProc (Msg);
end;

procedure TTemplateWindow.WMDrawItem (var Msg: TMessage);
begin
if (PDrawItemStruct (Msg.lParam)^.CtlId) = wListBoxId then
  AnOwnListBox^.DrawSelf (PDrawItemStruct (Msg.lParam));
Msg.Result := 1;
end;

var
  Application:TTemplateApplication;

begin
Application.Init (ApplicationName);
Application.Run;
Application.Done;
end.

{---------- snip ---------- snip ---------- snip ---------- snip ----------}

OWNLIST.RES WAS REMOVED.  IT HAS A DECODE ERROR.  SEE THE PAGE ON THE
ATTACHMENT LINK.
{---------- end ---------- end ---------- end ---------- end ----------}
