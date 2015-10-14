unit formoverzichttransactiesperverkop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
  c_Asc = ' Asc ';
  c_Desc = ' Desc ';

type

  { TfrmOverzichtTransactiesPerVerkoper }

  TfrmOverzichtTransactiesPerVerkoper = class(TForm)
    btnExporteer: TButton;
    btnInfo01: TBitBtn;
    btnToon: TButton;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblGrid: TLabel;
    lblMunteenheid: TLabel;
    lblPgBar: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pgBar: TProgressBar;
    pnlOverzicht: TPanel;
    procedure btnExporteerClick(Sender: TObject);
    procedure btnToonClick(Sender: TObject);
    procedure chkGetallenMaalHonderdChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure grdOverzichtTitleClick(Column: TColumn);

    procedure SetBasequery;

  private
    { private declarations }

    FSql:string;

    FSqlBase:string;
    FSqlBaseInCenten: string;

    FeuroString2:string;
    FeuroString3:string;
    FeuroString4:string;

    FcentString2:string;
    FcentString3:string;
    FcentString4:string;

    FOrderByVerkopercode:string;
    FOrderByVerkopercodeDescAsc:string;

    FOrderByKassanr:string;
    FOrderByKassanrDescAsc:string;

    FOrderByKortingspercentage:string;
    FOrderByKortingspercentageDescAsc:string;

    FOrderByOngekorteprijs:string;
    FOrderByOngekorteprijsDescAsc:string;

    FOrderByGekorteprijs:string;
    FOrderByGekorteprijsDescAsc:string;

    FOrderByBetaalwijze:string;
    FOrderByBetaalwijzeDescAsc:string;

    FOrderByTransactieid:string;
    FOrderByTransactieidDescAsc:string;
  public
    { public declarations }
  end;

var
  frmOverzichtTransactiesPerVerkoper: TfrmOverzichtTransactiesPerVerkoper;

implementation

{$R *.lfm}

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt;

{ TfrmOverzichtTransactiesPerVerkoper }

procedure TfrmOverzichtTransactiesPerVerkoper.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  m_tools.CloseOtherScreens(self);

  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  dmWobbel.vwOverzicht.Active:=false;
  dmWobbel.vwOverzicht.SQL.Clear;
  SetBasequery;
  //dmWobbel.vwOverzicht.SQL.Append(FSqlBase);
  dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercode);
  dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercodeDescAsc);
  //dmWobbel.vwOverzicht.Active:=true;

  FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
  mmoExportQuery.Text:=FSql;

  pgBar.Position:=0;
  lblPgBar.Caption:='';
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;
end;

procedure TfrmOverzichtTransactiesPerVerkoper.btnExporteerClick(Sender: TObject
  );
begin
  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;
  pgBar.Visible:=true;
  lblPgBar.Visible:=true;

  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Transacties per inbrenger');
end;

procedure TfrmOverzichtTransactiesPerVerkoper.btnToonClick(Sender: TObject);
begin
  try
    Screen.Cursor:=crHourGlass;
    pgBar.Visible:=false;
    lblPgBar.Visible:=false;

    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TfrmOverzichtTransactiesPerVerkoper.chkGetallenMaalHonderdChange(
  Sender: TObject);
begin
  try
    Screen.Cursor:=crHourGlass;
    dmWobbel.vwOverzicht.Active:=false;
    dmWobbel.vwOverzicht.SQL.Clear;
    SetBasequery;
    dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercode);
    dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercodeDescAsc);
    FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);

    mmoExportQuery.Text:=FSql;
    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;

end;

procedure TfrmOverzichtTransactiesPerVerkoper.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtTransactiesPerVerkoper.SetBasequery;
var
  displayformat: string;
begin
  if (chkGetallenMaalHonderd.Checked) then
  begin
    lblMunteenheid.Visible:=true;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBaseInCenten);
    displayformat:='';

    grdOverzicht.Columns.Items[2].DisplayName:=FcentString2;
    grdOverzicht.Columns.Items[2].Title.Caption:=FcentString2;
    grdOverzicht.Columns.Items[2].FieldName:=FcentString2;
    grdOverzicht.Columns.Items[2].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[3].DisplayName:=FcentString3;
    grdOverzicht.Columns.Items[3].Title.Caption:=FcentString3;
    grdOverzicht.Columns.Items[3].FieldName:=FcentString3;
    grdOverzicht.Columns.Items[3].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[4].DisplayName:=FcentString4;
    grdOverzicht.Columns.Items[4].Title.Caption:=FcentString4;
    grdOverzicht.Columns.Items[4].FieldName:=FcentString4;
    grdOverzicht.Columns.Items[4].DisplayFormat:=displayformat;

  end
  else
  begin
    lblMunteenheid.Visible:=false;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBase);
    displayformat:='0.00';

    grdOverzicht.Columns.Items[2].DisplayName:=FeuroString2;
    grdOverzicht.Columns.Items[2].Title.Caption:=FeuroString2;
    grdOverzicht.Columns.Items[2].FieldName:=FeuroString2;
    grdOverzicht.Columns.Items[2].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[3].DisplayName:=FeuroString3;
    grdOverzicht.Columns.Items[3].Title.Caption:=FeuroString3;
    grdOverzicht.Columns.Items[3].FieldName:=FeuroString3;
    grdOverzicht.Columns.Items[3].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[4].DisplayName:=FeuroString4;
    grdOverzicht.Columns.Items[4].Title.Caption:=FeuroString4;
    grdOverzicht.Columns.Items[4].FieldName:=FeuroString4;
    grdOverzicht.Columns.Items[4].DisplayFormat:=displayformat;

  end;
end;


procedure TfrmOverzichtTransactiesPerVerkoper.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FcentString2:='100 * Kortingspercentage';
  FcentString3:='CENTEN: Artikelprijs zonder korting';
  FcentString4:='CENTEN: Artikelprijs bij verkoopPin';

  FeuroString2:='Kortingspercentage';
  FeuroString3:='Artikelprijs zonder korting';
  FeuroString4:='Artikelprijs bij verkoop';

  sqlbase1:=' select ' +
        ' b.datum as beursdatum, v.verkopercode as Inbrengercode, ';

  // N.B. veldnamen mogen niet veranderen anders worden ze niet in het grid getoond
  fieldsInCenten:= ' cast(round(100*round(case when ta.kortingsfactor is null or ta.kortingsfactor = '''' then 0 else 100.0*(1.0-ta.kortingsfactor) end, 2),0) as int) as '''+FcentString2+''',  ' +
        ' cast(round(100*round(case when a.prijs is null or a.prijs = '''' then 0 else a.prijs end, 2),0) as int) as '''+FcentString3+''',  ' +
        ' cast(round(100*round(case when a.prijs is null or a.prijs = '''' then 0 else ta.kortingsfactor*a.prijs end, 2),0) as int) as '''+FcentString4+''', ';

  fields:= ' round(case when ta.kortingsfactor is null or ta.kortingsfactor = '''' then 0 else 100.0*(1.0-ta.kortingsfactor) end, 2) as '''+FeuroString2+''',  ' +
        ' round(case when a.prijs is null or a.prijs = '''' then 0 else a.prijs end, 2) as '''+FeuroString3+''',  ' +
        ' round(case when a.prijs is null or a.prijs = '''' then 0 else ta.kortingsfactor*a.prijs end, 2) as '''+FeuroString4+''', ';

  sqlbase2:=' t.transactie_id as Klantid, ' +
        ' k.kassanr as Kassanr, ' +
        ' bw.omschrijving as Betaalwijze, ' +
        ' n.aanhef as Aanhef, n.voorletters as Voorletters,n.tussenvoegsel,n.achternaam, ' +
        ' n.straat,n.huisnr,n.huisnrtoevoeging,n.postcode,n.woonplaats, ' +
        ' n.telefoonmobiel1,n.telefoonmobiel2,n.telefoonvast, n.email, ' +
        ' v.rekeningnummer, v.rekeningopnaam, v.rekeningbanknaam, v.rekeningplaats, ' +
        ' b.opmerkingen as beursopmerkingen, ' +
        ' v.opmerkingen as Verkoperopmerkingen ' +
        ' from verkoper as v ' +
        ' inner join beurs_verkoper as bv on bv.verkoperid=v.verkoper_id ' +
        ' inner join beurs as b on bv.beursid=b.beurs_id and b.isactief=1 ' +
        ' left join naw as n on n.naw_id=v.nawid ' +
        ' left join artikel as a on v.verkoper_id=a.verkoperid ' +
        ' left join transactieartikel as ta on a.artikel_id=ta.artikelid ' +
        ' left join transactie as t on ta.transactieid=t.transactie_id ' +
        ' left join kassa as k on t.kassaid=k.kassa_id ' +
        ' left join betaalwijze as bw on bw.betaalwijze_id=t.betaalwijzeid ' +
        ' left join klant as kl on t.klantid=kl.klant_id ';

  FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
  FSqlBase:=sqlbase1 + fields + sqlbase2;

  FOrderByVerkopercode:=' order by v.verkopercode ';
  FOrderByKortingspercentage:=' order by ta.kortingsfactor ';
  FOrderByOngekorteprijs:=' order by a.prijs ';
  FOrderByGekorteprijs:=' order by a.prijs ';
  FOrderByTransactieid:=' order by t.transactie_id ';
  FOrderByBetaalwijze:=' order by bw.omschrijving ';
  FOrderByKassanr:=' order by k.kassanr ';

  FOrderByVerkopercodeDescAsc:=c_Asc;
  FOrderByKortingspercentageDescAsc:=c_Asc;
  FOrderByOngekorteprijsDescAsc:=c_Asc;
  FOrderByGekorteprijsDescAsc:=c_Asc;
  FOrderByTransactieidDescAsc:=c_Asc;
  FOrderByBetaalwijzeDescAsc:=c_Asc;
  FOrderByKassanrDescAsc:=c_Asc;

  btnInfo01.Hint:='Een overzicht van alle transacties voor ieder Inbrenger in de geselecteerde beurs.'+c_CR+c_ExportHint;
  btnExporteer.Hint:=btnInfo01.Hint;
  mmoExportQuery.Visible:=false;
end;

procedure TfrmOverzichtTransactiesPerVerkoper.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


procedure TfrmOverzichtTransactiesPerVerkoper.grdOverzichtTitleClick(
  Column: TColumn);
var
  sColname:string;
begin
  try
    Screen.Cursor:=crHourGlass;
    sColname:=AnsiLowercase(Column.FieldName);
    dmWobbel.vwOverzicht.Active:=false;
    dmWobbel.vwOverzicht.SQL.Clear;
    SetBasequery;
    if (sColname = 'inbrengercode') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercode);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkopercodeDescAsc);
      if (FOrderByVerkopercodeDescAsc = c_Asc) then
      begin
        FOrderByVerkopercodeDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByVerkopercodeDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString3)) or (sColname = AnsiLowercase(FcentString3)) or
             (sColname = AnsiLowercase(FeuroString4)) or (sColname = AnsiLowercase(FcentString4))
    ) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOngekorteprijs);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOngekorteprijsDescAsc);
      if (FOrderByOngekorteprijsDescAsc = c_Asc) then
      begin
        FOrderByOngekorteprijsDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByOngekorteprijsDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'klantid') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByTransactieid);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByTransactieidDescAsc);
      if (FOrderByTransactieidDescAsc = c_Asc) then
      begin
        FOrderByTransactieidDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByTransactieidDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString2)) or (sColname = AnsiLowercase(FcentString2))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKortingspercentage);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKortingspercentageDescAsc);
      if (FOrderByKortingspercentageDescAsc = c_Asc) then
      begin
        FOrderByKortingspercentageDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKortingspercentageDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'betaalwijze') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByBetaalwijze);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByBetaalwijzeDescAsc);
      if (FOrderByBetaalwijzeDescAsc = c_Asc) then
      begin
        FOrderByBetaalwijzeDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByBetaalwijzeDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'kassanr') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanr);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanrDescAsc);
      if (FOrderByKassanrDescAsc = c_Asc) then
      begin
        FOrderByKassanrDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKassanrDescAsc:=c_Asc;
      end;
    end;

    FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
    mmoExportQuery.Text:=FSql;

    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

end.

