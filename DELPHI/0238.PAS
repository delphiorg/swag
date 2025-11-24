

{
JustOne v1.1 - A Delphi Component
By: Steven L. Keyser
    email: 71214,3117@compuserve.com

JustOne v1.1 - Added the ABOUT property
 (1/14/96)	 - Eliminated the AllowMultInst property
             - Eliminated the EXECUTE	property
             - Added JUSTONE.HLP
             - Added JUSTONE.KWF

             Notes: The ABOUT property was added simply as a learning
             exercise.  The EXECUTE property was removed due to an
             improvement in the component's design.  With special
             thanks to Russ Chinoy, the JustOne component no
             longer requires any code to be added to the user's
             application.  Dropping the JustOne component onto the startup
             form is all that is required now to make JustOne work for you.

JustOne v1.0 - The basic stuff.
 (Oct '95)

    Purpose:	JustOne is a component which makes it easy to limit the
    number of your application's instances to just one.  If a second
    instance of your application starts, the first instance is brought
    to the front and given the focus (or restored if it was minimized
    to an icon).  The second instance then halts.

    Credit where credit is due...

    Some of the source code for this component came from a Help file
    I downloaded from the Delphi Forum on CompuServe (LDELPHI.ZIP).  This
    Help file, called Lloyd's Delphi Notes (Lloyd Linklater), lists many
    tips on using Delphi.  One of the items addressed is how to add code
    to your application which will allow just one instance to run.  In the
    Help file, that code is further credited to Pat Ritchey.

    I took that snippet of code and put it into an easily re-usable
    component.

    Additional ideas came from Russ Chinoy (RC Software) on a way to
    have JustOne perform its function without the user having to put
    any code into their application.

    JustOne is released as Freeware.  If you use it, you do so at your
    own risk.  Feel free to modify this source code to suit your own
    purposes.  If you enhance JustOne, I'd like to see your work.
}
unit Justone;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DsgnIntf;

type
	TMyDataType = record
	Name : string;
end;

type
  TJustOne = class(TComponent)
  private
    FAbout:	string;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure GoToPreviousInstance;
    procedure ShowAbout;
  published
    property About: string read FAbout write FAbout stored False;
	end;

procedure Register;

type
  PHWND = ^HWND;
  function EnumFunc(Wnd:HWND; TargetWindow:PHWND): boolean; export;

implementation

{########################################################################}
type
  TAboutProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue:string; override;
  end;

{########################################################################}
procedure TAboutProperty.Edit;
{Invoke the about dialog when clicking on ... in the Object Inspector}
begin
  TJustOne(GetComponent(0)).ShowAbout;
end;

{########################################################################}
function TAboutProperty.GetAttributes: TPropertyAttributes;
{Make settings for just displaying a string in the ABOUT property in the
Object Inspector}
begin
  GetAttributes := [paDialog, paReadOnly];
end;

{########################################################################}
function TAboutProperty.GetValue: String;
{Text in the Object Inspector for the ABOUT property}
begin
  GetValue := '(About)';
end;

{########################################################################}
procedure TJustOne.ShowAbout;
var
	msg: string;
const
	carriage_return = chr(13);
  copyright_symbol = chr(169);
begin
	msg := 'JustOne  v1.1';
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'A Freeware component');
  AppendStr(msg, carriage_return);
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'Copyright ');
  AppendStr(msg, copyright_symbol);
  AppendStr(msg, ' 1995, 1996 by Steven L. Keyser');
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'e-mail 71214.3117@compuserve.com');
  AppendStr(msg, carriage_return);
  ShowMessage(msg);
end;

{########################################################################}
procedure Register;
{If you want, replace 'SLicK' with whichever component page you want
JustOne to show up on.}
begin
  RegisterComponents('SLicK', [TJustOne]);
  RegisterPropertyEditor(TypeInfo(String), TJustOne, 'About',
  	TAboutProperty);
end;

{########################################################################}
function EnumFunc(Wnd:HWND; TargetWindow:PHWND): boolean;
var
  ClassName : array[0..30] of char;
begin
  result := TRUE;
  if GetWindowWord(Wnd,GWW_HINSTANCE) = hPrevInst then
     begin
       GetClassName(Wnd,ClassName,30);
       if StrIComp(ClassName,'TApplication') = 0 then
         begin
           TargetWindow^ := Wnd;
           result := FALSE;
         end;
     end;
end;

{########################################################################}
procedure TJustOne.GotoPreviousInstance;
var
  PrevInstWnd : HWND;
begin
  PrevInstWnd := 0;
  EnumWindows(@EnumFunc,longint(@PrevInstWnd));

  if PrevInstWnd <> 0 then
   	if IsIconic(PrevInstWnd) then
      ShowWindow(PrevInstWnd,SW_RESTORE)
   	else
      BringWindowToTop(PrevInstWnd);
end;

{########################################################################}
constructor TJustOne.Create(AOwner:TComponent);
begin
	inherited Create(AOwner);
	if hPrevInst <> 0 then
    begin
      GotoPreviousInstance;
      halt;
    end;
end;

{########################################################################}
destructor TJustOne.Destroy;
begin
  inherited Destroy;
end;

{########################################################################}
end.

{ {------------------------- snip, snip ----------------------------}

ENCODED JUSTONE.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
