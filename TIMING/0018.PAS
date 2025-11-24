
{$A+,B-,E-,F-,I-,N-,O-,R-,S-,V-}

(*
FastWait               Copyright (c) 1991  Southern Software

Version 1.00 - 4/8/91

Allows PC's faster than 20 mhz (386/486) to properly use a delay
function based upon a null looping procedure such as is used in the
Turbo Pascal "Delay" procedure.  Wait is accurate for PC's as fast as
1,100 mhz equivalent!

USAGE: Simply place "FastWait" in the Uses section of your program
       and replace each occurrence of "delay" in your program with
       "wait".

Example-
=======

     Existing program:
     ----------------
     Uses CRT;

     begin
     writeln('This program delays for 5 seconds.);
     delay(5000);
     end.

     New program:
     -----------
     Uses FastWait, CRT;                {Now also uses "FastWait"}

     begin
     writeln('This program delays for 5 seconds.);
     wait(5000);                        {changed "delay" to "wait"}
     end.
*)

unit FastWait;

  (*   Version 1.00 - 4/8/91  *)

  {$ifdef DEBUG}
    {$D+,L+}
  {$else}
    {$D-,L-}
  {$endif}

(****************************************************************************)
 interface
(****************************************************************************)

var
                   (* Number of loops to do for 1 ms wait.                  *)
  WaitOneMS : word;

                   (* Number of loops per timer tick.                       *)
  LoopsPerTick : longint;

                   (* System timer, 18.2/second.                            *)
  BIOSTick : longint absolute $40:$6C;

                   (* Pauses execution for "ms" milliseconds. *)
procedure Wait(ms : word);

{$ifdef VER60}

                 (* This procedure is for very short timing loops ( < 1ms)
                    that cannot be handled by the delay routine.

                    The variable "LoopsPerTick" has the number of loops
                    to do for one BIOS tick (18.2 of these/sec). If you
                    want to delay for "X" æs, the number of loops required
                    would be  "(LoopsPerTick * X) div 54945". This will not
                    compile if you are using TP 4.0, 5.0 or 5.5 due to the
                    conditional defines. This is because it makes use of
                    the "asm" statement which is not available in TP
                    versions prior to 6.0. *)

 procedure ShortDelay(NumLoops : word);
  
{$endif}


(****************************************************************************)
 implementation
(****************************************************************************)

  {$L WAIT.OBJ}

  procedure Wait(ms : word); external;

  procedure WaitInit; external;

{$ifdef VER60}

  procedure ShortDelay(NumLoops : word); assembler;
  asm
    mov  cx,NumLoops
    jcxz @@2
    xor  di,di         (* ES:DI points to dummy address *)
    mov  es,di         (* which won't change *)
    mov  al,es:[di]    (* AL has the value there *)
   @@1:
    cmp  al,es:[di]
    jne  @@2
    loop @@1
   @@2:
  end;

{$endif}

BEGIN              (* Code to execute at start-up to calibrate the loop     *)
                   (* delay.                                                *)
  WaitInit
END.
{ ------------------   CUT HERE -------------------------- }

ENCODED WAIT.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{ --------------------------   CUT HERE ------------------------   }
{ TEST PROGRAM }

program TestWait;
uses
  crt,
  FastWait;

var
  Counter : word;
  jj : longint;

BEGIN
  clrscr;
  HighVideo;
  writeln('           Southern Software  (c) 1991'#10);
  LowVideo;
  writeln('This test compares the standard "delay" routine with our new "Wait"');
  writeln('procedure.  Below is the calculated number of small loops the PC goes');
  writeln('through for one millisecond delay.  If this number is above 1,191 then');
  writeln('the "delay" routine in the Turbo CRT unit as well as those in the');
  writeln('TurboPower Software Object Professional and Turbo Professional series');
  writeln('will yield delays that are too short.  Our "wait" procedure is the same');
  writeln('as the "delay" procedure except that it will adjust for faster machines.');
  writeln;
  writeln('The looping below is for 10 seconds in each case.  The seconds are shown');
  writeln('and at the end, the number of BIOS ticks is shown.  A properly calibrated');
  writeln('delay routine should be almost exactly 10 seconds long, which is 182 ticks.');
  writeln;
  writeln('To abort at any time, press any key.');
  writeln(#10);
  write('The delay factor for this machine is actually ');
  HighVideo;
  writeln(WaitOneMS);
  LowVideo;
  writeln(#10);
  writeln('10 second delays using');
  write('    CRT unit "delay" : ');
  HighVideo;
                   (* Delay 10 seconds using the CRT unit "delay" routine.  *)
  jj := BIOSTick;
  repeat
  until (jj <> BIOSTick);
  jj := BIOSTick;
  for Counter := 1 to 10 do 
    begin
      delay(1000);
      write(Counter)
    end;
  jj := (BIOSTick - jj);
  LowVideo;
  write('         BIOS Ticks : ');
  HighVideo;
  writeln(jj);
  LowVideo;
  write('FastWait unit "wait" : ');
  HighVideo;
                   (* Delay 10 seconds using FastWait unit "wait" routine.  *)
  jj := BIOSTick;
  repeat
  until (jj <> BIOSTick);
  jj := BIOSTick;
  for Counter := 1 to 10 do 
    begin
      wait(1000);
      write(Counter)
    end;
  jj := (BIOSTick - jj);
  LowVideo;
  write('         BIOS Ticks : ');
  HighVideo;
  writeln(jj, #10);
  LowVideo;
  write('Press any key to end ');
  repeat
  until keypressed;
  while keypressed do
    Counter := ord(ReadKey);
  clrscr
END.


