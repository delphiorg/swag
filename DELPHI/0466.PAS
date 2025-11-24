Tlzrw1 : compression component with LZH and LZRW1/KH compression

Version 1.01.00 : Danny Heijl (Danny.Heijl@cevi.be)

The LZH and LZRW1/KH routines are from the SWAG.
They are basically unchanged, I only added exceptions
and some cosmetic changes to the code, and added 32 bit support.

Version 1.01.01 : 
*****************

May 97 : 

1. Corrected a bug in the LZRW1/KH compression discovererd by 
Domionque Willems (Domus@compuserve.com).

2. Added a Delphi help File, and a HTML description file

Version 2.00.00 : 
*****************

25 May 1997 (stefan.westner@stud.uni-bamberg.de)
  Code for using a Stream instead of a File added by Stefan Westner.

30 May 1997 (danny.heijl@cevi.be)
  I removed the Seeks to the beginning of the stream (except in auto guess)
  and the Clear call, so that you can use TFilestream with more freedom, 
  or THandleStream.
  I also changed all string literals to const's so you can translate them more easily.
  (Should be made into resourcestrings for D3).

18 July 1997 (danny.heijl@cevi.be)
  Added a "Threshold" property that specifies the compression ratio for the Advise function
  (and for compression with "auto" compression-mode).

----------------------------------------------------------------------------------
file name 	: tlzrw1.zip
replaces	: tlzrw1.zip
file version	: 2.00
file description: freeware file compression/decompression component with source
target		: Delphi 1.0, 2.0, 3.0
author name	: Danny Heijl (Danny.Heijl@cevi.be)
author URL	: http://www.cevi.be/pp/danny/dhe.htm
file status	: freeware
full source	: included
category	: compression component

----------------------------------------------------------------------------------
Installation instructions :
----------------------------------------------------------------------------------

1. copy compon\*.* to your component directory

2.

16 bit : install tlzrw116.pas in your component library
32 bit : install tlzrw132.pas in your component library


3. rebuild the component library.

-----------------------------------------------------------------------------------

From this moment on you can excercize the test application compressp.dpr.

Or you can play with "tlzrw1" yourself.

Tlzrw1 presents itself as a panel that shows compression/decompression
progress if you set it's Visible proprty to True.

Properties :
------------

inputfile
outputfile
Threshold
compressmode : good (LZH, slow), fast (LZRW1/KH) or auto (takes a sample and chooses).
UseStream
InputStream
OutputStream

Methods :
---------

compress
decompress
advise : returns good or fast compressmode for inputfile

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}

------------------------- snip, snip ----------------------------}

ENCODED TLZRW1.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.