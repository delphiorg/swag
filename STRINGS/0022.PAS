(*
    TURBO PASCAL LIBRARY 2.0
    STRINGS unit: Extended string-handling routines
*)

UNIT STRINGS;

{ THESE FILES ARE XX34 AT THE BOTTOM OF THE LISTING }

{$L SUCASE}
{$L SUTRIM}
{$L SUPAD}
{$L SUTRUNC}
{$L SUCNVRT}
{$L SUMISC}

{$V-}

INTERFACE

TYPE
    FormatConfigRec =   RECORD
                            Fill,               { Symbol for padding }
                            Currency,           { Floating currency sign }
                            Overflow,           { Overflow indicator }
                            FracSep:    CHAR;   { Int/frac seperator }
                        END;


CONST
    UCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    LCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    Letters = UCaseLetters+LCaseLetters;
    DecDigits = '0123456789';
    HexDigits = '0123456789ABCDEF';
    OctDigits = '01234567';
    BinDigits = '01';

    { Format symbol record }
    FormatConfig: FormatConfigRec =
            (Fill: '*'; Currency: '$'; Overflow: '?'; FracSep: '-');



FUNCTION LoCase(ch: CHAR): CHAR;
FUNCTION UpperCase(s: STRING): STRING;
FUNCTION LowerCase(s: STRING): STRING;
FUNCTION DuplChar(ch: CHAR; count: BYTE): STRING;
FUNCTION DuplStr(s: STRING; count: BYTE): STRING;
FUNCTION TrimL(s: STRING): STRING;
FUNCTION TrimR(s: STRING): STRING;
FUNCTION PadL(s: STRING; width: BYTE): STRING;
FUNCTION PadR(s: STRING; width: BYTE): STRING;
FUNCTION TruncL(s: STRING; width: BYTE): STRING;
FUNCTION TruncR(s: STRING; width: BYTE): STRING;
FUNCTION JustL(s: STRING; width: BYTE): STRING;
FUNCTION JustR(s: STRING; width: BYTE): STRING;
FUNCTION JustC(s: STRING; width: BYTE): STRING;
FUNCTION Precede(s,target: STRING): STRING;
FUNCTION Follow(s,target: STRING): STRING;
FUNCTION Break(VAR s: STRING; d: STRING): STRING;
FUNCTION Span(VAR s: STRING; d: STRING): STRING;
FUNCTION Replace(s,srch,repl: STRING): STRING;
FUNCTION Remove(s,srch: STRING): STRING;
FUNCTION StripBit7(s: STRING): STRING;
FUNCTION FileSpecDefault(s,path,name,extn: STRING): STRING;
FUNCTION HexStr(n: WORD; count: BYTE): STRING;
FUNCTION OctStr(n: WORD; count: BYTE): STRING;
FUNCTION BinStr(n: WORD; count: BYTE): STRING;
FUNCTION Format(n: REAL; form: STRING): STRING;


IMPLEMENTATION

USES
    DOS;


FUNCTION LoCase(ch: CHAR): CHAR; EXTERNAL;
FUNCTION UpperCase(s: STRING): STRING; EXTERNAL;
FUNCTION LowerCase(s: STRING): STRING; EXTERNAL;
FUNCTION DuplChar(ch: CHAR; count: BYTE): STRING; EXTERNAL;


FUNCTION DuplStr(s: STRING; count: BYTE): STRING;

    VAR
        ds: STRING;
        i:  BYTE;

    BEGIN
        ds:='';
        FOR i:=1 TO count DO
            ds:=CONCAT(ds,s);
        DuplStr:=ds;
    END;


FUNCTION TrimL(s: STRING): STRING; EXTERNAL;
FUNCTION TrimR(s: STRING): STRING; EXTERNAL;
FUNCTION PadL(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION PadR(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION TruncL(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION TruncR(s: STRING; width: BYTE): STRING; EXTERNAL;


FUNCTION JustL(s: STRING; width: BYTE): STRING;

    BEGIN
        JustL:=PadR(TruncR(TrimL(TrimR(s)),width),width);
    END;


FUNCTION JustR(s: STRING; width: BYTE): STRING;

    BEGIN
        JustR:=PadL(TruncL(TrimL(TrimR(s)),width),width);
    END;


FUNCTION JustC(s: STRING; width: BYTE): STRING;

    BEGIN
        s:=TruncR(TrimL(TrimR(s)),width);
        IF LENGTH(s)>=width THEN
            JustC:=s
        ELSE
            JustC:=PadR(CONCAT(DuplChar(#32,(width-LENGTH(s)) DIV 2),s),width);
    END;


FUNCTION Precede(s,target: STRING): STRING;

    VAR
        i:  BYTE;

    BEGIN
        i:=POS(target,s);
        IF i=0 THEN             { Return entire string if target not found }
            Precede:=s
        ELSE
            Precede:=COPY(s,1,i-1);
    END;


FUNCTION Follow(s,target: STRING): STRING;

    VAR
        i:  BYTE;

    BEGIN
        i:=POS(target,s);
        IF i=0 THEN             { Return null string if target not found }
            Follow:=''
        ELSE
            Follow:=COPY(s,i+LENGTH(target),255);
    END;


FUNCTION Break(VAR s: STRING; d: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        i:=0;                                   { Index to input string }
        f:=FALSE;                               { Set when delim. found }
        WHILE (i<LENGTH(s)) AND (NOT(f)) DO     { For each char. in input }
            BEGIN
                INC(i);
                j:=1;                           { Index to delim. string }
                WHILE (j<=LENGTH(d)) AND (NOT(f)) DO { Scan for each delim. }
                    IF s[i]=d[j] THEN
                        f:=TRUE
                    ELSE
                        INC(j);
            END;
        IF NOT(f) THEN
            INC(i);
        Break:=COPY(s,1,i-1);           { Return sub-string up to delimiter }
        s:=COPY(s,i,255);               { and remove from the input string }
    END;


FUNCTION Span(VAR s: STRING; d: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        i:=0;                               { Index to input string }
        f:=FALSE;
        WHILE (i<LENGTH(s)) AND (NOT(f)) DO { For each char. in input }
            BEGIN
                INC(i);
                FOR j:=1 TO LENGTH(d) DO    { Check for specified chars. }
                    IF s[i]=d[j] THEN
                        f:=TRUE;
                f:=NOT(f);
            END;
        IF NOT(f) THEN
            INC(i);
        Span:=COPY(s,1,i-1);                { Return span of specified chrs }
        s:=COPY(s,i,255);                   { and remove from the input }
    END;



FUNCTION Replace(s,srch,repl: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        IF LENGTH(srch)>LENGTH(repl) THEN       { Ignore search chrs. }
            srch[0]:=CHR(LENGTH(repl));         { without replacements }
        FOR i:=1 TO LENGTH(s) DO                { For each char. in input }
            BEGIN
                j:=1;
                f:=FALSE;                       { Scan all search characters }
                WHILE (j<=LENGTH(srch)) AND (NOT(f)) DO
                    IF s[i]=srch[j] THEN
                        BEGIN
                            s[i]:=repl[j];      { Replace if found }
                            f:=TRUE;
                        END
                    ELSE
                        INC(j);
            END;
        Replace:=s;
    END;


FUNCTION Remove(s,srch: STRING): STRING;

    VAR
        i,j:    BYTE;

    BEGIN
        FOR i:=1 TO LENGTH(srch) DO     { For each search character }
            REPEAT
                j:=POS(srch[i],s);      { Repeat search in input string & }
                IF j<>0 THEN            { delete if found until no more }
                    DELETE(s,j,1);
            UNTIL j=0;
        Remove:=s;
    END;


FUNCTION StripBit7(s: STRING): STRING; EXTERNAL;


FUNCTION FileSpecDefault(s,path,name,extn: STRING): STRING;

    VAR
        d:  DirStr;
        n:  NameStr;
        e:  ExtStr;

    BEGIN
        FSplit(s,d,n,e);        { Split file spec. into path, name, & ext. }
        IF LENGTH(d)=0 THEN     { For each field, add default if none }
            d:=path;
        IF LENGTH(n)=0 THEN
            n:=name;
        IF LENGTH(e)=0 THEN
            e:=extn;
        FileSpecDefault:=CONCAT(d,n,e);
    END;


FUNCTION HexStr(n: WORD; count: BYTE): STRING; EXTERNAL;
FUNCTION OctStr(n: WORD; count: BYTE): STRING; EXTERNAL;
FUNCTION BinStr(n: WORD; count: BYTE): STRING; EXTERNAL;


FUNCTION Format(n: REAL; form: STRING): STRING;

    VAR
        s1,s2:                  STRING;
        width,dp,sign,i,j:      BYTE;
        pad,currency:           CHAR;
        blank,zero,left,paren,
        comma,adjust,reduce:    BOOLEAN;
        x:                      INTEGER;


    { Reduce fraction to lowest possible denominator }

    PROCEDURE ReduceFraction(VAR num,denom: BYTE);

        VAR
            i:  BYTE;

        BEGIN
            FOR i:=denom DOWNTO 2 DO
                IF ((num MOD i)=0) AND ((denom MOD i)=0) THEN
                    BEGIN
                        num:=num DIV i;
                        denom:=denom DIV i;
                    END;
        END;  { ReduceFraction }


    BEGIN  { Format }
        form:=UpperCase(form);
        s1:=Break(form,CONCAT(DecDigits,':'));      { Get leading options }
        IF POS('A',s1)<>0 THEN                      { Absolute value, no sign }
            n:=ABS(n);
        blank:=POS('B',s1)<>0;                      { Blank if zero }
        zero:=POS('Z',s1)<>0;                       { Zero-fill/zero-show }
        left:=POS('L',s1)<>0;                       { Left justify }
        comma:=(POS(',',s1)<>0) OR (POS('C',s1)<>0);    { Commas }
        reduce:=POS('R',s1)=0;                      { No reduction }
        paren:=POS('P',s1)<>0;                      { Negative in parenth. }
        IF POS('+',s1)<>0 THEN                      { Check leading + }
            sign:=1
        ELSE
            sign:=0;
        IF POS('*',s1)<>0 THEN                      { Set fill character }
            pad:='*'
        ELSE
            IF POS('F',s1)<>0 THEN
                pad:=FormatConfig.Fill
            ELSE
                pad:=' ';
        IF POS('$',s1)<>0 THEN                      { Set currency symbol }
            currency:=FormatConfig.Currency
        ELSE
            currency:=#0;
        s1:=Break(form,CONCAT('+- ',#9));           { Get width:decimals }
        IF POS('-',form)<>0 THEN                    { Check trailing +/- sign }
            sign:=3;
        IF POS('+',form)<>0 THEN                    
            sign:=2;

        s2:=Follow(s1,':');             { s2 is decimals }
        s1:=Precede(s1,':');            { s1 is width }
        VAL(s1,width,x);
        IF x<>0 THEN                    { Default width 12 }
            width:=12;
        IF COPY(s2,1,1)='/' THEN        { Use vulgar fractions }
            BEGIN
                n:=ABS(n);                          { Force absolute value }
                sign:=0;                            { Disable sign display }
                DELETE(s2,1,1);
                VAL(s2,i,x);
                IF (x<>0) OR (i<2) OR (i>99) THEN   { Default resolution 1/2 }
                    i:=2;
                j:=ROUND(FRAC(n)/(1.0/i));          { Calculate fraction }
                adjust:=(j=i);                      { Allow for rounding }
                IF adjust THEN
                    j:=0;
                IF reduce THEN                      { Reduce fraction }
                    ReduceFraction(j,i);
                STR(j,s1);
                STR(i,s2);
                IF j=0 THEN                         { Format fraction }
                    s2:=DuplChar(pad,6)
                ELSE
                    BEGIN
                        s2:=CONCAT(s1,'/',s2);
                        IF (INT(n)=0) AND NOT(zero) THEN
                            s2:=CONCAT(pad,s2)
                        ELSE
                            s2:=CONCAT(FormatConfig.FracSep,s2);
                        s2:=CONCAT(s2,DuplChar(pad,6-LENGTH(s2)));
                    END;
                IF (INT(n)=0) AND NOT(zero) AND (j<>0) THEN
                    s1:=s2
                ELSE
                    BEGIN                           { Format integral part }
                        IF adjust THEN
                            STR(INT(n)+1:0:0,s1)
                        ELSE
                            STR(INT(n):0:0,s1);
                        s1:=CONCAT(s1,s2);
                    END;
                zero:=FALSE;                        { Disable zero-fill }
            END
        ELSE
            BEGIN                       { Use decimal fractions }
                VAL(s2,dp,x);               { Get number of decimal places }
                IF x<>0 THEN                { Default to zero decimals }
                    dp:=0;
                STR(ABS(n):0:dp,s1);
            END;

        IF comma THEN                   { Insert commas if necessary }
            BEGIN
                s2:=Span(s1,DecDigits);
                i:=(LENGTH(s2)-1) DIV 3;    { i is no. of commas to insert }
                FOR j:=1 TO i DO
                    INSERT(',',s2,LENGTH(s2)-(j-1)-(j*3-1));
                s1:=CONCAT(s2,s1);
            END;
        IF currency<>#0 THEN            { Add floating currency symbol }
            s1:=CONCAT(currency,s1);
        IF paren THEN                   { Add signs as required }
            BEGIN
                IF n<0 THEN
                    s1:=CONCAT('(',s1,')')
                ELSE
                    IF NOT(left) THEN
                        s1:=CONCAT(s1,' ');
            END
        ELSE
            CASE sign OF
                0:  IF n<0 THEN                 { Leading - }
                        s1:=CONCAT('-',s1);
                1:  IF n<0 THEN                 { Leading + }
                        s1:=CONCAT('-', s1)
                    ELSE
                        s1:=CONCAT('+',s1);
                2:  IF n<0 THEN                 { Trailing + }
                        s1:=CONCAT(s1,'-')
                    ELSE
                        s1:=CONCAT(s1,'+');
                3:  IF n<0 THEN                 { Trailing - }
                        s1:=CONCAT(s1,'-')
                    ELSE
                        IF NOT(left) THEN
                            s1:=CONCAT(s1,' ');
            END;
        WITH FormatConfig DO
            IF LENGTH(s1)>width THEN            { Check for field overflow }
                Format:=DuplChar(Overflow,width)
            ELSE
                IF blank AND
                (LENGTH(Remove(s1,CONCAT('0. ()+-*',Fill,Currency)))=0) THEN
                    Format:=DuplChar(#32,width) { Blank if rounded=zero }
                ELSE
                    IF zero THEN                { Pad field to width }
                        BEGIN
                            s2:=Break(s1,DecDigits);
                            Format:=CONCAT(s2,DuplChar('0',
                                        width-(LENGTH(s2)+LENGTH(s1))),s1);
                        END
                    ELSE
                        IF left THEN
                            Format:=CONCAT(s1,DuplChar(pad,width-LENGTH(s1)))
                        ELSE
                            Format:=CONCAT(DuplChar(pad,width-LENGTH(s1)),s1);
    END;  { Format }


END.

(*


ENCODED STRASM.ZIP FILE REMOVED.  PLEASE DOWNLOAD EITHER THE 
ATTACHMENT OR THE COMPLETE ZIP FILE.