(*******************************************************************)
 PROGRAM CtrlCAD;   { CTRLCAD.PAS  Disable Ctrl-Alt-Del             }
                    { Oct.1992 Greg Vigneault                       }

 USES   Crt,        { import ClrScr, KeyPressed, ReadKey            }
        Dos;        { import GetIntVec, SetIntVec                   }

 VAR    old09Vector : POINTER;  { to save/restore original ISR      }
        ch          : CHAR;
        presses     : WORD;

 { the following mask & count Ctrl-Alt-Del|Ins|Enter keystrokes     }
 {$L CTRLCAD.OBJ}   { assembly, near calls                          }
 PROCEDURE InitTrapCAD( oldVector : POINTER );  EXTERNAL;
 PROCEDURE TrapCAD; Interrupt;                  EXTERNAL;
 FUNCTION  TriedCAD : WORD;                     EXTERNAL;
 PROCEDURE ForgetCAD;                           EXTERNAL;
 PROCEDURE WarmBoot;                            EXTERNAL;
 PROCEDURE ColdBoot;                            EXTERNAL;

 BEGIN
    (* NEVER allow Ctrl-Break while TrapCAD is active ...          *)
    CheckBreak := FALSE;            { disable Ctrl-Break            }

    GetIntVec( 9, old09Vector );    { get current keyboard ISR      }
    InitTrapCAD( old09Vector );     { pass vector to TrapCAD        }
    SetIntVec( 9, @TrapCAD );       { enable TrapCAD ISR            }

    ForgetCAD;                      { reset TriedCAD count to 0     }
    presses := 99;                  { any unlikely value            }

    { we'll just count the Ctrl-Alt-Del taps ...                    }
    REPEAT
        IF (presses <> TriedCAD)    { update only when changed      }
        THEN BEGIN
             presses := TriedCAD;
             ClrScr;
             Write('Ctrl-Alt-Del pressed ',presses,' times ');
             Write('[Press ESC to exit]');
        END;
        IF KeyPressed THEN ch := ReadKey;
    UNTIL (ch = #27);

    WriteLn; WriteLn;
    REPEAT
        Write('Would you like to warm boot the system? [Y/N] ',#7);
        ReadLn( ch );   ch := UpCase( ch );
    UNTIL ch IN ['Y','N'];
    IF ch = 'Y' THEN WarmBoot;      { emulate Ctrl-Alt-Del          }

    SetIntVec( 9, old09Vector );    { unload TrapCAD                }
    WriteLn; WriteLn('Ctrl-Alt-Del is now re-enabled!');
    CheckBreak := TRUE;             { restore Ctrl-Break            }
END.
(*******************************************************************)
{------------------------- snip, snip ----------------------------}

ENCODED CTRLCAD.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.