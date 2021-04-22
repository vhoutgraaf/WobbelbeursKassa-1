//------------------------------------------------------------------------------
// Name        : m_tools
// Purpose     : Verzameling handige functies en procedures
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       :
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_tools;

{$mode objfpc}{$H+}

interface

  uses
    Forms, types, StdCtrls, m_querystuff, ZConnection, ZDataset, ComCtrls, ExtCtrls;


  procedure MessageOK(mess: string; caption: string);
  procedure MessageOK(mess: string);
  procedure MessageError(mess: string; caption: string);
  procedure MessageError(mess: string);

  function GetDefaultWobbelErrorfilename():string;
  function GetDefaultWobbelLogfilename():string;
  procedure LogfileAdd(s:string);
  procedure LogfileEmpty();
  procedure ErrorfileEmpty();
  procedure ErrorfileAdd(s:string);
  function GetAppFileWithExtension(subdir, sExt:string):string;
  function AppendToFile(fname, s: string):integer;


  function MakePicklistItemDescription(Naam, Omschrijving: string): string;
  procedure FillTransactieBetaalwijzePicklist(cmb: TComboBox);
  procedure FillBeursPicklist(cmb: TComboBox);
  function getBeursOmschrijving(beursdatum, beursopmerkingen:string):string;
  function SetPicklistIdOfItemDescription(cmb: TComboBox; needleToFind:string):integer;
  function SetRadioItemOfGroupPicklist(rg: TRadioGroup; needleToFind:string):integer;

  function SubstFirst(InString, SearchString, WithString: string): string;

  procedure Msg(s: string);
  procedure MsgWarning(s: string);
  procedure MsgError(s: string);
  procedure MsgErrorTerminate(s: string);
  function  MsgYesNo(s: string): word;
  function  MsgOKCancel(s: string): word;
  function  MsgYesNoCancel(s: string): word;
  procedure MsgInt(l: integer);

  function IsInteger(s: string): boolean;
  function IsDouble(s: string): boolean;

  function FormatToMoney(s: string):string;
  function FormatToMoney(d: double):string;

  function DatabaseFileIsOk(fName: string): boolean;
  function MakeFilenameAbsolute(var fName:string): boolean;
  function GetDefaultWobbelInifilename():string;
  function GetDefaultWobbelDatabasefilename():string;

  function GetDatabaseFile(canHalt:boolean): string;
  function GetNewDatabaseFile():string;

  function CopyAFile(fnameSource, fnameDestination: string):integer;
  function BackupDatabaseFile():string;
  function BackupDatabaseFile(out sOut1:string; out sOut2:string):string;
  function BackupDatabaseFile(extraNamepart:string; out sOut1:string; out sOut2:string):string;
  function BackupImportDatabaseFile(fNameOrigineel:string):string;

  function GetStringFromIniFile(section, ident, default: string):string;
  function GetIntegerFromIniFile(section, ident: string; default:Integer):integer;
  procedure SetValueInIniFile(section, ident, value: string);

  function FactorToPercentage(factor:double):double;
  function FactorToPercentage(factor:string):double;
  function PercentageToFactor(percentage:double):double;
  function PercentageToFactor(percentage:string):double;

  procedure CloseOtherScreens(frm: TForm);
  function getPosition(frm: TForm): TRect;
  function getMaxTableFieldSize(fieldname:string;q:TZQuery):integer;

  function GetIntValueFromDb(conn: TZConnection; sql,idcol:string; valueIfNotFound:integer): integer;
  procedure OpenTransactie(conn: TZConnection);
  procedure OpenTransactie(conn: TZConnection; FK_on:boolean);

  procedure ExporteerQueryResultsetToFile(sql:string; fname:string);
  procedure ExporteerQueryResultsetToFile(pgBar:TProgressBar; txtBox: TLabel; sql:string; fname:string);
  function ExporteerQueryResultsetToXls(sql, fname, wsName:string): string;
  procedure ExporteerQuery(sql, wsName:string);
  function CreateDirRecursively(newDir:string):boolean;
  procedure ExporteerQuery(pgBar:TProgressBar; txtBox: TLabel; sql, wsName:string);
  function ExporteerQueryResultsetToXls(pgBar:TProgressBar; txtBox: TLabel; sql, fname, wsName:string): string;
  procedure RapporteerVoortgang(pgBar:TProgressBar; txtBox: TLabel; pos:integer; tekst:string);

  function ProbeerPadRelatiefTeMaken(bestandsnaam:string):string;
  function ProbeerPadRelatiefTeMaken(bestandsnaam, absoluteGedeelteVanPad:string):string;
  function FilenameTotalLengthTooLong():boolean;

implementation

uses
  Windows, Dialogs, Classes, SysUtils, Controls,
  IniFiles, Crt, db,
  m_error, m_constant,m_wobbeldata,
  c_appsettings, formmain, formhelp,
  fpspreadsheet, xlsbiff2, laz_fpspreadsheet; // voor uitvoer naar Excel formaat

procedure MessageOK(mess: string);
begin
  Application.MessageBox(PChar(mess), 'Wobbel beurs', MB_OK);
end;

procedure MessageOK(mess: string; caption: string);
begin
  Application.MessageBox(PChar(mess), PChar(caption), MB_OK);
end;

procedure MessageError(mess: string);
begin
  Application.MessageBox(PChar(mess), 'Wobbel beurs', MB_OK);
end;

procedure MessageError(mess: string; caption: string);
begin
  Application.MessageBox(PChar(mess), PChar(caption), MB_OK);
end;

function MakePicklistItemDescription(Naam, Omschrijving: string): string;
var
  s: string;
begin
  s := Naam;
  if (Trim(Omschrijving)<>'') then
  begin
    s:=s + ' (' + Omschrijving + ')';
  end;
  MakePicklistItemDescription := s;
end;


procedure FillTransactieBetaalwijzePicklist(cmb: TComboBox);
var
  q : TZQuery;
  v: string;
begin
  cmb.Clear;
  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := 'select betaalwijze_id, omschrijving, opmerkingen from betaalwijze order by betaalwijze_id;';
      q.Open;
      while not q.Eof do
      begin
        v:=MakePicklistItemDescription(q.FieldByName('omschrijving').AsString, '');
        cmb.AddItem(v, TObject(q.FieldByName('betaalwijze_id').AsInteger));
        q.Next;
      end;

      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageOk('Fout bij invulling betaalwijze-picklist voor transacties: ' + E.Message);
    end;
  end;
end;


function getBeursOmschrijving(beursdatum, beursopmerkingen:string):string;
begin
  Result:=beursdatum + ' (' + beursopmerkingen + ')';

end;


procedure FillBeursPicklist(cmb: TComboBox);
var
  q : TZQuery;
  v: string;
begin
  cmb.Clear;
  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := 'select beurs_id, datum, opmerkingen, opbrengst, isactief from beurs order by beurs_id;';
      q.Open;
      while not q.Eof do
      begin
        v:=getBeursOmschrijving(q.FieldByName('datum').AsString, q.FieldByName('opmerkingen').AsString);
        cmb.Items.AddObject(v, TObject(q.FieldByName('beurs_id').AsInteger));
        q.Next;
      end;

      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageOk('Fout bij invulling beurs-picklist: ' + E.Message);
    end;
  end;
end;

function SetPicklistIdOfItemDescription(cmb: TComboBox; needleToFind:string):integer;
var
  ix:integer;
  id:integer;
begin

  id:=-1;
  ix:=0;
  for ix:=0 to cmb.Items.Count-1 do
  begin
    if (cmb.Items[ix] = needleToFInd) then
    begin
      id:=ix;
      cmb.ItemIndex:=ix;
      break;
    end;
  end;
  SetPicklistIdOfItemDescription:=id;
end;

function SetRadioItemOfGroupPicklist(rg: TRadioGroup; needleToFind:string):integer;
var
  ix:integer;
  id:integer;
begin

  id:=-1;
  ix:=0;
  for ix:=0 to rg.Items.Count-1 do
  begin
    if (rg.Items[ix] = needleToFInd) then
    begin
      id:=ix;
      rg.ItemIndex:=ix;
      break;
    end;
  end;
  Result:=id;
end;



// -----------------------------------------------------------------------------
function SubstFirst(InString, SearchString, WithString: string): string;
var
  p: integer;
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
function MsgYesNo(s: string): word;
begin
  Screen.Cursor:=crDefault;
  MsgYesNo:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_YESNO + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
function MsgYesNoCancel(s: string): word;
begin
  Screen.Cursor:=crDefault;
  MsgYesNoCancel:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_YESNOCANCEL + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
function MsgOKCancel(s: string): word;
begin
  Screen.Cursor:=crDefault;
  MsgOKCancel:=Application.MessageBox(PChar(s),PChar(c_AppName),MB_OKCANCEL + MB_DEFBUTTON1 + MB_ICONINFORMATION);
end;

// -----------------------------------------------------------------------------
procedure MsgInt(l: integer);
begin
  Screen.Cursor:=crDefault;
  MessageDlg(IntToStr(l),mtInformation,[mbOK],0);
end;


function IsInteger(s: string): boolean;
var
  Code: integer;
  i: integer;
begin
  Val(s, i, Code);
  IsInteger:=(Code = 0);
end;

// -----------------------------------------------------------------------------
function IsDouble(s: string): boolean;
var
//  Code: integer;
  r: double;
begin
  Try
    r:=StrToFloat(s);
    Result:=true;
  except
    on E: Exception do
    begin
      Result:=false;
    end
  end;
  // Onderstaande code gaat niet goed om met punten/komma's als decimaalscheidingsteken
  //Val(s, r, Code);
  //IsDouble:=(Code = 0);
end;

function FormatToMoney(s: string):string;
var
  sTmp:string;
  dTmp:double;
begin
  sTmp:=StringReplace(StringReplace(s, ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]), '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  if (LastDelimiter(DefaultFormatSettings.DecimalSeparator,sTmp)=0) then
  begin
    sTmp:=sTmp+DefaultFormatSettings.DecimalSeparator+'00';
  end;
  //FormatToMoney:=Format('%00.2f',[StrToFloat(sTmp)]);

  if (TryStrToFloat(sTmp, dTmp)) then
  begin
    FormatToMoney:=Format('%00.2f',[dTmp]);
  end
  else
  begin
    FormatToMoney:=Format('%00.2f',[0.0]);
  end;
end;

function FormatToMoney(d:double):string;
begin
  FormatToMoney:=Format('%00.2f',[d]);
end;

function DatabaseFileIsOk(fName: string): boolean;
var
  s:string;
begin
  s:=ExtractFileExt(fName);
  DatabaseFileIsOk:=MakeFilenameAbsolute(fName) and FileExists(fName) and (s = '.sp3');
  //DatabaseFileIsOk:=FileExists(fName) and (s = '.sp3');
end;

function MakeFilenameAbsolute(var fName:string): boolean;
var
  s:string;
begin
  Result:=true;
  try
    s:=ExpandFileName(fName);
    fName:=s;
  except
    on E: Exception do
    begin
      Result:=false;
    end;
  end;
end;

function GetDefaultWobbelErrorfilename():string;
var
  ext:string;
begin
  ext:=AppSettings.GetErrorFileExtension;
  Result:=GetAppFileWithExtension('logs', ext);
end;

function GetDefaultWobbelLogfilename():string;
var
  subdir:string;
  ext:string;
begin
  subdir:='';
  ext:=AppSettings.GetLogFileExtension;
  Result:=GetAppFileWithExtension('logs', ext);
end;

procedure LogfileAdd(s:string);
var
  fname:string;
  sPrefix:string;
begin
  sPrefix:=DateTimeToStr(Now) + ': ';
  fname:=GetDefaultWobbelLogfilename;
  // zie ook: http://www.freepascal.org/docs-html/rtl/sysutils/filecreate.html
  AppendToFile(fname, sPrefix+s+m_constant.c_CR);
end;

procedure LogfileEmpty();
var
  F : TextFile;
begin
  AssignFile(F,GetDefaultWobbelLogfilename);
  Rewrite (F);
  CloseFile(F);
end;

procedure ErrorfileAdd(s:string);
var
  fname:string;
  sPrefix:string;
begin
  sPrefix:=DateTimeToStr(Now) + ': ';
  fname:=GetDefaultWobbelErrorfilename;
  AppendToFile(fname, sPrefix+s+m_constant.c_CR);
end;

procedure ErrorfileEmpty();
var
  F : TextFile;
begin
  AssignFile(F,GetDefaultWobbelErrorfilename);
  Rewrite (F);
  CloseFile(F);
end;


// sExt moet de . bevatten
function GetAppFileWithExtension(subdir, sExt:string):string;
var
  sdir:string;
  sExtCorrected: string;
  SearchString:string;
  p: byte;
begin
  SearchString:='.';
  sExtCorrected:=sExt;
  p:=pos(SearchString,sExtCorrected);

  if p=0 then
  begin
    sExtCorrected:='.'+sExt;
  end;


  //Result:=c_LongPathPrefix + ChangeFileExt(ExtractFilePath (ParamStr (0)) + subdir + DirectorySeparator + ExtractFileName(ParamStr (0)),sExtCorrected);
  Result:=c_LongPathPrefix + ChangeFileExt(ExtractFilePath (Application.ExeName) + subdir + DirectorySeparator + ExtractFileName(Application.ExeName),sExtCorrected);

  sDir:=ExtractFileDir(Result);
  if (not DirectoryExists(sDir)) then
  begin
    CreateDirRecursively(sDir);
  end;
end;

function GetDefaultWobbelInifilename():string;
begin
  Result:=GetAppFileWithExtension('config', '.ini');
end;

function GetDefaultWobbelDatabasefilename():string;
begin
  Result:=GetAppFileWithExtension('database', '.sp3');
end;


// haal de databasefilename uit de inifile. Staat-ie daar niet, zoek dan in ./database/wobbelbeurs.sp3
// N.B. deze funcie kan nog wel wat refactoring gebruiken: efficientie kan hoger
function GetDatabaseFile(canHalt:boolean): string;
var
  isOk, huidigeDBisOk, kiesNieuweDB:boolean;
  INI:TINIFile;
  dbReturnFilename, dbFilenameInInifile:string;
  doHalt:boolean;
  sTest:string;
begin
  huidigeDBisOk:=DatabaseFileIsOk(dmWobbel.connWobbelMdb.Database);
  doHalt:=false;
  dbReturnFilename:='';
  kiesNieuweDB:=false;

  try
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    dbFilenameInInifile := INI.ReadString('INIT','DBFilename','');

    if (not DatabaseFileIsOk(dbFilenameInInifile)) then
    begin
      MessageOk('Er is geen geldig database bestand in de inifile ingesteld. Kies svp een andere.');
      kiesNieuweDB:=true;
    end
    else
    begin
      // als de dbfilename niet een absoluut pad had, dan hier alsnog het absolute pad
      // wegschrijven in de inifile
      //INI.WriteString('INIT','DBFilename',ExpandFileName(dbFilenameInInifile));
      // test: juist het eventueel relatieve pad laten staan
      //INI.WriteString('INIT','DBFilename',dbFilenameInInifile);
      INI.WriteString('INIT','DBFilename',ProbeerPadRelatiefTeMaken(dbFilenameInInifile));
    end;

    if (dbFilenameInInifile = '') then
    begin
      if (huidigeDBisOk) then
      begin
        // geldige huidige db maar niets in inifile: schrijven in ini
        //INI.WriteString('INIT','DBFilename',dmWobbel.connWobbelMdb.Database);
        INI.WriteString('INIT','DBFilename',ProbeerPadRelatiefTeMaken(dmWobbel.connWobbelMdb.Database));
        end
      else
      begin
        // niets in de inifile en geen geldige huidige db: kies een nieuwe.
        MessageOk('Er is nog geen database bestand geselecteerd. Kies deze svp eerst.');
        kiesNieuweDB:=true;
      end;
    end
    else
    begin
      // we hebben een waarde in dbFilenameInInifile
      if (huidigeDBisOk) then
      begin
        // geldige huidige db en ook iets in de inifile: schrijven in ini
        //INI.WriteString('INIT','DBFilename',dmWobbel.connWobbelMdb.Database);
        INI.WriteString('INIT','DBFilename',ProbeerPadRelatiefTeMaken(dmWobbel.connWobbelMdb.Database));
      end
      else
      begin
        // wel iets in de inifile en geen geldige huidige db: kies die uit de inifile indien die uit de inifile OK is
        if (not kiesNieuweDB) then
        begin
          sTest:=c_LongPathPrefix + ExpandFileName(dbFilenameInInifile);
          dmWobbel.connWobbelMdb.Database:=c_LongPathPrefix + ExpandFileName(dbFilenameInInifile);
        end;
      end
    end;

    if (kiesNieuweDB) then
    begin
      dmWobbel.dlgDatabase.FileName:=GetDefaultWobbelDatabasefilename;
      dbReturnFilename:=dmWobbel.dlgDatabase.FileName;

      isOk:=false;
      while not isOk do
      begin
        if dmWobbel.dlgDatabase.Execute then
        begin
          isOk:=DatabaseFileIsOk(dmWobbel.dlgDatabase.Filename);
          if (isOk) then
          begin
            if (dmWobbel.connWobbelMdb.Connected) then
            begin
              // zou niet nodig moeten zijn
              dmWobbel.connWobbelMdb.Disconnect;
            end;
            sTest:=c_LongPathPrefix + dmWobbel.dlgDatabase.Filename;
            dmWobbel.connWobbelMdb.Database:=c_LongPathPrefix + dmWobbel.dlgDatabase.Filename;
            //INI.WriteString('INIT','DBFilename',dmWobbel.connWobbelMdb.Database);
            INI.WriteString('INIT','DBFilename',ProbeerPadRelatiefTeMaken(dmWobbel.connWobbelMdb.Database));
          end;
        end
        else
        begin
          if (canHalt) then
          begin
            MessageOk('De wobbelkassa wordt afgesloten');
            doHalt:=true;
            break;
          end;
        end;
      end;
    end;

    if (not doHalt) then
    begin
      //ShowMessage(dmWobbel.connWobbelMdb.Database);
      dbReturnFilename:=dmWobbel.connWobbelMdb.Database;
      if (dmWobbel.connWobbelMdb.Connected) then
      begin
        dmWobbel.connWobbelMdb.Disconnect;
      end;
      dmWobbel.connWobbelMdb.Connect;
    end;
  finally
    Ini.Free;
    if (doHalt) then
    begin
      Halt;
    end
  end;
  GetDatabaseFile:=dbReturnFilename;
end;

// hier wordt een absoluut pad weggeschreven in de inifile als de nieuwe db niet een subdir is van het
// pad waarde applicatie staat
function GetNewDatabaseFile():string;
var
  isOk:boolean;
  INI:TINIFile;
  dbReturnFilename, prevFilename:string;
  doSave:boolean;
  sTest:string;
begin
  prevFilename:=dmWobbel.connWobbelMdb.Database;
  dbReturnFilename:=prevFilename;

  try
    doSave:=true;
    isOk:=false;
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    dmWobbel.dlgDatabase.InitialDir:=ExtractFilePath (Application.ExeName);
    dmWobbel.dlgDatabase.FileName:=prevFilename;

    while not isOk do
    begin
      if dmWobbel.dlgDatabase.Execute then
      begin
        isOk:=DatabaseFileIsOk(dmWobbel.dlgDatabase.Filename);
        if (isOk) then
        begin
          doSave:=true;
          if (dmWobbel.connWobbelMdb.Connected) then
          begin
            dmWobbel.connWobbelMdb.Disconnect;
          end;
          sTest:=c_LongPathPrefix + dmWobbel.dlgDatabase.Filename;
          dmWobbel.connWobbelMdb.Database:=c_LongPathPrefix + dmWobbel.dlgDatabase.Filename;
          dmWobbel.connWobbelMdb.Connect;
        end;
      end
      else
      begin
        doSave:=false;
        break;
      end;
    end;

    if (doSave) then
    begin
      // probeer om het pad relatief te maken
      //INI.WriteString('INIT','DBFilename',dmWobbel.connWobbelMdb.Database);
      INI.WriteString('INIT','DBFilename',ProbeerPadRelatiefTeMaken(dmWobbel.connWobbelMdb.Database));
    end
    else
    begin
      if (dmWobbel.connWobbelMdb.Connected) then
      begin
        dmWobbel.connWobbelMdb.Disconnect;
      end;
      dmWobbel.connWobbelMdb.Database:=prevFilename;
      dmWobbel.connWobbelMdb.Connect;
    end;
    dbReturnFilename:=dmWobbel.connWobbelMdb.Database;
  finally
    Ini.Free;
  end;
  result:=dbReturnFilename;
end;


function ProbeerPadRelatiefTeMaken(bestandsnaam:string):string;
begin
  Result:=StringReplace(bestandsnaam, ExtractFilePath (Application.ExeName), '', [rfReplaceAll]);
end;

function ProbeerPadRelatiefTeMaken(bestandsnaam, absoluteGedeelteVanPad:string):string;
begin
  Result:=StringReplace(bestandsnaam, absoluteGedeelteVanPad, '', [rfReplaceAll]);
end;

// Let op: gaat waarschijnlijk niet goed op linux of een netwerkdirectory
function CreateDirRecursively(newDir:string):boolean;
var
  isOk:boolean;
  workDir, tmpDirPart, buildUpDir:string;
  p: integer;
  len, lMax: integer;
begin
  isOk:=true;

  try
    workDir:=newDir;
    len:=length(workDir);
    lMax:=length(workDir);
    buildUpDir:='';
    repeat
      p:=pos(DirectorySeparator,workDir);
      if p<>0 then
      begin
        tmpDirPart:=Copy(workDir,1,p-1);
        if (buildUpDir = '') then
        begin
          buildUpDir:=tmpDirPart;
        end
        else
        begin
          buildUpDir:=buildUpDir + DirectorySeparator + tmpDirPart;
        end;
        if (not DirectoryExists(buildUpDir)) then
        begin
          CreateDir(buildUpDir);
        end;
        workDir:=Copy(workDir,p+1,lMax);
      end
      else
      begin
        if (workDir<>'') then
        begin
          if (buildUpDir = '') then
          begin
            buildUpDir:=workDir;
          end
          else
          begin
            buildUpDir:=buildUpDir + DirectorySeparator + workDir;
          end;
          if (not DirectoryExists(buildUpDir)) then
          begin
            CreateDir(buildUpDir);
          end;
        end;
      end;
    until p=0;
  except
    on E: Exception do
    begin
      isOk:=false;
      MessageError('Foutmelding: ' + E.Message);
    end;
  end;

  Result:=isOk;
end;

function BackupDatabaseFile():string;
var
  sOut1,sOut2:string;
begin
  Result:=BackupDatabaseFile('', sOut1,sOut2);
end;

function BackupDatabaseFile(out sOut1:string; out sOut2:string):string;
begin
  Result:=BackupDatabaseFile('', sOut1,sOut2);
end;

function BackupDatabaseFile(extraNamepart:string; out sOut1:string; out sOut2:string):string;
var
  sExtraBackupDname,sExtraBackupFname,sNewnameExtra:string;
  sOldname, sDestinationName, sNewname, sExt, sStem: string;
  iRet1, iRet2:integer;
  sDir:string;


  function getNewFName(oldname, extraNamepart, ext: string):string;
  var
    sNewpart: string;
  begin
    sNewpart:=FormatDateTime('mmdd_hhnnss',Now);
    Result:=oldname+'_'+extraNamepart+'_'+sNewpart+ext;
    if (extraNamepart = '') then
    begin
      Result:=oldname+'_'+sNewpart+ext;
    end;
  end;
begin
  iRet1:=-1;
  iRet2:=-1;
  sNewname:='';
  Result:='';
  sOut1:='';
  sOut2:='';

  sOldname:=dmWobbel.connWobbelMdb.Database;
  sDestinationName:=ExtractFileDir(dmWobbel.connWobbelMdb.Database) + DirectorySeparator +
      GetStringFromIniFile('INIT','DatabaseBackupSubdirectory','') + DirectorySeparator +
      ExtractFileName(sOldname);
  sExt:=ExtractFileExt(sOldname);
  sDir:=ExtractFileDir(sDestinationName);
  if (not DirectoryExists(sDir)) then
  begin
    CreateDirRecursively(sDir);
  end;
  sStem:=StringReplace(sDestinationName,sExt,'',[rfReplaceAll]);

  sNewname:=getNewFName(sStem, extraNamepart, sExt);
  while (FileExists(sNewname)) do
  begin
    sNewname:=getNewFName(sStem, extraNamepart, sExt);
    Delay(1000);
  end;

  iRet1:=CopyAFile(sOldname, sNewname);
  if (iRet1>-1) then
  begin
    sOut1:=sNewname;
  end;


  sExtraBackupDname:=GetStringFromIniFile('INIT','DirectoryVoorExtraDatabaseBackup','');
  if (sExtraBackupDname <> '') then
  begin
    if (not DirectoryExists(sExtraBackupDname)) then
    begin
      CreateDirRecursively(sExtraBackupDname);
    end;

    sExtraBackupFname:=sExtraBackupDname+DirectorySeparator+ExtractFileName(sOldname);
    sStem:=StringReplace(sExtraBackupFname,sExt,'',[rfReplaceAll]);
    sNewnameExtra:=getNewFName(sStem, extraNamepart, sExt);
    while (FileExists(sNewnameExtra)) do
    begin
      sNewnameExtra:=getNewFName(sStem, extraNamepart, sExt);
      Delay(1000);
    end;
    iRet2:=CopyAFile(sOldname, sNewnameExtra);
    if (iRet2>-1) then
    begin
      sOut2:=sNewnameExtra;
      if (sOut2 = '') then
      begin
        Result:=sOut1;
      end
      else
      begin
        Result:=sOut1 + ' en ' + sOut2;
      end;
    end;
  end;
end;

function BackupImportDatabaseFile(fNameOrigineel:string):string;
var
  sOldname, sDestinationName, sDir, sNewname, sExt, sStem: string;
  iRet1:integer;

  function getNewFName(oldname, ext: string):string;
  var
    sNewpart: string;
  begin
    sNewpart:=FormatDateTime('mmdd_hhnnss',Now);
    Result:=oldname+'_import_'+sNewpart+ext;
  end;
begin
  iRet1:=-1;
  sNewname:='';
  Result:='';

  sOldname:=fNameOrigineel;
  sDestinationName:=ExtractFileDir(fNameOrigineel) + DirectorySeparator +
      GetStringFromIniFile('INIT','DatabaseBackupSubdirectory','') + DirectorySeparator +
      ExtractFileName(fNameOrigineel);
  sExt:=ExtractFileExt(sOldname);
  sDir:=ExtractFileDir(sDestinationName);
  if (not DirectoryExists(sDir)) then
  begin
    CreateDirRecursively(sDir);
  end;
  sStem:=StringReplace(sDestinationName,sExt,'',[rfReplaceAll]);


//  sOldname:=fNameOrigineel;
//  sExt:=ExtractFileExt(sOldname);
//  sStem:=StringReplace(sOldname,sExt,'',[rfReplaceAll]);

  sNewname:=getNewFName(sStem, sExt);
  while (FileExists(sNewname)) do
  begin
    sNewname:=getNewFName(sStem, sExt);
    Delay(1000);
  end;

  iRet1:=CopyAFile(sOldname, sNewname);
  if (iRet1>-1) then
  begin
    Result:=sNewname;
  end;
end;

function CopyAFile(fnameSource, fnameDestination: string):integer;
var
  SourceF, DestF: TFileStream;
  s: string;
  Filesize, TotalBytesRead, BytesRead : Int64;
  Buffer : array [0..4095] of byte;  // or, array [0..4095] of char

begin
  Result:=-1;
  try
    try
      SourceF:= TFileStream.Create(fnameSource, fmOpenRead + fmShareDenyNone);
      DestF:= TFileStream.Create(fnameDestination, fmCreate);

      TotalBytesRead:=0;
      SourceF.Position := 0;
      DestF.Position := 0;
      Filesize:=SourceF.Size;
      while TotalBytesRead < Filesize do
      begin
        BytesRead := SourceF.Read(Buffer,sizeof(Buffer));
        inc(TotalBytesRead, BytesRead);
        DestF.Write(Buffer, BytesRead);
      end;
      Result:=SourceF.Size;
    finally
      SourceF.Free;
      DestF.Free;
    end;
  except
    on E: Exception do
    begin
      s:='Fout bij aanmaken backup "'+fnameDestination+'" van database "'+fnameSource+'":  ' + E.Message;
      s:=s+'  SVP AFSLUITEN EN OPNIEUW OPSTARTEN';
      MessageOk(s);
    end;
  end;

end;

// http://wiki.freepascal.org/File_Handling_In_Pascal
(*
function xxAppendToFile(fname, s: string):integer;
var
 F: TextFile;
begin
  {$I+}
  try
    AssignFile(F, fname);
    Append(F, s);
    CloseFile(File1);
  except
    on E: EInOutError do
    begin
     Writeln('File handling error occurred. Details: '+E.ClassName+'/'+E.Message);
    end;
  end;
end;
*)
function AppendToFile(fname, s: string):integer;
var
  SS: TStringStream;
  FS: TFileStream;
  totsize, TotalBytesRead, BytesRead : Int64;
  Buffer : array [0..4095] of byte;  // or, array [0..4095] of char
begin
  Result:=-1;
  try
    try
      SS:= TStringStream.Create(s);
      totsize:=sizeof(s);

      // maak de directory als-ie nog niet bestaat
      if (not DirectoryExists(ExtractFileDir(fname))) then
      begin
        CreateDirRecursively(ExtractFileDir(fname));
      end;

      if (not FileExists(fname)) then
      begin
        FS:= TFileStream.Create(fname, fmCreate);
      end
      else
      begin
        FS:= TFileStream.Create(fname, fmOpenWrite);
      end;

      SS.Position := 0;
      totsize:=SS.Size;

      TotalBytesRead:=0;
      FS.Position := FS.Size;
      while TotalBytesRead < totsize do
      begin
        BytesRead := SS.Read(Buffer,sizeof(Buffer));
        inc(TotalBytesRead, BytesRead);
        FS.Write(Buffer, BytesRead);
      end;
      Result:=TotalBytesRead;
    finally
      SS.Free;
      FS.Free;
    end;
  except
    on E: Exception do
    begin
      s:='Fout bij schrijven naar "'+fname+'" ":  ' + E.Message;
      MessageOk(s);
    end;
  end;

end;

procedure SetValueInIniFile(section, ident, value: string);
var
  INI:TINIFile;
begin
  try
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    INI.WriteString(section,ident,value);
  finally
    Ini.Free;
  end;
end;

function GetStringFromIniFile(section, ident, default: string):string;
var
  INI:TINIFile;
begin
  try
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    Result:=INI.ReadString(section,ident,default);
  finally
    Ini.Free;
  end;
end;

function GetIntegerFromIniFile(section, ident: string; default:Integer):integer;
var
  INI:TINIFile;
begin
  try
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    Result:=INI.ReadInteger(section,ident,default);
  finally
    Ini.Free;
  end;
end;

function FactorToPercentage(factor:double):double;
begin
  Result:=100.0 * (1.0 - factor);
end;
function FactorToPercentage(factor:string):double;
begin
  Result:=100.0 * (1.0 - StrToFloat(factor));
end;

function PercentageToFactor(percentage:double):double;
begin
  Result:= 1.0 - percentage / 100.0;
end;
function PercentageToFactor(percentage:string):double;
begin
  Result:= 1.0 - StrToFloat(percentage) / 100.0;
end;


procedure CloseOtherScreens(frm: TForm);
var
  i: integer;
  frmMain: TfrmMain;
  frmHelp: TfrmHelp;
begin
  frmMain := TfrmMain(Application.FindComponent('frmMain'));
  frmHelp := TfrmHelp(Application.FindComponent('frmHelp'));
//  for i:= 0 to Screen.CustomFormCount - 1 do
  for i:= 0 to Screen.FormCount - 1 do
  begin
    if ((Screen.Forms[i] <> frm) and (Screen.Forms[i] <> frmMain) and (Screen.Forms[i] <> frmHelp)) then
    begin
      Screen.Forms[i].Hide;
    end;
  end;
end;


(*
RECT = record
          case Integer of
             0: (Left,Top,Right,Bottom : Longint);
             1: (TopLeft,BottomRight : TPoint);
       end;
*)

function getPosition(frm: TForm): TRect;
var
  frmMain: TfrmMain;
  rect:TRect;
  left, top, right, bottom: integer;
  topConstant:integer;
begin
  frmMain := TfrmMain(Application.FindComponent('frmMain'));

  if (frmMain <> nil) then
  begin
    topConstant:=21;

    left:=Round(frmMain.Left + frmMain.Width/2.0 - frm.Width/2.0);
    top:=topConstant + Round(frmMain.Top + frmMain.Height/2.0 - frm.Height/2.0);
    right:=left + frm.Width;
    bottom:=top + frm.Height;
  end;

  frm.Left:=left;
  frm.Top:=top;
  frm.Width:=right-left;
  frm.Height:=bottom-top;

  rect.Left:=left;
  rect.Top:=top;
  rect.Right:=right;
  rect.Bottom:=bottom;

  getPosition:=rect;
end;

function getMaxTableFieldSize(fieldname:string;q:TZQuery):integer;
var
  retsize:integer;
  intsize,doublesize,dtsize:integer;
begin
  retsize:=4;
  intsize:=10;
  doublesize:=10;
  dtsize:=20;
  case TFieldType(q.FieldByName(fieldname).DataType) of
     db.ftInteger, db.ftFloat : retsize:=intsize;
     db.ftString: retsize:=q.FieldByName(fieldname).Size;
     db.ftDate,db.ftTime,db.ftDateTime: retsize:=dtsize;
     else retsize:=10;
  end;
  Result:=retsize;
end;


function GetIntValueFromDb(conn: TZConnection; sql,idcol:string; valueIfNotFound:integer): integer;
var
  q : TZQuery;
  retVal:integer;
  s:string;
begin
  try
    try
      retval:=valueIfNotFound;
      q:=TZQuery.Create(nil);
      q.Connection := conn;

      q.SQL.Clear;
      q.SQL.Text:=sql;
      q.Open;
      while not q.Eof do
      begin
        s:=q.FieldByName(idcol).AsString;
        if (s='') then
        begin
          retVal:=valueIfNotFound;
        end
        else
        begin
          retVal:=StrToInt(s);
        end;
        break;
      end;
      q.Close;

      Result:=retval;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      Raise EWobbelError.Create('Fout(1001): bij opvragen waarde uit tabel: ' + E.Message);
    end;
  end;
end;

procedure OpenTransactie(conn: TZConnection; FK_on:boolean);
begin
  // commit geeft geen foutmelding in SQLite als er geen transactie bezig was
  conn.ExecuteDirect('commit transaction');
  conn.ExecuteDirect('begin transaction');
  if (FK_on) then
  begin
    conn.ExecuteDirect('PRAGMA foreign_keys = ON;');
  end
  else
  begin
    conn.ExecuteDirect('PRAGMA foreign_keys = OFF;');
  end;
end;

procedure OpenTransactie(conn: TZConnection);
begin
  OpenTransactie(conn, true);
end;


procedure RapporteerVoortgang(pgBar:TProgressBar; txtBox: TLabel; pos:integer; tekst:string);
begin
  if (pgBar <> nil) then
  begin
     pgBar.Position:=pos;
     if (txtBox <> nil) then
     begin
       txtBox.Caption:=tekst;
     end;
     Application.ProcessMessages;
  end;

end;


procedure ExporteerQueryResultsetToFile(sql:string; fname:string);
begin
  ExporteerQueryResultsetToFile(nil, nil, sql, fname);
end;


procedure ExporteerQueryResultsetToFile(pgBar:TProgressBar; txtBox: TLabel; sql:string; fname:string);
var
  q:TZQuery;
  ix:integer;
  recCount:integer;
  s, waarde:string;
  FileVar: TextFile;
  nEenVijfde, nTweeVijfde, nDrieVijfde, nVierVijfde:integer;
  FieldSeparator:char;
begin
  try
    try
      FieldSeparator:=chr(44);
      if (DefaultFormatSettings.DecimalSeparator = chr(44)) then // komma
      begin
        FieldSeparator:=chr(59); // puntkomma
      end
      else
      if (DefaultFormatSettings.DecimalSeparator = chr(46)) then // punt
      begin
        FieldSeparator:=chr(44); // komma
      end;


      RapporteerVoortgang(pgBar, txtBox, 10, 'Gegevens ophalen...');

      // maak de directory als-ie nog niet bestaat
      if (not DirectoryExists(ExtractFileDir(fname))) then
      begin
        CreateDirRecursively(ExtractFileDir(fname));
      end;


      AssignFile(FileVar, fname);
      {$I+} //use exceptions
      Rewrite(FileVar);  // creating the file

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text:=sql;
      q.ReadOnly:=true;
      q.Open;

      RapporteerVoortgang(pgBar, txtBox, 20, 'Gegevens opgehaald');

      nEenVijfde:=Round(q.RecordCount/5);
      nTweeVijfde:=2*nEenVijfde;
      nDrieVijfde:=3*nEenVijfde;
      nVierVijfde:=4*nEenVijfde;
      // schrijf de headers
      s:='';
      for ix:=0 to q.FieldCount-1 do
      begin
        if (ix>0) then
        begin
          s:=s+FieldSeparator;
        end;
        //s:=s+StringReplace(q.Fields[ix].FieldName, m_constant.c_TAB, ' ', [rfReplaceAll]);
        s:=s + c_CSVFieldBorder + StringReplace(q.Fields[ix].FieldName, '"', '""', [rfReplaceAll]) + c_CSVFieldBorder;
      end;
      Writeln(FileVar,s);

      RapporteerVoortgang(pgBar, txtBox, 30, 'Gegevens wegschrijven...');

      recCount:=0;
      while not q.Eof do
      begin
        s:='';
        for ix:=0 to q.FieldCount-1 do
        begin

          waarde:=c_CSVFieldBorder + q.Fields[ix].AsString + c_CSVFieldBorder;
          case TFieldType(q.Fields[ix].DataType) of
             db.ftInteger, db.ftSmallint, db.ftAutoInc, db.ftLargeint, db.ftTimeStamp :
                          waarde:=c_CSVFieldBorder + q.Fields[ix].AsString + c_CSVFieldBorder;

             db.ftFloat, db.ftCurrency:
                          waarde:=c_CSVFieldBorder + FloatToStr(1.0*q.Fields[ix].AsFloat) + c_CSVFieldBorder;

             db.ftString, db.ftWord, db.ftMemo, db.ftFixedChar, db.ftWideString, db.ftFixedWideChar, db.ftWideMemo:
                          waarde:=c_CSVFieldBorder + StringReplace(q.Fields[ix].AsString, '"', '""', [rfReplaceAll]) + c_CSVFieldBorder;

             db.ftDate,db.ftTime,db.ftDateTime: waarde:=c_CSVFieldBorder + q.Fields[ix].AsString + c_CSVFieldBorder;

             //db.ftInteger : waarde:=c_CSVFieldBorder + q.Fields[ix].AsString + c_CSVFieldBorder;
             //db.ftFloat   : waarde:=c_CSVFieldBorder + FloatToStr(1.0*q.Fields[ix].AsFloat) + c_CSVFieldBorder;
             //db.ftString  : waarde:=c_CSVFieldBorder + StringReplace(q.Fields[ix].AsString, '"', '""', [rfReplaceAll]) + c_CSVFieldBorder;
             //db.ftDate,db.ftTime,db.ftDateTime: waarde:=c_CSVFieldBorder + q.Fields[ix].AsString + c_CSVFieldBorder;
             else waarde:=c_CSVFieldBorder + StringReplace(q.Fields[ix].AsString, '"', '""',[rfReplaceAll]) + c_CSVFieldBorder;
          end;

          if (ix>0) then
          begin
            s:=s + FieldSeparator;
          end;
          s:=s + waarde;
        end;
        Writeln(FileVar,s);

        if (pgBar <> nil) then
        begin
          if (recCount = nEenVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 45, 'Gegevens wegschrijven...');
          end
          else if (recCount = nTweeVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 60, 'Gegevens wegschrijven...');
          end
          else if (recCount = nDrieVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 75, 'Gegevens wegschrijven...');
          end
          else if (recCount = nVierVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 90, 'Gegevens wegschrijven...');
          end;
        end;
        inc(recCount);

        q.Next;
      end;
      q.Close;

      RapporteerVoortgang(pgBar, txtBox, 100, 'Klaar');
      RapporteerVoortgang(pgBar, txtBox, 100, 'De tabel is opgeslagen.' + c_CR + '!! LET OP!! Als het bestand wordt geopend in Excel: voorkom eventuele latere problemen met bedragen door direct als een .xsl(x) bestand op te slaan!');

      CloseFile(FileVar);
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij exporteren query resultaten: ' + E.Message);
      RapporteerVoortgang(pgBar, txtBox, 100, 'Mislukt');
    end;
  end;
end;

function ExporteerQueryResultsetToXls(sql, fname, wsName:string): string;
begin
  Result:=ExporteerQueryResultsetToXls(nil, nil, sql, fname, wsName);
end;

function ExporteerQueryResultsetToXls(pgBar:TProgressBar; txtBox: TLabel; sql, fname, wsName:string): string;
var
  q:TZQuery;
  ix:integer;
  FileVar: TextFile;
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  counter:integer;
  fileExt:string;
  fnameWork:string;
  testIx:double;
  nEenVijfde, nTweeVijfde, nDrieVijfde, nVierVijfde:integer;
begin
//  MessageOK(sql);

  fileExt:=AnsiLowerCase(ExtractFileExt(fname));
  if (fileExt = '.csv') then
  begin
    ExporteerQueryResultsetToFile(pgBar, txtBox, sql, fname);
    Result:=fname;
    exit;
  end;

  //ExporteerQueryResultsetToFile(sql,fname);
  //Result:=fname;
  //exit;
  try
    // Create the spreadsheet
    MyWorkbook := TsWorkbook.Create;
    try
      MyWorksheet := MyWorkbook.AddWorksheet(wsName);

      RapporteerVoortgang(pgBar, txtBox, 5, 'Gegevens ophalen...');

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.ReadOnly:=true;
      q.SQL.Text:=sql;
      q.Open;

      RapporteerVoortgang(pgBar, txtBox, 10, 'Gegevens opgehaald');

      // schrijf de header weg
      for ix:=0 to q.FieldCount-1 do
      begin
        MyWorksheet.WriteUTF8Text(0,ix,q.Fields[ix].FieldName);
        MyWorksheet.WriteUsedFormatting(0, ix, [uffBold]);
      end;

      RapporteerVoortgang(pgBar, txtBox, 15, 'Gegevens wegschrijven...');

      counter:=0;
      nEenVijfde:=Round(q.RecordCount/5);
      nTweeVijfde:=2*nEenVijfde;
      nDrieVijfde:=3*nEenVijfde;
      nVierVijfde:=4*nEenVijfde;
      while not q.Eof do
      begin
        for ix:=0 to q.FieldCount-1 do
        begin
          case TFieldType(q.Fields[ix].DataType) of
             db.ftInteger, db.ftSmallint, db.ftAutoInc, db.ftLargeint, db.ftTimeStamp :
                          MyWorksheet.WriteNumber(counter+1,ix,q.Fields[ix].AsInteger);

             db.ftFloat, db.ftCurrency:
                          MyWorksheet.WriteNumber(counter+1,ix,q.Fields[ix].AsFloat);

             db.ftString, db.ftWord, db.ftMemo, db.ftFixedChar, db.ftWideString, db.ftFixedWideChar, db.ftWideMemo:
                          MyWorksheet.WriteUTF8Text(counter+1,ix,q.Fields[ix].AsString);

             db.ftDate,db.ftTime,db.ftDateTime: MyWorksheet.WriteDateTime(counter+1,ix,q.Fields[ix].AsDateTime);

             else MyWorksheet.WriteUTF8Text(counter+1,ix,q.Fields[ix].AsString);
          end;
        end;

        if (pgBar <> nil) then
        begin
          if (counter = nEenVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 20, 'Gegevens ophalen...');
          end
          else if (counter = nTweeVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 28, 'Gegevens ophalen...');
          end
          else if (counter = nDrieVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 36, 'Gegevens ophalen...');
          end
          else if (counter = nVierVijfde) then
          begin
            RapporteerVoortgang(pgBar, txtBox, 43, 'Gegevens ophalen...');
          end;
        end;

        q.Next;
        counter:=counter+1;
      end;
      q.Close;

      RapporteerVoortgang(pgBar, txtBox, 50, 'Gegevens wegschrijven naar bestand...');

      (*
      Select Case Application.Version
Case "5.0"
Ver = "Excel 5"
Case "7.0"
Ver = "Excel 95"
Case "8.0"
Ver = "Excel 97"
Case "9.0"
Ver = "Excel 2000"
Case "10.0"
Ver = "Excel 2002"
Case "11.0"
Ver = "Excel 2003"
Case "12.0"
Ver = "Excel 2007"
Case Else
Ver = "Unknown version"
End Select
      *)

      // maak de directory als-ie nog niet bestaat
      if (not DirectoryExists(ExtractFileDir(fname))) then
      begin
        CreateDirRecursively(ExtractFileDir(fname));
      end;

      // Save the spreadsheet to a file
      fnameWork:=fname;
      fileExt:=AnsiLowerCase(ExtractFileExt(fname));
      if (fileExt = '.xls') then
      begin
        MyWorkbook.WriteToFile(fnameWork, sfExcel8, true);
      end
      else if (fileExt = '.ods') then
      begin
        MyWorkbook.WriteToFile(fnameWork, sfOpenDocument, true);
      end
      else if (fileExt = '.xlsx') then
      begin
        MyWorkbook.WriteToFile(fnameWork, sfOOXML, true);
      end
      else
      begin
        Raise EWobbelError.Create('Fout: onbekend bestandsformaat: "' + fileExt + '"');
      end;

      RapporteerVoortgang(pgBar, txtBox, 100, 'Klaar');

      Result:=fnameWork;
    finally
      MyWorkbook.Free;
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij exporteren query resultaten: ' + E.Message);
      RapporteerVoortgang(pgBar, txtBox, 100, 'Mislukt');
    end;
  end;
end;

procedure ExporteerQuery(sql, wsName:string);
begin
  ExporteerQuery(nil, nil, sql, wsName);
end;

procedure ExporteerQuery(pgBar:TProgressBar; txtBox: TLabel; sql, wsName:string);
var
  xlsname:string;
  goOn:boolean;
  fnameExt:string;
  fname:string;
begin
  try
    goOn:=true;
    if (dmWobbel.dlgExporteerSQLNaarXls.Execute) then
    begin
      fname:=dmWobbel.dlgExporteerSQLNaarXls.FileName;
      fnameExt:=AnsiLowerCase(ExtractFileExt(fname));
      if (dmWobbel.dlgExporteerSQLNaarXls.FilterIndex=1) then
      begin
        if (fnameExt <> '.xls') then
        begin
          fnameExt:='.xls';
          fname:=ChangeFileExt(dmWobbel.dlgExporteerSQLNaarXls.FileName,'.xls');
        end;
      end
      else
      if (dmWobbel.dlgExporteerSQLNaarXls.FilterIndex=2) then
      begin
        if (fnameExt <> '.xlsx') then
        begin
          fnameExt:='.xlsx';
          fname:=ChangeFileExt(dmWobbel.dlgExporteerSQLNaarXls.FileName,'.xlsx');
        end;
      end
      else
      if (dmWobbel.dlgExporteerSQLNaarXls.FilterIndex=3) then
      begin
        if (fnameExt <> '.ods') then
        begin
          fnameExt:='.ods';
          fname:=ChangeFileExt(dmWobbel.dlgExporteerSQLNaarXls.FileName,'.ods');
        end;
      end
      else
      if (dmWobbel.dlgExporteerSQLNaarXls.FilterIndex=4) then
      begin
        if (fnameExt <> '.csv') then
        begin
          fnameExt:='.csv';
          fname:=ChangeFileExt(dmWobbel.dlgExporteerSQLNaarXls.FileName,'.csv');
        end;
      end;


      if (FileExists(fname)) then
      begin
        if MessageDlg('Wobbel', 'Bestand "'+fname+'" bestaat al. Overschrijven?', mtConfirmation,
        [mbYes, mbNo],0) = mrYes
        then
        begin
          DeleteFile(fname);
        end
        else
        begin
          MessageOk('De tabel is niet opgeslagen');
          goOn:=false;
        end;
      end;
      if (goOn) then
      begin
        xlsname:=m_tools.ExporteerQueryResultsetToXls(pgBar, txtBox, sql, fname, wsName);
        if (xlsname='') then
        begin
          Raise EWobbelError.Create('Export is mislukt');
        end;
        if (fnameExt = '.csv') then
        begin
          MessageOk('De tabel is opgeslagen in bestand "'+xlsname+'"' + c_CR + c_CR + '!! LET OP!! Als het csv bestand wordt geopend in Excel, bewaar dit dan direct als een .xsl(x) bestand!!' + c_CR + 'Hiermee voorkom je later eventuele problemen met bedragen.');
        end
        else
        begin
          MessageOk('De tabel is opgeslagen in bestand "'+xlsname+'"');
        end;
      end;
    end;
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;


function FilenameTotalLengthTooLong():boolean;
var
  name_backupsubdir, name_backupdatabasefile:string;
  name_dbfilename:string;
  len_name_dbfilename:integer;
  extraTovExe:string;
begin
  Result:=false;
  name_backupsubdir:='backup';
  name_dbfilename:=ChangeFileExt(ExtractFileName(Application.ExeName),'.sp3');
  if (AppSettings <> nil) then
  begin
    name_backupsubdir:=GetStringFromIniFile('INIT','DatabaseBackupSubdirectory','');
    name_dbfilename:=ExtractFileName(ExpandFileName(GetStringFromIniFile('INIT','DBFilename','')));
  end;
  // bij nader inzien: geef een schatting voor de naamlengte.
  name_dbfilename:='';
  len_name_dbfilename:=15;
  extraTovExe:='database'+
               DirectorySeparator+
               name_backupsubdir+
               DirectorySeparator+
               name_dbfilename+
               '_PreImport_'+'mmdd_hhnnss'+'.sp3';

  name_backupdatabasefile:=ExtractFilePath (Application.ExeName) + extraTovExe;

  (*
  MessageOk('extraTovExe:'+'('+IntToStr(Length(extraTovExe))+')'+c_CR +
            'name_backupdatabasefile:'+'('+IntToStr(Length(name_backupdatabasefile))+')'+c_CR +
            'Application dir:'+'('+IntToStr(Length(ExtractFileDir(Application.ExeName)))+')');
  *)

  if ((Length(name_backupdatabasefile)+len_name_dbfilename) >= (MAX_PATH-1)) then
  begin
    MsgError('LET OP! ' + c_CR +
    'De lengte van de naam van het complete pad waar de applicatie in de Windows folderstructuur is opgeslagen dreigt te groot te worden. ' + c_CR +
    'Het maximum is '+IntToStr(MAX_PATH-1)+' tekens; het totaal voor de applicatie is nu: ' + IntToStr(Length(ExtractFileDir(Application.ExeName))+1) + '.' + c_CR +
    'Hier kunnen nog '+IntToStr(Length(extraTovExe))+' tekens bij komen voor backups van de database, plus de naam van de database.' + c_CR +
    'Aan te raden is om de applicatie af te sluiten en het geheel, inclusief subfolders, te verplaatsen naar een locatie lager in de folderboom, bijvoorbeeld "E:\wobbelbeurs\" ' + c_CR +
    c_CR +
    '(huidige pad: ' + StringReplace(Application.ExeName,DirectorySeparator,DirectorySeparator+' ',[rfReplaceAll]) + ')' + c_CR
    );
    Result:=true;
  end;
end;


end.



