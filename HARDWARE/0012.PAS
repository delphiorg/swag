Unit CPU;

INTERFACE

Type
  CpuType = ( cpu8088,
              cpu8086,
              cpu80286,
              cpu80386,
              cpu80486,
              cpuPentium,
              cpuFuture
             );
  CpuStrType = String[7];

Function GetCpuType : CpuType;
  { Returns the currently executing CPU type }

Function GetCpuTypeStr : CpuStrType;
  { Returns the currently executing CPU type as a string }

IMPLEMENTATION

Const
  CpuTypeIdentified : Boolean = False;
Var
  ConfirmedCpuType : CpuType;

{$L CPU.OBJ}

{$F+}
Function WhichCPU : CpuType;
  { Determines and returns the currently executing CPU type }
EXTERNAL;
{$F-}

Procedure IdentifyCpuType;
  { Handles initialization of CPU type }
Begin
  If Not CpuTypeIdentified Then
  Begin
    ConfirmedCpuType  := WhichCPU;
    CpuTypeIdentified := True;
  End;
End;   { Procedure IdentifyCpuType }

Function GetCpuType : CpuType;
  { Returns the currently executing CPU type }
Begin
  IdentifyCpuType;
  GetCpuType := ConfirmedCpuType;
End;   { Function GetCpuType }

Function GetCpuTypeStr : CpuStrType;
  { Returns the currently executing CPU type as a string }
Begin
  IdentifyCpuType;
  Case ConfirmedCpuType Of
    cpu8088    : GetCpuTypeStr := '8088';
    cpu8086    : GetCpuTypeStr := '8086';
    cpu80286   : GetCpuTypeStr := '80286';
    cpu80386   : GetCpuTypeStr := '80386';
    cpu80486   : GetCpuTypeStr := '80486';
    cpuPentium : GetCpuTypeStr := 'Pentium';
    cpuFuture  : GetCpuTypeStr := 'Future';
  End;   { Case }
End;   { Function GetCpuTypeStr }

End.
{ eof CPU.PAS }


{------------------------- snip, snip ----------------------------}

ENCODED CPU.OBJ FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.