unit formoverzichtbeurs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
  c_Asc = ' Asc ';
  c_Desc = ' Desc ';

type

  { TfrmOverzichtBeurs }

  TfrmOverzichtBeurs = class(TForm)
    btnExporteer: TButton;
    btnInfo01: TBitBtn;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblMunteenheid: TLabel;
    lblGrid: TLabel;
    lblPgBar: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pgBar: TProgressBar;
    pnlOverzichtBeurzen: TPanel;
    procedure btnExporteerClick(Sender: TObject);
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

    FeuroString1:string;
    FeuroString2:string;
    FeuroString3:string;
    FeuroString4:string;

    FcentString1:string;
    FcentString2:string;
    FcentString3:string;
    FcentString4:string;

    FOrderByOpbrengstTotaal:string;
    FOrderByOpbrengstTotaalDescAsc:string;

    FOrderByOpbrengstPin:string;
    FOrderByOpbrengstPinDescAsc:string;

    FOrderByOpbrengstContant:string;
    FOrderByOpbrengstContantDescAsc:string;

    FOrderByAantalKlanten:string;
    FOrderByAantalKlantenDescAsc:string;

    FOrderByAantalArtikelen:string;
    FOrderByAantalArtikelenDescAsc:string;

  public
    { public declarations }
  end;

var
  frmOverzichtBeurs: TfrmOverzichtBeurs;

implementation

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt;

{$R *.lfm}

{ TfrmOverzichtBeurs }

procedure TfrmOverzichtBeurs.FormActivate(Sender: TObject);
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
  dmWobbel.vwOverzicht.Active:=true;

  FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
  mmoExportQuery.Text:=FSql;

  pgBar.Position:=0;
  lblPgBar.Caption:='';
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;
end;

procedure TfrmOverzichtBeurs.btnExporteerClick(Sender: TObject);
var
  xlsname:string;
  goOn:boolean;
  fnameExt:string;
  fname:string;
begin
  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Opbrengst gehele Beurs');
end;

procedure TfrmOverzichtBeurs.chkGetallenMaalHonderdChange(Sender: TObject);
begin
  try
    Screen.Cursor:=crHourGlass;
    dmWobbel.vwOverzicht.Active:=false;
    dmWobbel.vwOverzicht.SQL.Clear;
    SetBasequery;
    FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);

    mmoExportQuery.Text:=FSql;
    dmWobbel.vwOverzicht.Active:=true;
  finally
    Screen.Cursor:=crDefault;
  end;
end;

procedure TfrmOverzichtBeurs.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtBeurs.SetBasequery;
var
  displayformat: string;begin
  if (chkGetallenMaalHonderd.Checked) then
  begin
    lblMunteenheid.Visible:=true;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBaseInCenten);
    displayformat:='';

    grdOverzicht.Columns.Items[1].DisplayName:=FcentString1;
    grdOverzicht.Columns.Items[1].Title.Caption:=FcentString1;
    grdOverzicht.Columns.Items[1].FieldName:=FcentString1;
    grdOverzicht.Columns.Items[1].DisplayFormat:=displayformat;

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

    grdOverzicht.Columns.Items[1].DisplayName:=FeuroString1;
    grdOverzicht.Columns.Items[1].Title.Caption:=FeuroString1;
    grdOverzicht.Columns.Items[1].FieldName:=FeuroString1;
    grdOverzicht.Columns.Items[1].DisplayFormat:=displayformat;

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


procedure TfrmOverzichtBeurs.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FeuroString1:='Opbrengst Totaal';
  FeuroString2:='Opbrengst Contant';
  FeuroString3:='Opbrengst Pin';
  FeuroString4:='Opbrengst Pin';

  FcentString1:='CENTEN: Opbrengst Totaal';
  FcentString2:='CENTEN: Opbrengst Contant';
  FcentString3:='CENTEN: Opbrengst Pin';
  FcentString4:='CENTEN: Opbrengst Creditcard';

  sqlbase1:=' select ' +
    ' b.datum as Beursdatum, ';

  fieldsInCenten:=' cast(round(100*round(case when vaTotaal.opbrengst is null or vaTotaal.opbrengst = '''' then 0 else vaTotaal.opbrengst end,2),0) as int) as '''+FcentString1+''', ' +
      ' cast(round(100*round(case when vaContant.opbrengst is null or vaContant.opbrengst = '''' then 0 else vaContant.opbrengst end,2),0) as int) as '''+FcentString2+''', ' +
      ' cast(round(100*round(case when vaPin.opbrengst is null or vaPin.opbrengst = '''' then 0 else vaPin.opbrengst end,2),0) as int) as '''+FcentString3+''', ' +
      ' cast(round(100*round(case when vaCC.opbrengst is null or vaCC.opbrengst = '''' then 0 else vaCC.opbrengst end,2),0) as int) as '''+FcentString4+''', ';

  fields:=' round(case when vaTotaal.opbrengst is null or vaTotaal.opbrengst = '''' then 0 else vaTotaal.opbrengst end,2) as '''+FeuroString1+''', ' +
      ' round(case when vaContant.opbrengst is null or vaContant.opbrengst = '''' then 0 else vaContant.opbrengst end,2) as '''+FeuroString2+''', ' +
      ' round(case when vaPin.opbrengst is null or vaPin.opbrengst = '''' then 0 else vaPin.opbrengst end,2) as '''+FeuroString3+''', ' +
      ' round(case when vaCC.opbrengst is null or vaCC.opbrengst = '''' then 0 else vaCC.opbrengst end,2) as '''+FeuroString4+''', ';

  sqlbase2:=' round(case when at.aantalartikelen is null or at.aantalartikelen = '''' then 0 else at.aantalartikelen end, 0) as ''Aantal artikelen'', ' +
      ' round(case when ak.aantalklanten is null or ak.aantalklanten = '''' then 0 else ak.aantalklanten end, 0) as ''Aantal klanten''' +
      ' from beurs as b  ' +
      ' left join (  ' +
      '       select  ' +
      '       b.beurs_id, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
      '       from verkoper as v  ' +
      '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
      '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
      '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null ' +
      '       group by b.beurs_id ' +
      ' ) as vaTotaal on vaTotaal.beurs_id = b.beurs_id  ' +
      ' left join (  ' +
      '       select  ' +
      '       b.beurs_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
      '       from verkoper as v  ' +
      '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
      '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
      '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
      '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''contant'' ' +
      '       group by b.beurs_id, bw.omschrijving  ' +
      ' ) as vaContant on vaContant.beurs_id = b.beurs_id  ' +
      ' left join (  ' +
      '       select  ' +
      '       b.beurs_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
      '       from verkoper as v  ' +
      '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
      '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
      '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
      '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''pin'' ' +
      '       group by b.beurs_id, bw.omschrijving  ' +
      ' ) as vaPin on vaPin.beurs_id = b.beurs_id  ' +
      ' left join (  ' +
      '       select  ' +
      '       b.beurs_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
      '       from verkoper as v  ' +
      '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
      '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
      '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
      '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''creditcard'' ' +
      '       group by b.beurs_id, bw.omschrijving  ' +
      ' ) as vaCC on vaCC.beurs_id = b.beurs_id  ' +
      ' left join ( ' +
      '       select  ' +
      '       b.beurs_id, count(a.artikel_id) as aantalartikelen  ' +
      '       from artikel as a  ' +
      '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
      '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null ' +
      '       group by b.beurs_id ' +
      ' ) as at on at.beurs_id=b.beurs_id ' +
      ' left join ( ' +
      '       select  ' +
      '       b.beurs_id, count(kl.klant_id) as aantalklanten  ' +
      '       from transactie as t  ' +
      '       left join klant as kl on kl.klant_id=t.klantid  ' +
      '       left join kassa as k on t.kassaid=k.kassa_id  ' +
      '       left join beurs as b on k.beursid=b.beurs_id  ' +
      '       where b.isactief=1 and b.beurs_id is not null ' +
      '       group by b.beurs_id ' +
      ' ) as ak on ak.beurs_id=b.beurs_id ' +
      ' where b.isactief=1 ';

  FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
  FSqlBase:=sqlbase1 + fields + sqlbase2;

  FOrderByOpbrengstTotaal:=' order by vaTotaal.opbrengst ';
  FOrderByOpbrengstPin:=' order by vaPin.opbrengst ';
  FOrderByOpbrengstContant:=' order by vaContant.opbrengst ';
  FOrderByAantalKlanten:=' order by ak.aantalklanten ';
  FOrderByAantalArtikelen:=' order by at.aantalartikelen ';

  FOrderByOpbrengstTotaalDescAsc:=c_Asc;
  FOrderByOpbrengstPinDescAsc:=c_Asc;
  FOrderByOpbrengstContantDescAsc:=c_Asc;
  FOrderByAantalKlantenDescAsc:=c_Asc;
  FOrderByAantalArtikelenDescAsc:=c_Asc;

  btnInfo01.Hint:='Een overzicht van de geselecteerde beurs.'+c_CR+c_ExportHint;
  btnExporteer.Hint:=btnInfo01.Hint;
  mmoExportQuery.Visible:=false;
end;

procedure TfrmOverzichtBeurs.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmOverzichtBeurs.grdOverzichtTitleClick(Column: TColumn);
var
  sColname:string;
begin
  try
    Screen.Cursor:=crHourGlass;
    sColname:=AnsiLowercase(Column.FieldName);
    dmWobbel.vwOverzicht.Active:=false;
    dmWobbel.vwOverzicht.SQL.Clear;
    SetBasequery;
    if ((sColname = AnsiLowercase(FeuroString1)) or (sColname = AnsiLowercase(FcentString1))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstTotaal);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstTotaalDescAsc);
      if (FOrderByOpbrengstTotaalDescAsc = c_Asc) then
      begin
        FOrderByOpbrengstTotaalDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByOpbrengstTotaalDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString2)) or (sColname = AnsiLowercase(FcentString2))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstContant);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstContantDescAsc);
      if (FOrderByOpbrengstContantDescAsc = c_Asc) then
      begin
        FOrderByOpbrengstContantDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByOpbrengstContantDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString3)) or (sColname = AnsiLowercase(FcentString3))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstPin);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOpbrengstPinDescAsc);
      if (FOrderByOpbrengstPinDescAsc = c_Asc) then
      begin
        FOrderByOpbrengstPinDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByOpbrengstPinDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'aantal klanten') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByAantalKlanten);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByAantalKlantenDescAsc);
      if (FOrderByAantalKlantenDescAsc = c_Asc) then
      begin
        FOrderByAantalKlantenDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByAantalKlantenDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'aantal artikelen') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByAantalArtikelen);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByAantalArtikelenDescAsc);
      if (FOrderByAantalArtikelenDescAsc = c_Asc) then
      begin
        FOrderByAantalArtikelenDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByAantalArtikelenDescAsc:=c_Asc;
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

