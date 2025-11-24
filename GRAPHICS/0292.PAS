{ Frequency Domain Simulation to prove Fourier Transform
  Features:
  A friendly GUI with mouse and Help

  By  : Roby Johanes
  http://www.geocities.com/SiliconValley/Park/3230
  Finished in 1996

  Final Update: December 1997 for submission to SWAG

  Note from the author:
* In unit Images there contains all images of this program. They are
  in RAW format, you should convert them all into OBJ using BINOBJ.EXE
* In addition, you should convert the existing EGAVGA.BGI driver into
  OBJ file using BINOBJ.EXE (supplied in BP package) in order to make
  this code fully functional.
}
{ NOTE FROM SWAG :
  The OBJ files needed for this program in included in an XX34 module at
  the end.

{$A+,G+,N+,E-,R-,S-}
uses crt, graph, images;
var
  xm, ym, b : word;
  digit     : array[0..9] of pointer;
  mouseok   : boolean;

{ Far mouse handler to get (x,y) coordinate and button pressed }
procedure mousehand; far; assembler;
asm
  push    ds
  mov     ax,seg @data
  mov     ds,ax
  mov     [xm],cx
  mov     [ym],dx
  and     bx,3
  mov     [b],bx
  pop     ds
end;

{ Initialize douse driver }
procedure initmouse; assembler;
asm
  mov ax,3533h      { Check for the existence of mouse driver }
  int 21h
  mov dx,es
  or  dx,dx
  jnz @@1
  or  bx,bx
  jz  @@2
@@1:
  xor ax,ax         { Reset mouse driver and install handler }
  int 33h
  mov [mouseok],al
  or  ax,ax
  jz  @@2
  mov ax,cs
  mov es,ax
  mov dx,offset mousehand
  mov ax,12
  mov cx,1fh
  int 33h
@@2:
end;

procedure hidemouse; assembler;
asm
  cmp [mouseok],0
  je  @@1
  mov ax,2
  int 33h
@@1:
end;

procedure showmouse; assembler;
asm
  cmp [mouseok],0
  je  @@1
  mov ax,1
  int 33h
@@1:
end;

function inside(x1,y1,x2,y2 : word):boolean;
begin
  if (xm>=x1) and (xm<=x2) and (ym>=y1) and (ym<=y2) then inside:=true
     else inside:=false;
end;

procedure init;
type tfix = record
              x, y : word;
            end;
var gd, gm : integer; p:^tfix;
begin
  gd:=VGA; gm:=VGAHi;
  initgraph(gd,gm,'');
  if graphresult<>grok then
  begin
    writeln('Sorry, you have no compatible VGA cards.'); halt;
  end; mouseok:=false; initmouse;
  digit[0]:=@Digit0; digit[1]:=@Digit1; digit[2]:=@Digit2;
  digit[3]:=@Digit3; digit[4]:=@Digit4; digit[5]:=@Digit5;
  digit[6]:=@Digit6; digit[7]:=@Digit7; digit[8]:=@Digit8;
  digit[9]:=@Digit9; randomize; settextjustify(0,2);
  p:=@scrolldown; p^.y:=p^.y-1;
end;

procedure shade(x,y : word; c : byte; s : string);
begin
  setcolor(0);
  outtextxy(x+1,y+1,s);
  outtextxy(x+2,y+2,s);
  setcolor(c);
  outtextxy(x,y,s);
end;

procedure setupscreen;
var i : word; p : pointer; f : file;
begin
  setrgbpalette(3,0,0,0);
  setrgbpalette(20,0,0,0);
  setrgbpalette(57,0,0,0);
  setrgbpalette(59,0,0,0);
  setrgbpalette(5,0,0,0);
  setrgbpalette(2,0,0,0);

  for i:=0 to 7 do
  begin
    putimage(i*80,0,@pcb^,0);
    putimage(i*80,160,@pcb^,0);
    putimage(i*80,320,@pcb^,0);
  end;

  setfillstyle(1,0);
  bar(6,26,633,399);
  setrgbpalette(3,0,10,0);
  setrgbpalette(20,60,50,10);
  setrgbpalette(57,10,20,10);
  setrgbpalette(59,20,40,10);
  setrgbpalette(5,10,30,10);
  setrgbpalette(2,0,20,0);
  shade(34,416,6,'AMPLITUDE');
  shade(207,416,6,'PERIOD');
  shade(367,416,6,'DOMAIN');
  putimage(460,400,@about^,0);
  putimage(210,0,@title^,0);
  setcolor(11);
  rectangle(0,0,639,479);
  rectangle(5,25,634,400);
  settextstyle(0,0,1);
  settextjustify(2,2);
  shade(630,10,15,'F1 = Help');
end;

procedure drawaxis;
var i : word;
begin
  setcolor(2);
  setlinestyle(1,0,1);
  i:=33;
  repeat
    line(i,26,i,399); i:=i+30;
  until i>630;
  i:=32;
  repeat
    line(6,i,633,i); i:=i+30;
  until i>399;
  setcolor(10);
  setlinestyle(0,0,1);
  line(6,212,633,212);
end;

procedure plot(a,n : word; f : real);
var
  y     : array[0..629] of word;
  i, j  : word;
  t, at : real;
begin
   fillchar(y,1260,0);
   i:=1;
   repeat
      j:=0;
      repeat
         t:=2*pi*f*i; at:=a/i;
         y[j]  :=y[j]  +round(at*sin(t*j));
         y[j+1]:=y[j+1]+round(at*sin(t*(j+1)));
         y[j+2]:=y[j+2]+round(at*sin(t*(j+2)));
         y[j+3]:=y[j+3]+round(at*sin(t*(j+3)));
         y[j+4]:=y[j+4]+round(at*sin(t*(j+4)));
         y[j+5]:=y[j+5]+round(at*sin(t*(j+5)));
         y[j+6]:=y[j+6]+round(at*sin(t*(j+6)));
         j:=j+7;
      until j>=629;
      i:=i+2;
   until i>n;
   setcolor(14);
   moveto(6,y[0]+212);
   for j:=0 to 627 do lineto(j+6,y[j]+212);
end;

procedure drawdigit(x, y, n : word);
begin
  putimage(x,y,digit[n div 100]^,copyput); n:=n mod 100;
  putimage(x+15,y,digit[n div 10]^,copyput); n:=n mod 10;
  putimage(x+30,y,digit[n]^,copyput);
end;

procedure showstatus(a,n,f : word);
begin
  putimage(40,430,@scroller^,copyput);
  drawdigit(42,432,a);
  putimage(200,430,@scroller^,copyput);
  drawdigit(202,432,f);
  putimage(360,430,@scroller^,copyput);
  drawdigit(362,432,n);
end;

procedure help;
var p : pointer; s: word;
begin
  s:=imagesize(220,130,420,350);
  getmem(p,s);
  hidemouse;
  getimage(220,130,420,350,p^);
  putimage(220,130,@helppic^,0);
  showmouse;
  repeat until (keypressed) or (b>0);
  hidemouse;
  putimage(220,130,p^,0);
  showmouse;
  freemem(p,s);
end;

function quit : boolean;
var
  c : char;
  p : pointer;
  s : word;
  u : boolean;
begin
  s:=imagesize(180,190,460,290);
  getmem(p,s); u:=true;
  hidemouse;
  getimage(180,190,460,290,p^);
  showmouse;
  repeat
    if u then
    begin
      hidemouse;
      putimage(180,190,@quitpic^,copyput);
      showmouse;
      if mouseok then while b and 2 = 2 do;
    end;
    repeat until (keypressed) or (b>0);
    u:=false;
    if keypressed then c:=upcase(readkey) else
    if b and 2 = 2 then
    begin
      c:='N'; while b and 2 = 2 do ; break;
    end else
    if b and 1 = 1 then
    begin
      if not inside(180,190,460,290) then begin c:='N'; break; end;
      if inside(260,260,335,280) then
      begin
        hidemouse;
        putimage(260,260,@yesclicked^,copyput);
        showmouse; u:=true;
        while (inside(260,260,335,280)) and (b and 1 = 1) do ;
        if inside(260,260,335,280) then c:='Y';
      end;
      if inside(355,260,435,280) then
      begin
        hidemouse;
        putimage(355,260,@noclicked^,copyput);
        showmouse; u:=true;
        while (inside(355,260,435,280)) and (b and 1 = 1) do ;
        if inside(355,260,435,280) then c:='N';
      end;
    end;
    if c=#27 then c:='N';
  until c in ['Y','N'];
  if c='Y' then quit:=true else quit:=false;
  hidemouse;
  putimage(180,190,p^,copyput);
  showmouse;
  freemem(p,s);
end;

procedure main;
var
  a, n, f, bt : word;
  c           : char;
  update      : boolean;
  action      : byte;
begin
  a:=160; n:=1; f:=630; update:=true;
  setfillstyle(1,0); settextstyle(0,0,1);
  showmouse; action:=0;
  repeat
     if update then
     begin
        hidemouse;
        setfillstyle(1,0);
        bar(6,26,633,399);
        showstatus(a,n,f);
        drawaxis;
        plot(a,n,(1/f));
        showmouse;
     end;
     update:=false; c:=#0;
     while keypressed do readkey;
     repeat bt:=b; until (keypressed) or (bt>0);
     if bt and 2 = 2 then action:=7 else
     if bt and 1 = 1 then
     begin
       if inside(88,430,103,445)  then action:=1;
       if inside(88,446,103,471)  then action:=2;
       if inside(248,430,263,445) then action:=3;
       if inside(248,446,263,471) then action:=4;
       if inside(408,430,423,445) then action:=5;
       if inside(408,446,423,471) then action:=6;
     end else
     begin
       c:=readkey;
       case c of
          #0: case readkey of
                #59: help;
                #72: action:=1;
                #75: action:=4;
                #77: action:=3;
                #80: action:=2;
              end;
         '+': action:=5;
         '-': action:=6;
         #27: action:=7;
       end;
     end;

     case action of
       1 : if a<180 then
           begin
             inc(a); update:=true;
             hidemouse;
             putimage(88,430,@scrollup^,copyput);
             showmouse;
           end;
       2 : if a>50  then
           begin
             dec(a);  update:=true;
             hidemouse;
             putimage(88,446,@scrolldown^,copyput);
             showmouse;
           end;
       3 : if f<990 then
           begin
             f:=f+30; update:=true;
             hidemouse;
             putimage(248,430,@scrollup^,copyput);
             showmouse;
           end;
       4 : if f>30  then
           begin
             f:=f-30; update:=true;
             hidemouse;
             putimage(248,446,@scrolldown^,copyput);
             showmouse;
           end;
       5 : if n<399 then
           begin
             n:=n+2;  update:=true;
             hidemouse;
             putimage(408,430,@scrollup^,copyput);
             showmouse;
           end;
       6 : if n>1   then
           begin
             n:=n-2;  update:=true;
             hidemouse;
             putimage(408,446,@scrolldown^,copyput);
             showmouse;
           end;
       7 : if quit then exit;
     end;
     action:=0;
  until false;
end;

procedure done;
begin
  closegraph;
  writeln('Roby Johanes says : "See you next time !"'#10#13);
end;

begin
  init;
  setupscreen;
  drawaxis;
  main;
  done;
end.

{ ---------------------  IMAGES.PAS --------------------- }

{  By  : Roby Johanes
  http://www.geocities.com/SiliconValley/Park/3230
  Finished in 1996
}
unit images;
interface
uses graph;

procedure VGADriver;
procedure QuitPic;
procedure YesClicked;
procedure NoClicked;
procedure Digit0;
procedure Digit1;
procedure Digit2;
procedure Digit3;
procedure Digit4;
procedure Digit5;
procedure Digit6;
procedure Digit7;
procedure Digit8;
procedure Digit9;
procedure Scroller;
procedure ScrollUp;
procedure ScrollDown;
procedure PCB;
procedure HelpPic;
procedure About;
procedure Title;
implementation

{ VGA graphic driver routines (BGI) }
procedure VGADriver; external;  {$L EGAVGA.OBJ}
{ Pictures in object files }
procedure QuitPic; external;    {$L QUIT.OBJ}
procedure YesClicked; external; {$L YES.OBJ}
procedure NoClicked; external;  {$L NO.OBJ}
procedure Digit0; external;     {$L 0.OBJ}
procedure Digit1; external;     {$L 1.OBJ}
procedure Digit2; external;     {$L 2.OBJ}
procedure Digit3; external;     {$L 3.OBJ}
procedure Digit4; external;     {$L 4.OBJ}
procedure Digit5; external;     {$L 5.OBJ}
procedure Digit6; external;     {$L 6.OBJ}
procedure Digit7; external;     {$L 7.OBJ}
procedure Digit8; external;     {$L 8.OBJ}
procedure Digit9; external;     {$L 9.OBJ}
procedure Scroller; external;   {$L SCROLL.OBJ}
procedure ScrollUp; external;   {$L SCROLLUP.OBJ}
procedure ScrollDown; external; {$L SCROLLDN.OBJ}
procedure PCB; external;        {$L PCB.OBJ}
procedure HelpPic; external;    {$L HELP.OBJ}
procedure About; external;      {$L ABOUT.OBJ}
procedure Title; external;      {$L TITLE.OBJ}

begin
  if registerbgidriver(@VGADriver)<0 then halt;
end.

{ ---------------------  CUT ----------------- }
{------------------------- snip, snip ----------------------------}

ENCODED OBJFILES.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.