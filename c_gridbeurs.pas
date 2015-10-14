//------------------------------------------------------------------------------
// Name        : c_gridbeurs
// Purpose     : Implementatie van TGridBeurs
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               beurzen.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridbeurs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;

type
TGridBeurs = class(TWobbelGridPanel)
private
  FOwner:TComponent;

  FParent:TWinControl;
  FBeursOmschrijving: string;

  procedure btnPostClick(Sender: TObject);
  procedure btnDeleteClick(Sender: TObject);
  procedure btnRefreshClick(Sender: TObject);
  procedure btnCancelClick(Sender: TObject);

  procedure GridValidateEntry(sender: TObject; aCol,
    aRow: Integer; const OldValue: string; var NewValue: String);

  function CheckGridValues(iRowToSkip:integer): boolean;

  procedure WobbelGridClick(Sender: TObject);

  procedure SetGridProps;

  function DeleteData(beursid: integer; sDatum: string):boolean;

  function PostData(beurs_id, isactief :integer;
           datum, opmerkingen: string; opbrengst:double): boolean;

  procedure ProcessMainformStuff;

public
  constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight:integer);
  destructor Destroy; override;

  procedure FillGrid;
  function AnyRowIsDirty: boolean;
  function PostData:boolean;

end;



implementation

uses
  ZDataset,
  Dialogs, LCLType,
  formtransacties,
  m_wobbeldata, m_querystuff, m_tools, m_error,
  m_constant, c_appsettings;

constructor TGridBeurs.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
var
  navButs: TWobbelNavButtons;
begin
  inherited;

  FParent:=AParent;
  FOwner:=AOwner;

  Titel:='Beurs beheren';

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

  self.SetGridHint('Geef aan welke beurs de actieve beurs is in de database.'+m_constant.c_CR+'Er kan maar 1 beurs de actieve beurs zijn.'+m_constant.c_CR+'De beursdatum moet uniek zijn in de lijst.'+m_constant.c_CR+'De beursdatum hoeft niet perse een datum te zijn, het mag ook een (korte) omschrijving zijn (max. 20 tekens).');

  FillGrid;
  SetGridStatus([WSENABLEDEDITABLE]);
end;

destructor TGridBeurs.Destroy;
begin
  inherited Destroy;
end;

procedure TGridBeurs.SetGridProps;
var
  index: integer;
  q:TZQuery;
  bVal:boolean;
  ml_beursid,ml_datum,ml_isactief,ml_opbrengst,ml_opmerkingen,ml_datumtijdinvoeren,ml_datumtijdwijzigen:integer;
begin
  index:=-1;

  try
    ml_beursid:=10;
    ml_datum:=20;
    ml_isactief:=10;
    ml_opbrengst:=10;
    ml_opmerkingen:=100;
    ml_datumtijdinvoeren:=20;
    ml_datumtijdwijzigen:=20;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;
    q.SQL.Text:='select beurs_id, datum, isactief, opbrengst, opmerkingen, datumtijdinvoeren, datumtijdwijzigen from beurs limit 1';
    q.Open;
    ml_beursid:=m_tools.getMaxTableFieldSize('beurs_id', q);
    ml_datum:=m_tools.getMaxTableFieldSize('datum', q);
    ml_isactief:=m_tools.getMaxTableFieldSize('isactief', q);
    ml_opbrengst:=m_tools.getMaxTableFieldSize('opbrengst', q);
    ml_opmerkingen:=m_tools.getMaxTableFieldSize('opmerkingen', q);
    ml_datumtijdinvoeren:=m_tools.getMaxTableFieldSize('datumtijdinvoeren', q);
    ml_datumtijdwijzigen:=m_tools.getMaxTableFieldSize('datumtijdwijzigen', q);
    q.Next;
    q.Close;
  finally
    q.Free;
  end;

  //MessageOk('colcount Beurs: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='BeursId';
  WobbelGrid.Columns.Items[index].Visible:=false;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'beurs_id', [wtInteger], '', 1, ml_beursid, 'BeursId', 'interne unieke id van de beurs', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Datum';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=100;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datum', [wtDateTime], '', 1, ml_datum, 'Datum', 'voor iedere beurs de datum waarop deze plaatsvindt', WobbelGrid.Columns.Items[index].Width, true));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opbrengst (€)';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taRightJustify;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=100;
  WobbelGrid.Columns.Items[index].Visible:=false;
  //WobbelGrid.Columns.Items[index].f  #0.00
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'opbrengst', [wtMoney], '0', 0, ml_opbrengst, 'Opbrengst (€)', 'De opbrengst van deze beurs', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opmerkingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=150;
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
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdinvoer', [wtString], '', 0, ml_datumtijdinvoeren, 'Tijd van invoeren', 'datum/tijd van aanmaken van de beursgegevens', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van wijzigingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=170;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdwijzigen', [wtString], '', 0, ml_datumtijdwijzigen, 'Tijd van wijzigingen', 'datum/tijd van wijzigingen in de beursgegevens', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

  WobbelGrid.AutoAdjustColumns;

end;


procedure TGridBeurs.FillGrid;
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
      ' beurs_id, ' +
      ' datum, ' +
      ' isactief, ' +
      ' opbrengst, ' +
      ' opmerkingen,' +
      ' datetime(datumtijdinvoeren, ''localtime'') as datumtijdinvoeren,' +
      ' datetime(datumtijdwijzigen, ''localtime'') as datumtijdwijzigen' +
      ' from beurs order by datum;';
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('beurs_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('datum').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=FormatToMoney(q.FieldByName('opbrengst').AsString);
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('opmerkingen').AsString;
        inc(colCounter);
        isactief:=q.FieldByName('isactief').AsString;
        WobbelGrid.Cells[colCounter,rowCounter]:=isactief;
        if (isactief = '1') then
        begin
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
      MessageError('Fout bij vullen Beurs tabel vanuit de database: ' + E.Message);
    end;
  end;
end;

function TGridBeurs.PostData(beurs_id, isactief :integer;
         datum, opmerkingen: string; opbrengst:double): boolean;
var
  q : TZQuery;
  beursidCurrent: integer;
  sTmp: string;
  bRet:boolean;
begin
  bRet:=true;

  if (datum = '') then
  begin
    MessageError('Een beurs moet een datum hebben. De regel zonder datum wordt niet toegevoegd aan de database.');
    bRet:=false;
    PostData:=false;
    exit;
  end;

  try
    try
      beursidCurrent:=beurs_id;

      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);
      q.SQL.Clear;

      if (beursidCurrent >= 0) then
      begin
         q.SQL.Text:='update beurs set ' +
                     ' datum=:DATUM, ' +
                     ' opbrengst=:OPBRENGST, ' +
                     ' isactief=:ISACTIEF, ' +
                     ' opmerkingen=:OPMERKINGEN ' +
                     ' where beurs_id=:BEURS_ID';
         q.Params.ParamByName('DATUM').AsString := datum;
         q.Params.ParamByName('OPBRENGST').AsFloat := opbrengst;
         q.Params.ParamByName('ISACTIEF').AsInteger := isactief;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('BEURS_ID').AsInteger := beursidCurrent;
         q.ExecSQL();
       end
       else
       begin
         q.SQL.Text:='insert into beurs (' +
                     ' opbrengst, ' +
                     ' datum, ' +
                     ' isactief, ' +
                     ' opmerkingen' +
                     ' ) values(' +
                     ' :OPBRENGST, ' +
                     ' :DATUM, ' +
                     ' :ISACTIEF, ' +
                     ' :OPMERKINGEN)';
         q.Params.ParamByName('OPBRENGST').AsFloat := opbrengst;
         q.Params.ParamByName('DATUM').AsString := datum;
         q.Params.ParamByName('ISACTIEF').AsInteger := isactief;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //beursidCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(beurs_id) as beursid from beurs';
         q.Open;
         beursidCurrent:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('beursid').AsString;
           if (sTmp='') then
           begin
             beursidCurrent:=1;
           end
           else
           begin
             beursidCurrent:=StrToInt(sTmp);
           end;
           break;
         end;
         q.Close;
         if (beursidCurrent = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout beurs');
         end;
       end;

       if (isactief = 1) then
       begin
         m_tools.SetValueInIniFile('INIT','BeursDatum',datum);
       end;

       dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
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

function TGridBeurs.PostData:boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  beursid:integer;
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
      beursid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('beurs_id'), iRow] <> '') then
      begin
        beursid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('beurs_id'), iRow]);
      end;

      isactief:=0;
      sTest:=WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isactief'), iRow];
      //MessageOk(sTest);
      if (sTest = '1') then
      begin
        isactief:=1;
      end;

      bPostOk:=PostData(
          beursid,
          isactief,
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('datum'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen'), iRow],
          StrToFloat(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opbrengst'), iRow])
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
      MessageOk('De wijzigingen in de beursgegevens zijn opgeslagen, behalve de regel(s) met ongeldige invoer.');
    end
    else
    begin
      MessageOk('Alle wijzigingen in de beursgegevens zijn opgeslagen.');
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


procedure TGridBeurs.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;

function TGridBeurs.AnyRowIsDirty: boolean;
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

procedure TGridBeurs.GridValidateEntry(sender: TObject; aCol,
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
procedure TGridBeurs.WobbelGridClick(Sender: TObject);
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

function TGridBeurs.CheckGridValues(iRowToSkip:integer): boolean;
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
    iColUniek:=FindWobbelGridColumnIndexByDatabaseFieldName('datum');
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
      MessageOk('Datum moet uniek zijn voor een beurs. De waarden worden zo niet opgeslagen in de database. Kies een andere waarde svp.');
    end
    else if (isactiefCount=0) then
    begin
      bRet:=false;
      if (iRowToSkip >= 0) then
      begin
        MessageOk('Er moet 1 beurs als actieve beurs overblijven! De waarden worden zo niet opgeslagen in de database.');
      end
      else
      begin
        MessageOk('Er moet 1 beurs als actieve beurs zijn ingesteld! De waarden worden zo niet opgeslagen in de database.');
      end;
    end
    else if (isactiefCount>1) then
    begin
      bRet:=false;
      MessageOk('Er mag maximaal 1 beurs als actieve beurs zijn ingesteld! De waarden worden zo niet opgeslagen in de database.');
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

function TGridBeurs.DeleteData(beursid: integer; sDatum: string):boolean;
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
      q.SQL.Text := 'select count(*) as aantal from kassa where beursid=:BEURSID;';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
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
         MessageOk('Beurs "'+sDatum+'" heeft kassa''s aan zich verbonden. Verwijderen kan niet.');
      end;

      q.SQL.Clear;
      q.SQL.Text := 'select count(*) as aantal from beurs_klant where beursid=:BEURSID;';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
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
         MessageOk('Beurs "'+sDatum+'" heeft klanten aan zich verbonden. Verwijderen kan niet.');
      end;

      q.SQL.Clear;
      q.SQL.Text := 'select count(*) as aantal from beurs_vrijwilliger where beursid=:BEURSID;';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
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
         MessageOk('Beurs "'+sDatum+'" heeft accounts aan zich verbonden. Verwijderen kan niet.');
      end;

      if (isOk) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'delete from beurs where beurs_id=:KASSAID;';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
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
      MessageError('Fout bij verwijderen beurs: ' + E.Message);
    end;
  end;
  DeleteData:=isOk;
end;


procedure TGridBeurs.btnPostClick(Sender: TObject);
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

procedure TGridBeurs.btnDeleteClick(Sender: TObject);
var
  beursid: integer;
  sBeursid: string;
  iCol:integer;
  sDatum:string;
begin
  if (not CheckGridValues(WobbelGrid.Row)) then
  begin
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('beurs_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen beurs_id kolom gevonden');
  end;
  sBeursid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  sDatum:='';
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('datum');
  if (iCol >= 0) then
  begin
    sDatum:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  end;

  if (sBeursid <> '') then
  begin
    beursid:=StrToInt(sBeursid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u de beurs "' + sDatum + '" wilt verwijderen?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(beursid, sDatum)) then
      begin
        MessageOk('Beurs op "' + sDatum + '" is verwijderd');
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

procedure TGridBeurs.btnRefreshClick(Sender: TObject);
begin
  FillGrid;
end;

procedure TGridBeurs.btnCancelClick(Sender: TObject);
begin
  SetGridStatus([WSDISABLEDNOTEDITABLE]);
  FillGrid;
end;

end.


