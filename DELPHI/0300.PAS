
These units demonstrate the implementation of a TextSort engine,
which uses a three-way merge for Memory and a five-way merge for files.
I've wrote this because I've wasted so mucht time waiting for sorting.
It's very fast, one Million lines with an average length of 40 in 210 seconds.
It isn't true that QuickSort is the fastest Algorithm available.
This is only true for pure Integer or Word arrays.
With text or records MergeSort can compete and is in many cases faster.
In all cases of interrest it may be slightly slower in the worst case but
it can overcome Quicksort several times, especialy with large keys or
a time intensive comparision like AnsiCompareText.

This implementation is very fast but not the fastest possible.
There are some ways to improve it.

You can compile it with Delphi 2+3 and the BCB, with little changes with
Delphi 1 too.
It will be fast with Delphi 1 too, because it can run in little memory.

TTextSort has no compare function:
You must provide one like this!

function Compare(Item1, Item2: Pointer): Integer;
begin
   Result:= CompareText(PMergeData(Item1)^.Data, PMergeData(Item2)^.Data);
end;

Put it with the constructor.
TextSort:= TTextSort.Create(Compare);

With MaxLines you can determine the maximum number of lines for the in-memory
merge. More than 200000 are seldom useful.
With MaxMem you can determine the maximum number of Bytes for the in-memory
merge. More than 1/3 of main momory is seldom useful.

E-Mail me at Martin.Waldenburg@t-online.de

{ ------------------------- snip, snip ----------------------------}

ENCODED MWTXTSOR.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
