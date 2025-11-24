
> Is anybody have examples on how to create a Control
> Panel Applet in Delphi 2.0 ?

Borland stuffed up on this one - they didn't bother to
port the CPL.H header file to a Delphi unit. But never
fear, Johnny's here. :-)

I've attached a Cpl.pas unit that is the port and a
CplTest project that tests it out. The important thing
is the CplApplet function - it must be exported as
"CplApplet" since the Control Panel searches for a
function with this name. With only minor changes, the
entire CplApplet function can be reused for any
applet.

Depending on what you need to do, you are probably
better off NOT using the VCL (Forms, etc) and using
the old fashioned Windows dialog box functions, etc.
(you can still do this with Delphi). You'll save at
least 150K of disk space this way.

{ ------------------------- snip, snip ----------------------------}

ENCODED CPLTEST.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.