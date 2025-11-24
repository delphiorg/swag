
PLEASE NOTE :
       This is a LARGE project of the type not normally included in SWAG
       However, we feel that this work is very important and relevant, and
       with Harry's permission, we include it here.  To get the ZIP file
       FLATMEM.ZIP, cut out the XX3402 code at the end of this document,
       and use XX3402 to decode it.

       Swag Support Team.


Documentation on: FlatMem, BASM32 and XMS30.
============================================

Most of the units do have internal documentation. I will here only give
the quick and dirty info - i.e. the least you need to know in order to use
them. If you get confused by detail, skip directly to "Conclusion"...

Limitation:
----------

No Windows(TM), no EMM386, no QEMM. ONLY Himem.SYS must be loaded as memory
manegement. Any of the Borland 7.0 compilers can be used. ONLY Turbo.EXE
and TD.EXE can be used to run/debug this code.

FlatMem & XMS30:
---------------

FlatMem is a unit with which to access all memory, up to 4G, with pascal.
The result is however not entirely seamless. This unit creates and assigns
the GS segment register, a 32-bit segment, with base address 00000h.
This means that any 16-bit seg:ofs pair can be accessed as an offset equal
to seg*16+ofs, using GS as segment register. If this sounds too complicated,
there are routines to read or write bytes, words, integers, longint, real,
extended and strings, to and from an absolute address.

An absolute address (also linear-,physical-address) is a longint. To get
this value for any DOS-pointer, use the function AbsAddr(pointer).

Although FlatMem can function without XMS30, and XMS30 without FlatMem,
you will want to use the two in concert. To allocate/free memory from the
XMS-heap, you can use GetMemXMS and FreeMemXMS.

To read or write to memory allocated with XMS30, you can do it in one of two
possible ways. If you only use XMS30, you will have to shuttle the area
which you want to access, to and from DOS memory. For this you can use
DOS2XMS, and XMS2DDOS. The data can then be accessed in DOS memory, in the
conventional pascal way.

To read or write directly to XMS-memory, you will have to use FlatMem.
Since accessing this memory directly implies that you know exactly where
the data resides, you will have to "lock" it. Incedently, LockXMS returns
the absolute address for us to be used directly in these routines:
putbyte, getbyte, putword, getword...ect.
The last thing to remember about locking memory, is that it must be unlocked
before it can be freed.


BASM32:
------

I you REALLY want to access XMS directly from within an ASM...END block,
this is it.

The Build in Assembler for BP can only handle '286 code at the most. It does
however allow us to include operation codes as data, right inside the code,
with which we can construct 32-bit codes. The least of the 32-bit code you
would want to use is indexed read and writes:
mov EAX, GS:[ESI]    ....1
mov GS:[ESI],EAX     ....2
Since I set up GS to the 32-bit segment, we will always want to override the
default segment with GS.

Most of the 32-bit instructions are only extentions of their 16-bit versions.
You can in most cases extend an instruction to cover 32-bits of data, by
merely preceding it with a $66(USE32). This constant (and others) are
defined in BASM32. To overrige the default segment with GS, use GSEG.
To make the indexing register also 32-bit, use INDEX32.

Example 1 can now be encoded in the following way:

   db USE32, GSEG, INDEX32, _read, _AX+_iSI

Notice the sequence of the constants. This order of use is NOT open to
negotiation. You MUST use them in this order.

A very complex statment could be:

   add GS:[EBX+ESI+0200h],ECX

which becomes:

   db USE32, GSEG, INDEX32, _add2mem, _iBX_iSI + _CX + _DWORD; dd 00000200

There are only made provision for the following types of instructions,
reading from memory into a register: _read
writing from a register to memory:  _write
adding a value in memory to a register: _add2reg
adding a value in a register to memory: _add2mem
substracting a value in memory with one in register: _sub2mem
substracting a value in a register with one in memory: _sub2reg.

!!!!IMPORTANT WARNING!!!!:

ALWAY CHECK THE CODE WITH AN UNASSEMBLER TO SEE IF YOU DID SAY WHAT
YOU WANTED TO.
There are NO checking done on code entered this way - NONE. I got a runtime
error once, when I didn't:
"The memory manager stoped this process since it wanted to write to an area
used by DoubleSpace. Continueing may result in the loss of ALL information
on your hard disk."
I was lucky - once. now I always check. Turbo debug is excelent to do
this with.

--------------
In Conclusion:
--------------

You can access XMS very easy, if you follow this few simple steps:

Include FLATMEM, XMS30 in the "uses"-clause of your program.

Define the neccesary variables:
   var
      my_XMS_var:word;
      my_XMS_var_addr:longint;

   const
      a_longint_amount:longint=1024;

To Allocate XMS, use:
   my_XMS_var:=GETMEMXMS(a_longint_amount);
   my_XMS_var_addr:=LOCKXMS(my_XMS_var);

To access it as a string:

   PUTSTR('Hallo World',my_XMS_var_addr);
   WRITELN(GETSTR(my_XMS_var_addr));

To free it:
   UNLOCK(my_XMS_var);
   FREEMEMXMS(my_XMS_var);

...and that's it.

One last remark. Suppose you want to access my_XMS_var as an
array[1..4]:string, and you want to read/write the n'th string, use:
   my_XMS_var_addr+(n-1)*length(string)
as arguement for PUTSTR and GETSTR.


DISCLAIMER:
----------
I nor anybody else can take ANY responsibility for ANY damage done,
resulting from, or linked to, the use of this code.
(enough CYA-ness for me :-)

If you do find a bug that bytes you, do tell me. I'll try to fix it.


BYE
---

You can reach me at:

marxh@alpha.unisa.ac.za
or on the pascal discussion list: PASCAL-L@vm.ege.edu.tr

Harry Marx.
Dept. Computer Services (Library System Development)
UNISA
0003
South Africa

{ ----------------------   XX3402 code for FLATMEM.ZIP ------------- }


ENCODED FLATMEM.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.