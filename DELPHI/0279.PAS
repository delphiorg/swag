
!! NOTE:  The code is contained the XX3402 file below.  Cut out and extract.


tObjectList & tSortedObjectList: Real containers for tObject descendants

I wrote this tool because of 3 areas where I felt Delphi was weak. Delphi's
containers are weak in two areas  : Iteration and object disposal. Delphi's
stream support is un-documented. It's might be in there, but you have to do
detective work. As far as I know, non component streaming is not supported.

A container  should  give  ways  to  iterate  it's  content easily. None of
Delphi's containers  (tStrings, tStringList )  have iterator functions.  As
for  disposal, an  object container  should free  it's objects  in it's own
destructor. I'm not talking of GUI objects here, but of real world objects.
By this I mean  non GUI objects. Let's not forget that  GUI is only a tool.
The real  work, the work we  get paid for, is  behind the GUI, and  that is
also OOP. If a Form owns a container full of non-GUI objects, the container
should take care of disposing of it's content.

tStringList doesn't  dispose of it's  objects (it does  free it's strings).
This last problem would have been easy to  fix if it had been the only one,
but  we  still  have  the  streaming   problem.  As  far  as  I  can  tell,
tStringList's stream support is limited to  it's string content, even if it
can hold both objects and strings,

For those  of you new  to Pascal, tCollection  was the container  that came
with BP7. I found tCollection to be very fast and easy to use. It supported
easy streaming and it had very good iterator functions.

Robert Daignault
LPL Soft

{ ---------------------   CUT  ---------------------- }

ENCODED CONTAIN.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.
