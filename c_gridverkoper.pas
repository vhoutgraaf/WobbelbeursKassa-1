//------------------------------------------------------------------------------
// Name        : c_gridverkoper
// Purpose     : Implementatie van TGridVerkoper
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               verkopers.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridverkoper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;


type
TGridVerkoper = class(TWobbelGridPanel)
private

  FParent:TWinControl;
  FBeursId: integer;

  FGridSql:string;

  procedure btnPostClick(Sender: TObject);
  procedure btnDeleteClick(Sender: TObject);
  procedure btnRefreshClick(Sender: TObject);
  procedure btnCancelClick(Sender: TObject);

  procedure GridValidateEntry(sender: TObject; aCol,
    aRow: Integer; const OldValue: string; var NewValue: String);

  procedure WobbelGridClick(Sender: TObject);


  function DeleteData(verkoperid: integer):boolean;

  function PostData(verkoper_id, saldobetalingcontant:integer;
    opmerkingen, aanhef, voorletters, tussenvoegsel, achternaam, straat, huisnr, huisnrtoevoeging,
    postcode, woonplaats, telefoonmobiel1, telefoonmobiel2, telefoonvast, email,
    verkopercode, rekeningnummer, rekeningopnaam, rekeningbanknaam, rekeningplaats: string): boolean;

public
  constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight, BeursId:integer);
  destructor Destroy; override;

  procedure FillGrid;
  function AnyRowIsDirty: boolean;
  function PostData:boolean;
  property GridSql : string read FGridSql;
  function CheckGridValues(iRowToSkip:integer): string;
  procedure SetDirtyRow(gridRownr: integer; isDirty:boolean);

  property BeursId: integer read FBeursId write FBeursId;
  procedure SetGridProps;

end;


implementation

uses
  ZDataset,
  Dialogs, LCLType,
  c_appsettings, m_wobbeldata, m_querystuff, m_tools, m_error, m_constant;

constructor TGridVerkoper.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight, BeursId:integer);
var
  navButs: TWobbelNavButtons;
begin
  if (BeursId <= 0) then
  begin
    MessageDlg('Wobbel', 'Er is geen beurs gekozen. Svp eerst een beurs kiezen', mtConfirmation,
              [mbYes],0);
    exit;
  end;

  FBeursId:=BeursId;
  FParent:=AParent;

  Titel:='Inbrengergegevens beheren';

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

  SetGridHint('Geef in deze tabel de inbrengers aan voor de beurs die eerder is geselecteerd.'+m_constant.c_CR+'De kolommen met roodgedrukte titel zijn verplicht in te vullen.'+m_constant.c_CR+'Let op: de InbrengerCode moet uniek zijn in de lijst met inbrengers.');

  FillGrid;
  SetGridStatus([WSENABLEDEDITABLE]);
end;

destructor TGridVerkoper.Destroy;
begin
  inherited Destroy;
end;

procedure TGridVerkoper.SetGridProps;
var
  index: integer;
  q:TZQuery;
  bVal:boolean;
  ml_verkoper_id,ml_verkopercode,ml_opmerkingen,ml_aanhef,ml_voorletters,ml_tussenvoegsel,ml_achternaam,ml_straat,ml_huisnr,ml_huisnrtoevoeging,ml_postcode,ml_woonplaats,ml_telefoonmobiel1,ml_telefoonmobiel2,ml_telefoonvast,ml_email,ml_saldobetalingcontant,ml_rekeningnummer,ml_rekeningopnaam,ml_rekeningbanknaam,ml_rekeningplaats:integer;
begin
  index:=-1;

  try
    ml_verkoper_id:=10;
    ml_verkopercode:=50;
    ml_aanhef:=10;
    ml_voorletters:=20;
    ml_tussenvoegsel:=10;
    ml_achternaam:=50;
    ml_straat:=100;
    ml_huisnr:=10;
    ml_huisnrtoevoeging:=10;
    ml_postcode:=20;
    ml_woonplaats:=100;
    ml_telefoonmobiel1:=20;
    ml_telefoonmobiel2:=20;
    ml_telefoonvast:=20;
    ml_email:=50;
    ml_saldobetalingcontant:=1;
    ml_rekeningnummer:=20;
    ml_rekeningopnaam:=50;
    ml_rekeningbanknaam:=50;
    ml_rekeningplaats:=100;
    ml_opmerkingen:=255;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;
    q.SQL.Text:='select ' +
      ' verkoper.verkoper_id, ' +
      ' verkoper.verkopercode, ' +
      ' verkoper.opmerkingen, ' +
      ' naw.aanhef, ' +
      ' naw.voorletters, ' +
      ' naw.tussenvoegsel, ' +
      ' naw.achternaam, ' +
      ' naw.straat, ' +
      ' naw.huisnr, ' +
      ' naw.huisnrtoevoeging, ' +
      ' naw.postcode, ' +
      ' naw.woonplaats, ' +
      ' naw.telefoonmobiel1, ' +
      ' naw.telefoonmobiel2, ' +
      ' naw.telefoonvast, ' +
      ' naw.email, ' +
      ' verkoper.saldobetalingcontant, ' +
      ' verkoper.rekeningnummer, ' +
      ' verkoper.rekeningopnaam, ' +
      ' verkoper.rekeningbanknaam, ' +
      ' verkoper.rekeningplaats ' +
      ' from verkoper ' +
      ' left join naw on verkoper.nawid=naw.naw_id ' +
      ' limit 1';
    q.Open;
    ml_verkoper_id:=m_tools.getMaxTableFieldSize('verkoper_id', q);
    ml_verkopercode:=m_tools.getMaxTableFieldSize('verkopercode', q);
    ml_aanhef:=m_tools.getMaxTableFieldSize('aanhef', q);
    ml_voorletters:=m_tools.getMaxTableFieldSize('voorletters', q);
    ml_tussenvoegsel:=m_tools.getMaxTableFieldSize('tussenvoegsel', q);
    ml_achternaam:=m_tools.getMaxTableFieldSize('achternaam', q);
    ml_straat:=m_tools.getMaxTableFieldSize('straat', q);
    ml_huisnr:=m_tools.getMaxTableFieldSize('huisnr', q);
    ml_huisnrtoevoeging:=m_tools.getMaxTableFieldSize('huisnrtoevoeging', q);
    ml_postcode:=m_tools.getMaxTableFieldSize('postcode', q);
    ml_woonplaats:=m_tools.getMaxTableFieldSize('woonplaats', q);
    ml_telefoonmobiel1:=m_tools.getMaxTableFieldSize('telefoonmobiel1', q);
    ml_telefoonmobiel2:=m_tools.getMaxTableFieldSize('telefoonmobiel2', q);
    ml_telefoonvast:=m_tools.getMaxTableFieldSize('telefoonvast', q);
    ml_email:=m_tools.getMaxTableFieldSize('email', q);
    ml_saldobetalingcontant:=m_tools.getMaxTableFieldSize('saldobetalingcontant', q);
    ml_rekeningnummer:=m_tools.getMaxTableFieldSize('rekeningnummer', q);
    ml_rekeningopnaam:=m_tools.getMaxTableFieldSize('rekeningopnaam', q);
    ml_rekeningbanknaam:=m_tools.getMaxTableFieldSize('rekeningbanknaam', q);
    ml_rekeningplaats:=m_tools.getMaxTableFieldSize('rekeningplaats', q);
    ml_opmerkingen:=m_tools.getMaxTableFieldSize('opmerkingen', q);
    q.Close;
  finally
    q.Free;
  end;




//  MessageOk('colcount verkopers: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='VerkoperId';
  WobbelGrid.Columns.Items[index].Visible:=false;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'verkoper_id', [wtInteger], '', 1, ml_verkoper_id, 'VerkoperId', 'interne unieke id van de verkoper', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='InbrengerCode';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=50;
  WobbelGrid.Columns.Items[index].Width:=150;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'verkopercode', [wtString], '', 0, ml_verkopercode, 'Inbrenger code', 'door Wobbel aangegeven ID van de inbrenger', WobbelGrid.Columns.Items[index].Width, true));
  WobbelGrid.Columns.Items[index].SizePriority:=4;

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Aanhef';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=55;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'aanhef', [wtString], '', 0, ml_aanhef, 'Aanhef', 'Dhr, Mw, etc.', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Voorletters';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=75;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'voorletters', [wtString], '', 0, ml_voorletters, 'Initialen', '', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Tussenvoegsel';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=95;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'tussenvoegsel', [wtString], '', 0, ml_tussenvoegsel, 'Tussenvoegsel', '(van, van der, etc.)', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Achternaam';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=2;
  WobbelGrid.Columns.Items[index].MaxSize:=50;
  WobbelGrid.Columns.Items[index].Width:=130;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'achternaam', [wtString], '', 2, ml_achternaam, 'Achternaam', '', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Straat';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=2;
  WobbelGrid.Columns.Items[index].MaxSize:=100;
  WobbelGrid.Columns.Items[index].Width:=130;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'straat', [wtString], '', 2, ml_straat, 'Straat', 'straatnaam van het adres', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Huisnr';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=55;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'huisnr', [wtinteger], '', 1, ml_huisnr, 'Huisnr', 'huisnummer (een getal)', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Huisnr toevoeging';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=10;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'huisnrtoevoeging', [wtString], '', 0, ml_huisnrtoevoeging, 'Huisnr toevoeging', 'eventuele toevoeging aan het huisnummer', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Postcode';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=6;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=65;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'postcode', [wtString], '', 6, ml_postcode, 'Postcode', '', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Woonplaats';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=100;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'woonplaats', [wtString], '', 1, ml_woonplaats, 'Woonplaats', 'woonplaats van de inbrenger', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Mobiel 1';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=80;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'telefoonmobiel1', [wtString], '', 0, ml_telefoonmobiel1, 'Mobiel 1', 'mobiel telefoonnummer', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Mobiel 2';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=80;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'telefoonmobiel2', [wtString], '', 0, ml_telefoonmobiel2, 'Mobiel 2', 'alternatief mobiel telefoonnummer', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Telf vast';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=80;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'telefoonvast', [wtString], '', 0, ml_telefoonvast, 'Telf vast', 'vast telefoonnummer', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='E-mail';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=50;
  WobbelGrid.Columns.Items[index].Width:=130;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'email', [wtString], '', 0, ml_email, 'E-mail', '', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Saldo betaling contant';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=1;
  WobbelGrid.Columns.Items[index].Width:=140;
  WobbelGrid.Columns.Items[index].ButtonStyle:=cbsCheckboxColumn;
  //WobbelGrid.Columns.Items[index].PickList.AddObject('Nee', TObject(0));
  //WobbelGrid.Columns.Items[index].PickList.AddObject('Ja', TObject(1));
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'saldobetalingcontant', [wtString], '0', 1, ml_saldobetalingcontant, 'Saldo betaling contant', 'Geef aan of de inbrenger contante uitbetaling heeft gekregen of via een overschrijving', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Bank: Rekening nr.';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=20;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'rekeningnummer', [wtString], '', 0, ml_rekeningnummer, 'Bank-Rekening nr.', 'optioneel een bankrekeningnummer', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Bank: Rekening op Naam';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=50;
  WobbelGrid.Columns.Items[index].Width:=160;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'rekeningopnaam', [wtString], '', 0, ml_rekeningopnaam, 'Bank-Rekening op Naam', 'optioneel de tenaamstelling van de bankrekening', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Bank: Naam bank';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=50;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'rekeningbanknaam', [wtString], '', 0, ml_rekeningbanknaam, 'Bank-Naam bank', 'optioneel de naam van de bank', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Bank: Plaats';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=100;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'rekeningplaats', [wtString], '', 0, ml_rekeningplaats, 'Bank-Plaats', 'optioneel de plaatsnaam van de bankvestiging', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opmerkingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=250;
  WobbelGrid.Columns.Items[index].Width:=120;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'opmerkingen', [wtMemo], '', 0, ml_opmerkingen, 'Opmerkingen', 'Vrij veld voor opmerkingen', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

end;

procedure TGridVerkoper.FillGrid;
var
  q: TZQuery;
  rowCounter: integer;
  colCounter: integer;
  ix: integer;
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
          ' v.verkopercode, ' +
          ' n.achternaam, ' +
          ' v.rekeningnummer, ' +
          ' v.rekeningopnaam, ' +
          ' v.rekeningbanknaam, ' +
          ' v.rekeningplaats, ' +
          ' n.email, ' +
          ' n.telefoonmobiel1, ' +
          ' n.aanhef, ' +
          ' n.voorletters, ' +
          ' n.tussenvoegsel, ' +
          ' n.straat, ' +
          ' n.huisnr, ' +
          ' n.huisnrtoevoeging, ' +
          ' n.postcode, ' +
          ' n.woonplaats, ' +
          ' v.opmerkingen, ' +
          ' n.telefoonmobiel2, ' +
          ' n.telefoonvast, ' +
          ' v.saldobetalingcontant, ' +
          ' v.verkoper_id ' +
          ' from verkoper as v ' +
          ' left join beurs_verkoper as bv on v.verkoper_id=bv.verkoperid and bv.beursid=b.beurs_id ' +
          ' left join beurs as b on bv.beursid=b.beurs_id ' +
          ' left join naw as n on v.nawid=n.naw_id ' +
          ' where (bv.beurs_verkoper_id!='''' and bv.beurs_verkoper_id is not null) and b.isactief=1; ';
      FGridSql:=string(q.SQL.GetText);
      //q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('verkoper_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('verkopercode').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('Aanhef').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('voorletters').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('tussenvoegsel').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('achternaam').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('straat').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('huisnr').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('huisnrtoevoeging').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('postcode').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('woonplaats').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('telefoonmobiel1').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('telefoonmobiel2').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('telefoonvast').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('email').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('saldobetalingcontant').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('rekeningnummer').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('rekeningopnaam').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('rekeningbanknaam').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('rekeningplaats').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('opmerkingen').AsString;
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
      MessageError('Fout bij invullen inbrengertabel: ' + E.Message);
    end;
  end;
end;

function TGridVerkoper.PostData(verkoper_id, saldobetalingcontant:integer;
  opmerkingen, aanhef, voorletters, tussenvoegsel, achternaam, straat, huisnr, huisnrtoevoeging,
  postcode, woonplaats, telefoonmobiel1, telefoonmobiel2, telefoonvast, email,
  verkopercode, rekeningnummer, rekeningopnaam, rekeningbanknaam, rekeningplaats: string): boolean;
var
  q : TZQuery;
  nawidCurrent, verkoperidCurrent: integer;
  sTmp: string;
  bRet:boolean;
begin
  bRet:=true;

  if (verkopercode = '') then
  begin
    PostData:=false;
    MessageError('De InbrengerCode moet een waarde hebben. De regel met een lege code wordt niet toegevoegd aan de database.');
    exit;
  end;

  nawidCurrent:=-1;
  try
    try
      verkoperidCurrent:=verkoper_id;

      q := m_querystuff.GetSQLite3QueryMdb;


      // find nawid
      if (verkoperidCurrent<0) then
      begin
        nawidCurrent:=-1;
      end
      else
      begin
        q.SQL.Clear;
        q.SQL.Text := 'select nawid from verkoper where verkoper_id=:VERKOPERID;';
        q.Params.ParamByName('VERKOPERID').AsInteger := verkoperidCurrent;
        q.Open;
        while not q.Eof do
        begin
          nawidCurrent:=q.FieldByName('nawid').AsInteger;
          break;
        end;
        q.Close;
      end;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);
      q.SQL.Clear;
      if (nawidCurrent >= 0) then
      begin
         q.SQL.Text:='update naw set ' +
                      ' aanhef=:AANHEF, ' +
                      ' voorletters=:VOORLETTERS, ' +
                      ' tussenvoegsel=:TUSSENVOEGSEL, ' +
                      ' achternaam=:ACHTERNAAM, ' +
                      ' straat=:STRAAT, ' +
                      ' huisnr=:HUISNR, ' +
                      ' huisnrtoevoeging=:HUISNRTOEVOEGING, ' +
                      ' postcode=:POSTCODE, ' +
                      ' woonplaats=:WOONPLAATS, ' +
                      ' telefoonmobiel1=:TELEFOONMOBIEL1, ' +
                      ' telefoonmobiel2=:TELEFOONMOBIEL2, ' +
                      ' telefoonvast=:TELEFOONVAST, ' +
                      ' email=:EMAIL' +
                      ' where naw_id=:NAWID';
        q.Params.ParamByName('AANHEF').AsString := aanhef;
        q.Params.ParamByName('VOORLETTERS').AsString := voorletters;
        q.Params.ParamByName('TUSSENVOEGSEL').AsString := tussenvoegsel;
        q.Params.ParamByName('ACHTERNAAM').AsString := achternaam;
        q.Params.ParamByName('STRAAT').AsString := straat;
        q.Params.ParamByName('HUISNR').AsString := huisnr;
        q.Params.ParamByName('HUISNRTOEVOEGING').AsString := huisnrtoevoeging;
        q.Params.ParamByName('POSTCODE').AsString := postcode;
        q.Params.ParamByName('WOONPLAATS').AsString := woonplaats;
        q.Params.ParamByName('TELEFOONMOBIEL1').AsString := telefoonmobiel1;
        q.Params.ParamByName('TELEFOONMOBIEL2').AsString := telefoonmobiel2;
        q.Params.ParamByName('TELEFOONVAST').AsString := telefoonvast;
        q.Params.ParamByName('EMAIL').AsString := email;
        q.Params.ParamByName('NAWID').AsInteger := nawidCurrent;

        q.ExecSQL();
      end
      else
      begin
        q.SQL.Text:='insert into naw (' +
                     ' aanhef, ' +
                     ' voorletters, ' +
                     ' tussenvoegsel, ' +
                     ' achternaam, ' +
                     ' straat, ' +
                     ' huisnr, ' +
                     ' huisnrtoevoeging, ' +
                     ' postcode, ' +
                     ' woonplaats, ' +
                     ' telefoonmobiel1, ' +
                     ' telefoonmobiel2, ' +
                     ' telefoonvast, ' +
                     ' email) ' +
                     ' values ( ' +
                     ' :AANHEF, ' +
                     ' :VOORLETTERS, ' +
                     ' :TUSSENVOEGSEL, ' +
                     ' :ACHTERNAAM, ' +
                     ' :STRAAT, ' +
                     ' :HUISNR, ' +
                     ' :HUISNRTOEVOEGING, ' +
                     ' :POSTCODE, ' +
                     ' :WOONPLAATS, ' +
                     ' :TELEFOONMOBIEL1, ' +
                     ' :TELEFOONMOBIEL2, ' +
                     ' :TELEFOONVAST, ' +
                     ' :EMAIL)';
       q.Params.ParamByName('AANHEF').AsString := aanhef;
       q.Params.ParamByName('VOORLETTERS').AsString := voorletters;
       q.Params.ParamByName('TUSSENVOEGSEL').AsString := tussenvoegsel;
       q.Params.ParamByName('ACHTERNAAM').AsString := achternaam;
       q.Params.ParamByName('STRAAT').AsString := straat;
       q.Params.ParamByName('HUISNR').AsString := huisnr;
       q.Params.ParamByName('HUISNRTOEVOEGING').AsString := huisnrtoevoeging;
       q.Params.ParamByName('POSTCODE').AsString := postcode;
       q.Params.ParamByName('WOONPLAATS').AsString := woonplaats;
       q.Params.ParamByName('TELEFOONMOBIEL1').AsString := telefoonmobiel1;
       q.Params.ParamByName('TELEFOONMOBIEL2').AsString := telefoonmobiel2;
       q.Params.ParamByName('TELEFOONVAST').AsString := telefoonvast;
       q.Params.ParamByName('EMAIL').AsString := email;

       q.ExecSQL();
       q.Close;

       // lijkt niet te werken binnen een transactie
       //nawidCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

       q.SQL.Clear;
       q.SQL.Text:='select max(naw_id) as nawid from naw';
       q.Open;
       nawidCurrent:=-1;
       while not q.Eof do
       begin
         sTmp:=q.FieldByName('nawid').AsString;
         if (sTmp='') then
         begin
           nawidCurrent:=1;
         end
         else
         begin
           nawidCurrent:=StrToInt(sTmp);
         end;
         break;
       end;
       q.Close;
       if (nawidCurrent = -1) then
       begin
         Raise EWobbelError.Create('Invoerfout NAW-gegevens (NAW)');
       end;
      end;

      if (verkoperidCurrent >= 0) then
      begin
         q.SQL.Text:='update verkoper set ' +
                     ' verkopercode=:VERKOPERCODE, ' +
                     ' saldobetalingcontant=:SALDOBETALINGENCONTANT, ' +
                     ' rekeningnummer=:REKENINGNUMMER, ' +
                     ' rekeningopnaam=:REKENINGOPNAAM, ' +
                     ' rekeningbanknaam=:REKENINGBANKNAAM, ' +
                     ' rekeningplaats=:REKENINGPLAATS, ' +
                     ' opmerkingen=:OPMERKINGEN, ' +
                     ' nawid=:NAWID ' +
                     ' where verkoper_id=:VERKOPER_ID';
         q.Params.ParamByName('VERKOPERCODE').AsString := verkopercode;
         q.Params.ParamByName('SALDOBETALINGENCONTANT').AsInteger := saldobetalingcontant;
         q.Params.ParamByName('REKENINGNUMMER').AsString := rekeningnummer;
         q.Params.ParamByName('REKENINGOPNAAM').AsString := rekeningopnaam;
         q.Params.ParamByName('REKENINGBANKNAAM').AsString := rekeningbanknaam;
         q.Params.ParamByName('REKENINGPLAATS').AsString := rekeningplaats;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('NAWID').AsInteger := nawidCurrent;
         q.Params.ParamByName('VERKOPER_ID').AsInteger := verkoperidCurrent;
         q.ExecSQL();
       end
       else
       begin
         q.SQL.Text:='insert into verkoper (' +
                     ' verkopercode, ' +
                     ' saldobetalingcontant, ' +
                     ' rekeningnummer, ' +
                     ' rekeningopnaam, ' +
                     ' rekeningbanknaam, ' +
                     ' rekeningplaats, ' +
                     ' opmerkingen, ' +
                     ' nawid' +
                     ' ) values(' +
                     ' :VERKOPERCODE, ' +
                     ' :SALDOBETALINGENCONTANT, ' +
                     ' :REKENINGNUMMER, ' +
                     ' :REKENINGOPNAAM, ' +
                     ' :REKENINGBANKNAAM, ' +
                     ' :REKENINGPLAATS, ' +
                     ' :OPMERKINGEN, ' +
                     ' :NAWID)';
         q.Params.ParamByName('VERKOPERCODE').AsString := verkopercode;
         q.Params.ParamByName('SALDOBETALINGENCONTANT').AsInteger := saldobetalingcontant;
         q.Params.ParamByName('REKENINGNUMMER').AsString := rekeningnummer;
         q.Params.ParamByName('REKENINGOPNAAM').AsString := rekeningbanknaam;
         q.Params.ParamByName('REKENINGBANKNAAM').AsString := rekeningbanknaam;
         q.Params.ParamByName('REKENINGPLAATS').AsString := rekeningplaats;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('NAWID').AsInteger := nawidCurrent;
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //verkoperidCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(verkoper_id) as verkoperid from verkoper';
         q.Open;
         verkoperidCurrent:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('verkoperid').AsString;
           if (sTmp='') then
           begin
             verkoperidCurrent:=1;
           end
           else
           begin
             verkoperidCurrent:=StrToInt(sTmp);
           end;
           break;
         end;
         q.Close;
         if (verkoperidCurrent = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout NAW-gegevens (inbrenger)');
         end;

         q.SQL.Clear;
         q.SQL.Text:='insert into beurs_verkoper (' +
                     ' beursid, ' +
                     ' verkoperid ' +
                     ' ) values(' +
                     ' :BEURSID, ' +
                     ' :VERKOPERID)';
         q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
         q.Params.ParamByName('VERKOPERID').AsInteger := verkoperidCurrent;
         q.ExecSQL();
         q.Close;
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

procedure TGridVerkoper.GridValidateEntry(sender: TObject; aCol,
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

function TGridVerkoper.AnyRowIsDirty: boolean;
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

function TGridVerkoper.PostData:boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  verkoperid:integer;
  bRet, bPostOk : boolean;
  postCount: integer;
  saldobetalingcontant:integer;
  invalidrowcount:integer;
  sRet:string;
begin
  bRet:=true;
  sRet:=CheckGridValues(-1);
  if (sRet <> '') then
  begin
    MessageOk(sRet);
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
      verkoperid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('verkoper_id'), iRow] <> '') then
      begin
        verkoperid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('verkoper_id'), iRow]);
      end;

      saldobetalingcontant:=0;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('saldobetalingcontant'), iRow] <> '') then
      begin
        saldobetalingcontant:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('saldobetalingcontant'), iRow]);
      end;

      bPostOk:=PostData(
          verkoperid,
          saldobetalingcontant,
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('aanhef'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('voorletters'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('tussenvoegsel'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('achternaam'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('straat'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('huisnr'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('huisnrtoevoeging'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('postcode'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('woonplaats'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('telefoonmobiel1'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('telefoonmobiel2'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('telefoonvast'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('email'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('rekeningnummer'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('rekeningopnaam'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('rekeningbanknaam'), iRow],
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('rekeningplaats'), iRow]);
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
      MessageOk('De wijzigingen in de inbrengergegevens zijn opgeslagen, behalve de regel(s) met ongeldige invoer.');
    end
    else
    begin
      MessageOk('Alle wijzigingen in de inbrengergegevens zijn opgeslagen');
    end;

    //SetGridStatus([WSDISABLEDNOTEDITABLE]);
    if (WobbelGrid.IsVisible) then
    begin
      SetGridStatus([WSENABLEDEDITABLE]);
      if (WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
      FillGrid;
    end;
  end;
  PostData:=bRet;
  AppSettings.Beurs.SetAantalVerkopersInActieveBeurs();

end;

procedure TGridVerkoper.SetDirtyRow(gridRownr: integer; isDirty:boolean);
var
  dirtyval:integer;
begin
  dirtyval:=1;
  if (not isDirty) then
  begin
    dirtyval:=0;
  end;
  WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isdirty'),gridRownr]:=IntToStr(dirtyval);

end;

procedure TGridVerkoper.btnPostClick(Sender: TObject);
begin
  PostData;
end;

// extra actie nodig voor checkboxkolommen
procedure TGridVerkoper.WobbelGridClick(Sender: TObject);
var
  iCol:integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('saldobetalingcontant');
  if (WobbelGrid.Col = iCol) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

function TGridVerkoper.CheckGridValues(iRowToSkip:integer): string;
var
  iRow: integer;
  iRowStop:integer;
  uniekList:TStringList;
  iColUniek: integer;
  sTest:string;
  uniekIndexInList:integer;
  uniekDubbelCount:integer;
  sRet:string;
  sDubbele:string;
begin
  sRet:='';
  try
    uniekList:=TStringList.Create;

    sDubbele:='';
    uniekDubbelCount:=0;
    iRowStop:=WobbelGrid.RowCount-1;
    iColUniek:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
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
          sDubbele:=sTest;
          inc(uniekDubbelCount);
        end;
        uniekList.Add(sTest);
      end;
    end;

    sRet:='';
    if (uniekDubbelCount>0) then
    begin
      sRet:='InbrengerCode "'+sDubbele+'" is niet uniek in de beurs. Kies een andere waarde svp.';
    end;

  finally
    if (uniekList<>nil) then
    begin
      uniekList.Free;
      uniekList:=nil;
    end;
  end;
  Result:=sRet;
end;


function TGridVerkoper.DeleteData(verkoperid: integer):boolean;
var
  q : TZQuery;
  aantalHits: integer;
  isOk: boolean;
  nawid:integer;
  bDoDelete: boolean;
begin
  isOk:=true;
  nawid:=-1;

  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      // find nawid
      q.SQL.Clear;
      q.SQL.Text := 'select nawid from verkoper where verkoper_id=:VERKOPERID;';
      q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
      q.Open;
      while not q.Eof do
      begin
        nawid:=q.FieldByName('nawid').AsInteger;
        break;
      end;
      q.Close;

      if (nawid>=0) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'select count(*) as aantal from verkoper where nawid=:NAWID and verkoper_id!=:VERKOPERID;';
        q.Params.ParamByName('NAWID').AsInteger := nawid;
        q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
        q.Open;
        aantalHits:=-1;
        while not q.Eof do
        begin
          aantalHits:=q.FieldByName('aantal').AsInteger;
          break;
        end;
        q.Close;
        if (aantalHits>1) then
        begin
           isOk:=false;
           MessageOk('Er zijn meerdere inbrengers en/of vrijwilligers met hetzelfde adres. Verwijderen kan niet doorgaan');
        end;
      end;

      if (isOk) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'select count(*) as aantal from artikel as a ' +
           ' left join transactieartikel as ta on ta.artikelid=a.artikel_id ' +
           //' where a.verkoperid=:VERKOPERID and ta.transactieid is not null;';
           ' where a.verkoperid=:VERKOPERID and (ta.transactieid != '''' and ta.transactieid is not null);';
        q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
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
           MessageOk('Er zijn kopers van artikelen die bij deze inbrenger horen. De inbrenger kan niet worden verwijderd.');
        end;
      end;

      if (isOk) then
      begin
        q.SQL.Clear;
        q.SQL.Text := 'select count(*) as aantal from artikel as a ' +
           ' left join transactieartikel as ta on ta.artikelid=a.artikel_id ' +
           //' where a.verkoperid=:VERKOPERID and ta.transactieid is null;';
           ' where a.verkoperid=:VERKOPERID and (ta.transactieid = '''' or ta.transactieid is null);';
        q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
        q.Open;
        aantalHits:=-1;
        while not q.Eof do
        begin
          aantalHits:=q.FieldByName('aantal').AsInteger;
          break;
        end;
        q.Close;
        bDoDelete:=false;
        if (aantalHits>0) then
        begin
          isOk:=false;
          if MessageDlg('Wobbel', 'Er zijn artikelen verbonden aan deze inbrenger (maar geen klanten / kopers). Alles verwijderen?', mtConfirmation,
            [mbYes, mbNo],0) = mrYes
          then
          begin
            isOk:=true;
            q.SQL.Clear;
            q.SQL.Text := 'delete from artikel where verkoperid=:VERKOPERID;';
            q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
            q.ExecSQL;
            bDoDelete:=true;
          end;
        end
        else
        begin
          bDoDelete:=true;
        end;
        if (bDoDelete) then
        begin
          q.SQL.Clear;
          q.SQL.Text := 'delete from beurs_verkoper where verkoperid=:VERKOPERID;';
          q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
          q.ExecSQL;

          q.SQL.Clear;
          q.SQL.Text := 'delete from verkoper where verkoper_id=:VERKOPERID;';
          q.Params.ParamByName('VERKOPERID').AsInteger := verkoperid;
          q.ExecSQL;

          if (nawid >= 0) then
          begin
            q.SQL.Clear;
            q.SQL.Text := 'delete from naw where naw_id=:NAWID;';
            q.Params.ParamByName('NAWID').AsInteger := nawid;
            q.ExecSQL;
          end;
        end;
      end;
    finally
      q.Free;
      dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
      DeleteData:=isOk;
    end;
  except
    on E: Exception do
    begin
      isOk:=false;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij check of verwijderen inbrenger mogelijk is: ' + E.Message);
    end;
  end;
end;

procedure TGridVerkoper.btnDeleteClick(Sender: TObject);
var
  verkoperid: integer;
  sVerkoperid: string;
  sAchternaam, sVerkopercode:string;
  iCol:integer;
  sTmp:string;
begin
  sTmp:=CheckGridValues(WobbelGrid.Row);
  if (sTmp <> '') then
  begin
    MessageOk(sTmp);
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkoper_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen verkoper_id kolom gevonden');
  end;
  sVerkoperid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  sAchternaam:='';
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('achternaam');
  if (iCol >= 0) then
  begin
    sAchternaam:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  end;

  sVerkopercode:='';
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('verkopercode');
  if (iCol >= 0) then
  begin
    sVerkopercode:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  end;


  if (sVerkoperid <> '') then
  begin
    verkoperid:=StrToInt(sVerkoperid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u inbrenger "' + sAchternaam + '" (' + sVerkopercode + ') wilt verwijderen?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(verkoperid)) then
      begin
        MessageOk('Inbrenger "' + sAchternaam + '" (' + sVerkopercode + ')" is verwijderd');
        FillGrid;
      end;
    end;
  end
  else
  begin
    //MessageError('Deze inbrenger is nog niet in de database ingevoerd');
    WobbelGrid.DeleteRow(WobbelGrid.Row);
    FillGrid;
  end;
end;

procedure TGridVerkoper.btnRefreshClick(Sender: TObject);
begin
  FillGrid;
end;



procedure TGridVerkoper.btnCancelClick(Sender: TObject);
begin
  //SetGridStatus([WSDISABLEDNOTEDITABLE]);
  FillGrid;
end;


end.




