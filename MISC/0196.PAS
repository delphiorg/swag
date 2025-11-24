{
PROGRAM NAME : STUPID ALIEN INVADERS FROM ORKNEY (Revision 2)

AUTHOR       : SCOTT TUNSTALL B.Sc

CREATION     : JUNE 1996
DATE

	       ALL OFFENSIVE CRAP & EXPLETIVES REMOVED

			"Kojak's on the case!"


----------------------------------------------------------------------


NOTE: THE PCX AND IMAGE FILES THAT THIS GAME USES ARE ATTACHED TO
THE BOTTOM OF THIS PROGRAM, IN XX3402 FORMAT!!!

EXTRACT THE FILE IMAGES.ZIP USING XX3402, THEN COMPILE THIS FILE
AND UNZIP THE IMAGES INTO THE ** SAME DIRECTORY ** AS THE EXECUTABLE!!!!

THEN RUN, OF COURSE!!!



DISCLAIMER
----------

If this crashes on you, try FORMAT C: and re-install (THAT WAS A JOKE)
No, instead try unzipping the image files first and compiling with
TP6 or better.

And don't run this on a P90, see the game flash by, and blame me. Try
and slow it down yourself you geek! :)




REQUIREMENTS
------------

NEWGRAPH unit, from June 96 GRAPHICS.SWG - heading "Improved Graphics
Routines". Author : Me!

Turbo Pascal 6 or better running TPX.EXE (You may have to change "switches")
386 (Or better) processor
500K memory
A sense of humour
Penchant for sheep



GAME INFO
---------

Z 	     = Move Ship left
X 	     = Move Ship Right
SPACE 	     = Fire Missile
CTRL-ALT-DEL = Mercy :)



Included in this game is:

	 o Dave Norrie (P90 man)

	 o Fish (Alright Alan Henderson? :) )

	 o Aliens who don't fire back (makes game more fun)

	 o Orvilles!!!! I HATED THAT DUCK WHEN HE WAS ON TELLY
	   SO THIS IS MY REVENGE!!! ;)

	 o Sheep




Thanks to Dave Jack for his "inspirational" advice!





PARAMETERS -> PROGRAM


-speech       If you have a speech synthesiser then use this switch.
	      Surely EVERYONE must have access to a speech synthesiser
	      program somehow, they come with soundblasters and you can
	      get em off the 'Net easy! I use TRAN.EXE anyway.


-nofilth      No effect - there aren't any rude words in this game. If you
	      want the hardcore, uncut all singing all dancing :)
	      version, send œ4000 used notes in Sterling to:

		       Kojak Van Damme
		       Somewhere in Dunfermline
		       Fife
		       Don't tell the missus


-nocrap       Skips the "Lieutenant Kojak Van Damme" bit at the start.
	      If you want to cut the crap and get straight to the title
	      proper, then pass this parameter!


-realstupid   Makes the aliens sitting ducks!! :)
	      They don't move AT ALL!




IF YOU LOVE SHEEP
-----------------

If any of you lot out there are emotionally attached to sheep then this
game could offend you. Instead, try something like "meeting women". You
can participate in this pastime by attending pubs, nightclubs or even
in the street of your village! If you are a woman and love sheep then
well...


}


Program YaAlienBasts;


Uses Crt, Dos,NewGraph; { NEWGRAPH was posted to the SWAG, it's
			  in the June 96 GRAPHICS.SWG - author:
			  Scott Tunstall }


{$m 4096,0,327680}







Const SPEECH_SYNTHESISER = 'TRAN.EXE';           { Change if you have
                                                   a better one }





Type AlienRec = Record

     AlienType    : byte;   { 0 = Dead, 1 = A Orville, 2 = Normal Alien }
     AlienDying   : byte;

     AlienX       : integer;
     AlienY       : integer;
End;





{
My KOJAKVGA unit (which wasn't placed in the SWAG despite it being
ultra cool) gets rid of this seg: offs crap, but as y'all are using
NEWGRAPH (maybe :) )
}


Var     Title1Seg,
        Title1Ofs,
        Title2Seg,
        Title2Ofs : word;

        LutherPal,
	Title1Pal,
        Title2Pal          : PaletteType;

        PlayFieldSeg,
	PlayFieldOfs       : word;


        PlayerPtr,
        MissilePtr,
        FishPtr,
        NorriePtr,
        SheepImg,
        ItsTuckMsg,
        WantAP90Msg,
	LoveOberMsg        : pointer;

        AlienPtr, OrvillePtr,
        DeadAlienPtr,
	AbuseMsg           : Array[0..1] of Pointer;

        SaySpeech,
        ShowCrap,
        ShowFilth,
        AngelWords,
        AliensMove,
        LaserOn,
        NorrieOn,
        FishOn,
        SheepOn,
        GameOver,
        NextLevel          : boolean; { Before you say it, I know it's
                                        a waste of RAM OK? }
        Alien:
        Array[1..8, 1..6] of AlienRec;


        AnimFrame,
        AnimDelay,
	AnimLatch,
        AlienCount         : byte;
        AliensPauseVar,
        AlienDirection,
        NorrieTime,
        SheepMessage,
        SheepMessageTime   : byte;


	PlayerX,
	LaserX,
	LaserY             : integer;

	FishX,
	SheepX             : integer;






{ If these switches give you errors in Tp6, compile with Turbo 7 or
remove some of 'em! }




{$r-,q-,v-,s-,x+}







Procedure GetSwitches;
Var Count: byte;
Begin
     SaySpeech   :=False;                 { Defaults }
     ShowCrap    :=True;
     ShowFilth   :=True;		  { No filth in this game }
     AngelWords  :=True;
     AliensMove  :=True;


     If ParamCount = 0 Then exit;


     For Count:=1 to ParamCount do
	 Begin
	 If ParamStr(Count) = '-speech' Then
	    SaySpeech:=True
	 Else
	     If ParamStr(Count) = '-nocrap' Then
		ShowCrap:=False
	     Else
		 If ParamStr(Count) = '-nofilth' Then
		    ShowFilth:=False
		 Else
		     If ParamStr(Count) = '-noangelwords' Then
			AngelWords:=False
		     Else
			 If ParamStr(Count) ='-realstupid' Then
			    AliensMove:=False;

     End;

End;







{
Load In Title pages, sprites, Messages etc.
}







Procedure LoadGraphics;
Begin
     Bitmap(Title1Seg, Title1Ofs);
     SetSourceBitmapAddr(Title1Seg, Title1Ofs);
     LoadPCX('TITLEPGE.PCX',Title1Pal);
     Bitmap(Title2Seg, Title2Ofs);
     SetSourceBitmapAddr(Title2Seg, Title2Ofs);
     LoadPCX('2NDTITLE.PCX',Title2Pal);

     LoadShape('PLAYER.IMG'   , PlayerPtr);
     LoadShape('MISSILE.IMG'  , MissilePtr);
     LoadShape('ALIEN1.IMG'   , AlienPtr[0]);
     LoadShape('ALIEN2.IMG'   , AlienPtr[1]);
     LoadShape('ORVILLE1.IMG' , OrvillePtr[0]);
     LoadShape('ORVILLE2.IMG' , OrvillePtr[1]);
     LoadShape('DEADGUY1.IMG' , DeadAlienPtr[0]);
     LoadShape('DEADDUCK.IMG' , DeadAlienPtr[1]);
     LoadShape('FISH.IMG'     , FishPtr);
     LoadShape('NORRIE.IMG'   , NorriePtr);
     LoadShape('SHEEP.IMG'    , SheepImg);

     LoadShape('ITS_TUCK.IMG' , ItsTuckMsg);
     LoadShape('WANTP90.IMG'  , WantAP90Msg);
     LoadShape('LOVEOBER.IMG' , LoveOberMsg);

     Bitmap(PlayfieldSeg, PlayFieldOfs);
     SetSourceBitmapAddr(PlayFieldSeg, PlayFieldOfs);
     CCls(0);
End;














Procedure InitObjects;
Var Across, Down: byte;

Begin
     PlayerX:=160;
     LaserOn:=False;

     SheepOn:=False;
     FishOn:=False;
     NorrieOn:=False;


     GameOver:=False;
     NextLevel:=False;

     AlienCount:=48;
     AliensPauseVar:=AlienCount;

     AnimFrame:=0;
     AnimDelay:=AlienCount DIV 6;

     AnimLatch:=AnimDelay;


     AlienDirection:=1;

     For Across:=1 to 8 do
         With Alien[Across,1] do
         Begin
	      AlienType:=1;

              AlienDying:=0;
	      AlienX:=((Across-1) * 18) ;
              AlienY:=40;
         End;

     For Down:=2 to 6 do
         For Across:=1 to 8 do
         With Alien[Across,Down] do
         Begin
              AlienType:=2;
              AlienDying:=0;
              AlienX:=((Across-1) * 18) ;
              AlienY:=40+((Down-1) * 18);
         End;
End;













Procedure DrawObjects;
Begin
     If NorrieOn Then
	Begin
	Blit(40,160,NorriePtr^);         { Draw Dave Norrie }
        If NorrieTime < 128 Then         { Display WANT A P90 ? }
           Blit(16,144,WantAP90Msg^)
        Else
            Blit(16,144,ItsTuckMsg^);    { Announce Norries Arrival ! }
     End;


     {
     Draw Fish! Alan Henderson come on down!
     }

     If FishOn Then
        ClipBlit(FishX,20,FishPtr^)
     Else
         If SheepOn Then
            Begin
            ClipBlit(SheepX,20,SheepImg^);              { Draw Sheep }
            If SheepMessage = 1 Then                    { Display .. }
               ClipBlock(SheepX-40,0,LoveOberMsg^);     { I LOVE OBER }
            End;
End;











{ Taito made a killing from Space Invaders.

  It's quite simple to program, actually!

}



Procedure DrawAliens;
Var Across, Down: byte;

Begin
     For Across:=1 to 8 do
         For Down:=1 to 6 do
         With Alien[Across,Down] do
         Begin
         If AlienType <>0 Then
            Begin
            If (AlienDying = 0) Then
               Begin
                    Case AlienType Of
                    1 : Blit(AlienX,AlienY,OrvillePtr[AnimFrame]^);
                    2 : Blit(AlienX,AlienY,AlienPtr[AnimFrame]^);
                    End;
               End
            Else

                {
                  Draw Alien with Halo!

                  }


                Begin
                     Case AlienType Of
                     1 : ClipBlit(AlienX, AlienY, DeadAlienPtr[1]^);
                     2 : ClipBlit(AlienX, AlienY, DeadAlienPtr[0]^);
                     End;
                End;

            End;
         End;
End;








{
Even tho there is only 1 command in here it helps make the
code more 'modular'
}



Procedure DrawLaser;
Begin
     Blit(LaserX, LaserY, MissilePtr^);
End;







Procedure DrawPlayer;
Begin
     Blit(PlayerX, 192, PlayerPtr^);
end;






{
All non-essential objects are updated, i.e. Sheep/Fish/Norrie
}



Procedure UpdateCharacters;
Begin
     If NorrieOn Then
        Begin
	Dec(NorrieTime);
	If NorrieTime=0 Then NorrieOn:=False;
        End
     Else
         If Random(500)=1 Then
            Begin
            NorrieOn:=True;
            NorrieTime:=200;
         End;





     If FishOn Then
        Begin
        Inc(FishX,1);           { Move fish right }
	If FishX >320 Then
           FishOn:=False;
        End
     Else
         If Not SheepOn Then
            Begin
            If Random(20)=10 Then
               Begin
               FishOn:=True;
               FishX:=-12;
	    End;
         End;


     {
     When SheepMessage = 2 that means it's already been displayed
     }


     If SheepOn Then
        Begin
        If SheepMessage<>1 Then
           Begin
           Dec(SheepX,1);
           If SheepX < -12 Then
              SheepOn:=False
           Else
               If (SheepMessage <>2) And (SheepX < 164) Then
                  Begin
		  SheepMessage:=1;
                  SheepMessageTime:=50;
               End;
           End
        Else
            if SheepMessage = 1 Then
               Begin
               Dec(SheepMessageTime);
               If SheepMessageTime = 0 Then
                  SheepMessage:=2;
            End;
	End

     Else
         If Not FishOn Then
            Begin
	    If Random(20)=10 Then
               Begin
               SheepOn:=True;
               SheepMessage:=0;
               SheepX:=320;
            End;
         End;

End;












Function UpdateAliensPos(IncX, IncY: integer) : boolean;
Var Across, Down : byte;
    IsGameOver   : boolean;

Begin
     IsGameOver:=False;
     For Down:=1 to 6 do
         For Across:=1 to 8 do
	     With Alien[Across,Down] do
             Begin
             If (AlienType <> 0) And (AlienDying = 0) Then
                Begin
                Inc(AlienX, IncX);
                Inc(AlienY, IncY);
                If AlienY >= 192 Then
                   IsGameOver:=True;
                End;
             End;


     UpdateAliensPos:=IsGameOver;
End;








{
The procedure name gives a small hint as to what it actually does.
(Unlike some software eh Geoff? :) :) :) )

I couldn't be bothered giving it a name like:

  "Move Aliens about until they hit the bottom of the screen
  Or get shot to pieces" :)
}



Procedure UpdateAliens;

Var ChangeDirectionNow: boolean;
    Across, Down,Sway: byte;
    NewX, NewY : integer;


Begin



     Dec(AnimDelay);
     If AnimDelay = 0 Then
        Begin
        If AliensPauseVar > 6 Then
           AnimDelay:=(AliensPauseVar DIV 6)+2
        Else
            AnimDelay:=1;

        If AliensMove Then
           Begin
           AnimFrame:=AnimFrame XOR 1;


{ SOMEBODY ** PLEASE ** ADD SOME .WAV PLAYING CODE !! (And a WAV!) }


	   Sound(AnimFrame * 40);                  { 20 }
           Delay(25);
           NoSound;



        End;


        ChangeDirectionNow:=False;

        For Down:=1 to 6 do
            For Across:=1 to 8 do
            With Alien[Across,Down] do
            Begin
            If (AlienType<> 0) And (AlienDying = 0) Then
               Begin


{ Sorry about the extreme nesting, but as I said I didn't intend this
  code to be examined... I've already spent ages removing the
  expletives from my code !!! >-| }


               If AliensMove Then
                  Begin

                  If AlienDirection = 0 Then
                     Begin
		     NewX:=integer (AlienX) - 4;
                     If NewX <= -1 Then
                        Begin
                        ChangeDirectionNow:=True;
                        Across:=8;
                        Down:=6;
                        End;
                     End
                  Else
                      Begin
                      NewX:=integer (AlienX) + 4;
		      If NewX >= 304 Then
			 Begin
                         ChangeDirectionNow:=True;
                         Across:=8;
                         Down:=6;
			 End;
                      End;


{
If any aliens have made it to the edge of the screen
obviously a change of direction is required.
And of course to move the aliens down one row.
}


                  End;


               End
            Else

                { Alien with halo }


                If AlienType <>0 Then
                Begin
                If AlienDying = 1 Then
                   begin
                   Dec(AlienY,2);

                   {
                   Make alien sway about as he flies to heaven!
                   }

                   Sway:=Random(50) AND 3;
                   Case Sway Of
                   0: Dec(AlienX,2);
                   2: Inc(AlienX,2);
                   End;


                   {
                   If alien has reached Nirvana then update
                   dead alien counter
		   }


                   If AlienY <= 4 Then
                      Begin
		      AlienType:=0;
                      Dec(AlienCount);
                      If AlienCount=0 Then
                          NextLevel:=True;
                      end;
                   end
                end;

            End;



            If AliensMove Then
            Begin
                 If ChangeDirectionNow Then
                    Begin
                    AlienDirection:=AlienDirection XOR 1;
                    GameOver:=UpdateAliensPos(0,16);
                    End
                 Else
                     Begin
                     If AlienDirection = 0 Then
                        UpdateAliensPos(-4,0)
                     Else
                         UpdateAliensPos(4,0);
                     End;
            End;

     End;
End;










{
This is the laser to alien collision detection routine.
Tis groovy! (As you chaps can guess, modesty was never my
weak point)
}


Procedure UpDateLaser;
Var DistX, Disty: integer;
    Across, Down: byte;
Begin
     Dec(LaserY,4);
     If LaserY <=20 Then
	Begin
	LaserOn:=False;
	Exit;
     End;


     { Hit any aliens ? }

     For Down:=1 to 6 do
	 For Across:=1 to 8 do
	 With Alien[Across,Down] do
	      Begin
	      If (AlienType<> 0) And (AlienDying = 0) Then
		 Begin

		 DistX:=Abs(AlienX - LaserX);
		 DistY:=Abs(AlienY - LaserY);


		 If (DistX < 8) And (DistY < 6) Then
		    Begin
		    LaserOn:=False;
		    Dec(AliensPauseVar);
		    AlienDying:=1;

{
You know, you could add some code to play .VOC/WAV files here,
such as Aargh, ieeee etc. For more sound FX ideas, check out
those old "Commando" magazines, where the enemy dies in various
awful ways... "Mein leben, I never knew there was a rather large
machine gun round das corner" :)
}


		    Sound(80);
		    Delay(10);
		    NoSound;

		    Down:=6;
		    Across:=8;
		 End;
	      End;
	 End;
End;










Procedure UpDatePlayer;
Begin
     If Keypressed Then
	Begin
	Case upcase(ReadKey) Of
	'Z' : If PlayerX > 0 Then Dec(PlayerX,2);
	'X' : If PlayerX < 304 Then Inc(PlayerX,2);
	' ' : If Not LaserOn Then
		 Begin
		 LaserX:=PlayerX+3;
		 LaserY:=184;
		 LaserOn:=True;
	      End;
	End;


	Mem[$40:$1a]:=Mem[$40:$1c];             { Flush key buffer }
     End;
End;





















{
Change SPEECH_SYNTHESISER constant at top if you have a better
speech synthesis program on the go.

I use a SoundBlaster Pro myself, but unfortunately I can't get
Speech Synthesis on the go (without CT-VOICE.DRV anyway)
}



procedure CallTran(WhatToSay: String);
Var F: Text;

Begin
     Assign(F,'INFILE.TXT');
     ReWrite(F);
     Writeln(F,WhatToSay);
     Close(F);
     Delay(1000);
     exec(SPEECH_SYNTHESISER, '-v INFILE.TXT');
End;








{
My tribute to DOOM 2 !
}




Procedure Disclaimer;
Var COunt: byte;
    CurrDir: string[80];
Begin
     TextMode(CO80);
     TextColor(YELLOW);
     TextBackground(BLACK);
     ClrScr;

     TextBackGround(BLUE);



     GotoXY(1,1);
     For Count:=1 to 10 do
	 Write('        ');

     GotoXY(1,1);
     Write('STUPID INVADERS FROM ');
     TextColor(LIGHTRED);
     Write('O**NEY II ');
     TextColor(YELLOW);
     Write('(C) 1996 ');
     TextColor(WHITE);
     Write('SCOTT TUNSTALL. ');
     TextColor(YELLOW);
     Write('Version 1.2.9.(b)');

     GotoXY(1,4);
     TextColor(LightGray);
     TextBackground(BLACK);

     For Count:=1 to 10 do
         Write('========');

     Writeln('THIS GAME IS ALKYWARE. IF YOU USE IT, SEND BEER TO ME. OR WOMEN..');
     Writeln('DISTRIBUTE FREELY AMONGST YOUR WORST ENEMIES, GIRLS WHO HAVE GIVEN YOU THE');
     Writeln('ELBOW FOR AN UGLIER BLOKE (Oh hi Susie!) AND THOSE MATES WHO WON''T BUY A');
     Writeln('ROUND IN THE PUB.');


     For Count:=1 to 10 do
	 Write('========');

     Writeln;
     Writeln('<Press any key>');

     ReadKey;


     ClrScr;
     TextColor(LightGray);
     Writeln('CONTROLS :');
     Writeln;
     Writeln('Z     = Move Wellwood raider rocket Left');
     Writeln('X     = Move Rocket Right');
     Writeln('SPACE = Fire abuse missile :)');
     Writeln('Q     = Quit the game');
     Writeln('CTRL + ALT + DEL = Best thing ever ! :)');
     Writeln;
     Writeln;
     TextColor(RED + BLINK);
     Writeln('PRESS ANY KEY TO BEGIN THIS CRAP !!!!');


     if SaySpeech And ShowFilth Then
        begin
        CallTran('DONT PLAY THIS CRAP');
     end;


     Readkey;
End;









Procedure ShowTitleScreens;
Var ExitTitles: boolean;
    Count: word;
Begin
     InitVGAMode;
     ExitTitles:=False;
     While Keypressed do
           ReadKey;


     Repeat
           SetAllPalette(Title1Pal);
           ShowBitmap(Title1Seg,Title1Ofs);
           For Count:=1 to 1000 do
               begin
	       If Keypressed Then
                  begin
                  exittitles:=true;
                  Count:=1000;
                  end;
               delay(10);
               end;

           if exittitles = false Then
              Begin
              SetAllPalette(Title2Pal);
	      ShowBitmap(Title2Seg, Title2Ofs);
              For Count:=1 to 500 do
                  begin
                  If Keypressed Then
                     begin
                     exittitles:=true;
                     Count:=500;
                  end;
                  delay(10);
              end;
           end;
     Until exittitles;
end;














Begin
     LoadGraphics;
     GetSwitches;                       { Any params passed ? }


{
  Has anyone ever told you I look like Jean Claude Van Damme? :)
  (I wish! Then my woman problems would be solved :) )
}

     If ShowCrap Then                   { You can skip it by using the -nocrap
					  switch }
	Begin
	Disclaimer;
	InitVGAMode;
	SetSourceBitmapAddr($a000,0);
	LoadPCX('LUTHER.PCX',LutherPal);
	SetAllPalette(LutherPal);
	Delay(3000);
     End;





     Repeat
           ShowTitleScreens;

{ It's not bad spelling, it's phonetics ya eejit! :) }

           If SaySpeech Then
              CallTran('GET REDY TO DIE, HEWMAN SCUM');

           InitVGAMode;                  { back to normal colours }
           SetSourceBitmapAddr(PlayFieldSeg, PlayFieldOfs);

	   InitObjects;
           Repeat
                 Cls;
		 DrawAliens;
                 DrawObjects;

                 If LaserOn Then
		    DrawLaser;

                 DrawPlayer;
                 ShowBitmap(PlayFieldSeg, PlayFieldOfs);

                 UpdateCharacters;

                 UpdateAliens;

		 If LaserOn Then
                    UpdateLaser;       { This is the collision detection routine }

                 UpdatePlayer;

                 Delay(1);

           Until GameOver OR NextLevel;       { NextLevel ? Is there one!!! }

           If GameOver = True Then
              CallTran('HA HA HA YOU LOST!');

     Until false;

End.


{------------------------- snip, snip ----------------------------}

ENCODED IMAGES.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

