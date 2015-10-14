unit formoverzichttotaalexport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
  c_Asc = ' Asc ';
  c_Desc = ' Desc ';

type

  { TfrmOverzichtTotaalExport }

  TfrmOverzichtTotaalExport = class(TForm)
    btnExporteer: TButton;
    btnInfo01: TBitBtn;
    btnToon: TButton;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblMunteenheid: TLabel;
    lblPgBar: TLabel;
    lblGrid: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pnlOverzicht: TPanel;
    pgBar: TProgressBar;
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

    FeuroString4:string;
    FeuroString5:string;
    FeuroString6:string;

    FcentString4:string;
    FcentString5:string;
    FcentString6:string;

    FOrderByVerkopercode:string;
    FOrderByVerkopercodeDescAsc:string;

    FOrderByKassanr:string;
    FOrderByKassanrDescAsc:string;

    FOrderByKortingspercentage:string;
    FOrderByKortingspercentageDescAsc:string;

    FOrderByArtikelprijs:string;
    FOrderByArtikelprijsDescAsc:string;

    FOrderByTransactieid:string;
    FOrderByTransactieidDescAsc:string;

    FOrderByBetaalwijze:string;
    FOrderByBetaalwijzeDescAsc:string;

  public
    { public declarations }
  end;

var
  frmOverzichtTotaalExport: TfrmOverzichtTotaalExport;

implementation

{$R *.lfm}

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt,
  db;

{ TfrmOverzichtTotaalExport }

procedure TfrmOverzichtTotaalExport.FormActivate(Sender: TObject);
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
  dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanr);
  dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanrDescAsc);
  FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
  mmoExportQuery.Text:=FSql;
  //dmWobbel.vwOverzicht.Active:=true;

  pgBar.Position:=0;
  lblPgBar.Caption:='';
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;
end;

procedure TfrmOverzichtTotaalExport.SetBasequery;
var
  displayformat: string;
begin
  if (chkGetallenMaalHonderd.Checked) then
  begin
    lblMunteenheid.Visible:=true;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBaseInCenten);
    displayformat:='';

    grdOverzicht.Columns.Items[4].DisplayName:=FcentString4;
    grdOverzicht.Columns.Items[4].Title.Caption:=FcentString4;
    grdOverzicht.Columns.Items[4].FieldName:=FcentString4;
    grdOverzicht.Columns.Items[4].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[5].DisplayName:=FcentString5;
    grdOverzicht.Columns.Items[5].Title.Caption:=FcentString5;
    grdOverzicht.Columns.Items[5].FieldName:=FcentString5;
    grdOverzicht.Columns.Items[5].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[6].DisplayName:=FcentString6;
    grdOverzicht.Columns.Items[6].Title.Caption:=FcentString6;
    grdOverzicht.Columns.Items[6].FieldName:=FcentString6;
    grdOverzicht.Columns.Items[6].DisplayFormat:=displayformat;

  end
  else
  begin
    lblMunteenheid.Visible:=false;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBase);
    displayformat:='0.00';

    grdOverzicht.Columns.Items[4].DisplayName:=FeuroString4;
    grdOverzicht.Columns.Items[4].Title.Caption:=FeuroString4;
    grdOverzicht.Columns.Items[4].FieldName:=FeuroString4;
    grdOverzicht.Columns.Items[4].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[5].DisplayName:=FeuroString5;
    grdOverzicht.Columns.Items[5].Title.Caption:=FeuroString5;
    grdOverzicht.Columns.Items[5].FieldName:=FeuroString5;
    grdOverzicht.Columns.Items[5].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[6].DisplayName:=FeuroString6;
    grdOverzicht.Columns.Items[6].Title.Caption:=FeuroString6;
    grdOverzicht.Columns.Items[6].FieldName:=FeuroString6;
    grdOverzicht.Columns.Items[6].DisplayFormat:=displayformat;
  end;
end;

procedure TfrmOverzichtTotaalExport.btnExporteerClick(Sender: TObject);
begin
  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;
  pgBar.Visible:=true;
  lblPgBar.Visible:=true;

  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Totaal export');
end;

procedure TfrmOverzichtTotaalExport.btnToonClick(Sender: TObject);
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

procedure TfrmOverzichtTotaalExport.chkGetallenMaalHonderdChange(Sender: TObject);
begin
  try
    Screen.Cursor:=crHourGlass;
    dmWobbel.vwOverzicht.Active:=false;
    dmWobbel.vwOverzicht.SQL.Clear;
    SetBasequery;
    dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanr);
    dmWobbel.vwOverzicht.SQL.Append(FOrderByKassanrDescAsc);
    FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);

    mmoExportQuery.Text:=FSql;
    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TfrmOverzichtTotaalExport.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtTotaalExport.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FeuroString4:='Kortingspercentage';
  FeuroString5:='Artikelprijs zonder korting';
  FeuroString6:='Artikelprijs bij verkoop';

  FcentString4:='CENTEN: Kortingspercentage';
  FcentString5:='CENTEN: Artikelprijs zonder korting';
  FcentString6:='CENTEN: Artikelprijs bij verkoop';

  sqlbase1:=' select ' +
    ' b.datum as Beursdatum, ' +
    ' k.kassanr as Kassanr,  ' +
    ' va.Inbrengercode as Inbrengercode, va.klantid as Klantid,  ';

  // N.B. veldnamen mogen niet veranderen anders worden ze niet in het grid getoond
  fieldsInCenten:=' cast(round(100*round(case when va.kortingspercentage is null or va.kortingspercentage = '''' then 0 else va.kortingspercentage end, 2),0) as int) as '''+FcentString4+''', ' +
    ' cast(round(100*round(case when va.ArtikelprijsZonderKorting is null or va.ArtikelprijsZonderKorting = '''' then 0 else va.ArtikelprijsZonderKorting end, 2),0) as int) as '''+FcentString5+''', ' +
    ' cast(round(100*round(case when va.ArtikelprijsVerkocht is null or va.ArtikelprijsVerkocht = '''' then 0 else va.ArtikelprijsVerkocht end, 2),0) as int) as '''+FcentString6+''', ';

  fields:=' round(case when va.kortingspercentage is null or va.kortingspercentage = '''' then 0 else va.kortingspercentage end, 0) as '''+FeuroString4+''', ' +
  ' round(case when va.ArtikelprijsZonderKorting is null or va.ArtikelprijsZonderKorting = '''' then 0 else va.ArtikelprijsZonderKorting end, 2) as '''+FeuroString5+''', ' +
  ' round(case when va.ArtikelprijsVerkocht is null or va.ArtikelprijsVerkocht = '''' then 0 else va.ArtikelprijsVerkocht end, 2) as '''+FeuroString6+''',  ';

  sqlbase2:=' va.betaalwijze as Betaalwijze, ' +
    ' va.Aanhef, va.Voorletters,va.tussenvoegsel,va.achternaam,  ' +
    ' va.straat,va.huisnr,va.huisnrtoevoeging,va.postcode,va.woonplaats,  ' +
    ' va.telefoonmobiel1,va.telefoonmobiel2,va.telefoonvast, va.email,  ' +
    ' va.rekeningnummer, va.rekeningopnaam, va.rekeningbanknaam, va.rekeningplaats,  ' +
    ' va.transactie_invoertijd, ' +
    ' va.beursopmerkingen as ''Opmerkingen Beurs'', ' +
    ' va.kassaopmerkingen as ''Opmerkingen Kassa'' ' +
    ' from beurs as b ' +
    ' left join kassa as k on k.beursid=b.beurs_id ' +
    ' left join ( ' +
    ' 	select  ' +
    ' 	k.kassa_id, ' +
    ' 	v.verkopercode as Inbrengercode, ' +
    ' 	t.transactie_id as klantid,  ' +
    ' 	100.0*(1.0-ta.kortingsfactor) as kortingspercentage, a.prijs as ArtikelprijsZonderKorting, ta.kortingsfactor*a.prijs as ArtikelprijsVerkocht,  ' +
    ' 	bw.omschrijving as betaalwijze, ' +
    ' 	n.aanhef as Aanhef, n.voorletters as Voorletters,n.tussenvoegsel,n.achternaam,  ' +
    ' 	n.straat,n.huisnr,n.huisnrtoevoeging,n.postcode,n.woonplaats,  ' +
    ' 	n.telefoonmobiel1,n.telefoonmobiel2,n.telefoonvast, n.email,  ' +
    ' 	v.rekeningnummer, v.rekeningopnaam, v.rekeningbanknaam, v.rekeningplaats,  ' +
    ' 	t.datumtijdinvoer as transactie_invoertijd, ' +
    ' 	b.opmerkingen as beursopmerkingen, ' +
    ' 	k.opmerkingen as kassaopmerkingen ' +
    ' 	from verkoper as v  ' +
    ' 	left join naw as n on n.naw_id=v.nawid  ' +
    ' 	left join artikel as a on v.verkoper_id=a.verkoperid  ' +
    ' 	left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
    ' 	left join transactie as t on ta.transactieid=t.transactie_id  ' +
    ' 	left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id ' +
    ' 	left join kassa as k on t.kassaid=k.kassa_id   ' +
    ' 	left join beurs as b on k.beursid=b.beurs_id   ' +
    ' 	where b.isactief=1 and b.beurs_id is not null ' +
    ' ) as va on va.kassa_id=k.kassa_id ' +
    ' where b.isactief=1 ';

  FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
  FSqlBase:=sqlbase1 + fields + sqlbase2;

  FOrderByVerkopercode:=' order by va.Inbrengercode ';
  FOrderByKassanr:=' order by k.kassanr ';
  FOrderByArtikelprijs:=' order by va.ArtikelprijsZonderKorting ';
  FOrderByTransactieid:=' order by va.klantid ';
  FOrderByBetaalwijze:=' order by va.betaalwijze ';
  FOrderByKortingspercentage:=' order by va.kortingspercentage ';

  FOrderByVerkopercodeDescAsc:=c_Asc;
  FOrderByKassanrDescAsc:=c_Asc;
  FOrderByArtikelprijsDescAsc:=c_Asc;
  FOrderByTransactieidDescAsc:=c_Asc;
  FOrderByBetaalwijzeDescAsc:=c_Asc;

  btnInfo01.Hint:='Een overzicht van alle transacties, inclusief de artikelen, in de geselecteerde beurs.'+c_CR+c_ExportHint;
  btnExporteer.Hint:=btnInfo01.Hint;
  mmoExportQuery.Visible:=false;
end;

procedure TfrmOverzichtTotaalExport.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmOverzichtTotaalExport.grdOverzichtTitleClick(Column: TColumn);
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
    end
    else if ((sColname = AnsiLowercase(FeuroString5)) or (sColname = AnsiLowercase(FcentString5)) or
             (sColname = AnsiLowercase(FeuroString6)) or (sColname = AnsiLowercase(FcentString6))
    ) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByArtikelprijs);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByArtikelprijsDescAsc);
      if (FOrderByArtikelprijsDescAsc = c_Asc) then
      begin
        FOrderByArtikelprijsDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByArtikelprijsDescAsc:=c_Asc;
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
    else if ((sColname = AnsiLowercase(FeuroString4)) or (sColname = AnsiLowercase(FcentString4))) then
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
    end;

    FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
    mmoExportQuery.Text:=FSql;

    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

end.

