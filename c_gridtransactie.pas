//------------------------------------------------------------------------------
// Name        : c_gridtransactie
// Purpose     : Implementatie van TGridTransactie
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               transacties.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridtransactie;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;

type
  TGridTransactie = class(TWobbelGridPanel)
  private
    FOwner:TComponent;

    FParent:TWinControl;
    //FVrijwilligerId: integer;
    FEditableRownr:integer;

    FInitieleVulling:boolean;

    procedure btnPostClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);

    procedure GridValidateEntry(sender: TObject; aCol,
      aRow: Integer; const OldValue: string; var NewValue: String);

    function CheckGridValues(iRowToSkip:integer): boolean;

    procedure WobbelGridClick(Sender: TObject);

    procedure SetGridProps;

    procedure FillGrid;
    function DeleteData(transactieid: integer):boolean;

    function PostData(transactie_id, betaalwijzeid:integer;
             opmerkingen: string; totaalbedrag:double): integer;


    function FindIdOfPicklistItemDescription(ARow:integer; out betaalwijzeid:integer):boolean;
    procedure FillBetaalwijzePicklist();
    procedure ProcessMainformStuff;

  public
    constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight:integer);
    destructor Destroy; override;
    function AnyRowIsDirty: boolean;
    function AddNewTransactie():boolean;
    procedure AddARecord();
    function PostData:integer;
    property EditableRownr: integer read FEditableRownr write FEditableRownr;
    procedure RefreshWobbelGrid();
    function GetCurrentTransactieId: integer;
    procedure SetDetailsFromCurrentGridrow();
    procedure SetOpmerkingen(opmerkingen:string);
    procedure SetBetaalwijze(betaalwijzeomschrijving:string);

    property InitieleVulling: boolean read FInitieleVulling write FInitieleVulling;

end;


implementation

uses
  ZDataset,
  Dialogs, LCLType,
  formtransacties,
  m_wobbeldata, m_querystuff, m_tools, m_error,
  m_constant, c_appsettings;

constructor TGridTransactie.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
var
  navButs: TWobbelNavButtons;
begin
  FInitieleVulling:=true;
  if (AppSettings.Beurs.BeursId < 0) then
//  if (BeursId < 0) then
  begin
//    MessageDlg('Wobbel', 'Er is geen beurs gekozen. Svp eerst een beurs kiezen', mtConfirmation, [mbYes],0);
    exit;
  end;
//  if (KassaId < 0) then
  if (AppSettings.Kassa.KassaId < 0) then
  begin
    MessageDlg('Wobbel', 'Er is geen kassa gekozen. Svp eerst een kassa kiezen', mtConfirmation,
              [mbYes],0);
    exit;
  end;

  FParent:=AParent;
  FOwner:=AOwner;

  Titel:='Transactieoverzicht';

  navButs:=[wbFirst, wbPrev, wbNext, wbLast, wbRefresh];
  inherited Create(AOwner, AParent, ATop, ALeft, AHeight, navButs);

  SetGridProps;
  FillBetaalwijzePicklist();

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

  self.SetGridHint('Transacties: Per koper wordt een transactie gemaakt. '+m_constant.c_CR+'Een transactie kan over meerdere artikelen gaan.'+m_constant.c_CR+'De tabel is alleen-lezen: wijzigingen kunnen worden gedaan in het gedeelte tussen de twee tabellen.');

  SetGridStatus([WSDISABLEDNOTEDITABLE]);

  FillGrid;

end;

destructor TGridTransactie.Destroy;
begin
  inherited Destroy;
end;


procedure TGridTransactie.SetGridProps;
var
  index: integer;
  q:TZQuery;
  w:integer;
  bVal:boolean;
  ml_transactieid,ml_klantid,ml_totaalbedrag,ml_betaalwijze,ml_opmerkingen,ml_datumtijdinvoeren,ml_datumtijdwijzigen:integer;
  defaultStringwaarde:string;
begin
  index:=-1;

  try
    ml_transactieid:=10;
    ml_klantid:=10;
    ml_totaalbedrag:=10;
    ml_betaalwijze:=100;
    ml_opmerkingen:=255;
    ml_datumtijdinvoeren:=10;
    ml_datumtijdwijzigen:=10;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;
    q.SQL.Text := 'select ' +
               ' t.transactie_id,t.klantid,t.totaalbedrag,b.omschrijving as betaalwijze,t.opmerkingen,t.datumtijdinvoer,t.datumtijdwijzigen ' +
               ' from transactie as t ' +
               ' left join betaalwijze as b on t.betaalwijzeid=b.betaalwijze_id ' +
               ' limit 1;';
    q.Open;
    ml_transactieid:=m_tools.getMaxTableFieldSize('transactie_id', q);
    ml_klantid:=m_tools.getMaxTableFieldSize('klantid', q);
    ml_totaalbedrag:=m_tools.getMaxTableFieldSize('totaalbedrag', q);
    ml_betaalwijze:=m_tools.getMaxTableFieldSize('betaalwijze', q);
    ml_opmerkingen:=m_tools.getMaxTableFieldSize('opmerkingen', q);
    ml_datumtijdinvoeren:=m_tools.getMaxTableFieldSize('datumtijdinvoer', q);
    ml_datumtijdwijzigen:=m_tools.getMaxTableFieldSize('datumtijdwijzigen', q);
    q.Close;
  finally
    q.Free;
  end;




  //MessageOk('colcount Beurs: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='KlantId';// eigenlijk Transactieid
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=100;
  WobbelGrid.Columns.Items[index].Visible:=true;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].SizePriority:=0;
  //lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'transactie_id', [wtInteger], '', 1, ml_transactieid, 'TransactieId', 'nummer van de transactie', WobbelGrid.Columns.Items[index].Width, false));
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'transactie_id', [wtInteger], '', 1, ml_transactieid, 'KlantId', 'nummer van de klant', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='KlantId';
  WobbelGrid.Columns.Items[index].Visible:=false;
  WobbelGrid.Columns.Items[index].SizePriority:=0;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'klantid', [wtInteger], '', 1, ml_klantid, 'KlantId', 'nummer van de klant', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  w:=120;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=180;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Totaalbedrag (€)';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taRightJustify;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=w;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=true;
  WobbelGrid.Columns.Items[index].SizePriority:=0;
  //WobbelGrid.Columns.Items[index].f  #0.00
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'totaalbedrag', [wtMoney], '0', 0, ml_totaalbedrag, 'Totaalbedrag (€)', 'Het totaalbedrag van deze transactieDe opbrengst van deze beurs', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Betaalwijze';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  //WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=2;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=130;
  WobbelGrid.Columns.Items[index].Visible:=true;
  defaultStringwaarde:=''; // 'contant'
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'betaalwijzeid', [wtString], defaultStringwaarde, 2, ml_betaalwijze, 'Betaalwijze', 'manier van betalen', WobbelGrid.Columns.Items[index].Width, true));
  WobbelGrid.Columns.Items[index].ButtonStyle:=cbsPickList;

  inc(index);
  w:=170;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=300;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opmerkingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Visible:=true;
  WobbelGrid.Columns.Items[index].Width:=w;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'opmerkingen', [wtMemo], '', 0, ml_opmerkingen, 'Opmerkingen', 'Eventueel commentaar bij de kassa', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van invoeren';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=170;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdinvoer', [wtString], '', 0, ml_datumtijdinvoeren, 'Tijd van invoeren', 'datum/tijd van aanmaken van de transactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van wijzigingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=170;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdwijzigen', [wtString], '', 0, ml_datumtijdwijzigen, 'Tijd van wijzigingen', 'datum/tijd van wijzigingen in de transactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.DebugStatus;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Width:=50;
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

end;


procedure TGridTransactie.FillBetaalwijzePicklist();
var
  q : TZQuery;
  v: string;
  ix, iCol, iColCorrected: integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen betaalwijze kolom gevonden in transactie grid');
  end;
  iColCorrected:=iCol-WobbelGrid.FixedCols;

  try
    try
      for ix:=WobbelGrid.Columns.Items[iColCorrected].PickList.Count-1 downto 0 do
      begin
        WobbelGrid.Columns.Items[iColCorrected].PickList.Delete(ix);
      end;
      q := m_querystuff.GetSQLite3QueryMdb;
      WobbelGrid.Columns.Items[iColCorrected].PickList.Clear;

      q.SQL.Clear;
      q.SQL.Text := 'select betaalwijze_id, omschrijving, opmerkingen from betaalwijze order by betaalwijze_id;';
      q.Open;
      while not q.Eof do
      begin
        v:=MakePicklistItemDescription(q.FieldByName('omschrijving').AsString, '');
        WobbelGrid.Columns.Items[iColCorrected].PickList.AddObject(v, TObject(q.FieldByName('betaalwijze_id').AsInteger));
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

function TGridTransactie.FindIdOfPicklistItemDescription(ARow:integer; out betaalwijzeid:integer):boolean;
var
  iCol, iColCorrected: integer;
  betaalwijzeDescription, sTest:string;
  ix:integer;
begin
  FindIdOfPicklistItemDescription:=true;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  iColCorrected:=iCol-WobbelGrid.FixedCols;
  betaalwijzeDescription:=WobbelGrid.Cells[iCol,ARow];

  betaalwijzeid:=-1;
  ix:=0;
  for ix:=0 to WobbelGrid.Columns.Items[iColCorrected].PickList.Count-1 do
  begin
    sTest:=WobbelGrid.Columns.Items[iColCorrected].PickList.Strings[ix];
    if (sTest = betaalwijzeDescription) then
    begin
      sTest:=IntToStr(integer(WobbelGrid.Columns.Items[iColCorrected].PickList.Objects[ix]));
      betaalwijzeid:=Integer(WobbelGrid.Columns.Items[iColCorrected].PickList.Objects[ix]);
      //MessageOk(sTest);
      break;
    end;
  end;
  if (betaalwijzeid=-1) then
  begin
    FindIdOfPicklistItemDescription:=false;
    MessageError('De regel met betaalwijze "'+betaalwijzeDescription+'" kan niet worden opgeslagen: de waarde is ongeldig. Kies een waarde uit de lijst!!');
  end;
end;


procedure TGridTransactie.FillGrid;
var
  q: TZQuery;
  rowCounter: integer;
  colCounter: integer;
  ix: integer;
  s: string;
  isFirstRecord:boolean;
begin
  try
    try
      for ix:=WobbelGrid.RowCount-1 downto 1 do
      begin
        s:=WobbelGrid.Cells[2,ix];
        WobbelGrid.DeleteRow(ix);
      end;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text:='select ' +
      ' t.transactie_id,  ' +
      ' k.klant_id,  ' +
      ' t.totaalbedrag,  ' +
      ' case when p.prijssom is null or p.prijssom = '''' then 0 else p.prijssom end as prijssom,  ' +
      ' t.opmerkingen,  ' +
      ' datetime(t.datumtijdinvoer, ''localtime'') as datumtijdinvoer,  ' +
      ' datetime(t.datumtijdwijzigen, ''localtime'') as datumtijdwijzigen,  ' +
      ' bw.omschrijving as betaalwijze, ' +
      ' ks.kassanr  ' +
      ' from transactie as t  ' +
      ' inner join klant as k on t.klantid=k.klant_id  ' +
      ' inner join beurs_klant as bk on k.klant_id=bk.klantid and bk.beursid=:BEURSID ' +
      ' inner join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id ' +
      ' inner join kassa as ks on (t.kassaid=ks.kassa_id and ks.isactief=1)' +
      ' left join ( ' +
      ' 	select ta.transactieid, sum(a.prijs) as prijssom ' +
      ' 	from transactieartikel as ta ' +
      ' 	inner join artikel as a on ta.artikelid=a.artikel_id ' +
      ' 	group by transactieid) as p on p.transactieid=t.transactie_id;';
      q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      isFirstRecord:=true;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        if (isFirstRecord) then
        begin
          //WobbelGrid.Row:=rowCounter;
          isFirstRecord:=false;
        end;



        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('transactie_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('klant_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=FormatToMoney(q.FieldByName('prijssom').AsFloat);
        inc(colCounter);
        s := MakePicklistItemDescription(q.FieldByName('betaalwijze').AsString, '');
        WobbelGrid.Cells[colCounter,rowCounter]:=s;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('opmerkingen').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('datumtijdinvoer').AsString;
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
      MessageError('Fout bij vullen Transactie tabel vanuit de database: ' + E.Message);
    end;
  end;
end;

procedure TGridTransactie.AddARecord();
begin
  inherited AddARecord;
  FEditableRownr:=WobbelGrid.RowCount-1;
end;


function TGridTransactie.AddNewTransactie():boolean;
begin
  AddARecord();
  Result:=true;
  (*
  AddNewTransactie:=PostData(-1,
    StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid'), FEditableRownr]),
    '',
    0);
  FillGrid;
  WobbelGrid.Row:=FEditableRownr;
  *)
end;


function TGridTransactie.PostData(transactie_id, betaalwijzeid:integer;
         opmerkingen: string; totaalbedrag:double): integer;
var
  q : TZQuery;
  transactieidCurrent: integer;
  sTmp: string;
  klantid:integer;
begin
  transactieidCurrent:=-1;
  if (betaalwijzeid = -1) then
  begin
    MessageError('Een transactie moet een betaalwijze hebben. De regel zonder betaalwijze kan zo niet worden toegevoegd aan de database.');
    PostData:=transactieidCurrent;
    exit;
  end;

  try
    try
      transactieidCurrent:=transactie_id;

      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      q.SQL.Clear;

      if (transactieidCurrent >= 0) then
      begin
         q.SQL.Text:='update transactie set ' +
                     ' betaalwijzeid=:BETAALWIJZEID, ' +
                     ' totaalbedrag=:TOTAALBEDRAG, ' +
                     ' opmerkingen=:OPMERKINGEN ' +
                     ' where transactie_id=:TRANSACTIE_ID';
         q.Params.ParamByName('BETAALWIJZEID').AsInteger := betaalwijzeid;
         q.Params.ParamByName('TOTAALBEDRAG').AsFloat := totaalbedrag;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('TRANSACTIE_ID').AsInteger := transactieidCurrent;
         q.ExecSQL();
       end
       else
       begin
         // maak een nieuwe klantid
         q.SQL.Text:='insert into klant (' +
                     ' opmerkingen' +
                     ' ) values(' +
                     ' :OPMERKINGEN)';
         q.Params.ParamByName('OPMERKINGEN').AsString := 'Hoort bij transactie '+IntToStr(transactieidCurrent);
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //klantid:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(klant_id) as klantid from klant';
         q.Open;
         klantid:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('klantid').AsString;
           if (sTmp='') then
           begin
             klantid:=1;
           end
           else
           begin
             klantid:=StrToInt(sTmp);
           end;
           break;
         end;
         q.Close;
         if (klantid = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout klant');
         end;

         // voeg record toe aan beurs_klant
         q.SQL.Text:='insert into beurs_klant (' +
                     ' klantid, ' +
                     ' beursid ' +
                     ' ) values (' +
                     ' :KLANTID, ' +
                     ' :BEURSID)';
         q.Params.ParamByName('KLANTID').AsInteger := klantid;
         q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
         q.ExecSQL();
         q.Close;


         // voeg transactie toe
         q.SQL.Text:='insert into transactie (' +
                     ' klantid, ' +
                     ' kassaid, ' +
                     ' vrijwilligerid, ' +
                     ' betaalwijzeid, ' +
                     ' totaalbedrag, ' +
                     ' opmerkingen' +
                     ' ) values (' +
                     ' :KLANTID, ' +
                     ' :KASSAID, ' +
                     ' :VRIJWILLIGERID, ' +
                     ' :BETAALWIJZEID, ' +
                     ' :TOTAALBEDRAG, ' +
                     ' :OPMERKINGEN)';
         q.Params.ParamByName('KLANTID').AsInteger := klantid;
         q.Params.ParamByName('KASSAID').AsInteger := Appsettings.Kassa.KassaId;
         q.Params.ParamByName('VRIJWILLIGERID').AsInteger := Appsettings.Vrijwilliger.VrijwilligerId;
         q.Params.ParamByName('BETAALWIJZEID').AsInteger := betaalwijzeid;
         q.Params.ParamByName('TOTAALBEDRAG').AsFloat := totaalbedrag;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //transactieidCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(transactie_id) as transactieid from transactie';
         q.Open;
         transactieidCurrent:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('transactieid').AsString;
           if (sTmp='') then
           begin
             transactieidCurrent:=1;
           end
           else
           begin
             transactieidCurrent:=StrToInt(sTmp);
           end;
           break;
         end;
         q.Close;
         if (transactieidCurrent = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout nieuwe transactie');
         end;
       end;

       dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      transactieidCurrent:=-1;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij aanpassen data in de database: ' + E.Message);
    end;
  end;
  PostData:=transactieidCurrent;
end;

function TGridTransactie.PostData:integer;
var
  iRow, iCol: integer;
  iRowStop:integer;
  transactieid:integer;
  bAllOk: boolean;
  postId:integer;
  postCount: integer;
  betaalwijzeid:integer;
  invalidrowcount:integer;
  sIdentify:string;
begin
  bAllOk:=true;
  transactieid:=-1;
  sIdentify:='';
  if (not CheckGridValues(-1)) then
  begin
    PostData:=transactieid;
    exit;
  end;
  postCount:=0;
  invalidrowcount:=0;
  iRowStop:=WobbelGrid.RowCount-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  iRow:=GetCurrentGridRowNr;
//  for iRow:=WobbelGrid.FixedRows to iRowStop do
//  begin
    if ((WobbelGrid.Cells[iCol, iRow] = '1') and (FEditableRowNr = iRow)) then
    begin
      //MessageOk('isdirty:' + WobbelGrid.Cells[iCol, iRow]);
      transactieid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id'), iRow] <> '') then
      begin
        transactieid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id'), iRow]);
      end;
      sIdentify:=IntToStr(transactieid);

      if (FindIdOfPicklistItemDescription(iRow, betaalwijzeid)) then
      begin
        transactieid:=PostData(
            transactieid,
            betaalwijzeid,
            WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen'), iRow],
            StrToFloat(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('totaalbedrag'), iRow])
            );
//        if (postId<>-1) then
        if (transactieid<>-1) then
        begin
          inc(postCount);
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isdirty'),iRow]:='0';
        end
        else
        begin
          inc(invalidrowcount);
        end;
      end
      else
      begin
        inc(invalidrowcount);
      end;
//      bAllOk:=bAllOk and (postId<>-1);
      bAllOk:=bAllOk and (transactieid<>-1);
    end;
//  end;
  if (postCount>0) then
  begin
    if (invalidrowcount>0) then
    begin
      MessageOk('De wijzigingen in de transactiegegevens van transactie "'+sIdentify+'" zijn opgeslagen. Wijzigingen in andere transacties zijn genegeerd.');
    end
    else
    begin
      //MessageOk('De wijzigingen in de transactiegegevens van transactie "'+sIdentify+'" zijn opgeslagen.');
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
  FEditableRowNr:=-1;
  PostData:=transactieid;
end;

procedure TGridTransactie.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;

function TGridTransactie.GetCurrentTransactieId: integer;
var
  id, iRow, iCol: integer;
  sId: string;
begin
  id:=-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id');
  iRow:=GetCurrentGridRowNr;
  if (iCol>=0) then
  begin
    sId:=WobbelGrid.Cells[iCol, iRow];
    if (IsInteger(sId)) then
    begin
      id:=StrToInt(sId);
    end;
  end;
  Result:=id;
end;


// Wordt niet (meer) gebruikt
procedure TGridTransactie.SetDetailsFromCurrentGridrow();
var
  iCol, iRow:integer;
  s:string;
  TransactieId:integer;
  Betaalwijze:string;
  Totaalbedrag:Double;
  Opmerkingen:String;
  DatumtijdInvoer:String;
  DatumtijdWijziging:String;
begin
  TransactieId:=-1;
  Totaalbedrag:=0;
  Betaalwijze:='';
  Opmerkingen:='';
  DatumtijdInvoer:='';
  DatumtijdWijziging:='';

  iRow:=GetCurrentGridRowNr;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id');
  if (iCol>=0) then
  begin
    s:=WobbelGrid.Cells[iCol, iRow];
    if (IsInteger(s)) then
    begin
      TransactieId:=StrToInt(s);
    end;
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('totaalbedrag');
  if (iCol>=0) then
  begin
    s:=WobbelGrid.Cells[iCol, iRow];
    if (not IsDouble(s)) then
    begin
      s:='0';
    end;
    Totaalbedrag:=StrToFloat(s);
  end;


  // FindIdOfPicklistItemDescription(iRow, BetaalwijzeId);
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  if (iCol>=0) then
  begin
    Betaalwijze:=WobbelGrid.Cells[iCol, iRow];
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen');
  if (iCol>=0) then
  begin
    Opmerkingen:=WobbelGrid.Cells[iCol, iRow];
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('datumtijdinvoer');
  if (iCol>=0) then
  begin
    DatumtijdInvoer:=WobbelGrid.Cells[iCol, iRow];
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('datumtijdwijzigen');
  if (iCol>=0) then
  begin
    DatumtijdWijziging:=WobbelGrid.Cells[iCol, iRow];
  end;

  frmTransacties.SetSelectedTransactie(TransactieId, Totaalbedrag, Betaalwijze, Opmerkingen, DatumtijdInvoer, DatumtijdWijziging);

end;


procedure TGridTransactie.SetBetaalwijze(betaalwijzeomschrijving:string);
var
  s:string;
  iCol,iRow:integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  iRow:=GetCurrentGridRowNr;
  s := MakePicklistItemDescription(betaalwijzeomschrijving, '');
  WobbelGrid.Cells[iCol,iRow]:=s;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  if ((iCol>=0) and not InitieleVulling) then
  begin
    WobbelGrid.Cells[iCol, iRow]:='1';
  end;
end;

procedure TGridTransactie.SetOpmerkingen(opmerkingen:string);
var
  iCol,iRow:integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen');
  iRow:=GetCurrentGridRowNr;
  if (iCol>=0) then
  begin
    WobbelGrid.Cells[iCol, iRow]:=opmerkingen;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  if ((iCol>=0) and not InitieleVulling) then
  begin
    WobbelGrid.Cells[iCol, iRow]:='1';
  end;
end;

function TGridTransactie.AnyRowIsDirty: boolean;
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

procedure TGridTransactie.GridValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  iCol:integer;
begin
  if (WobbelGridValidateCellentry(aCol, aRow, OldValue, NewValue)) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      //WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

// extra actie nodig voor checkboxkolommen
procedure TGridTransactie.WobbelGridClick(Sender: TObject);
var
  iCol:integer;
  s:string;
  TransactieId: Integer;
  Totaalbedrag: Double;
  BetaalwijzeId, Opmerkingen, DatumtijdInvoer, DatumtijdWijziging: string;
begin
  if ((btnPost<>nil) and btnPost.Enabled) then
  begin
  //  exit;
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  if (WobbelGrid.Col = iCol) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      //WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
  FEditableRownr:=WobbelGrid.Row;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id');
  s:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  if (not IsInteger(s)) then
  begin
    s:='-1';
  end;
  TransactieId:=StrToInt(s);

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('totaalbedrag');
  s:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  if (not IsDouble(s)) then
  begin
    s:='0';
  end;
  Totaalbedrag:=StrToFloat(s);

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('betaalwijzeid');
  BetaalwijzeId:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen');
  Opmerkingen:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('datumtijdinvoer');
  DatumtijdInvoer:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('datumtijdwijzigen');
  DatumtijdWijziging:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  frmTransacties.SetSelectedTransactie(TransactieId, Totaalbedrag, BetaalwijzeId, Opmerkingen, DatumtijdInvoer, DatumtijdWijziging);

end;

function TGridTransactie.CheckGridValues(iRowToSkip:integer): boolean;
begin
  CheckGridValues:=true;
end;

function TGridTransactie.DeleteData(transactieid: integer):boolean;
var
  q : TZQuery;
  isOk: boolean;
begin
  isOk:=true;

  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      if (isOk) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'delete from beurs_klant ' +
            ' where klantid in ( ' +
            ' select klantid from transactie where transactie_id=:TRANSACTIEID);';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := transactieid;
        q.ExecSQL;

        q.SQL.Clear;
        q.SQL.Text := 'delete from klant ' +
            ' where klant_id in ( ' +
            ' select klantid from transactie where transactie_id=:TRANSACTIEID);';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := transactieid;
        q.ExecSQL;

        // Artikel verwijderen omdat deze on-the-fly wordt aangemaakt in de
        // huidige opzet van de beurs: artikelen worden niet eerst geregistreerd
        // in de database vanwege de grote hoeveelheid
        q.SQL.Clear;
        q.SQL.Text := 'delete from artikel ' +
            ' where artikel_id in ( ' +
            ' select artikelid from transactieartikel where transactieid=:TRANSACTIEID);';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := transactieid;
        q.ExecSQL;

        q.SQL.Clear;
        q.SQL.Text := 'delete from transactieartikel ' +
            ' where transactieid=:TRANSACTIEID;';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := transactieid;
        q.ExecSQL;

        q.SQL.Clear;
        q.SQL.Text := 'delete from transactie ' +
            ' where transactie_id=:TRANSACTIEID;';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := transactieid;
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
      MessageError('Fout bij verwijderen transactie: ' + E.Message);
    end;
  end;
  DeleteData:=isOk;
end;


procedure TGridTransactie.btnPostClick(Sender: TObject);
begin
  PostData;
  //SetGridStatus([WSDISABLEDNOTEDITABLE]);
  if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
  begin
    WobbelGrid.SetFocus;
  end;
end;

procedure TGridTransactie.btnDeleteClick(Sender: TObject);
var
  transactieid: integer;
  stransactieid: string;
  iCol:integer;
begin
  if (not CheckGridValues(WobbelGrid.Row)) then
  begin
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('transactie_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen transactieid kolom gevonden');
  end;
  stransactieid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  if (stransactieid <> '') then
  begin
    transactieid:=StrToInt(stransactieid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u de transactie "' + stransactieid + '" wilt verwijderen?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(transactieid)) then
      begin
        MessageOk('Transactie "' + stransactieid + '" is verwijderd');
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
  //SetGridStatus([WSDISABLEDNOTEDITABLE]);
  if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
  begin
    WobbelGrid.SetFocus;
  end;
end;

procedure TGridTransactie.btnRefreshClick(Sender: TObject);
var
  currentRow:integer;
begin
  // eentje minder omdat GetCurrentGridRowNr het rijnummer incl fixedrows teruggeeft
  currentRow:=GetCurrentGridRowNr-1;
  FillGrid;
  //SetGridStatus([WSDISABLEDNOTEDITABLE]);
  SetGridRowNr(currentRow);
  if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
  begin
    WobbelGrid.SetFocus;
  end;
end;

procedure TGridTransactie.btnCancelClick(Sender: TObject);
begin
  //SetGridStatus([WSDISABLEDNOTEDITABLE]);
  if (WobbelGrid.IsVisible) then
  begin
    if (WobbelGrid.Enabled) then
    begin
      WobbelGrid.SetFocus;
    end;
    FillGrid;
  end;
end;

procedure TGridTransactie.RefreshWobbelGrid();
begin
  FillBetaalwijzePicklist();
  if (WobbelGrid.IsVisible) then
  begin
    if (WobbelGrid.Enabled) then
    begin
      WobbelGrid.SetFocus;
    end;
    FillGrid;
  end;
end;

end.

