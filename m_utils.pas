//------------------------------------------------------------------------------
// Name        : m_utils
// Purpose     : Implementatie van utilities.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : -
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_utils;

{$mode objfpc}{$H+}

interface

uses Dialogs, Graphics, SysUtils, Classes, Forms,
     Controls, ExtCtrls, Windows;

const
  TAB = chr(9);


type
  TDirOption = (do_Normal, do_Recursive, do_SubdirsOnly);

(*
type
  TimeZoneInformation = record
    Bias:             Int64;
    StandardName:     array[0..32] of WCHAR;
    StandardDate:     SYSTEMTIME;
    StandardBias:     Longint;
    DaylightName:     array[0..32] of WCHAR;
    DaylightDate:     SYSTEMTIME;
    DaylightBias:     Int64;
  end {TimeZoneInformation};
type PTimeZoneInformation = ^TimeZoneInformation;
*)

function BooleanToYesNo(b: boolean): string;
function YesNoToBoolean(s: string): boolean;

function StripLeadingZeros(s: string): string;

{$IFDEF DEVELOP}
procedure DbMsg(s: string);
{$ENDIF}

procedure KillProcess(Pid: integer);

function  SubstFirst(InString, SearchString, WithString: string): string;

function  CheckInvalidCharactersDirectory(DirName: string): string;
function  CheckInvalidCharactersFileEntry(FileEntry: string): string;

function  DblQuoteFileName(FileName: string): string;
function  StrClad(S, Clad: string): string;
function  IsValidFileEntry(s: string): boolean;

function  DoubleToStrE(dd: double; precision: integer; digits: integer): string;

procedure ProcessMessages;

function  GetPathNoDrive(s: string): string;
function  GetDrive(Dir: string): string;

procedure MsgSystemModal(s: string; c: string);
function  MsgSystemModalYesNo(s: string; c: string): integer;

//function  FileGetTempName: string;
function  GetScratchFileName: string;

function  MonthOfYear(m: integer): string;

function  PointInRect(p: TPoint; r: TRect): boolean;

procedure WindowWaitFor(s: string);

procedure WindowActivateByCaption(s: string);

procedure WindowHide(h: HWnd);
procedure WindowMaximize(h: HWnd);
procedure WindowMinimize(h: HWnd);
procedure WindowRestore(h: HWnd);

function  GetQuotedString(s: string): string;
function  ExtractQuotedString(s: string; n: integer): string;

function  WaitGetIndex: double;

function  RemoveLastBackslash(s: string): string;

function  ReplaceTabsBySpaces(s: string): string;

procedure DirMake(s: string);

function  FileIsReadOnly(FileName: string): boolean;
procedure FileSetReadOnly(FileName: string; Flag: boolean);
function  FileIsHidden(FileName: string): boolean;
procedure FileSetHidden(FileName: string; Flag: boolean);
function  HiddenFileExists(FileName: string): boolean;

procedure FileTouch(FileName: string);

procedure FileWriteString(FileName: string; s: string);
procedure FileAppendString(FileName: string; s: string);

function  WindowScreenHeight: integer;
function  WindowScreenWidth: integer;

function  SingleToStrF(ss: single; w: integer; d: integer): string;
function  DoubleToStrF(dd: double; w: integer; d: integer): string;

function  DirExists(s: string): boolean;

function  StrToDouble(s: string): double;

function  DoubleRound(d: double; digits: integer): double;

procedure FileCopy(Source, Dest: string);
procedure DirCopy(Source, Dest: string);
procedure DirDelete(Dir: string; Option: TDirOption);
function DirIsEmpty(const inDir: string) : boolean;overload;
function DirIsEmpty(const inDir:string;
                    FileAllowedList: TStringList):boolean;overload;
procedure DirFileList(const inDir, inFilePattern: string;
                      var FileList: TStringList;
                      IncludePathInList:boolean=true);
procedure DirSubDirList(const inDir: string; var SubDirList: TStringList);
procedure DirClear(const inDir: string;
                   const inFilePattern: string = '*.*';
                   Option: TDirOption = do_Recursive);
procedure DirCleanse(const inDir: string;
                     FileToRemoveList,
                     FileAllowedList: TStringList;
                     Option: TDirOption = do_Recursive);
function DirContainsFilePattern(const inDir,
                                inFilePattern: string):boolean;overload;
function DirContainsFilePattern(const inDir: string;
                                inFileToRemoveList: TStringList;
                                inFileAllowedList: TStringList):integer;overload;
function  MinDouble(i,j: double): double;
function  MaxDouble(i,j: double): double;
procedure LatLongToRDM(b,l: double; var x: double; var y: double);
procedure SwapDouble(var a, b: double);

procedure SetMetricsUK;
procedure SetMetricsDutch;

function  SingleToStr(s: single): string;
function  DoubleToStr(d: double): string;

//function  MinSingle(i,j: single): single;
//function  MaxSingle(i,j: single): single;
//procedure SwapSingle(var a, b: single);

function  BitOn(const val: integer; const TheBit: byte): integer;
function  BitOff(const val: integer; const TheBit: byte): integer;
function  BitToggle(const val: integer; const TheBit: byte): integer;
function  Ceil(r: single): integer;
procedure ColorToRGB(Color: TColor; var R,G,B:byte);
function  Extract(s:string; token:integer; delimiter:char): string;
function  FillSpaces(len: integer): string;
function  GetCurrentWorkDirectory: string;
function  IntToMonth(m: integer): string;
function  IsBitSet(const val: integer; const TheBit: byte): boolean;
function  IsInRange(s,mins,maxs: string): boolean;
function  IsInRangeMsg(s,mins,maxs: string): boolean;
function  IsIntegerInRangeMsg(s,mins,maxs: string): boolean;
function  IsSingleInRangeMsg(s,mins,maxs: string): boolean;
function  IsInteger(s: string): boolean;
function  IsIntegerMsg(s: string): boolean;
function  IsDouble(s: string): boolean;
function  IsSingle(s: string): boolean;
function  IsSingleMsg(s: string): boolean;
function  IsSingleOrIntegerMsg(s: string): boolean;
function  Log10(r: double): double;
function  Max(i,j: integer): integer;
function  MaxSingle(i,j: single): single;
function  Min(i,j: integer): integer;
function  MinSingle(i,j: single): single;
procedure Msg(s: string);
procedure MsgWarning(s: string);
procedure MsgError(s: string);
procedure MsgErrorTerminate(s: string);
function  MsgYesNo(s: string): word;
function  MsgOKCancel(s: string): word;
function  MsgYesNoCancel(s: string): word;
procedure MsgInt(l: integer);
function  Power(a,b: double): double;
function  Power3(r: double): double;
function  RGBToColor(R,G,B:integer): TColor;
function  StrAlignLeft(s: string; len: integer): string;
function  StrAlignRight(s: string; len: integer): string;
function  Stuff(s: string; pos: integer; ss: string): string;
function  Subst(InString, SearchString, WithString: string): string;
procedure SwapInt(var a, b: integer);
procedure Swapinteger(var a, b: integer);
function  TrimL(s:string): string;
function  TrimR(s:string): string;
function  Trim(s:string): string;
function  UnifiedFileDir(s: string): string;
function  UnifiedFileDirEntry(d: string; f: string): string;
function  UnifiedFileEntry(s: string): string;
function  UnifiedFileName(s: string): string; { FileDir + FileEntry }
procedure Wait(NumMSec: integer);
function  WaitCalculateIndexCount: integer;
function  WaitCalculateIndex: double;
procedure WaitIndexed(Count: integer);
procedure WaitWithBreak(NumMSec: integer);
procedure WaitBreak;
procedure WindowActivate(h: HWnd);
procedure WindowCenterOnScreen(Form: TForm; SizePercentage: integer);
procedure WindowClose(Caption: string);
procedure WindowsClose;
procedure WindowTopMost(Caption: string);
function  WindowGetHandle(s: string): HWnd;
//<vh200408>
//function  GetEnvironmentString(inName: string): string;
function  IsNil(inVal: String):Boolean;
//procedure ConvertStr2PChar(inVal: String; var outVal: PChar);overload;
function  ConvertStr2PChar(inVal: String): PChar;overload;
function  UTC2DateTime(const UTCTime: LongInt) : TDateTime;
function  DateTime2UTC(const T: TDateTime): LongInt;
function  MyDateTime2Str(const T: TDateTime):String;
function  UTC2Str(const UTCTime: LongInt):String;
function  GetTotalTimeSecondsBias: Longint;
function  Copy2String(const PchVal: PChar): String; overload;
function  Copy2String(const IntVal: Integer): String; overload;
//function  Copy2String(const ExtendedVal: Extended): String; overload;
function  SubstNoCase(InString, SearchString, WithString: string): string;
function  GetTheFileSize(f: String): Integer;
function AddPathSeparator(s: string): string;

implementation

uses m_constant,
     m_error,
     strutils;

var
  _WaitBreak: boolean;
  _WaitIndexCount: integer;
  _WaitIndex: double;
  ControlEvents: TList;

// -----------------------------------------------------------------------------
// Geeft YES of No terug.
function BooleanToYesNo(b: boolean): string;
begin
  if b then
    Result:='NO'
  else
    Result:='YES'
end;

// -----------------------------------------------------------------------------
// Geeft True terug indien s is YES, anders False.
// Is case-insensitive.
function YesNoToBoolean(s: string): boolean;
begin
  Result:=SameText(s,'YES');
end;

// -----------------------------------------------------------------------------
// Verwijderd voorlopende nullen.
function StripLeadingZeros(s: string): string;
begin
  while Length(s)>0 do
  begin
    if s[1]='0' then
      Delete(s,1,1)
    else
      break;
  end;
  Result:=s;
end;

{$IFDEF DEVELOP}
// -----------------------------------------------------------------------------
procedure DbMsg(s: string);
begin
  if TestForm=nil then
    TestForm:=TTestForm.Create(nil);
  TestForm.Debug(s);
end;
{$ENDIF}

// -----------------------------------------------------------------------------
procedure KillProcess(Pid: integer);
begin
  TerminateProcess(OpenProcess(PROCESS_TERMINATE,Bool(1),Pid),0);
end;

// -----------------------------------------------------------------------------
function  DblQuoteFileName(FileName: string): string;
begin
  // Verwijder quotes.
  FileName:=subst(FileName,'"','');
  if Pos(' ',FileName)>0 then
    FileName:='"'+FileName+'"';
  Result:=FileName;
end;

// -----------------------------------------------------------------------------
// Plak aan de voor en achterkant van string S de string Clad, als-ie er niet
// al staat
function StrClad(S, Clad: string): string;
var
  SReverse: string;
begin
  if Pos(Clad,S) > 1 then
  begin
    S := Clad + S;
  end;
  SReverse := ReverseString(S);
  if Pos(Clad,SReverse) > 1 then
  begin
    SReverse := Clad + SReverse;
    S := ReverseString(SReverse);
  end;
  Result:=S;
end;

// -----------------------------------------------------------------------------
// Geeft terug of er ongeldige karakters INVALIDCHARS in de string S voorkomen.
// Geeft de gevonden ongeldige karakters terug of een lege string.
function CheckInvalidCharacters(s: string; InvalidChars: string): string;
var
  t: string;
  i:integer;
begin
  t:='';
  // Controleer op ongeldige karakters.
  for i:=1 to Length(InvalidChars) do
  begin
    if pos(InvalidChars[i],s)>0 then
      t:=t+','''+InvalidChars[i]+'''';
  end;
  // Ongeldige karakters gevonden?
  if t<>'' then
  begin
    // Verwijder de eerste komma.
    Delete(t,1,1);
    // Vervang een eventuele spatie door het woord 'space'.
    t:=Subst(t,''' ''','space');
  end;
  Result:=t;
end;

// -----------------------------------------------------------------------------
// Geeft terug of er ongeldige karakters in de Directory voorkomen.
// Het verschil met CheckInvalidCharactersFileEntry is dat nu
// wel : en \ zijn toegestaan.
// Spaties worden ook niet toegestaan!
function  CheckInvalidCharactersDirectory(DirName: string): string;
const
  c_InvalidChars = ' /|[]<>+=;,';

begin
  Result:=CheckInValidCharacters(DirName,c_InvalidChars);
end;

// -----------------------------------------------------------------------------
// Geeft terug of er ongeldige karakters in de FileEntry (dus inclusief
// het pad) voorkomen.
// Het verschil met CheckInvalidCharactersDirectory is dat nu ook
// geen : en \ zijn toegestaan.
// Spaties worden ook niet toegestaan!
function  CheckInvalidCharactersFileEntry(FileEntry: string): string;
const
  c_InvalidChars = ' :\/|[]<>+=;,';
begin
  Result:=CheckInValidCharacters(FileEntry,c_InvalidChars);
end;

// -----------------------------------------------------------------------------
// Geeft terug of er ongeldige karakters in de FileEntry (dus exclusief
// het pad) voorkomen.
// Spaties worden ook niet toegestaan!
function IsValidFileEntry(s: string): boolean;
const
  c_InvalidChars = ' :\/|[]<>+=;,';
begin
  if CheckInValidCharacters(s,c_InvalidChars)='' then
    Result:=True
  else
    Result:=False;
end;
// -----------------------------------------------------------------------------
// TheBit parameter is counted from 0..31
function BitOn(const val: integer; const TheBit: byte): integer;
begin
  result := val or (1 shl TheBit);
end;

// -----------------------------------------------------------------------------
function BitOff(const val: integer; const TheBit: byte): integer;
begin
  result := val and not (1 shl TheBit);
end;

// -----------------------------------------------------------------------------
function BitToggle(const val: integer; const TheBit: byte): integer;
begin
  result := val xor (1 shl TheBit);
end;

// -----------------------------------------------------------------------------
function Ceil(r: single): integer;
begin
  if frac(r) > 0 then
    Ceil:=trunc(r)+1
  else
    Ceil:=trunc(r);
end;

// -----------------------------------------------------------------------------
procedure ColorToRGB(Color: TColor; var R,G,B:byte);
begin
  B:=Color and $00FF0000;
  G:=Color and $0000FF00;
  R:=Color and $000000FF;
end;

// -----------------------------------------------------------------------------
procedure DirCopy(Source, Dest: string);
var
  SearchRec: TSearchRec;
  Result: integer;
  NewSource: string;
  NewDest: string;
begin

  if Source[length(Source)] = '\' then
      Source:=copy(Source,1,length(Source)-1);

  if not DirExists(Source) then
  begin
    raise EInOutError.Create('Source directory does not exist.');
  end;

  if Dest[length(Dest)] = '\' then
      Dest:=copy(Dest,1,length(Dest)-1);

  if not DirExists(Dest) then
    DirMake(Dest);

  Result:=FindFirst(Source+'\*.*',faAnyFile,SearchRec);
  while Result = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      if (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        NewSource:=Source+'\'+SearchRec.Name;
        NewDest:=Dest+'\'+SearchRec.Name;
        DirCopy(NewSource,NewDest);
      end
      else
      begin
        NewSource:=Source+'\'+SearchRec.Name;
        NewDest:=Dest+'\'+SearchRec.Name;
        FileCopy(NewSource,NewDest);
      end;
      Application.ProcessMessages;
    end;
    Result:=FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
end;

// -----------------------------------------------------------------------------
procedure DirDelete(Dir: string; Option: TDirOption);
var
  SearchRec: TSearchRec;
  Result: integer;
  NewDir: string;
  FileName: string;
begin

  if Dir[length(dir)] = '\' then
    Dir:=copy(Dir,1,length(Dir)-1);

  if not DirExists(Dir) then
    raise EInOutError.Create('Directory does not exist');

  if Option = do_Recursive then
  begin
    Result:=FindFirst(Dir+'\*.*',faAnyFile,SearchRec);
    while Result = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        FileName:=Dir+'\'+SearchRec.Name;
        if FileIsReadOnly(FileName) then
          FileSetReadOnly(FileName,False);

        if (SearchRec.Attr and faDirectory) = faDirectory then
        begin
          NewDir:=Dir+'\'+SearchRec.Name;
          DirDelete(NewDir,option);
        end
        else
          SysUtils.DeleteFile(Dir+'\'+SearchRec.Name);
        Application.ProcessMessages;
      end;
      Result:=FindNext(SearchRec);
    end;
    SysUtils.FindClose(SearchRec);

    {$I-}
    RmDir(Dir);
    {$I+}
    if DirExists(Dir) then
      raise EInOutError.Create('Cannot remove directory');
  end
  else
  begin
    {$I-}
    RmDir(Dir);
    {$I+}
    if DirExists(Dir) then
      raise EInOutError.Create('Cannot remove directory');
  end;
end;


//------------------------------------------------------------------------------
// returns true if a given directory is empty, false otherwise
function DirIsEmpty(const inDir : string) : boolean;
var
  SearchRec :TSearchRec;
begin
  if not DirExists(inDir) then
  begin
    raise EInOutError.Create('Directory does not exist');
  end;

  try
    Result := (FindFirst(inDir+'\*.*', faAnyFile, SearchRec) = 0) AND
              (FindNext(SearchRec) = 0) AND
              (FindNext(SearchRec) <> 0) ;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;


//------------------------------------------------------------------------------
// returns true if a given directory is empty, false otherwise
function DirIsEmpty(const inDir:string;
                    FileAllowedList: TStringList):boolean;
var
  SearchRec :TSearchRec;
  BlnFound:boolean;
  i,res:integer;
begin
  Result:=true;
  if not DirExists(inDir) then
  begin
    raise EInOutError.Create('Directory does not exist');
  end;

  try
    res:=FindFirst(IncludeTrailingPathDelimiter(inDir)+'\*.*',faAnyFile,SearchRec);
    while res=0 do
    begin
      if (SearchRec.Name <> '.') and
         (SearchRec.Name <> '..') then
      begin
        BlnFound:=false;
        for i := 0 to FileAllowedList.Count - 1 do
        begin
          if (SameText(FileAllowedList[i],SearchRec.Name)) then
          begin
            BlnFound:=true;
          end;
        end;
        if (not BlnFound) then
        begin
          Result:=false;
          exit;
        end;
      end;
      res:=FindNext(SearchRec);
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;


//------------------------------------------------------------------------------
// Returns true if a given directory contains files of given pattern.
function DirContainsFilePattern(const inDir,
                                inFilePattern: string) : boolean;
var
  SearchRec :TSearchRec;
  res: Integer;
begin
  if not DirExists(inDir) then
  begin
    raise EInOutError.Create('Directory does not exist');
  end;

  Result := False;
  try
    res := FindFirst(IncludeTrailingPathDelimiter(inDir) + inFilePattern, faAnyFile, SearchRec);
    if (res = 0) then // found
    begin
      Result := True;
    end;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;


//------------------------------------------------------------------------------
// Returns true if a given directory contains files of given pattern.
// VH 20081007 Overloade versie gemaakt waarin toegevoegd een lijst met over te slaan namen
function DirContainsFilePattern(const inDir: string;
                                inFileToRemoveList: TStringList;
                                inFileAllowedList: TStringList):integer;
var
  Dir: String;
  FileListRemove, FileListAllow: TStringList;
  i,j: integer;
begin
  Result:=0;
  Dir := inDir;
  if Dir[length(Dir)] = '\' then
  begin
    Dir:=copy(Dir,1,length(Dir)-1);
  end;

  if not DirExists(Dir) then
  begin
    raise EInOutError.Create('Directory does not exist');
  end;

  FileListRemove:=TStringList.Create;
  FileListAllow:=TStringList.Create;
  try
    // Zet de in de directory voorkomende filenamen die moeten worden verwijderd
    // in FileListRemove
    for i := 0 to inFileToRemoveList.Count - 1 do
    begin
      DirFileList(Dir, inFileToRemoveList[i], FileListRemove);
    end;

    // Zet de in de directory voorkomende filenamen die mogen blijven
    // in FileListAllow
    for i := 0 to inFileAllowedList.Count - 1 do
    begin
      DirFileList(Dir, inFileAllowedList[i], FileListAllow);
    end;

    // Verwijder uit de FileListRemove de eventueel voorkomende namen uit
    // FileListAllow. Het zou nl. kunnen dat je een wildcard hebt opgenomen in
    // FileListRemove.
    for i := FileListRemove.Count-1 downto 0 do
    begin
      for j := 0 to FileListAllow.Count - 1 do
      begin
        if (SameText(FileListRemove[i], FileListAllow[j])) then
        begin
          FileListRemove.Delete(i);
        end;
      end;
    end;

    // Geef True terug als de bestanden in FileListRemove voorkomen, anders false.
    Result:=FileListRemove.Count;
  finally
    if (Assigned(FileListRemove)) then FileListRemove.Free;
    if (Assigned(FileListAllow)) then FileListAllow.Free;
  end;
end;


// -----------------------------------------------------------------------------
procedure DirClear(const inDir: string;
                   const inFilePattern: string = '*.*';
                   Option: TDirOption = do_Recursive);
var
  SearchRec: TSearchRec;
  Result: integer;
  NewDir: string;
  FileName: string;
  Dir: String;
begin
  {$IFDEF DEVELOP}
  //MsgOKCancel('inFilePattern:'+inFilePattern+'; inDir:'+inDir);
  {$ENDIF}
  Dir := inDir;
  if Dir[length(dir)] = '\' then
    Dir:=copy(Dir,1,length(Dir)-1);

  if not DirExists(Dir) then
    raise EInOutError.Create('Directory does not exist');

  Result:=FindFirst(Dir + '\' + inFilePattern,faAnyFile,SearchRec);
  while Result = 0 do
  begin
    if (SearchRec.Name <> '.') and
       (SearchRec.Name <> '..') then
    begin
      FileName:=Dir+'\'+SearchRec.Name;
      if FileIsReadOnly(FileName) then
        FileSetReadOnly(FileName,False);

      if (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        if (Option = do_Recursive) then
        begin
          NewDir:=Dir+'\'+SearchRec.Name;
          DirDelete(NewDir,Option);
        end
        // Als alleen de subdirs moeten worden verwijderd uit de hoofddirectory:
        // verander de option naar do_Recursive
        else if (Option = do_SubdirsOnly) then
        begin
          NewDir:=Dir+'\'+SearchRec.Name;
          DirDelete(NewDir,do_Recursive);
        end;
      end
      else
      begin
        if (Option <> do_SubdirsOnly) then
        begin
          SysUtils.DeleteFile(Dir+'\'+SearchRec.Name);
        end;
      end;
      Application.ProcessMessages;
    end;
    Result:=FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
end;


// -----------------------------------------------------------------------------
// Aangepaste versie van DirClear waar opgegeven kan worden dat bepaalde
// bestanden moeten blijven staan: die met inFilePatternExcluded.
procedure DirCleanse(const inDir: string;
                     FileToRemoveList,
                     FileAllowedList: TStringList;
                     Option: TDirOption = do_Recursive);
var
  SearchRec :TSearchRec;
  FileName: string;
  Dir: String;
  FileList: TStringList;
  i: integer;
  res: integer;
  NewDir: string;
begin
  {$IFDEF DEVELOP}
  //MsgOKCancel('inFilePattern:'+inFilePattern+'; inDir:'+inDir);
  {$ENDIF}
  Dir := inDir;
  if Dir[length(Dir)] = '\' then
  begin
    Dir:=copy(Dir,1,length(Dir)-1);
  end;

  if not DirExists(Dir) then
  begin
    raise EInOutError.Create('Directory does not exist');
  end;

  FileList:=TStringList.Create;
  try
    // Vul FileList met alle bestanden die voldoen aan de criteria in FileAllowedList.
    for i := 0 to FileAllowedList.Count - 1 do
    begin
      res:=FindFirst(Dir + '\' + FileAllowedList[i],faAnyFile,SearchRec);
      while res = 0 do
      begin
        if (SearchRec.Name <> '.') and
           (SearchRec.Name <> '..') then
        begin
          FileName:=Dir+'\'+SearchRec.Name;
        end;
        FileList.Add(SearchRec.Name);
        res:=FindNext(SearchRec);
      end;
      SysUtils.FindClose(SearchRec);
    end;

    for i := 0 to FileToRemoveList.Count - 1 do
    begin
      // Ga nu alle bestanden (files en directories) in Dir na of ze weg moeten
      /// of juist moeten blijven staan
      res:=FindFirst(Dir + '\' + FileToRemoveList[i],faAnyFile,SearchRec);
      while res = 0 do
      begin
        if (SearchRec.Name <> '.') and
           (SearchRec.Name <> '..') then
        begin
          FileName:=Dir+'\'+SearchRec.Name;
          if (SearchRec.Attr and faDirectory) = faDirectory then
          begin
            if (Option = do_Recursive) then
            begin
              NewDir:=Dir+'\'+SearchRec.Name;
              if FileIsReadOnly(FileName) then FileSetReadOnly(FileName,False);
              DirDelete(NewDir,Option);
            end
            // Als alleen de subdirs moeten worden verwijderd uit de hoofddirectory:
            // verander de option naar do_Recursive
            else if (Option = do_SubdirsOnly) then
            begin
              NewDir:=Dir+'\'+SearchRec.Name;
              if FileIsReadOnly(FileName) then FileSetReadOnly(FileName,False);
              DirDelete(NewDir,do_Recursive);
            end;
          end
          else
          begin
            if (Option <> do_SubdirsOnly) then
            begin
              // Als SearchRec.Name niet voorkomt in FileList mag SearchRec.Name
              // worden verwijderd.
              if (FileList.IndexOf(SearchRec.Name)<0) then
              begin
                if FileIsReadOnly(FileName) then FileSetReadOnly(FileName,False);
                SysUtils.DeleteFile(Dir+'\'+SearchRec.Name);
              end;
            end;
          end;
          Application.ProcessMessages;
        end;
        res:=FindNext(SearchRec);
      end;
      SysUtils.FindClose(SearchRec);
    end;
  finally
    FileList.Free;
  end;
end;


// -----------------------------------------------------------------------------
procedure DirFileList(const inDir, inFilePattern: string;
                      var FileList: TStringList;
                      IncludePathInList:boolean=true);
var
  SearchRec: TSearchRec;
  Result: integer;
  Dir: String;
begin

  Dir := inDir;
  if Dir[length(dir)] = '\' then
    Dir:=copy(Dir,1,length(Dir)-1);

  if not DirExists(Dir) then
    raise EInOutError.Create('Directory does not exist');

  if FileList = nil then
    raise Exception.Create('FileList not initialized.');

  Result:=FindFirst(Dir+'\'+ inFilePattern,faAnyFile,SearchRec);
  while Result = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      //FileName:=Dir+'\'+SearchRec.Name;

      if (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        //niks doen
      end
      else
      begin
        if (IncludePathInList) then
        begin
          FileList.Add('"' + Dir+'\'+SearchRec.Name + '"');
        end
        else
        begin
          FileList.Add('"' + SearchRec.Name + '"');
        end;
      end;
      Application.ProcessMessages;
    end;
    Result:=FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
end;


// -----------------------------------------------------------------------------
procedure DirSubDirList(const inDir: string; var SubDirList: TStringList);
var
  SearchRec: TSearchRec;
  Result: integer;
  Dir: String;
begin
  Dir := inDir;
  if Dir[length(dir)] = '\' then
    Dir:=copy(Dir,1,length(Dir)-1);

  if not DirExists(Dir) then
    raise EInOutError.Create('Directory does not exist');

  if SubDirList = nil then
    raise Exception.Create('SubDirList not initialized.');

  Result:=FindFirst(Dir + '\*',faAnyFile,SearchRec);
  while Result = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      if (SearchRec.Attr and faDirectory) = faDirectory then
        SubDirList.Add(Dir+'\'+SearchRec.Name);
      Application.ProcessMessages;
    end;
    Result:=FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
end;

// -----------------------------------------------------------------------------
function DirExists(s: string): boolean;
begin
  Result:=DirectoryExists(s);
end;

// -----------------------------------------------------------------------------
procedure DirMake(s: string);
begin
  try
    MkDir(s)
  except
    raise EInOutError.Create('Cannot create directory');
  end;
end;

// -----------------------------------------------------------------------------
function  DoubleRound(d: double; digits: integer): double;
var
  l: double;
  t: double;
begin
  l:=power(10,digits);
  try
    t:=int(d*l)/l;
    DoubleRound:=t;
  except
    DoubleRound:=0.0;
  end;
end;

// -----------------------------------------------------------------------------
function Extract(s:string;token:integer;delimiter:char):string;
var
  i:integer;
  tmp:string;
begin
  if length(s)=0 then
    Extract:=''
  else
  begin
    Tmp:=trim(s)+Delimiter;
    for i:=1 to token-1 do
    begin
      Tmp:=trim(copy(Tmp,pos(Delimiter,Tmp)+1,
                             length(Tmp)-pos(Delimiter,Tmp)))+Delimiter;
    end;
    Extract:=copy(Tmp,1,pos(Delimiter,Tmp)-1);
  end;
end;

// -----------------------------------------------------------------------------
// Bepaalt de n-de quotedstring van s.
// ExtractQuotedString("dit 'is een test',1) geeft 'is een test'.
// Geeft '' terug als er geen quotes zijn.
// Geeft '' terug bij oneven quotes.
// Ondersteunt geen quotes in strings.
function ExtractQuotedString(s: string; n: integer): string;
var
  t: string;
  i: integer;
  p: integer;
begin
  if pos('''',s)=0 then
    ExtractQuotedString:=''
  else
  begin
    t:='';
    for i:=1 to n do
    begin
      p:=pos('''',s);
      if p=0 then
      begin
        t:='';
        break;
      end;
      delete(s,1,p);
      p:=pos('''',s);
      if p=0 then
      begin
        t:='';
        break;
      end;
      t:=copy(s,1,p-1);
      delete(s,1,p);
    end;
    ExtractQuotedString:=t;
  end;
end;

// -----------------------------------------------------------------------------
procedure FileCopy(Source, Dest: string);
const
  MaxRead: integer = 65535;
var
  F: File of byte;
  Fin: integer;
  Fout: integer;
  Size: integer;
  Buf: pointer;
  BufSize: integer;
  BytesRead: integer;
begin
  if not FileExists(Source) then
    raise Exception.Create('File '+Source+' does not exist.');

  if (ExpandFileName(Source) = ExpandFileName(Dest)) then
    raise Exception.Create('Source and destination cannot be the same');

  AssignFile(F,Source);
  Reset(F);
  Size:=FileSize(F);
  CloseFile(F);

  if Size < MaxRead then
    BufSize:=Size
  else
    BufSize:=MaxRead;

  try

    if BufSize > 0 then
      Buf:=AllocMem(BufSize)
    else
      Buf:=nil;

    Fin:=FileOpen(Source,fmOpenRead);
    Fout:=FileCreate(Dest);

    if BufSize > 0 then
    begin
      repeat
        BytesRead:=FileRead(Fin,Buf^,BufSize);
        FileWrite(Fout,Buf^,BytesRead);
      until BytesRead < BufSize;
    end;

    if Fin > 0 then
      FileClose(Fin);
    if Fout > 0 then
      FileClose(Fout);

    if BufSize > 0 then
      FreeMem(Buf,BufSize);

  except
    raise Exception.Create('Error copying file.');
  end;

end;

// -----------------------------------------------------------------------------
function  GetScratchFileName: string;
var
  Path: array[0..255] of char;
  Prefix: array[0..6] of char;
  FileName: array[0..255] of char;
begin
  StrPCopy(Prefix,'ops');
  GetTempPath(sizeof(Path),Path);
  GetTempFileName(Path,Prefix,0,FileName);
  Result:=StrPas(FileName);
end;

// -----------------------------------------------------------------------------
function  FileIsReadOnly(FileName: string): boolean;
begin
  FileIsReadOnly:=((FileGetAttr(FileName) and faReadOnly)=1);
end;

// -----------------------------------------------------------------------------
procedure FileSetReadOnly(FileName: string; Flag: boolean);
begin
  if Flag then
  begin
    if not FileIsReadOnly(FileName) then
    begin
      FileSetAttr(FileName,FileGetAttr(FileName)+faReadOnly);
    end
  end
  else
  begin
    if FileIsReadOnly(FileName) then
    begin
      FileSetAttr(FileName,FileGetAttr(FileName)-faReadOnly);
    end;
  end;
end;

// -----------------------------------------------------------------------------
function  HiddenFileExists(FileName: string): boolean;
begin
  HiddenFileExists:=(FileGetAttr(FileName)>=0);
end;

// -----------------------------------------------------------------------------
function  FileIsHidden(FileName: string): boolean;
begin
  FileIsHidden:=((FileGetAttr(FileName) and faHidden)=1);
end;

// -----------------------------------------------------------------------------
procedure FileSetHidden(FileName: string; Flag: boolean);
begin
  if Flag then
  begin
    if not FileIsHidden(FileName) then
    begin
      FileSetAttr(FileName,FileGetAttr(FileName)+faHidden);
    end
  end
  else
  begin
    if FileIsHidden(FileName) then
    begin
      FileSetAttr(FileName,FileGetAttr(FileName)-faHidden);
    end;
  end;
end;

// -----------------------------------------------------------------------------
procedure FileTouch(FileName: string);
var
  Handle: integer;
begin
  Handle:=FileOpen(FileName,fmInput);
  FileSetDate(Handle,DateTimeToFileDate(now));
  FileClose(Handle);
end;

// -----------------------------------------------------------------------------
procedure FileWriteString(FileName: string; s: string);
var
  F: TextFile;
begin
  AssignFile(F,FileName);
  try
    Rewrite(F);
    Writeln(F,s);
  finally
    CloseFile(F);
  end;

end;

// -----------------------------------------------------------------------------
procedure FileAppendString(FileName: string; s: string);
var
  F: TextFile;
begin
  AssignFile(F,FileName);
  try
    if FileExists(FileName) then
      Append(F)
    else
      Rewrite(F);
    Writeln(F,s);
  finally
    CloseFile(F);
  end;
end;

// -----------------------------------------------------------------------------
function FillSpaces(len: integer): string;
begin
  Result := StringOfChar(' ',len);
end;

// -----------------------------------------------------------------------------
// Returns bv. 'c:'
function GetDrive(Dir: string): string;
begin
  if length(Dir)<=1 then
    Result:=''
  else if Dir[2]<>':' then
    Result:=''
  else
    Result:=copy(Dir,1,2);
end;

// -----------------------------------------------------------------------------
function GetPathNoDrive(s: string): string;
var
  Path: string;
begin
  Path:=ExtractFilePath(s);
  if Path[2]=':' then
    delete(Path,1,2);
  Result:=Path
end;


// -----------------------------------------------------------------------------
function AddPathSeparator(s: string): string;
var
  sWork:string;
begin
  sWork:=Copy(s, length(s),1);
  if (SameText(sWork,'/') or Sametext(sWork,'\')) then
  begin
    Result:=s;
    exit;
  end;

  if (Pos('/',s)>0) then
  begin
    Result:=s+'/';
  end
  else if (Pos('\',s)>0) then
  begin
    Result:=s+'\';
  end
  else
  begin
    Result:=s+'/';
  end;
end;


// -----------------------------------------------------------------------------
function GetCurrentWorkDirectory: string;
var
  s: string;
begin
  GetDir(0,s);
  GetCurrentWorkDirectory:=s;
end;

// -----------------------------------------------------------------------------
// Bepaald de quotedstring van s.
//  GetQuotedString("dit 'is een test',1) geeft 'is een test'.
//  GetQuotedString("dit 'is 'een' test',1) geeft 'is 'een' test'.
//  Geeft '' terug als er geen quotes zijn.
//  Geeft '' terug bij 1 quote.
//  Ondersteund geneste quotedstrings.
function GetQuotedString(s: string): string;
var
  i: integer;
  p1: integer;
  p2: integer;
begin
  if pos('''',s)=0 then
    GetQuotedString:=''
  else
  begin
    p1:=0;
    p2:=0;
    for i:=1 to length(s) do
      if s[i]='''' then
      begin
        p1:=i;
        break;
      end;
    for i:=length(s) downto 1 do
      if s[i]='''' then
      begin
        p2:=i;
        break;
      end;
    if (p1=p2) or (p2=0) then
      GetQuotedString:=''
    else
      GetQuotedString:=copy(s,p1+1,p2-p1-1);
  end;
end;

// -----------------------------------------------------------------------------
function IsBitSet(const val: integer; const TheBit: byte): boolean;
begin
  result := (val and (1 shl TheBit)) <> 0;
end;

// -----------------------------------------------------------------------------
function IntToMonth(m: integer): string;
const
  Months: array[1..12] of string = ('January','February','March','April','May',
          'June','July','August','Septembre','Octobre','Novembre','Decembre');
begin
  if (m>=1) and (m<=12) then
    IntToMonth:=Months[m]
  else
    IntToMonth:='';
end;

// -----------------------------------------------------------------------------
function IsDouble(s: string): boolean;
var
  Code: integer;
  r: double;
begin
  Val(s, r, Code);
  Result:=(Code=0);
end;

// -----------------------------------------------------------------------------
function IsInRange(s,mins,maxs: string): boolean;
var
  CodeR, CodeMin, CodeMax: integer;
  r: single;
  minvalue,maxvalue: single;
begin
  Val(s, R, CodeR);
  if CodeR <> 0 then
    IsInRange:=False
  else
  begin
    try
      Val(mins, minvalue, CodeMin);
      Val(maxs, maxvalue, CodeMax);
      if (CodeMin <> 0) and (CodeMax <> 0) then
        IsInRange:=False
      else
        if (mins = '') and (CodeMax=0) then
          IsInRange:=(R<=Maxvalue)
        else
          if (maxs = '') and (CodeMin=0) then
            IsInRange:=(R>=Minvalue)
          else
            IsInRange:=(R>=Minvalue) and (R<=Maxvalue);
    except
      IsInRange:=False;
    end;
  end;
end;


// -----------------------------------------------------------------------------
function IsInRangeMsg(s,mins,maxs: string): boolean;
begin
  if not IsInRange(s,mins,maxs) then
  begin
    if (mins <> '') and (maxs <> '') then
      MsgError('Value must be in range of '+mins+' - '+maxs+'.')
    else if (mins = '') then
      MsgError('Value must be less than '+maxs+'.')
    else if (maxs = '') then
      MsgError('Value must be greater than '+mins+'.');
    IsInRangeMsg:=False;
  end
  else
    IsInRangeMsg:=True;
end;

// -----------------------------------------------------------------------------
function IsIntegerInRangeMsg(s,mins,maxs: string): boolean;
begin
  if IsIntegerMsg(s) then
  begin
    if not IsInRangeMsg(s,mins,maxs) then
      IsIntegerInRangeMsg:=False
    else
      IsIntegerInRangeMsg:=True;
  end
  else
    IsIntegerInRangeMsg:=False;
end;

// -----------------------------------------------------------------------------
function IsSingleInRangeMsg(s,mins,maxs: string): boolean;
begin
  if IsSingleMsg(s) then
  begin
    if not IsInRangeMsg(s,mins,maxs) then
      IsSingleInRangeMsg:=False
    else
      IsSingleInRangeMsg:=True;
  end
  else
    IsSingleInRangeMsg:=False;
end;

// -----------------------------------------------------------------------------
function IsInteger(s: string): boolean;
var
  Code: integer;
  i: integer;
begin
  Val(s, i, Code);
  IsInteger:=(Code = 0);
end;

// -----------------------------------------------------------------------------
function IsIntegerMsg(s: string): boolean;
begin
  if not IsInteger(s) then
  begin
    IsIntegerMsg:=False;
    MsgError('Value must be an integer.');
  end
  else
    IsIntegerMsg:=True;
end;

// -----------------------------------------------------------------------------
function IsSingle(s: string): boolean;
var
  Code: integer;
  r: single;
begin
  Val(s, r, Code);
  IsSingle:=(Code = 0);
end;

// -----------------------------------------------------------------------------
function IsSingleMsg(s: string): boolean;
begin
  if not IsSingle(s) then
  begin
    IsSingleMsg:=False;
    MsgError('Value must be a single.');
  end
  else
    IsSingleMsg:=True;
end;

// -----------------------------------------------------------------------------
function IsSingleOrIntegerMsg(s: string): boolean;
begin
  if not IsSingle(s) then
  begin
    IsSingleOrIntegerMsg:=False;
    MsgError('Value must be an integer or single.');
  end
  else
    IsSingleOrIntegerMsg:=True;
end;

// -----------------------------------------------------------------------------
procedure LatLongToRDM(b,l: double; var x: double; var y: double);
var
  b1: double;
  l1: double;
begin
  b1 := 0.36 * b - 18.7762;
  l1 := 0.36 * l - 1.9395;
  x := 190.06691 * l1 - 11.831 * b1 * l1 + 155. - 0.1142 * sqr(b1) * l1 -
       0.03239 * Power3(l1);
  y := 309.02034 * b1 + 3.63836 * sqr(l1) + 463. + 0.07292 * sqr(b1) -
       0.15797 * b1 * sqr(l1) + 0.05977 * Power3(b1);
end;

// -----------------------------------------------------------------------------
function Log10(r: double): double;
begin
  Log10:=ln(r)/ln(10.0);
end;

// -----------------------------------------------------------------------------
function Max(i,j: integer): integer;
begin
  if i>j then
    Max:=i
  else
    Max:=j;
end;

// -----------------------------------------------------------------------------
function MaxSingle(i,j: single): single;
begin
  if i>j then
    MaxSingle:=i
  else
    MaxSingle:=j;
end;

// -----------------------------------------------------------------------------
function MaxDouble(i,j: double): double;
begin
  if i>j then
    MaxDouble:=i
  else
    MaxDouble:=j;
end;

// -----------------------------------------------------------------------------
function Min(i,j: integer): integer;
begin
  if i<j then
    Min:=i
  else
    Min:=j;
end;

// -----------------------------------------------------------------------------
function MinSingle(i,j: single): single;
begin
  if i<j then
    MinSingle:=i
  else
    MinSingle:=j;
end;

// -----------------------------------------------------------------------------
function MinDouble(i,j: double): double;
begin
  if i<j then
    MinDouble:=i
  else
    MinDouble:=j;
end;

// -----------------------------------------------------------------------------
function  MonthOfYear(m: integer): string;
const
  Months: array[1..12] of string[3] = (
          'jan','feb','mrt','apr','may','jun',
          'jul','aug','sep','oct','nov','dec');
begin
  if (m<1) or (m>12) then
    MonthOfYear:=''
  else
    MonthOfYear:=Months[m];
end;

// -----------------------------------------------------------------------------
procedure Msg(s: string);
begin
  Screen.Cursor:=crDefault;
  Application.MessageBox(PChar(s),PChar(c_AppName),MB_OK + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
procedure MsgWarning(s: string);
begin
  Screen.Cursor:=crDefault;
  Application.MessageBox(PChar(s),PChar(c_AppName),MB_OK + MB_DEFBUTTON1 + MB_ICONWARNING)
end;

// -----------------------------------------------------------------------------
procedure MsgError(s: string);
begin
  Screen.Cursor:=crDefault;
  Application.MessageBox(PChar(s),PChar(c_AppName),MB_OK + MB_DEFBUTTON1 + MB_ICONERROR)
end;

// -----------------------------------------------------------------------------
procedure MsgErrorTerminate(s: string);
begin
  Screen.Cursor:=crDefault;
  MsgError(s);
  Application.Terminate;
end;

// -----------------------------------------------------------------------------
procedure MsgSystemModal(s: string; c: string);
var
  Text: array[0..255] of char;
  Caption: array[0..255] of char;
begin
  Screen.Cursor:=crDefault;
  StrPCopy(Caption,c);
  StrPCopy(Text,s);
  MessageBox(0,Text,Caption,MB_SYSTEMMODAL or MB_ICONEXCLAMATION);
end;

// -----------------------------------------------------------------------------
function MsgSystemModalYesNo(s: string; c: string): integer;
var
  Text: array[0..255] of char;
  Caption: array[0..255] of char;
begin
  Screen.Cursor:=crDefault;
  StrPCopy(Caption,c);
  StrPCopy(Text,s);
  Result:=MessageBox(0,Text,Caption,MB_SYSTEMMODAL or MB_ICONQUESTION or MB_YESNO);
end;

// -----------------------------------------------------------------------------
function MsgYesNo(s: string): word;
begin
  Screen.Cursor:=crDefault;
  Result:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_YESNO + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
function MsgYesNoCancel(s: string): word;
begin
  Screen.Cursor:=crDefault;
  Result:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_YESNOCANCEL + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
function MsgOKCancel(s: string): word;
begin
  Screen.Cursor:=crDefault;
  Result:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_OKCANCEL + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
procedure MsgInt(l: integer);
begin
  Screen.Cursor:=crDefault;
  MessageDlg(IntToStr(l),mtInformation,[mbOK],0);
end;

// -----------------------------------------------------------------------------
function  PointInRect(p: TPoint; r: TRect): boolean;
begin
  PointInRect:=(p.X>=r.Left) and (p.X<=r.Right) and (p.Y>=r.Top) and (p.Y<=r.Bottom);
end;

// -----------------------------------------------------------------------------
function Power(a,b: double): double;
begin
  Power:=exp(b*ln(a)); { a power b }
end;

// -----------------------------------------------------------------------------
function Power3(r: double): double;
begin
  Power3:=sqr(r)*r;
end;

// -----------------------------------------------------------------------------
function SingleToStr(s: single): string;
begin
  SingleToStr:=FloatToStrF(s,ffGeneral,7,0);
end;

// -----------------------------------------------------------------------------
// Converteert een double naar een string met een '.'.
// De default precision is 2.
{function DoubleToStr(d: double; p: integer = 2): string;
var
  TmpDecimalSeparator: char;
begin
  TmpDecimalSeparator:=DecimalSeparator;
  DecimalSeparator:='.';
  DoubleToStr:=Format('%.'+IntToStr(p)+'f',[d]);
  DecimalSeparator:=TmpDecimalSeparator;
end;}

// -----------------------------------------------------------------------------
function DoubleToStr(d: double): string;
begin
  DoubleToStr:=FloatToStrF(d,ffGeneral,15,0);
end;

// -----------------------------------------------------------------------------
function SingleToStrF(ss: single; w: integer; d: integer): string;
var
  s: string;
begin
  Str(ss:w:d,s);
  SingleToStrF:=s;
end;

// -----------------------------------------------------------------------------
function DoubleToStrF(dd: double; w: integer; d: integer): string;
var
  s: string;
begin
  Str(dd:w:d,s);
  DoubleToStrF:=s;
end;

// -----------------------------------------------------------------------------
function DoubleToStrE(dd: double; precision: integer; digits: integer): string;
begin
  Result:=FloatToStrF(dd,ffExponent,precision,digits);
end;

// -----------------------------------------------------------------------------
function  RGBToColor(R,G,B:integer):TColor;
var
  Color: TColor;
begin
  Color:=R;
  Color:=Color or ((G * $000000FF) and $0000FF00);
  Color:=Color or ((B * $0000FFFF) and $00FF0000);
  RGBToColor:=Color;
end;

// -----------------------------------------------------------------------------
function  RemoveLastBackslash(s: string): string;
begin
  if s[length(s)]='\' then
    s:=copy(s,1,length(s)-1);
  RemoveLastBackslash:=s;
end;

// -----------------------------------------------------------------------------
function  ReplaceTabsBySpaces(s: string): string;
const
  TAB = #09;
begin
  ReplaceTabsBySpaces:=subst(s,TAB,' ');
end;

// -----------------------------------------------------------------------------
procedure SetMetricsDutch;
begin
  DecimalSeparator:=',';
end;

// -----------------------------------------------------------------------------
procedure SetMetricsUK;
begin
  DecimalSeparator:='.';
end;

// -----------------------------------------------------------------------------
function StrAlignLeft(s: string; len: integer): string;
begin
  s:=s+FillSpaces(255);
  StrAlignLeft:=copy(s,1,len);
end;

// -----------------------------------------------------------------------------
function StrAlignRight(s: string; len: integer): string;
begin
  if len > length(s) then
    s:=FillSpaces(len-length(s))+s;
  StrAlignRight:=copy(s,length(s)-len,len);
end;

// -----------------------------------------------------------------------------
// Converteert een string getal met een '.' naar een double.
function StrToDouble(s: string): double;
var
  t: string;
  d: double;
  Status: integer;
begin
  t:=trim(s);
  val(t,d,Status);
  if Status <> 0 then
  begin
    raise Exception.Create('Error converting string to double.');
  end;
  Result:=d;
end;

// -----------------------------------------------------------------------------
function Stuff(s: string; pos: integer; ss: string): string;
begin
  if pos > 255 then
    s:=s+FillSpaces(255)
  else
  begin
    if length(s) >= pos then
    begin
      delete(s,pos,length(ss));
      insert(ss,s,pos);
    end
    else
    begin
      s:=s+FillSpaces(255);
      delete(s,pos,length(ss));
      insert(ss,s,pos);
      s:=copy(s,1,pos+length(ss)-1);
    end;
  end;
  Stuff:= s;
end;

// -----------------------------------------------------------------------------
function SubstFirst(InString, SearchString, WithString: string): string;
var
  p: byte;
  s: string;
  l: integer;
begin
  s:=InString;
  l:=length(SearchString);
  p:=pos(SearchString,s);
  if p<>0 then
  begin
    delete(s,p,l);
    if WithString<>'' then
      insert(WithString,s,p);
  end;
  SubstFirst:=s;
end;

// -----------------------------------------------------------------------------
function Subst(InString, SearchString, WithString: string): string;
var
  p: byte;
  s: string;
  l: integer;
begin
  s:=InString;
  l:=length(SearchString);
  repeat
    p:=pos(SearchString,s);
    if p<>0 then
    begin
      delete(s,p,l);
      if WithString<>'' then
        insert(WithString,s,p);
    end;
  until p=0;
  Subst:=s;
end;

// -----------------------------------------------------------------------------
function SubstNoCase(InString, SearchString, WithString: string): string;
var
  p: byte;
  sorg, sin, ssearch: string;
  l: integer;
begin
  sorg:=InString;
  sin:=UpperCase(InString);
  ssearch := UpperCase(SearchString);
  l:=length(ssearch);
  repeat
    p:=pos(ssearch,sin);
    if p<>0 then
    begin
      delete(sorg,p,l);
      if WithString<>'' then
      begin
        insert(WithString,sorg,p);
        sin := UpperCase(sorg);
      end;
    end;
  until p=0;
  SubstNoCase:=sorg;
end;

// -----------------------------------------------------------------------------
procedure SwapInt(var a, b: integer);
var
  Tmp: integer;
begin
  Tmp:=a;
  a:=b;
  b:=Tmp;
end;

// -----------------------------------------------------------------------------
procedure Swapinteger(var a, b: integer);
var
  Tmp: integer;
begin
  Tmp:=a;
  a:=b;
  b:=Tmp;
end;

// -----------------------------------------------------------------------------
procedure SwapSingle(var a, b: single);
var
  Tmp: single;
begin
  Tmp:=a;
  a:=b;
  b:=Tmp;
end;

// -----------------------------------------------------------------------------
procedure SwapDouble(var a, b: double);
var
  Tmp: double;
begin
  Tmp:=a;
  a:=b;
  b:=Tmp;
end;

// -----------------------------------------------------------------------------
function  TrimL(s:string):string;
begin
  TrimL:=s;
  while copy(s,1,1)=' ' do
  begin
    delete(s,1,1);
    TrimL:=s;
  end;
end;

// -----------------------------------------------------------------------------
function  TrimR(s:string):string;
begin
  TrimR:=s;
  while copy(s,length(s),1)=' ' do
  begin
    delete(s,length(s),1);
    TrimR:=s;
  end;
end;

// -----------------------------------------------------------------------------
function  Trim(s:string):string;
begin
  s:=TrimL(s);
  s:=TrimR(s);
  Trim:=s;
end;

// -----------------------------------------------------------------------------
// With tailing '\'
//
//  ''     wordt d:\project\igiops\prg\
//  tmp    wordt d:\project\igiops\prg\tmp\
//  \      wordt d:\
//
function  UnifiedFileDir(s: string): string;
begin
  s:=Subst(s,'\\','\');
  s:=ExpandFileName(s);
  if not DirectoryExists(s) then
    s:=ExtractFilePath(s);
  if copy(s,length(s),1)<>'\' then
    s:=s+'\';
  UnifiedFileDir:=s;
end;

// -----------------------------------------------------------------------------
function  UnifiedFileDirEntry(d: string; f: string): string;
begin
  f:=UnifiedFileEntry(f);
  if d<>'' then
    d:=UnifiedFileDir(d);
  Result:=d+f;
end;

// -----------------------------------------------------------------------------
function  UnifiedFileEntry(s: string): string;
begin
  s:=ExtractFileName(s);
  UnifiedFileEntry:=s;
end;

// -----------------------------------------------------------------------------
function  UnifiedFileName(s: string): string;
begin
  if ExtractFilePath(s) <> '' then
    s:=ExpandFileName(s);
  s:=subst(s,'\\','\');
  UnifiedFileName:=s;
end;

// -----------------------------------------------------------------------------
procedure Wait(NumMSec: integer);
var
  StartTime: DWORD;
  EndTime: DWORD;
begin
  StartTime := GetTickCount;
  EndTime := StartTime + DWORD(NumMSec); { * (1/24/60/60) * 1000;}
  repeat
    Application.ProcessMessages;
  until GetTickCount > EndTime;
end;

// -----------------------------------------------------------------------------
function WaitCalculateIndexCount: integer;
var
  Count: integer;
  StartTime: DWORD;
  DeltaTime: DWORD;
begin
  Count:=1;
  DeltaTime:=0;
  StartTime:=GetTickCount;
  while DeltaTime < 500 do
  begin
    inc(Count);
    DeltaTime:=GetTickCount-StartTime;
  end;
  WaitCalculateIndexCount:=Count;
end;

// -----------------------------------------------------------------------------
function WaitCalculateIndex: double;
var
  Count: integer;
  i: integer;
  n: integer;
begin
  n:=4;
  Count:=0;
  for i:=1 to n do
    Count:=Count+WaitCalculateIndexCount;
  Count:=Count div n;
  _WaitIndex:=_WaitIndexCount/Count;
  WaitCalculateIndex:=_WaitIndex;
end;

// -----------------------------------------------------------------------------
function WaitGetIndex: double;
begin
  WaitGetIndex:=_WaitIndex;
end;

// -----------------------------------------------------------------------------
procedure WaitIndexed(Count: integer);
var
  StartTime: integer;
  EndTime: integer;
begin
  StartTime := GetTickCount;
  EndTime := StartTime + trunc(Count * _WaitIndex * 2); { * (1/24/60/60) * 1000;}
  repeat
    Application.ProcessMessages;
  until GetTickCount > EndTime;
end;

// -----------------------------------------------------------------------------
procedure WaitWithBreak(NumMSec: integer);
var
  StartTime: DWORD;
  EndTime: DWORD;
begin
  _WaitBreak:=False;
  StartTime := GetTickCount;
  EndTime := StartTime + DWORD(NumMSec); { * (1/24/60/60) * 1000;}
  repeat
    Application.ProcessMessages;
  until (GetTickCount > EndTime) or _WaitBreak;
end;

// -----------------------------------------------------------------------------
procedure WaitBreak;
begin
  _WaitBreak:=True;
end;

// -----------------------------------------------------------------------------
procedure WindowActivateByCaption(s: string);
begin
  WindowActivate(WindowGetHandle(s));
end;

// -----------------------------------------------------------------------------
procedure WindowActivate(h: HWnd);
begin
  if h <> 0 then
  begin
    BringWindowToTop(h);
    Windows.SetFocus(h);
  end;
end;

// -----------------------------------------------------------------------------
procedure WindowHide(h: HWnd);
begin
  ShowWindow(h,SW_HIDE);
end;

// -----------------------------------------------------------------------------
procedure WindowMaximize(h: HWnd);
begin
  ShowWindow(h,SW_SHOWMAXIMIZED);
end;

// -----------------------------------------------------------------------------
procedure WindowMinimize(h: HWnd);
begin
  ShowWindow(h,SW_SHOWMINIMIZED);
end;

// -----------------------------------------------------------------------------
procedure WindowRestore(h: HWnd);
begin
  ShowWindow(h,SW_RESTORE);
end;

// -----------------------------------------------------------------------------
procedure WindowCenterOnScreen(Form: TForm; SizePercentage: integer);
var
  ScreenW,
  ScreenH,
  FormW,
  FormH: integer;
begin

  ScreenW:=Screen.Width;
  ScreenH:=Screen.Height;
  FormW:=Form.Width;
  FormH:=Form.Height;

  if (SizePercentage > 0) and (SizePercentage <= 100) then
  begin
    FormW:=(ScreenW * SizePercentage) div 100;
    FormH:=(ScreenH * SizePercentage) div 100;
  end;

  Form.Width:=FormW;
  Form.Height:=FormH;
  Form.Top:=(ScreenH - Form.Height) div 2;
  Form.Left:=(ScreenW - Form.Width) div 2;

end;

// -----------------------------------------------------------------------------
procedure WindowClose(Caption: string);
var
  c: array[0..255] of char;
  w: HWnd;
begin
  strpcopy(c,Caption);
  w:=FindWindow(nil,c);
  if w > 0 then
    PostMessage(w,WM_CLOSE,0,0);
end;

// -----------------------------------------------------------------------------
function WindowGetHandle(s: string): HWnd;
var
  c: array[0..255] of char;
begin
  StrPCopy(c,s);
  WindowGetHandle:=FindWindow(nil,c);
end;

// -----------------------------------------------------------------------------
procedure WindowsClose;
var
  c: array[0..255] of char;
  w: HWnd;
begin
  strpcopy(c,'');
  w:=FindWindow(nil,c);
  PostMessage(w,WM_CLOSE,0,0);
end;

// -----------------------------------------------------------------------------
function WindowScreenHeight: integer;
var
  Rect: TRect;
begin
  GetWindowRect(GetDesktopWindow, Rect);
  WindowScreenHeight:=Rect.Bottom-Rect.Top;
end;

// -----------------------------------------------------------------------------
function WindowScreenWidth: integer;
var
  Rect: TRect;
begin
  GetWindowRect(GetDesktopWindow, Rect);
  WindowScreenWidth:=Rect.Right-Rect.Left;
end;

// -----------------------------------------------------------------------------
procedure WindowTopMost(Caption: string);
var
  Handle: HWnd;
begin
  Handle:=WindowGetHandle(caption);
  if Handle<>0 then
  begin
    SetWindowPos(Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
  end;
end;

// -----------------------------------------------------------------------------
procedure WindowWaitFor(s: string);
begin
  while WindowGetHandle(s)=0 do
    Application.ProcessMessages;
end;

// -----------------------------------------------------------------------------
procedure ProcessMessages;
var
  Msg: TMsg;
begin
  while (PeekMessage (Msg, 0, 0, 0, PM_REMOVE)) do
  begin
    TranslateMessage (Msg);
    DispatchMessage (Msg);
  end;
end;

// -----------------------------------------------------------------------------
// Test of inVal een waarde heeft die overeenkomt met een nil-pointer (bij:
// inVal = '', 'nil', 'null'). Te gebruiken bij invoer van waarden bij een
// editveld dat uit String bestaat. Geeft True of False terug.
function IsNil(inVal: String):Boolean;
begin
  //@@## REVIEW
  //if ((inVal = '') or (StrIComp(PChar(inVal), PChar('nil')) = 0) or (StrIComp(PChar(inVal), PChar('null')) = 0)) then
  if (inVal = '') or SameText(inVal,'nil') or SameText(inVal,'null') then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------
// Geeft een nil-pointer terug of de waarde zelf, als PChar. Het resultaat is een
// nil-pointer als inVal = '', 'nil', 'null'.
{
procedure ConvertStr2PChar(inVal: String; var outVal: PChar);
begin
  if (IsNil(inVal)) then
  begin
    outVal := nil;
  end
  else
  begin
    try
      StrPLCopy(outVal, inVal, Length(inVal)+1);
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar(E.message), PChar('Error in ConvertStr2PChar('+inVal+')'), MB_OK);
      end;
    end;
  end;
end;
}
// -----------------------------------------------------------------------------
//@@## REVIEW Wordt niet vrijgegeven!!!!!!!!!!!!!!!!????????????????????
function ConvertStr2PChar(inVal: String): PChar;
begin
  if (IsNil(inVal)) then
  begin
    Result := nil;
  end
  else
  begin
    try
      Result := StrAlloc(Length(inVal)+1);
      StrPCopy(Result,inVal);
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar(E.message), 'Open Error', MB_OK);
        Result := nil;
      end;
    end;
  end;
end;

// -----------------------------------------------------------------------------
//<vh200408> met dank aan http://www.elists.org/pipermail/delphi/2001-May/014626.html
// UTC-conversie naar een TDateTime. UTC is gedefinieerd als het aantal seconden
// vanaf middernacht 1 januari 1970. 1093250604 bijvoorbeeld is 2004 08 23 10:43:24
function UTC2DateTime(const UTCTime: LongInt) : TDateTime;
var
  DateMidnight19700101 : TDateTime;
begin
  DateMidnight19700101 := EncodeDate(1970,1,1); // UTC start time
  Result := DateMidnight19700101 + (UTCTime div (60*60*24)); //seconds to days
  Result := Result + ((UTCTime mod (60*60*24)) / (60*60*24)); //fraction
end;

// -----------------------------------------------------------------------------
function DateTime2UTC(const T: TDateTime): LongInt;
var
  DateMidnight19700101, TTmp : TDateTime;
begin
//  TTmp := now;
  DateMidnight19700101 := EncodeDate(1970,1,1); // UTC start time
  TTmp := T - DateMidnight19700101;
  Result := Round(TTmp * (60*60*24));
end;

// -----------------------------------------------------------------------------
function MyDateTime2Str(const T: TDateTime):String;
var
  StrTmp: String;
begin
  DateTimeToString(StrTmp, 'mm-dd-yyyy hh:nn:ss', T);
  Result := StrTmp;
end;

// -----------------------------------------------------------------------------
// http://www.delphi32.com/info_facts/tips/GetTimeZoneInfo.asp
function GetTotalTimeSecondsBias: Longint;
var
  TZoneInfo: TTimeZoneInformation;
  TimezoneBias: longint;
  DaylightBias: longint;
  StandardBias: longint;
begin
  GetTimeZoneInformation(TZoneInfo);
  TimezoneBias := TZoneInfo.Bias;
  DaylightBias := TZoneInfo.DaylightBias;
  StandardBias := TZoneInfo.StandardBias;
  Result := (TimezoneBias + DaylightBias + StandardBias) * 60;
end;

// -----------------------------------------------------------------------------
// UTC-conversie naar een String met een voor mensen leesbare datum/tijd.
// Houdt rekening met de offset door tijdszone en zomer/wintertijd.
function UTC2Str(const UTCTime: LongInt):String;
var
  Datetime: TDateTime;
begin
  DateTime := UTC2DateTime(UTCTime - GetTotalTimeSecondsBias);
  Result := MyDateTime2Str(DateTime);
end;

// -----------------------------------------------------------------------------
function Copy2String(const PchVal: PChar): String;
var StrTmp: String;
begin
  StrTmp := String(PchVal);
  //@@## REVIEW Copy wel nodig???
  Result := Copy(StrTmp, 1, Length(StrTmp));
end;

// -----------------------------------------------------------------------------
function Copy2String(const IntVal: Integer): String;
var StrTmp: String;
begin
  StrTmp := IntToStr(IntVal);
  //@@## REVIEW Copy wel nodig???
  Result := Copy(StrTmp, 1, Length(StrTmp));
end;

// -----------------------------------------------------------------------------
// Bepaal de grootte (in Bytes) van een file.
function GetTheFileSize(f: String): Integer;
var
  RecFileAttr: TSearchRec;
  IntRet: Integer;
begin
  IntRet := FindFirst(f, faAnyFile, RecFileAttr);
  if (IntRet = 0) then
  begin
    Result := RecFileAttr.Size;
  end
  else
  begin
    Result := -1;
  end;
end;


initialization
  _WaitIndexCount:=1297367;
  _WaitIndex:=1.0;
  SetMetricsUK;

  ControlEvents:=TList.Create;

finalization

  ControlEvents.Free;

end.


