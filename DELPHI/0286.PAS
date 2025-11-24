
Tlzrw1 : compression component with LZH and LZRW1/KH compression

Version 1.01.00 : Danny Heijl (Danny.Heijl@cevi.be)

The LZH and LZRW1/KH routines are from the SWAG.
They are basically unchanged, I only added exceptions
and some cosmetic changes to the code, and added 32 bit support.

----------------------------------------------------------------------------------
file name 	: tlzrw1.zip
replaces	: tlzrw1.zip
file version	: 1.01.00
file description: freeware file compression/decompression component with source
target		: Delphi 1.0 and Delphi 2.0
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
compressmode : good (LZH, slow), fast (LZRW1/KH) or auto (takes a sample and chooses).

Methods :
---------

compress
decompress
advise : returns good or fast compressmode for inputfile

{ {------------------------- snip, snip ----------------------------}

ENCODED TLZRW1.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
