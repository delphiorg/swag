{
PROGRAM NAME: SHAKEIT.PAS

AUTHOR      : SCOTT TUNSTALL B.Sc

CREATION    : 12TH AUGUST 1997
DATE


NOTES:
I guess you could call this a kind of "water ripple" demo.

It needs VGA, TP7 and my KOJAKVGA unit V3.3 to run (get it from
June 97 SWAG, GRAPHICS section) and in case you're wondering why
I wrote this, I was inspired by a demo that came with a file my
mate Geoff gave me ages ago. Which was much better than this <g> !

Hope you like it. The "shake" proc is quite interesting,
if I say so myself !!! ;)

Have fun!
     Scott.



DISCLAIMER:
Use this program at your OWN RISK. CGA/EGA card owners, do NOT complain
if this kills your PC! :>

If you use this routine at all, please credit KojakVGA. Thank you.
}



Program ShakeIt_Baby;


Uses KOJAKVGA,crt;       { My baby! ;) }



{ If you wanna see 1 kind of shake, use the $DEFINE below }

{$DEFINE USE_SHAKE}


type shaketype=(ShakeLeft,ShakeRight);


Const StartY=1;     { Pixel row where dat shakin' starts ! }
      EndY=199;       { And where it ends }



Var HiddenBMap : pointer;
    MyPalette  : PaletteType;
    ShakeDir   : ShakeType;
    XDistLatch,
    XDist      : byte;
    YCount     : byte;


Begin
     { Load PCX to "shake" into a hidden bitmap }

     HiddenBMap:=New64KBitmap;
     UseBitmap(HiddenBMap);
     Cls;


     { You can use any 256 colour PCX file you like (up to 320x200 in size,
       any bigger and the image is clipped) }

     LoadPCX(ParamStr(1),MyPalette);

     InitVGAMode;
     UsePalette(Mypalette);

     { Initial X distance }

     XDistLatch:=1;

     { And we're shaking to the left initially.. }

     ShakeDir:=ShakeLeft;


     Repeat
           { Draw "non-shaking" parts of screen.. If you're doing
             any scrolly messages etc., draw to bitmap <HiddenBmap>
           }

           If StartY >0 Then
              CopyAreaToBitmap(0,0,319,StartY-1,Ptr($a000,0),0,0);

           If EndY < 199 Then
              CopyAreaToBitmap(0,EndY+1,319,199,Ptr($a000,0),0,EndY+1);



           { Now do the "difficult" stuff. }

           XDist:=XDistLatch;
           For YCount:=StartY To EndY Do
           Begin


{$IFDEF USE_SHAKE}
               Case ShakeDir Of



               ShakeLeft: Begin
                          CopyAreaToBitmap(4,YCount,315,YCount,
                          Ptr($a000,0),3-XDist,YCount);
                          Inc(XDist);
                          End;

               ShakeRight: Begin
                           CopyAreaToBitmap(4,YCount,315,YCount,
                           Ptr($a000,0),XDist,YCount);
                           Inc(XDist);
                           End;
               End;

               If XDist=4 Then
               Begin
                  XDist:=1;
                  If ShakeDir = ShakeRight Then
                     ShakeDir:=ShakeLeft
                  Else
                      ShakeDir:=ShakeRight;
               End;


{$ELSE}

                CopyAreaToBitmap(4,YCount,315,YCount,
                Ptr($a000,0),3-XDist,YCount);
                Inc(XDist);
                If XDist=3 Then
                   XDist:=1;
{$ENDIF}


           End;


           { Make the Latch (XDist reload value) different for
             each time the for loop executes }


           Inc(XDistLatch);
           If XDistLatch = 3 Then
              Begin
              XDistLatch:=1;
              If ShakeDir = ShakeLeft Then
                 ShakeDir:= ShakeRight
              Else
                  ShakeDir:= ShakeLeft;
              End;


     { Wait 5 video retraces }

     Vwait(8);
     Until Keypressed;

     { Release hidden bitmap from memory }

     FreeBitmap(HiddenBMap);

End.



{{------------------------- snip, snip ----------------------------}

ENCODED SHAKEIT.PCX FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.