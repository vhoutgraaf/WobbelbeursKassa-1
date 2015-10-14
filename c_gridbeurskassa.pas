//------------------------------------------------------------------------------
// Name        : c_gridbeurskassa
// Purpose     : Implementatie van TGridBeursKassa
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               kassa;s, voor de acieve beurs.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridbeurskassa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;

type
TGridBeursKassa = class(TWobbelGridPanel)
private
  FOwner:TComponent;

  FParent:TWinControl;
  FBeursId: integer;
  FBeursOmschrijving: string;

  procedure btnPostClick(Sender: TObject);
  procedure btnDeleteClick(Sender: TObject);
  procedure btnRefreshClick(Sender: TObject);
  procedure btnCancelClick(Sender: TObject);

  procedure GridValidateEntry(sender: TObject; aCol,
    aRow: Integer; const OldValue: string; var NewValue: String);

  function CheckGridValues(iRowToSkip:integer): boolean;

  procedure WobbelGridClick(Sender: TObject);


  function DeleteData(kassaid: integer; sKassanr: string):boolean;

  function PostData(kassa_id, isactief :integer;
           kassanr, opmerkingen: string): boolean;

  function KassanrIsUniek(kassanr:string): integer;
  procedure ProcessMainformStuff;

public
  constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight, BeursId:integer; BeursOmschrijving: string);
  destructor Destroy; override;

  procedure SetGridProps;

  procedure FillGrid;
  function AnyRowIsDirty: boolean;
  function PostData:boolean;

  property BeursId: integer read FBeursId write FBeursId;
  property BeursOmschrijving: string read FBeursOmschrijving write FBeursOmschrijving;


end;



implementation

uses
  ZDataset,
  Dialogs, LCLType,
  formtransacties,
  m_wobbeldata, m_querystuff, m_tools, m_error,
  c_appsettings,
  m_constant;

constructor TGridBeursKassa.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight, BeursId:integer; BeursOmschrijving: string);
var
  navButs: TWobbelNavButtons;
begin
  if (BeursId <= 0) then
  begin
//    MessageDlg('Wobbel', 'Er is geen beurs gekozen. Svp eerst een beurs kiezen', mtConfirmation, [mbYes],0);
    exit;
  end;

  FBeursId:=BeursId;
  FBeursOmschrijving:=BeursOmschrijving;
  FParent:=AParent;
  FOwner:=AOwner;

  Titel:='Kassa''s voor de actuele beurs beheren';

  navButs:=[wbFirst, wbPrev, wbNext, wbLast, wbAdd, wbDelete, wbEdit, wbPost, wbCancel, wbRefresh];
  inherited Create(AOwner, AParent, ATop, ALeft, AHeight, navButs);

  SetGridProps;

  if (WBPOST in navButs) then
  begin
    btnPost.OnClick:=@btnPostClick;
  end;
  if (WBDELETE in navButs) then
  begin
    btnDelete.OnClick:=@btnDeleteClick;
  end;
  if (WBREFRESH in navButs) then
  begin
    btnRefresh.OnClick:=@btnRefreshClick;
  end;
  if (WBCANCEL in navButs) then
  begin
    btnCancel.OnClick:=@btnCancelClick;
  end;

  WobbelGrid.OnValidateEntry:=@GridValidateEntry;
  WobbelGrid.OnClick:=@WobbelGridClick;

  self.SetGridHint('Geef in de tabel aan welke kassa''s er zijn voor de beurs.'+m_constant.c_CR+'Er moet voor iedere kassa een aparte database worden gemaakt.');

  FillGrid;
  SetGridStatus([WSENABLEDEDITABLE]);
end;

destructor TGridBeursKassa.Destroy;
begin
  inherited Destroy;
end;

procedure TGridBeursKassa.SetGridProps;
var
  index: integer;
  q:TZQuery;
  bVal:boolean;
  ml_kassaid, ml_kassanr, ml_isactief, ml_opmerkingen, ml_datumtijdinvoeren,ml_datumtijdwijzigen:integer;
begin
  index:=-1;

  try
    ml_kassaid:=10;
    ml_kassanr:=20;
    ml_isactief:=10;
    ml_opmerkingen:=255;
    ml_datumtijdinvoeren:=20;
    ml_datumtijdwijzigen:=20;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;
    q.SQL.Text:='select kassa_id, kassanr, isactief, opmerkingen, datumtijdinvoeren,datumtijdwijzigen from kassa limit 1';
    q.Open;
    ml_kassaid:=m_tools.getMaxTableFieldSize('kassa_id', q);
    ml_kassanr:=m_tools.getMaxTableFieldSize('kassanr', q);
    ml_isactief:=m_tools.getMaxTableFieldSize('isactief', q);
    ml_opmerkingen:=m_tools.getMaxTableFieldSize('opmerkingen', q);
    ml_datumtijdinvoeren:=m_tools.getMaxTableFieldSize('datumtijdinvoeren', q);
    ml_datumtijdwijzigen:=m_tools.getMaxTableFieldSize('datumtijdwijzigen', q);
    q.Close;
  finally
    q.Free;
  end;


  //MessageOk('colcount BeursKassa: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='KassaId';
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'kassa_id', [wtInteger], '', 1, ml_kassaid, 'KassaId', 'interne unieke id van de kassa', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Kassanr';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=250;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'kassanr', [wtString], '', 1, ml_kassanr, 'Kassanr', 'voor iedere beurs uniek nummer van de kassa', WobbelGrid.Columns.Items[index].Width, true));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opmerkingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=250;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'opmerkingen', [wtMemo], '', 0, ml_opmerkingen, 'Opmerkingen', 'Eventueel commentaar biji de kassa', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Is actief';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=1;
  WobbelGrid.Columns.Items[index].Width:=100;
  WobbelGrid.Columns.Items[index].ButtonStyle:=cbsCheckboxColumn;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isactief', [wtinteger], '0', 1, ml_isactief, 'Is actief', 'aangevinkt als dit de kassa voor de actuele beurs ("'+FBeursOmschrijving+'") is', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van invoeren';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=170;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdinvoer', [wtString], '', 0, ml_datumtijdinvoeren, 'Tijd van invoeren', 'datum/tijd van aanmaken van de kassagegevens', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van wijzigingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=170;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdwijzigen', [wtString], '', 0, ml_datumtijdwijzigen, 'Tijd van wijzigingen', 'datum/tijd van wijzigingen in de kassagegevens', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

  WobbelGrid.AutoAdjustColumns;
end;


procedure TGridBeursKassa.FillGrid;
var
  q: TZQuery;
  rowCounter: integer;
  colCounter: integer;
  ix: integer;
  isactief: string;
begin
  try
    try
      for ix:=WobbelGrid.RowCount-1 downto 1 do
      begin
        WobbelGrid.DeleteRow(ix);
      end;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      q.SQL.Text:='select ' +
      ' kassa_id, ' +
      ' kassanr, ' +
      ' isactief, ' +
      ' opmerkingen,' +
      ' datetime(datumtijdinvoeren, ''localtime'') as datumtijdinvoeren,' +
      ' datetime(datumtijdwijzigen, ''localtime'') as datumtijdwijzigen' +
      ' from kassa ' +
      ' where beursid=:BEURSID;';
      q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('kassa_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('kassanr').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('opmerkingen').AsString;
        inc(colCounter);
        isactief:=q.FieldByName('isactief').AsString;
        WobbelGrid.Cells[colCounter,rowCounter]:=isactief;
        if (isactief = '1') then
        begin
          // in de loop al aanpassen; doe je het achteraf dan wordt meteen rowdirty = 1 gezet
          WobbelGrid.Row:=rowCounter;
        end;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('datumtijdinvoeren').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('datumtijdwijzigen').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:='0';

        inc(rowCounter);
        q.Next;
      end;
      q.Close;

      self.SetFontSize(0);

    finally
      q.Free;
  end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij vullen BeursKassa tabel vanuit de database: ' + E.Message);
    end;
  end;
end;

function TGridBeursKassa.PostData(kassa_id, isactief:integer;
         kassanr, opmerkingen: string): boolean;
var
  q : TZQuery;
  kassaidCurrent: integer;
  sTmp: string;
  bRet:boolean;
  iKassanrAantal: integer;
begin
  bRet:=true;

  if (kassanr = '') then
  begin
    MessageError('Kassanr moet een waarde hebben. De regel met een leeg kassanr wordt niet toegevoegd aan de database.');
    bRet:=false;
    PostData:=false;
    exit;
  end;
  iKassanrAantal:=KassanrIsUniek(kassanr);
  if (((kassa_id > 0) and (iKassanrAantal <> 1))
      or ((kassa_id < 0) and (iKassanrAantal <> 0)))
  then
  begin
    MessageError('Kassanr is niet uniek voor de gekozen beurs. Svp aanpassen.');
    bRet:=false;
    PostData:=false;
    exit;
  end;


  try
    try
      kassaidCurrent:=kassa_id;

      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);
      q.SQL.Clear;

      if (kassaidCurrent >= 0) then
      begin
         q.SQL.Text:='update kassa set ' +
                     ' kassanr=:KASSANR, ' +
                     ' isactief=:ISACTIEF, ' +
                     ' opmerkingen=:OPMERKINGEN ' +
                     ' where kassa_id=:KASSA_ID';
         q.Params.ParamByName('KASSANR').AsString := kassanr;
         q.Params.ParamByName('ISACTIEF').AsInteger := isactief;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('KASSA_ID').AsInteger := kassaidCurrent;
         q.ExecSQL();
       end
       else
       begin
         q.SQL.Text:='insert into kassa (' +
                     ' beursid, ' +
                     ' kassanr, ' +
                     ' isactief, ' +
                     ' opmerkingen' +
                     ' ) values(' +
                     ' :BEURSID, ' +
                     ' :KASSANR, ' +
                     ' :ISACTIEF, ' +
                     ' :OPMERKINGEN)';
         q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
         q.Params.ParamByName('KASSANR').AsString := kassanr;
         q.Params.ParamByName('ISACTIEF').AsInteger := isactief;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //kassaidCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(kassa_id) as kassaid from kassa';
         q.Open;
         kassaidCurrent:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('kassaid').AsString;
           if (sTmp='') then
           begin
             kassaidCurrent:=1;
           end
           else
           begin
             kassaidCurrent:=StrToInt(sTmp);
           end;
           break;
         end;
         q.Close;
         if (kassaidCurrent = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout kassa');
         end;
       end;

       dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');

       if (isactief = 1) then
       begin
         m_tools.SetValueInIniFile('INIT','KassaNummer',kassanr);
       end;

    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      bRet:=false;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij aanpassen data in de database: ' + E.Message);
    end;
  end;
  PostData:=bRet;
end;

function TGridBeursKassa.KassanrIsUniek(kassanr:string): integer;
var
  q : TZQuery;
  retVal:integer;
  sFout:string;
begin
  try
    try
      retVal:=-1;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := 'select count(*) as aantal ' +
          ' from kassa as k, beurs as b ' +
          ' where k.beursid=b.beurs_id ' +
          ' and b.isactief=1 ' +
          ' and b.beurs_id=:BEURSID ' +
          ' and kassanr=:KASSANR ';
      q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
      q.Params.ParamByName('KASSANR').AsString := kassanr;
      q.Open;
      while not q.Eof do
      begin
        retVal:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
    finally
      q.Free;
      KassanrIsUniek:=retVal;
    end;
  except
    on E: Exception do
    begin
      sFout:='Fout bij check of het kassanr ("'+kassanr+'") uniek is: ' + E.Message;
      raise(Exception.Create(sFout));
    end;
  end;
end;


function TGridBeursKassa.PostData:boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  kassaid:integer;
  bRet, bPostOk : boolean;
  postCount: integer;
  isactief:integer;
  sTest:string;
  invalidrowcount:integer;
begin
  bRet:=true;
  if (not CheckGridValues(-1)) then
  begin
    PostData:=false;
    exit;
  end;
  postCount:=0;
  invalidrowcount:=0;
  iRowStop:=WobbelGrid.RowCount-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  for iRow:=WobbelGrid.FixedRows to iRowStop do
  begin
    if (WobbelGrid.Cells[iCol, iRow] = '1') then
    begin
      //MessageOk('isdirty:' + WobbelGrid.Cells[iCol, iRow]);
      kassaid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('kassa_id'), iRow] <> '') then
      begin
        kassaid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('kassa_id'), iRow]);
      end;

      isactief:=0;
      sTest:=WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isactief'), iRow];
      //MessageOk(sTest);
      if (sTest = '1') then
      begin
        isactief:=1;
      end;

      bPostOk:=PostData(
          kassaid,
          isactief,
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('kassanr'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen'), iRow]
          );
      if bPostOk then
      begin
        inc(postCount);
        WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isdirty'),iRow]:='0';
      end
      else
      begin
        inc(invalidrowcount);
      end;
      bRet:=bRet and bPostOk;
    end;
  end;
  if (postCount>0) then
  begin
    if (invalidrowcount>0) then
    begin
      MessageOk('De wijzigingen in de kassa gegevens zijn opgeslagen, behalve de regel(s) met ongeldige invoer.');
    end
    else
    begin
      MessageOk('Alle wijzigingen in de kassa gegevens zijn opgeslagen.');
    end;
    SetGridStatus([WSDISABLEDNOTEDITABLE]);
    if (WobbelGrid.IsVisible) then
    begin
      if (WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
      FillGrid;
    end;

    ProcessMainformStuff;
  end;
  PostData:=bRet;
end;

procedure TGridBeursKassa.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;


function TGridBeursKassa.AnyRowIsDirty: boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  bRet: boolean;
begin
  bRet:=false;
  iRowStop:=WobbelGrid.RowCount-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  if (iCol>=0) then
  begin
    for iRow:=WobbelGrid.FixedRows to iRowStop do
    begin
        if (WobbelGrid.Cells[iCol, iRow] = '1') then
        begin
          bRet:=true;
          break;
        end;
    end;
  end;
  AnyRowIsDirty:=bRet;
end;

procedure TGridBeursKassa.GridValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  iCol:integer;
begin
  if (WobbelGridValidateCellentry(aCol, aRow, OldValue, NewValue)) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

// extra actie nodig voor checkboxkolommen
procedure TGridBeursKassa.WobbelGridClick(Sender: TObject);
var
  iCol:integer;
begin
  if ((btnPost<>nil) and btnPost.Enabled) then
  begin
  //  exit;
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isactief');
  if (WobbelGrid.Col = iCol) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

function TGridBeursKassa.CheckGridValues(iRowToSkip:integer): boolean;
var
  iRow: integer;
  iRowStop:integer;
  uniekList:TStringList;
  iColUniek, iColIsActief: integer;
  sTest:string;
  uniekIndexInList:integer;
  isactiefCount:integer;
  uniekDubbelCount:integer;
  bRet:boolean;
begin
  bRet:=true;
  try
    uniekList:=TStringList.Create;

    isactiefCount:=0;
    uniekDubbelCount:=0;
    iRowStop:=WobbelGrid.RowCount-1;
    iColUniek:=FindWobbelGridColumnIndexByDatabaseFieldName('kassanr');
    iColIsActief:=FindWobbelGridColumnIndexByDatabaseFieldName('isactief');
    //messageOk(TWobbelGridColumnProps(lstColTypes.Items[FindWobbelGridColumnIndexByColIndex(WobbelGrid.Col)]).ColNaam);

    if (iRowToSkip >= 0) then
    begin
      MessageOk(WobbelGrid.Cells[iColUniek,iRowToSkip]);
    end;
    for iRow:=WobbelGrid.FixedRows to iRowStop do
    begin
      if (iRow <> iRowToSkip) then
      begin
        sTest:=WobbelGrid.Cells[iColUniek, iRow];
        if (uniekList.Find(sTest, uniekIndexInList)) then
        begin
          inc(uniekDubbelCount);
        end;
        uniekList.Add(sTest);

        sTest:=WobbelGrid.Cells[iColIsActief, iRow];
        if (sTest='1') then
        begin
          inc(isactiefCount);
        end;
      end;
    end;

    CheckGridValues:=true;
    if (uniekDubbelCount>0) then
    begin
      bRet:=false;
      MessageOk('Kassanr moet uniek zijn per beurs. De waarden worden zo niet opgeslagen in de database. Kies een andere waarde svp.');
    end
    else if (isactiefCount=0) then
    begin
      bRet:=false;
      if (iRowToSkip >= 0) then
      begin
        MessageOk('Er moet 1 kassa als actieve kassa overblijven! De waarden worden zo niet opgeslagen in de database.');
      end
      else
      begin
        MessageOk('Er moet 1 kassa als actieve kassa zijn ingesteld! De waarden worden zo niet opgeslagen in de database.');
      end;
    end
    else if (isactiefCount>1) then
    begin
      bRet:=false;
      MessageOk('Er mag maximaal 1 kassa als actieve kassa zijn ingesteld! De waarden worden zo niet opgeslagen in de database.');
    end;

  finally
    if (uniekList<>nil) then
    begin
      uniekList.Free;
      uniekList:=nil;
    end;
  end;
  CheckGridValues:=bRet;
end;

function TGridBeursKassa.DeleteData(kassaid: integer; sKassanr: string):boolean;
var
  q : TZQuery;
  isOk: boolean;
  aantalHits:integer;
begin
  isOk:=true;

  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      q.SQL.Clear;
      q.SQL.Text := 'select count(*) as aantal from transactie where kassaid=:KASSAID;';
      q.Params.ParamByName('KASSAID').AsInteger := kassaid;
      q.Open;
      aantalHits:=-1;
      while not q.Eof do
      begin
        aantalHits:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
      if (aantalHits>0) then
      begin
         isOk:=false;
         MessageOk('Kassa "'+sKassanr+'" heeft transacties aan zich verbonden. Verwijderen kan niet.');
      end;

      if (isOk) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'delete from kassa where kassa_id=:KASSAID;';
        q.Params.ParamByName('KASSAID').AsInteger := kassaid;
        q.ExecSQL;
      end;

      dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
    finally
      q.Free;
      DeleteData:=isOk;
    end;
  except
    on E: Exception do
    begin
      isOk:=false;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij verwijderen kassa: ' + E.Message);
    end;
  end;
  DeleteData:=isOk;
end;


procedure TGridBeursKassa.btnPostClick(Sender: TObject);
var
  frmTransacties:TfrmTransacties;
begin
  PostData;

  frmTransacties:=TfrmTransacties(Application.FindComponent('frmTransacties'));
  if ((frmTransacties <> nil) and (frmTransacties.gridpanelTransactie <> nil)) then
  begin
//    frmTransacties.gridpanelTransactie.RefreshWobbelGrid();
  end;
end;


procedure TGridBeursKassa.btnDeleteClick(Sender: TObject);
var
  kassaid: integer;
  sKassaid: string;
  iCol:integer;
  sKassanr:string;
begin
  if (not CheckGridValues(WobbelGrid.Row)) then
  begin
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('kassa_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen kassa_id kolom gevonden');
  end;
  sKassaid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  sKassanr:='';
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('kassanr');
  if (iCol >= 0) then
  begin
    sKassanr:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  end;

  if (sKassaid <> '') then
  begin
    kassaid:=StrToInt(sKassaid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u de kassa "' + sKassanr + '" wilt verwijderen?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(kassaid, sKassanr)) then
      begin
        MessageOk('Kassa "' + sKassanr + '" is verwijderd');
        FillGrid;
      end;
    end;
  end
  else
  begin
    //MessageError('Deze verkoper is nog niet in de database ingevoerd');
    WobbelGrid.DeleteRow(WobbelGrid.Row);
    FillGrid;
  end;
end;

procedure TGridBeursKassa.btnRefreshClick(Sender: TObject);
begin
  FillGrid;
end;

procedure TGridBeursKassa.btnCancelClick(Sender: TObject);
begin
  SetGridStatus([WSDISABLEDNOTEDITABLE]);
  FillGrid;
end;



end.

