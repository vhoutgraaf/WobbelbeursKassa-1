//------------------------------------------------------------------------------
// Name        : c_gridtransactieartikel
// Purpose     : Implementatie van TGridTransactieartikel
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               artikelen per transactie.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridtransactieartikel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;

type
  TGridTransactieartikel = class(TWobbelGridPanel)
  private
    FOwner:TComponent;

    FParent:TWinControl;
    FTransactieId: integer;

    FInbrengerCodeList: TStringList;

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
    function DeleteData(transactieartikelid: integer):boolean;

    function PostData(transactieartikel_id, verkoperid:integer;verkoopprijs, kortingspercentage:double): boolean;

    function FindIdOfPicklistItemDescription(ARow:integer; out verkoperid:integer):boolean;
    function FindIdOfPicklistItemDescription(suppressMessages:boolean; ARow:integer; out verkoperid:integer):boolean;
    procedure FillVerkopercodePicklist();
    procedure ProcessMainformStuff;

  public
    constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight:integer);
    destructor Destroy; override;
    function AnyRowIsDirty: boolean;
    function PostData:boolean;
    procedure FillGrid(TransactieId:integer);
    procedure RefreshWobbelGrid();

    Property TransactieId : integer read FTransactieId write FTransactieId;
    procedure FocusToStartupColumn();
    procedure BeweegGrid();

end;

implementation

uses
  ZDataset,
  Dialogs, LCLType,
  formtransacties,
  m_wobbeldata, m_querystuff, m_tools, m_error, c_appsettings,
  m_constant;

constructor TGridTransactieartikel.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
var
  navButs: TWobbelNavButtons;
begin

  if (AppSettings.Beurs.BeursId < 0) then
  begin
    MessageDlg('Wobbel', 'Er is geen beurs gekozen. Svp eerst een beurs kiezen', mtConfirmation,
              [mbYes],0);
    exit;
  end;
//  if (KassaId < 0) then
//  begin
//    MessageDlg('Wobbel', 'Er is geen kassa gekozen. Svp eerst een kassa kiezen', mtConfirmation,
//              [mbYes],0);
//    exit;
//  end;


  FParent:=AParent;
  FOwner:=AOwner;

  Titel:='Artikelen per Klant';

  //navButs:=[wbFirst, wbPrev, wbNext, wbLast, wbAdd, wbDelete, wbEdit, wbPost, wbCancel, wbRefresh];
  navButs:=[wbFirst, wbPrev, wbNext, wbLast, wbRefresh];
  inherited Create(AOwner, AParent, ATop, ALeft, AHeight, navButs);

  SetGridProps;
  FInbrengerCodeList:=TStringList.Create;
  FillVerkopercodePicklist();

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

  self.SetGridHint('Transactie-artikelen: alle artikelen die bij een transactie behoren, dus die bij een koper horen. '+m_constant.c_CR+'De prijzen van de artikelen worden bij elkaar opgeteld en in de transactietabel opgeslagen.'+m_constant.c_CR+'Alleen verkopercode en bedrag zijn verplicht.'+m_constant.c_CR+'Het maakt niet uit of er een punt of een komma wordt gebruikt als decimaalscheidingsteken: WobbelKassa zet deze zonodig om naar de vorm die het moet hebben.');

  SetGridStatus([WSENABLEDNOTEDITABLE]);
end;

destructor TGridTransactieartikel.Destroy;
begin
  if (FInbrengerCodeList <> nil) then
  begin
    FInbrengerCodeList.Free;
  end;
  inherited Destroy;
end;


procedure TGridTransactieartikel.SetGridProps;
var
  index: integer;
  defval:string;
  q:TZQuery;
  w:integer;
  bVal:boolean;
  ml_transactieartikel_id,ml_volgnr,ml_kortingsfactor,ml_verkopercode,ml_prijs,ml_datumtijdinvoer,ml_datumtijdwijzigen:integer;
begin
  index:=-1;

  try
    ml_transactieartikel_id:=10;
    ml_volgnr:=10;
    ml_verkopercode:=255;
    ml_kortingsfactor:=10;
    ml_prijs:=10;
    ml_datumtijdinvoer:=255;
    ml_datumtijdwijzigen:=255;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;
    // geen complete query, met kassa- en beurs restricties, nodig: het gaat nu
    // even alleen om de veldgroottes
    q.SQL.Text:='select ' +
         ' ta.transactieartikel_id, ' +
         ' ta.volgnr, ' +
         ' ta.kortingsfactor, ' +
         ' a.code, ' +
         ' v.verkoper_id, ' +
         ' v.verkopercode, ' +
         ' ta.kortingsfactor as volleprijs, ' +
         ' a.prijs, ' +
         ' ta.datumtijdinvoer,  ' +
         ' ta.datumtijdwijzigen ' +
         ' from transactieartikel as ta ' +
         ' left join artikel as a on ta.artikelid=a.artikel_id ' +
         ' left join verkoper as v on a.verkoperid=v.verkoper_id ' +
         ' limit 1 ';
    q.Open;
    ml_transactieartikel_id:=m_tools.getMaxTableFieldSize('transactieartikel_id', q);
    ml_volgnr:=m_tools.getMaxTableFieldSize('volgnr', q);
    ml_verkopercode:=m_tools.getMaxTableFieldSize('verkopercode', q);
    ml_kortingsfactor:=m_tools.getMaxTableFieldSize('kortingsfactor', q);
    ml_kortingsfactor:=m_tools.getMaxTableFieldSize('kortingsfactor', q);
    ml_prijs:=m_tools.getMaxTableFieldSize('prijs', q);
    ml_datumtijdinvoer:=m_tools.getMaxTableFieldSize('datumtijdinvoer', q);
    ml_datumtijdwijzigen:=m_tools.getMaxTableFieldSize('datumtijdwijzigen', q);
    q.Close;
  finally
    q.Free;
  end;


  //MessageOk('colcount Beurs: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='TransactieartikelId';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=80;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=false;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'transactieartikel_id', [wtInteger], '', 1, ml_transactieartikel_id, 'TransactieartikelId', 'nummer van de artikeltransactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Volgnr';
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=60;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.Vrijwilliger.IsSuperAdmin;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'volgnr', [wtInteger], '', 1, ml_volgnr, 'Volgnr', 'volgnr van het artikel binnen de transactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  w:=110;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=200;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='InbrengerCode';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=2;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=w;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'verkopercode', [wtString], '', 2, ml_verkopercode, 'Verkopercode', 'Code van de verkoper', WobbelGrid.Columns.Items[index].Width, true));
  //WobbelGrid.Columns.Items[index].ButtonStyle:=cbsPickList;

  inc(index);
  w:=80;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=120;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Prijs (€)';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taRightJustify;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=w;
  //WobbelGrid.Columns.Items[index].f  #0.00
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'volleprijs', [wtMoney], '0', 0, ml_prijs, 'Prijs (€)', 'volle prijs van het artikel', WobbelGrid.Columns.Items[index].Width, true));

  inc(index);
  w:=80;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=120;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Korting (%)';
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=w;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=true;
  defval:=FloatToStr(m_tools.FactorToPercentage(AppSettings.KortingsFactor));
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'kortingspercentage', [wtInteger],defval, 1, ml_kortingsfactor, 'Kortingspercentage', 'Percentage korting op het artikel', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  w:=120;
  if ((not AppSettings.Vrijwilliger.VrijwilligerIsAdmin) and (not AppSettings.Vrijwilliger.IsSuperAdmin)) then
  begin
    w:=180;
  end;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Verkoopprijs (€)';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taRightJustify;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=w;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'prijs', [wtMoney], '0', 0, ml_kortingsfactor, 'Verkoopprijs (€)', 'prijs (incl. evt. korting) van het artikel', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van invoeren';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=150;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdinvoer', [wtString], '', 0, ml_datumtijdinvoer, 'Tijd van invoeren', 'datum/tijd van aanmaken van de transactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tijd van wijzigingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=150;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'datumtijdwijzigen', [wtString], '', 0, ml_datumtijdwijzigen, 'Tijd van wijzigingen', 'datum/tijd van wijzigingen in de transactie', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=AppSettings.DebugStatus;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

end;



procedure TGridTransactieartikel.FillVerkopercodePicklist();
var
  q : TZQuery;
  v: string;
  ix, iCol, iColCorrected: integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen verkopercode kolom gevonden in transactieartikel grid');
  end;
  iColCorrected:=iCol-WobbelGrid.FixedCols;

  try
    if (FInbrengerCodeList = nil) then
    begin
      FInbrengerCodeList:=TStringList.Create;
    end;
    try
      FInbrengerCodeList.Clear;
      q := m_querystuff.GetSQLite3QueryMdb;

      q.SQL.Clear;
      q.SQL.Text := 'select v.verkoper_id, ' +
          ' v.verkopercode, ' +
          ' naw.achternaam, ' +
          ' case when naw.achternaam is null or naw.achternaam='''' then '''' else naw.achternaam end as omschrijving ' +
          ' from beurs_verkoper as bv ' +
          ' inner join verkoper as v on bv.verkoperid=v.verkoper_id ' +
          ' left join naw on v.nawid=naw.naw_id ' +
          ' where bv.beursid=:BEURSID' +
          ' order by v.verkopercode;';
      q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
      q.Open;
      while not q.Eof do
      begin
        v:=MakePicklistItemDescription(q.FieldByName('verkopercode').AsString, '');
        FInbrengerCodeList.AddObject(v, TObject(q.FieldByName('verkoper_id').AsInteger));
        //WobbelGrid.Columns.Items[iColCorrected].PickList.AddObject(v, TObject(q.FieldByName('verkoper_id').AsInteger));
        q.Next;
      end;

      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageOk('Fout bij invulling verkoper-picklist voor transactieartikelen: ' + E.Message);
    end;
  end;
end;

function TGridTransactieartikel.FindIdOfPicklistItemDescription(ARow:integer; out verkoperid:integer):boolean;
begin
  Result:=FindIdOfPicklistItemDescription(false, ARow, verkoperid);
end;

function TGridTransactieartikel.FindIdOfPicklistItemDescription(suppressMessages:boolean; ARow:integer; out verkoperid:integer):boolean;
var
  iCol, iColCorrected: integer;
  verkopercodeDescription, sTest:string;
  ix:integer;
begin
  Result:=true;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  iColCorrected:=iCol-WobbelGrid.FixedCols;
  verkopercodeDescription:=WobbelGrid.Cells[iCol,ARow];

  verkoperid:=-1;
  ix:=0;
  for ix:=0 to FInbrengerCodeList.Count-1 do
  begin
    sTest:=FInbrengerCodeList.Strings[ix];
    if (sTest = verkopercodeDescription) then
    begin
      sTest:=IntToStr(integer(FInbrengerCodeList.Objects[ix]));
      verkoperid:=Integer(FInbrengerCodeList.Objects[ix]);
      //MessageOk(sTest);
      break;
    end;
  end;
  if (verkoperid=-1) then
  begin
    Result:=false;
    if (not suppressMessages) then
    begin
      MessageError('De regel met verkopercode "'+verkopercodeDescription+'" kan niet worden opgeslagen: de waarde is ongeldig. Kies een waarde uit de lijst!!');
    end;
  end;
end;

procedure TGridTransactieartikel.FillGrid;
begin
  FillGrid(FTransactieId);
end;

procedure TGridTransactieartikel.FillGrid(TransactieId:integer);
var
  q: TZQuery;
  rowCounter: integer;
  colCounter: integer;
  ix: integer;
  s: string;
  f:double;
begin
  if (TransactieId < 0) then
  begin
//    MessageDlg('Wobbel', 'Er is geen transactieid bekend. Svp eerst een transactie kiezen!', mtConfirmation,
//              [mbYes],0);
//    exit;
  end;
  FTransactieId:=TransactieId;

  FillVerkopercodePicklist();

  try
    try
      for ix:=WobbelGrid.RowCount-1 downto 1 do
      begin
        WobbelGrid.DeleteRow(ix);
      end;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      q.SQL.Text:='select ' +
           ' ta.transactieartikel_id, ' +
           ' ta.volgnr, ' +
           ' ta.kortingsfactor, ' +
           ' a.code, ' +
           ' v.verkoper_id, ' +
           ' v.verkopercode, ' +
           ' case when ta.kortingsfactor = 0 then 0 else a.prijs/ta.kortingsfactor end as volleprijs, ' +
           ' a.prijs, ' +
           ' datetime(ta.datumtijdinvoer, ''localtime'') as datumtijdinvoer, ' +
           ' datetime(ta.datumtijdwijzigen, ''localtime'') as datumtijdwijzigen ' +
           ' from transactieartikel as ta ' +
           ' inner join artikel as a on ta.artikelid=a.artikel_id ' +
           ' inner join verkoper as v on a.verkoperid=v.verkoper_id ' +
           ' where ta.transactieid=:TRANSACTIEID ' +
           ' order by ta.volgnr;';
      q.Params.ParamByName('TRANSACTIEID').AsInteger := FTransactieId;
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('transactieartikel_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('volgnr').AsString;
        inc(colCounter);
        s:=MakePicklistItemDescription(q.FieldByName('verkopercode').AsString, '');
        WobbelGrid.Cells[colCounter,rowCounter]:=s;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=FormatToMoney(q.FieldByName('volleprijs').AsString);
        inc(colCounter);
        f:=q.FieldByName('kortingsfactor').AsFloat;
        WobbelGrid.Cells[colCounter,rowCounter]:=FloatToStr(m_tools.FactorToPercentage(f));
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=FormatToMoney(q.FieldByName('prijs').AsString);
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

      if (TransactieId < 0) then
      begin
        self.AddARecord();
      end;

    finally
      q.Free;
  end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij vullen Transactieartikel tabel vanuit de database: ' + E.Message);
    end;
  end;
end;

function TGridTransactieartikel.PostData(transactieartikel_id, verkoperid:integer;verkoopprijs, kortingspercentage:double): boolean;
var
  q : TZQuery;
  transactieartikelidCurrent: integer;
  sTmp: string;
  bRet:boolean;
  artikelid:integer;
  volgnr:integer;
begin
  bRet:=true;


  if (verkoperid = -1) then
  begin
    MessageError('Een transactieartikel moet een verkopercode hebben. De regel zonder verkopercode kan zo niet worden toegevoegd aan de database.');
    bRet:=false;
    PostData:=false;
    exit;
  end;

  try
    try
      transactieartikelidCurrent:=transactieartikel_id;

      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      q.SQL.Clear;

      if (transactieartikelidCurrent >= 0) then
      begin
        // bewaar volgnr
        volgnr:=-1;
        q.SQL.Text:='select volgnr from transactieartikel ' +
                    ' where transactieartikel_id=:TRANSACTIEARTIKELID';
        q.Params.ParamByName('TRANSACTIEARTIKELID').AsInteger := transactieartikelidCurrent;
        q.Open;
        while not q.Eof do
        begin
          sTmp:=q.FieldByName('volgnr').AsString;
          if (sTmp='') then
          begin
            volgnr:=-1;
          end
          else
          begin
            volgnr:=StrToInt(sTmp);
          end;
          break;
        end;
        q.Close;
        if (volgnr = -1) then
        begin
          Raise EWobbelError.Create('Invoerfout volgnr bepalen');
        end;

        // verwijder transactiearitkel
        q.SQL.Text:='delete from artikel where artikel_id in ( ' +
                   ' select artikelid from transactieartikel ' +
                   ' where transactieartikel_id=:TRANSACTIEARTIKEL_ID);';
        q.Params.ParamByName('TRANSACTIEARTIKEL_ID').AsInteger := transactieartikelidCurrent;
        q.ExecSQL();

        q.SQL.Text:='delete from transactieartikel where ' +
                   ' transactieartikel_id=:TRANSACTIEARTIKEL_ID;';
        q.Params.ParamByName('TRANSACTIEARTIKEL_ID').AsInteger := transactieartikelidCurrent;
        q.ExecSQL();
      end
      else
      begin
        // zoek een nieuw volgnr
        q.SQL.Text:='select count(*) as aantal from transactieartikel ' +
                    ' where transactieid=:TRANSACTIEID ' +
                    ' and (volgnr is not null and volgnr != '''')';
        q.Params.ParamByName('TRANSACTIEID').AsInteger := FTransactieId;
        q.Open;
        volgnr:=-1;
        while not q.Eof do
        begin
          sTmp:=q.FieldByName('aantal').AsString;
          if (sTmp='') then
          begin
            volgnr:=1;
          end;
          break;
        end;
        q.Close;
        if (volgnr <> 1) then
        begin
          q.SQL.Text:='select max(volgnr) as nieuwvolgnr from transactieartikel ' +
                      ' where transactieid=:TRANSACTIEID';
          q.Params.ParamByName('TRANSACTIEID').AsInteger := FTransactieId;
          q.Open;
          while not q.Eof do
          begin
            sTmp:=q.FieldByName('nieuwvolgnr').AsString;
            if (sTmp='') then
            begin
              volgnr:=1;
            end
            else
            begin
              volgnr:=StrToInt(sTmp)+1;
            end;
            break;
          end;
          q.Close;
          if (volgnr = -1) then
          begin
            Raise EWobbelError.Create('Invoerfout volgnr bepalen');
          end;
        end;
      end;

      // voeg (opnieuw) toe

       // maak een nieuw artikelid
       q.SQL.Text:='insert into artikel (' +
                   ' verkoperid,' +
                   ' prijs' +
                   ' ) values(' +
                   ' :VERKOPERID, ' +
                   ' :PRIJS)';
       q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
       q.Params.ParamByName('PRIJS').AsFloat := verkoopprijs;
       q.ExecSQL();
       q.Close;

       // lijkt niet te werken binnen een transactie
       //artikelid:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

       q.SQL.Clear;
       q.SQL.Text:='select max(artikel_id) as artikelid from artikel';
       q.Open;
       artikelid:=-1;
       while not q.Eof do
       begin
         sTmp:=q.FieldByName('artikelid').AsString;
         if (sTmp='') then
         begin
           artikelid:=1;
         end
         else
         begin
           artikelid:=StrToInt(sTmp);
         end;
         break;
       end;
       q.Close;
       if (artikelid = -1) then
       begin
         Raise EWobbelError.Create('Invoerfout artikel');
       end;

       // voeg record toe aan transactieartikel
       q.SQL.Text:='insert into transactieartikel (' +
                   ' transactieid, ' +
                   ' artikelid, ' +
                   ' volgnr, ' +
                   ' kortingsfactor ' +
                   ' ) values (' +
                   ' :TRANSACTIEID, ' +
                   ' :ARTIKELID, ' +
                   ' :VOLGNR, ' +
                   ' :KORTINGSFACTOR)';
       q.Params.ParamByName('TRANSACTIEID').AsInteger := FTransactieId;
       q.Params.ParamByName('ARTIKELID').AsInteger := artikelid;
       q.Params.ParamByName('VOLGNR').AsInteger := volgnr;
       q.Params.ParamByName('KORTINGSFACTOR').AsFloat:=m_tools.PercentageToFactor(kortingspercentage);
       q.ExecSQL();
       q.Close;

       dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      bRet:=false;
      MessageError('Fout bij aanpassen data in de database: ' + E.Message);
    end;
  end;
  PostData:=bRet;
end;

procedure TGridTransactieartikel.FocusToStartupColumn();
var
  iCol:integer;
begin
  // hack: meteen op verkopercode zetten gaf iets raars: in het eerste veld draaide de
  // volgorde van getallen invoeren om bij snel tikken
  //iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  WobbelGrid.Col:=iCol;
end;


function TGridTransactieartikel.PostData:boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  transactieartikelid:integer;
  bRet, bPostOk : boolean;
  postCount: integer;
  invalidrowcount:integer;
  verkoperid:integer;
  tmpDouble, volleprijs,kortingspercentage,kortingsfactor,verkoopprijs:double;
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
      transactieartikelid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('transactieartikel_id'), iRow] <> '') then
      begin
        transactieartikelid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('transactieartikel_id'), iRow]);
      end;

      // de laatste regel kan zeer gemakkelijk leeg zijn, in de flow van het invoeren. Dan een bericht onderdrukken
      if (FindIdOfPicklistItemDescription(iRow = iRowStop, iRow, verkoperid)) then
      begin
//        volleprijs:=StrToFloat(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('volleprijs'), iRow]);
        // TODO Dit is een lelijke HACK, om ervoor te zorgen dat als gebruiker een bedrag heeft ingevoerd zonder de cel te verlaten
        // en meteen op 'Opslaan' drukt, er geen 'enge' melding komt over OK en riskeer datacorruptie of Cancel
        //volleprijs:=StrToFloat(FormatToMoney(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('volleprijs'), iRow]));
        if (TryStrToFloat(FormatToMoney(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('volleprijs'), iRow]), tmpDouble)) then
        begin
          volleprijs:=tmpDouble;
        end;

        //kortingspercentage:=StrToFloat(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('kortingspercentage'), iRow]);
        if (TryStrToFloat(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('kortingspercentage'), iRow], tmpDouble)) then
        begin
          kortingspercentage:=tmpDouble;
        end;


        kortingsfactor:=m_tools.PercentageToFactor(kortingspercentage);
        verkoopprijs:=volleprijs*kortingsfactor;

        bPostOk:=PostData(
            transactieartikelid,
            verkoperid,
            verkoopprijs,
            kortingspercentage
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
      //MessageOk('De wijzigingen in de transactiegegevens zijn opgeslagen, behalve de regel(s) met ongeldige invoer.');
      // Wees zuinig met mededelingen aan de gebruiker
      //MessageOk('Alle wijzigingen zijn opgeslagen.');
    end
    else
    begin
      //MessageOk('Alle wijzigingen zijn opgeslagen.');
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


procedure TGridTransactieartikel.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;



function TGridTransactieartikel.AnyRowIsDirty: boolean;
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

procedure TGridTransactieartikel.GridValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  iRow,iRowStop, iCol:integer;
  iTmp: integer;
  tmpDouble, totPrijs:double;
  sTest:string;
  bValueReset:boolean;
  icolKorting,icolVerkoopprijs:integer;
  volleprijs,verkoopprijs,kortingspercentage,kortingsfactor:double;
begin
  // geen checks als er niets mag worden veranderd
  if (not (WSENABLEDEDITABLE in self.WobbelGridStatus)) then
  begin
    exit;
  end;


  if (WobbelGridValidateCellentry(aCol, aRow, OldValue, NewValue)) then
  begin
    bValueReset := false;

    // check of de verkopercode voorkomt in de picklist
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
    if ((iCol >= 0) and (iCol = aCol))then
    begin
      if (not FindIdOfPicklistItemDescription(true, aRow, iTmp)) then
      begin
        ShowMessage('De verkopercode "'+NewValue+'" komt niet voor in de lijst! Opnieuw invullen svp.');
        bValueReset := true;
        WobbelGrid.Cells[aCol, aRow] := OldValue;  // oude waarde terugzetten

        bValueReset := false;
        WobbelGrid.Cells[aCol, aRow] := '';  // leegmaken
      end;
    end;

    // bereken de verkoopprijs adhv prijs en korting indien het de volleprijs kolom is
    // die is aangepast
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('volleprijs');
    if ((iCol >= 0) and (iCol = aCol))then
    begin
      icolKorting:=FindWobbelGridColumnIndexByDatabaseFieldName('kortingspercentage');
      icolVerkoopprijs:=FindWobbelGridColumnIndexByDatabaseFieldName('prijs');
      if ((icolKorting >= 0) and (icolVerkoopprijs >= 0)) then
      begin
        //volleprijs:=StrToFloat(WobbelGrid.Cells[iCol, aRow]);
        //kortingspercentage:=StrToFloat(WobbelGrid.Cells[icolKorting, aRow]);
        if (TryStrToFloat(WobbelGrid.Cells[iCol, aRow], tmpDouble)) then
        begin
          volleprijs:=tmpDouble;
        end;
        if (TryStrToFloat(WobbelGrid.Cells[icolKorting, aRow], tmpDouble)) then
        begin
          kortingspercentage:=tmpDouble;
        end;


        kortingsfactor:=m_tools.PercentageToFactor(kortingspercentage);

        verkoopprijs:=volleprijs*kortingsfactor;
        WobbelGrid.Cells[icolVerkoopprijs, aRow]:=FormatToMoney(FloatToStr(verkoopprijs));
      end;
    end;


    // Bepaal de som van alle prijzen
    iRowStop:=WobbelGrid.RowCount-1;
    totPrijs:=0.0;
    for iRow:=WobbelGrid.FixedRows to iRowStop do
    begin
      sTest:=WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('prijs'), iRow];
      if (TryStrToFloat(sTest, tmpDouble)) then
      begin
        totPrijs:=totPrijs+tmpDouble;
      end;
    end;
    frmTransacties.SetTotaalPrijs(totPrijs);

    // zet de isdirty rowwaarde op 1
    if (not bValueReset) then
    begin
      iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
      if (iCol >= 0) then
      begin
        WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
      end;
    end
    else
    begin
      WobbelGrid.Row:=aRow;
      WobbelGrid.Col:=aCol;
      //WobbelGrid.SelectCell(self,aRow,aCol,cansel);
      if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
    end;
  end;
end;

// extra actie nodig voor checkboxkolommen
procedure TGridTransactieartikel.WobbelGridClick(Sender: TObject);
var
  iCol:integer;
begin
  if ((btnPost<>nil) and btnPost.Enabled) then
  begin
  //  exit;
  end;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  if (WobbelGrid.Col = iCol) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;

end;

function TGridTransactieartikel.CheckGridValues(iRowToSkip:integer): boolean;
begin
  CheckGridValues:=true;
end;

function TGridTransactieartikel.DeleteData(transactieartikelid: integer):boolean;
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
        // verwijder transactiearitkel
        q.SQL.Text:='delete from artikel where artikel_id in ( ' +
                   ' select artikelid from transactieartikel ' +
                   ' where transactieartikel_id=:TRANSACTIEARTIKEL_ID);';
        q.Params.ParamByName('TRANSACTIEARTIKEL_ID').AsInteger := transactieartikelid;
        q.ExecSQL();

        q.SQL.Text:='delete from transactieartikel where ' +
                   ' transactieartikel_id=:TRANSACTIEARTIKEL_ID;';
        q.Params.ParamByName('TRANSACTIEARTIKEL_ID').AsInteger := transactieartikelid;
        q.ExecSQL();
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
      MessageError('Fout bij verwijderen transactie artikel: ' + E.Message);
    end;
  end;
  DeleteData:=isOk;
end;


procedure TGridTransactieartikel.btnPostClick(Sender: TObject);
begin
  PostData;
  if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
  begin
    WobbelGrid.SetFocus;
  end;
end;

procedure TGridTransactieartikel.btnDeleteClick(Sender: TObject);
var
  transactieartikelid: integer;
  stransactieartikelid: string;
  iCol:integer;
begin
  if (not CheckGridValues(WobbelGrid.Row)) then
  begin
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('transactieartikel_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen transactieartikel_id kolom gevonden');
  end;
  stransactieartikelid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  if (stransactieartikelid <> '') then
  begin
    transactieartikelid:=StrToInt(stransactieartikelid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u artikel "' + stransactieartikelid + '" wilt verwijderen uit de transactie?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(transactieartikelid)) then
      begin
        MessageOk('Transactie artikel "' + stransactieartikelid + '" is verwijderd');
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
  if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
  begin
    WobbelGrid.SetFocus;
  end;
end;

procedure TGridTransactieartikel.btnRefreshClick(Sender: TObject);
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

procedure TGridTransactieartikel.btnCancelClick(Sender: TObject);
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

procedure TGridTransactieartikel.RefreshWobbelGrid();
begin
  FillGrid;
  (* 20130224 - dit staat in transactiegrid, niet in transactieartikelgrid:
  //FillverkoperPicklist();
  if (WobbelGrid.IsVisible) then
  begin
    if (WobbelGrid.Enabled) then
    begin
      WobbelGrid.SetFocus;
    end;
    FillGrid;
  end;
  *)
end;


procedure TGridTransactieartikel.BeweegGrid();
var
  iCol, iColCorrected, iRow: integer;
begin
  // Ga naar kolom volgnr om een validate te forceren van de velden.
  // kolom volgnr is het handigst omdat daar ook de focus wordt gelegd bij een
  // nieuwe transactie
  // Nieuwer inzicht: ga naar kolom 'verkopercode' om direcet daarin te kunnen invoeren.
  iCol := FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  WobbelGrid.Col:=iCol;
  exit;

  (*

  // eerst naar 'volleprijs' om in ieder geval uit de verkopercode kolom te gaan.
  // Dat forceert een
  iCol := FindWobbelGridColumnIndexByDatabaseFieldName('volleprijs');
  WobbelGrid.Col:=iCol;

  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  iColCorrected:=iCol-WobbelGrid.FixedCols;

  iRow:= self.GetCurrentGridRowNr;
  if (iRow = self.GetGridLastRowNr()) then
  begin
    if (WobbelGrid.Cells[iCol,iRow] <> '') then
    begin
      self.AddARecord();
      // laatste regel is geen lege regel: voeg er 1 toe om een validat te forceren
    end;
  end;
  self.SetGridRowNrToLast();
  *)

end;


end.
