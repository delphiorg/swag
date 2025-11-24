unit ColorApp;

{ see the DEMO unit at the end of this code snipet }
{
 COLORAPP.PAS v1.00 -- Unit for making "pretty" applications

 Written by Scott F. Earnest (scott@whiplash.res.cmu.edu)


 This unit defines three objects:

   TColorApplication -- A simple descendant of TApplication.  It uses color
     text screen images in place of the common "hash" backdrop.
   TColorDesktop -- An intermediate object, direct descendant of TDesktop.
   TColorBackground -- A descendant of TBackground, this object is the one
     that actually manages color images.


 Credits to:

 - Unknown author of source that appears in SWAG -- this is my effort to take
   that badly kludged source and make a valid, functional tool from it.

 - Portions of this code Copyright (C) 1992 Borland International (I had to
   cheat the Init method of TColorApplication to keep it from zeroing out
   the proper pointers.


 Bug reports, upgrade suggestions, comments, flames, humble cash contri-
 butions to author.  Standard disclaimers apply.  Free for general use, but
 if you use this code in a shareware or commercial product, please contact
 me to offer some sort of compensation; i.e., if you profit from this, I'd
 better profit, too!

 Please do not add this code to the SWAG collection.  It will be distributed
 in package form via FTP sites.
}

interface

uses
  App, Objects;

{ -- Public Object Declarations ------------------------------------------- }

type
  PColorApplication = ^TColorApplication;
  TColorApplication = object(TApplication)
    Image25, Image43, Image50 : pointer;
    Len25, Len43, Len50 : word;
    constructor Init;
    destructor Done; virtual;
    procedure InitDesktop; virtual;
    procedure FreeImages; virtual;
    procedure LoadImages; virtual;
  end;

type
  PColorDesktop = ^TColorDesktop;
  TColorDesktop = object(TDesktop)
    Image25, Image43, Image50 : pointer;
    Len25, Len43, Len50 : word;
    constructor Init (var Bounds : TRect;
                      i25, i43, i50 : pointer; l25, l43, l50 : word);
    procedure InitBackground; virtual;
  end;

type
  PColorBackground = ^TColorBackground;
  TColorBackground = object(TBackground)
    Background25,
    Background43,
    Background50 : pointer;
    BGLen25, BGLen43, BGLen50 : word;
    constructor Init (var Bounds : TRect; i25, i43, i50 : pointer;
                      l25, l43, l50 : word);
    procedure Draw; virtual;
  end;

implementation

uses
  Views, Memory, Drivers, HistList;

{ -- TColorApplication ---------------------------------------------------- }

constructor TColorApplication.init;

var
  R : TRect;

begin
  {App.TApplication.Init:}
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  InitHistory;
  {End App.TApplication.Init}

  {App.TProgram.Init:}
  Application := @Self;
  InitScreen;
  R.Assign(0, 0, ScreenWidth, ScreenHeight);
  TGroup.Init(R);
  State := sfVisible + sfSelected + sfFocused + sfModal + sfExposed;
  Options := 0;
  Buffer := ScreenBuffer;
  LoadImages; {This line inserted.}
  InitDesktop;
  InitStatusLine;
  InitMenuBar;
  if Desktop <> nil then Insert(Desktop);
  if StatusLine <> nil then Insert(StatusLine);
  if MenuBar <> nil then Insert(MenuBar);
  {End App.TProgram.Init}
end;

destructor TColorApplication.Done;

begin
  FreeImages;
  inherited done;
end;

procedure TColorApplication.FreeImages;

{
 Use this method to free loaded images if they are loaded onto the heap.
 Default action is to do nothing.
}

begin
end;

procedure TColorApplication.InitDesktop;

var
  R : TRect;

begin
  GetExtent(R);
  inc(R.A.Y);
  dec(R.B.Y);
  Desktop := new(PColorDesktop,init(R,image25,image43,image50,
                                    len25,len43,len50));
end;

procedure TColorApplication.LoadImages;

{
 Use this method to allocate and/or load the image buffers and set the
 proper lengths.
}

begin
  Abstract;
end;

{ -- TColorDesktop -------------------------------------------------------- }

constructor TColorDesktop.Init (var Bounds : TRect;
                                i25, i43, i50 : pointer;
                                l25, l43, l50 : word);

begin
  TGroup.Init(Bounds);
  GrowMode := gfGrowHiX or gfGrowHiY;
  image25 := i25;
  image43 := i43;
  image50 := i50;
  len25 := l25;
  len43 := l43;
  len50 := l50;
  InitBackground;
  if Background <> nil then
    Insert(Background);
end;

procedure TColorDesktop.InitBackground;

var
  R : TRect;

begin
  GetExtent(R);
  Background := new (PColorBackground,init(R,image25,image43,image50,
                                           len25,len43,len50));
end;

{ -- TColorBackground ----------------------------------------------------- }

constructor TColorBackground.Init (var Bounds : TRect;
                                   i25, i43, i50 : pointer;
                                   l25, l43, l50 : word);

begin
  inherited Init (Bounds,#176);
  Background25 := i25;
  Background43 := i43;
  Background50 := i50;
  BGLen25 := l25;
  BGLen43 := l43;
  BGLen50 := l50;
end;

procedure TColorBackground.Draw;

var
  Background : pointer;
  R : TRect;

begin
  getextent (R);
  case R.B.Y of
    23 .. 25 : BackGround := Background25;
    41 .. 43 : BackGround := Background43;
    48 .. 50 : BackGround := Background50;
  else
    BackGround := Background25;
  end;
  WriteBuf (0,0,R.B.X,R.B.Y,Background^);
end;

end.

{ -----------------------   DEMO ----------------------------- }
program Colordesk;

{
 CA-DEMO.PAS -- Demonstration for the ColorApp Unit

 Written by Scott F. Earnest (scott@whiplash.res.cmu.edu)


 It's almost the same as a normal application!
}

uses
  ColorApp, App, Objects, Views, Menus, Drivers, Msgbox, Dialogs;

{Command constants}

const
  cmOptionsVideo = 1501;
  cmMessageHello = 1502;
  cmAppAbout     = 1503;

{These are the raw screen images}

procedure data_25_lines; external;
{$L LINES_25}  { OBJ code  -- extract XX3402 OBJ files at end of this snipet}

procedure data_43_lines; external;
{$L LINES_43}

procedure data_50_lines; external;
{$L LINES_50}

{ -- Application Object --------------------------------------------------- }

type
  PDemoApp = ^TDemoApp;
  TDemoApp = object(TColorApplication)
    procedure LoadImages; virtual;
    procedure initmenubar; virtual;
    procedure About; virtual;
    procedure HandleEvent (var Event : TEvent); virtual;
  end;

procedure TDemoApp.LoadImages;

begin
  image25 := @data_25_lines;
  len25 := 2000;
  image43 := @data_43_lines;
  len43 := 3440;
  image50 := @data_50_lines;
  len50 := 4000;
end;

procedure TDemoApp.InitMenuBar;

var
  r : TRect;

begin
  getextent(R);
  R.B.Y := R.A.Y + 1;
  menubar := new(pmenubar, init(R, NewMenu(
    NewSubMenu('~A~ction', hcNoContext, NewMenu(
      NewItem('Toggle ~L~ines', 'F7', kbF7, cmOptionsVideo, hcNoContext,
      NewItem('Say ~H~ello...', 'F8', kbF8, cmMessageHello, hcNoContext,
      NewLine(
      NewItem('About...', 'F1', kbF1, cmAppAbout, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X',kbAltX, cmQuit, hcNoContext,
      nil))))))),
    nil)
  )));
end;

procedure TDemoApp.About;

var
  D: PDialog;
  Control: PView;
  R: TRect;

begin
  R.Assign (0,0,40,12);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;
    Flags := Flags and not (wfMove or wfGrow or wfZoom or wfClose);
    R.Grow(-1, -1);
    Dec(R.B.Y, 1);
    Insert(New(PStaticText, Init(R,
      #13#3'Color DeskTop Demo'#13#13+
      #3'by Scott F. Earnest'#13+
      #3'(scott@whiplash.res.cmu.edu)'#13#13+
      #3'Screens created with TheDraw(TM)'#13)));
    R.Assign (15,9,25,11);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D)<>nil then
  begin
    DeskTop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

procedure TDemoApp.HandleEvent (var Event : TEvent);

begin
  inherited HandleEvent (Event);
  if Event.What=evCommand then
    case Event.Command of
      cmOptionsVideo : begin
                         SetScreenMode(ScreenMode xor smFont8x8);
                         ClearEvent (Event);
                       end;
      cmMessageHello : begin
                         messagebox (#3'Hello!  Move me around!'#13,nil,
                                      mfInformation or mfOKButton);
                         ClearEvent (Event);
                       end;
      cmAppAbout     : begin
                         About;
                         ClearEvent (Event);
                       end;
    end;
end;

var
  Appl : TDemoApp;

begin
  Appl.init;
  Appl.About;
  Appl.run;
  Appl.done;
end.

{------------------------- snip, snip ----------------------------}

ENCODED LINES25.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{------------------------- snip, snip ----------------------------}

ENCODED LINES43.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
{------------------------- snip, snip ----------------------------}

ENCODED LINES50.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.