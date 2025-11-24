
{
This is for all who wanted sometimes have a set with more than 256 elements.

The type defined for this is "BigSet". It may have up to 500 000 elements.
You need it initialize befor use with function bsInit and
at the end of program free memory for each BigSet-variable with bsDone.
  Any function returns TRUE if it's all OK, 
and FALSE when 
- the variable is not initialized (aray=nil), 
- the given parameters don't match (n out of <min, max> etc...), 
- we make anything with two BigSets, which have different range (min..max)
  (it would go, but I'm lazy ;-)

If you want the .asm sources of adddelin.obj, andorsub.obj and clrfill.obj,
my e-mail is: qmuller@fi.muni.cz.

{ cut here - JMBIGSET.PAS ---------------------------------------- }

{$X+}

{ Performs using of SETs, which may have up to 500 000 elements! }
{ Elements of BigSets are longint numbers}

unit jmbigset;

interface

type Paray=^Taray;
     Taray= array[0..31249] of word;
     BigSet=record
              aray:Paray;
              total:longint;
              minel:longint;
              maxel:longint;
             end;

Function bsInit(var bs: BigSet; min, max:longint):boolean;
 { initialize any BigSet variable befor use! }
 { min - minimal element of set, max - maximal elem. of set }
 { condition: (max-min) <= 500000 }
 { returns false if initialization is not possible }
Procedure bsDone(var bs: BigSet);
function bsAdd(var a: BigSet; n:longint):boolean;        { a:= a + [n] }
function bsDel(var a: BigSet; n:longint):boolean;        { a:= a - [n] }
function bsIn(var a: BigSet; n:longint):boolean;         { test n IN a }
Function bsAnd(var p:BigSet; a,b:BigSet):boolean;        { p:=a * b }
Function bsOr (var p:BigSet; a,b:BigSet):boolean;        { p:=a + b }
Function bsSub(var p:BigSet; a,b:BigSet):boolean;        { p:=a - b }
Function bsEQ(a,b: BigSet):boolean;                      { test a=b }
Function bsLE(a,b: BigSet):boolean;                      { test a<=b }
Function bsMov(var a: BigSet; b: BigSet):boolean;        { a:=b }
Function bsClear(var a: BigSet):boolean;                 { a:=[] }
Function bsFill(var a: BigSet):boolean;                  { a:=[minel..maxel] }
Function bsAddInt(var a: BigSet; m,n: longint):boolean;  { a:=a + [m..n] }
Function bsDelInt(var a: BigSet; m,n: longint):boolean;  { a:=a - [m..n] }


implementation
{$L ADDDELIN.OBJ}
function bsAdd(var a: BigSet; n:longint):boolean;  external;
function bsDel(var a: BigSet; n:longint):boolean;  external;
function bsIn(var a: BigSet; n:longint):boolean;   external;
{$L ANDORSUB.OBJ}
Function bsAnd(var p:BigSet; a,b:BigSet):boolean;  external;
Function bsOr (var p:BigSet; a,b:BigSet):boolean;  external;
Function bsSub(var p:BigSet; a,b:BigSet):boolean;  external;
Function bsEQ(a,b: BigSet):boolean;  external; 
Function bsLE(a,b: BigSet):boolean;  external; 
Function bsMov(var a: BigSet; b: BigSet):boolean; external; 
{$L CLRFILL.OBJ}
Function bsClear(var a: BigSet):boolean; external;
Function bsFill(var a: BigSet):boolean;  external;  

Function bsAddInt(var a: BigSet; m,n: longint):boolean; 
var i,lm,nl:longint; q:boolean;
begin
     q:=(m<=n) and (a.aray<>nil);
     if q then
     begin
          if a.minel>m then lm:=a.minel else lm:=m;
          if a.maxel<n then nl:=a.maxel else nl:=n;
          for i:=lm to nl do bsAdd(a,i)
     end;
     bsAddInt:=q;
end;

Function bsDelInt(var a: BigSet; m,n: longint):boolean;  {a:=a-[m..n]}
var i,lm,nl:longint; q:boolean;
begin
     q:=(m<=n) and (a.aray<>nil);
     if q then
     begin
          if a.minel>m then lm:=a.minel else lm:=m;
          if a.maxel<n then nl:=a.maxel else nl:=n;
          for i:=lm to nl do bsDel(a,i)
     end;
     bsDelInt:=q;
end;

Function bsInit(var bs: BigSet; min, max:longint):boolean;
var q:boolean;
    i,size:longint;
begin
   q:=(min<max) and (max-min <= 500000) and (bs.aray=nil);
   if q then
   begin
     size:=(max-min+15) div 16;
     with bs do begin
                  GetMem(aray,size*2);
                  total:=0; minel:=min; maxel:=max;
                  for i:=0 to size-1 do aray^[i]:=0;
                 end;
   end;
  bsInit:=q;
end;

Procedure bsDone(var bs: BigSet);
var size:longint;
begin
     if bs.aray=nil then exit;
     size:=(bs.maxel-bs.minel+15) div 16;
     FreeMem(bs.aray,size);
     bs.aray:=nil;
end;


end.
{ cut here - EXAMPLE.PAS ---------------------------------- }

{a very simple example:}

{$X+}
uses jmbigset;
var a,b,c: bigset;
    n: longint;
begin
   writeln;
   bsinit(a,1,1000);
   bsinit(b,1,1000);
   bsinit(c,1,1000);

   bsaddint(a, 1, 500);    { a = [1..500] }
    writeln('set a has ',a.total,' elements');
   bsaddint(b, 490, 800);  { b = [490.. 800] }
    writeln('set b has ',b.total,' elements');
   bsand(c, a, b);         { c = a*b =[490..500] }
    writeln('set c has ',c.total,' elements');
   for n:=1 to 1000 do if bsin(c, n) then write(n,' ');

   bsdone(a); bsdone(b); bsdone(c);
end.

{ cut here - ADDDELIN.XX ------------------------------------ }

ENCODED ADDDELIN.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{ cut here - ANDORSUB.XX ------------------------------------ }

ENCODED ANDORSUB.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.

{ cut here - CLRFILL.XX ------------------------------------ }

ENCODED CLRFILL.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.