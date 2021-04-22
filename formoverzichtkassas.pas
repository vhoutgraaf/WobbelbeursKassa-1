unit formoverzichtkassas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
  c_Asc = ' Asc ';
  c_Desc = ' Desc ';


type

  { TfrmOverzichtKassas }

  TfrmOverzichtKassas = class(TForm)
    btnExporteerOverzichtKassas: TButton;
    btnInfo01: TBitBtn;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblKassastitel: TLabel;
    lblMunteenheid: TLabel;
    lblPgBar: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pgBar: TProgressBar;
    pnlOverzichtKassas: TPanel;
    procedure btnExporteerOverzichtKassasClick(Sender: TObject);
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
    FeuroString5:string;
    FeuroString6:string;
    FeuroString7:string;
    FeuroString8:string;

    FcentString2:string;
    FcentString3:string;
    FcentString4:string;
    FcentString5:string;
    FcentString6:string;
    FcentString7:string;
    FcentString8:string;

    FOrderByKassanr:string;
    FOrderByKassanrDescAsc:string;

    FOrderByOpbrengstTotaal:string;
    FOrderByOpbrengstTotaalDescAsc:string;

    FOrderByOpbrengstPin:string;
    FOrderByOpbrengstPinDescAsc:string;

    FOrderByOpbrengstContant:string;
    FOrderByOpbrengstContantDescAsc:string;

    FOrderByKassaverschil:string;
    FOrderByKassaverschilDescAsc:string;

    FOrderByAantalKlanten:string;
    FOrderByAantalKlantenDescAsc:string;

    FOrderByAantalArtikelen:string;
    FOrderByAantalArtikelenDescAsc:string;

    FOrderByKassabedragBegin:string;
    FOrderByKassabedragBeginDescAsc:string;

    FOrderByKassabedragEinde:string;
    FOrderByKassabedragEindeDescAsc:string;

    FOrderByKassaOpmerkingen:string;
    FOrderByKassaOpmerkingenDescAsc:string;

  public
    { public declarations }
  end;

var
  frmOverzichtKassas: TfrmOverzichtKassas;

implementation

{$R *.lfm}

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt;

{ TfrmOverzichtKassas }

procedure TfrmOverzichtKassas.FormActivate(Sender: TObject);
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
  dmWobbel.vwOverzicht.Active:=true;

  FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
  mmoExportQuery.Text:=FSql;

  pgBar.Position:=0;
  lblPgBar.Caption:='';
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;

end;

procedure TfrmOverzichtKassas.btnExporteerOverzichtKassasClick(
  Sender: TObject);
var
  xlsname:string;
  goOn:boolean;
  fnameExt:string;
  fname:string;
begin
  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Opbrengst per Kassa');
end;

procedure TfrmOverzichtKassas.chkGetallenMaalHonderdChange(Sender: TObject);
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

procedure TfrmOverzichtKassas.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtKassas.SetBasequery;
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

    grdOverzicht.Columns.Items[5].DisplayName:=FcentString5;
    grdOverzicht.Columns.Items[5].Title.Caption:=FcentString5;
    grdOverzicht.Columns.Items[5].FieldName:=FcentString5;
    grdOverzicht.Columns.Items[5].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[6].DisplayName:=FcentString6;
    grdOverzicht.Columns.Items[6].Title.Caption:=FcentString6;
    grdOverzicht.Columns.Items[6].FieldName:=FcentString6;
    grdOverzicht.Columns.Items[6].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[7].DisplayName:=FcentString7;
    grdOverzicht.Columns.Items[7].Title.Caption:=FcentString7;
    grdOverzicht.Columns.Items[7].FieldName:=FcentString7;
    grdOverzicht.Columns.Items[7].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[8].DisplayName:=FcentString8;
    grdOverzicht.Columns.Items[8].Title.Caption:=FcentString8;
    grdOverzicht.Columns.Items[8].FieldName:=FcentString8;
    grdOverzicht.Columns.Items[8].DisplayFormat:=displayformat;

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

    grdOverzicht.Columns.Items[5].DisplayName:=FeuroString5;
    grdOverzicht.Columns.Items[5].Title.Caption:=FeuroString5;
    grdOverzicht.Columns.Items[5].FieldName:=FeuroString5;
    grdOverzicht.Columns.Items[5].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[6].DisplayName:=FeuroString6;
    grdOverzicht.Columns.Items[6].Title.Caption:=FeuroString6;
    grdOverzicht.Columns.Items[6].FieldName:=FeuroString6;
    grdOverzicht.Columns.Items[6].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[7].DisplayName:=FeuroString7;
    grdOverzicht.Columns.Items[7].Title.Caption:=FeuroString7;
    grdOverzicht.Columns.Items[7].FieldName:=FeuroString7;
    grdOverzicht.Columns.Items[7].DisplayFormat:=displayformat;

    grdOverzicht.Columns.Items[8].DisplayName:=FeuroString8;
    grdOverzicht.Columns.Items[8].Title.Caption:=FeuroString8;
    grdOverzicht.Columns.Items[8].FieldName:=FeuroString8;
    grdOverzicht.Columns.Items[8].DisplayFormat:=displayformat;

  end;

end;


procedure TfrmOverzichtKassas.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FeuroString2:='Opbrengst Totaal';
  FeuroString3:='Opbrengst Contant';
  FeuroString4:='Opbrengst Pin';
  FeuroString5:='Opbrengst Creditcard';
  FeuroString6:='Contant in kassa (begin)';
  FeuroString7:='Contant in kassa (einde)';
  FeuroString8:='Kassaverschil';

  FcentString2:='CENTEN: Opbrengst Totaal';
  FcentString3:='CENTEN: Opbrengst Contant';
  FcentString4:='CENTEN: Opbrengst Pin';
  FcentString5:='CENTEN: Opbrengst Creditcard';
  FcentString6:='CENTEN: Contant in kassa (begin)';
  FcentString7:='CENTEN: Contant in kassa (einde)';
  FcentString8:='CENTEN: Kassaverschil';

  sqlbase1:=' select ' +
    ' b.datum as Beursdatum, ' +
    ' k.kassanr as Kassanr, ';

  fieldsInCenten:=' cast(round(100*round(case when vaTotaal.opbrengst is null or vaTotaal.opbrengst = '''' then 0 else vaTotaal.opbrengst end,2),0) as int) as '''+FcentString2+''', ' +
       ' cast(round(100*round(case when vaContant.opbrengst is null or vaContant.opbrengst = '''' then 0 else vaContant.opbrengst end,2),0) as int) as '''+FcentString3+''', ' +
       ' cast(round(100*round(case when vaPin.opbrengst is null or vaPin.opbrengst = '''' then 0 else vaPin.opbrengst end,2),0) as int) as '''+FcentString4+''', ' +
       ' cast(round(100*round(case when vaCC.opbrengst is null or vaCC.opbrengst = '''' then 0 else vaCC.opbrengst end,2),0) as int) as '''+FcentString5+''', ' +
       ' cast(round(100*round(case when kbopensluit.kassaopenbedrag is null or kbopensluit.kassaopenbedrag = '''' then 0 else kbopensluit.kassaopenbedrag end,2),0) as int) as '''+FcentString6+''',  ' +
       ' cast(round(100*round(case when kbopensluit.kassasluitbedrag is null or kbopensluit.kassasluitbedrag = '''' then 0 else kbopensluit.kassasluitbedrag end,2),0) as int) as '''+FcentString7+''',  ' +
       ' cast(round(100*round(case when kbopensluit.kassasluitbedrag is null or kbopensluit.kassaopenbedrag is null or vaContant.opbrengst is null or kbopensluit.kassasluitbedrag = '''' or kbopensluit.kassaopenbedrag = '''' or vaContant.opbrengst = '''' then 0 else kbopensluit.kassasluitbedrag - kbopensluit.kassaopenbedrag - vaContant.opbrengst end,2),0) as int) as '''+FcentString8+''', ';

  fields:=' round(case when vaTotaal.opbrengst is null or vaTotaal.opbrengst = '''' then 0 else vaTotaal.opbrengst end,2) as '''+FeuroString2+''', ' +
       ' round(case when vaContant.opbrengst is null or vaContant.opbrengst = '''' then 0 else vaContant.opbrengst end,2) as '''+FeuroString3+''', ' +
       ' round(case when vaPin.opbrengst is null or vaPin.opbrengst = '''' then 0 else vaPin.opbrengst end,2) as '''+FeuroString4+''', ' +
       ' round(case when vaCC.opbrengst is null or vaCC.opbrengst = '''' then 0 else vaCC.opbrengst end,2) as '''+FeuroString5+''', ' +
       ' round(case when kbopensluit.kassaopenbedrag is null or kbopensluit.kassaopenbedrag = '''' then 0 else kbopensluit.kassaopenbedrag end,2) as '''+FeuroString6+''',  ' +
       ' round(case when kbopensluit.kassasluitbedrag is null or kbopensluit.kassasluitbedrag = '''' then 0 else kbopensluit.kassasluitbedrag end,2) as '''+FeuroString7+''',  ' +
       ' round(case when kbopensluit.kassasluitbedrag is null or kbopensluit.kassaopenbedrag is null or vaContant.opbrengst is null or kbopensluit.kassasluitbedrag = '''' or kbopensluit.kassaopenbedrag = '''' or vaContant.opbrengst = '''' then 0 else kbopensluit.kassasluitbedrag - kbopensluit.kassaopenbedrag - vaContant.opbrengst end,2) as '''+FeuroString8+''', ';

  sqlbase2:=' round(case when at.aantalartikelen is null or at.aantalartikelen = '''' then 0 else at.aantalartikelen end, 0) as ''Aantal artikelen'', ' +
       ' round(case when ak.aantalklanten is null or ak.aantalklanten = '''' then 0 else ak.aantalklanten end, 0) as ''Aantal klanten'', ' +
       ' k.opmerkingen as ''Kassa - opmerkingen'', ' +
       ' kbopensluit.kassaopenopmerkingen as ''Opmerkingen Contant in kassa (begin)'', kbopensluit.kassasluitopmerkingen as ''Opmerkingen Contant in kassa (einde)'' ' +
       ' from beurs as b  ' +
       ' inner join kassa as k on k.beursid=b.beurs_id  ' +
       ' left join (  ' +
       '       select  ' +
       '       k.kassa_id, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
       '       from verkoper as v  ' +
       '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
       '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
       '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null ' +
       '       group by k.kassa_id ' +
       ' ) as vaTotaal on vaTotaal.kassa_id = k.kassa_id  ' +
       ' left join (  ' +
       '       select  ' +
       '       k.kassa_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
       '       from verkoper as v  ' +
       '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
       '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
       '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
       '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''contant'' ' +
       '       group by k.kassa_id, bw.omschrijving  ' +
       ' ) as vaContant on vaContant.kassa_id = k.kassa_id  ' +
       ' left join (  ' +
       '       select  ' +
       '       k.kassa_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
       '       from verkoper as v  ' +
       '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
       '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
       '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
       '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''pin'' ' +
       '       group by k.kassa_id, bw.omschrijving  ' +
       ' ) as vaPin on vaPin.kassa_id = k.kassa_id  ' +
       ' left join (  ' +
       '       select  ' +
       '       k.kassa_id, bw.omschrijving as betaalwijze, sum(ta.kortingsfactor*a.prijs) as opbrengst  ' +
       '       from verkoper as v  ' +
       '       left join artikel as a on v.verkoper_id=a.verkoperid  ' +
       '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
       '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
       '       left join betaalwijze as bw on t.betaalwijzeid=bw.betaalwijze_id  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null and bw.omschrijving=''creditcard'' ' +
       '       group by k.kassa_id, bw.omschrijving  ' +
       ' ) as vaCC on vaCC.kassa_id = k.kassa_id  ' +
       ' left join ( ' +
       ' 	select  ' +
       ' 	k.kassa_id, ' +
       ' 	1.0*kbopen.totaalbedrag as kassaopenbedrag, kbopen.opmerkingen as kassaopenopmerkingen, ' +
       ' 	1.0*kbsluit.totaalbedrag as kassasluitbedrag, kbsluit.opmerkingen as kassasluitopmerkingen ' +
       ' 	from  ' +
       ' 	kassa as k ' +
       ' 	left join kassabedrag as kbsluit on (kbsluit.kassabedrag_id = (select kassabedragid from kassaopensluit where datumtijd=(select max(kkos.datumtijd) from kassaopensluit as kkos inner join kassabedrag as kkb on (kkos.kassabedragid=kkb.kassabedrag_id and kkb.totaalbedrag != 0)  where kkos.kassaid=k.kassa_id and kkos.kassastatusid=2))) ' +
       ' 	left join kassabedrag as kbopen on  (kbopen.kassabedrag_id =  (select kassabedragid from kassaopensluit where datumtijd=(select min(kkos.datumtijd) from kassaopensluit as kkos inner join kassabedrag as kkb on (kkos.kassabedragid=kkb.kassabedrag_id and kkb.totaalbedrag != 0)  where kkos.kassaid=k.kassa_id and kkos.kassastatusid=1))) ' +
       ' ) as kbopensluit on kbopensluit.kassa_id=k.kassa_id ' +
       ' left join ( ' +
       '       select  ' +
       '       k.kassa_id, count(a.artikel_id) as aantalartikelen  ' +
       '       from artikel as a  ' +
       '       left join transactieartikel as ta on a.artikel_id=ta.artikelid  ' +
       '       left join transactie as t on ta.transactieid=t.transactie_id  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null ' +
       '       group by k.kassa_id ' +
       ' ) as at on at.kassa_id=k.kassa_id ' +
       ' left join ( ' +
       '       select  ' +
       '       k.kassa_id, count(kl.klant_id) as aantalklanten  ' +
       '       from transactie as t  ' +
       '       left join klant as kl on kl.klant_id=t.klantid  ' +
       '       left join kassa as k on t.kassaid=k.kassa_id  ' +
       '       left join beurs as b on k.beursid=b.beurs_id  ' +
       '       where b.isactief=1 and b.beurs_id is not null ' +
       '       group by k.kassa_id ' +
       ' ) as ak on ak.kassa_id=k.kassa_id ' +
       ' where b.isactief=1 ';

   FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
   FSqlBase:=sqlbase1 + fields + sqlbase2;

   FOrderByKassanr:=' order by k.kassanr ';
   FOrderByOpbrengstTotaal:=' order by vaTotaal.opbrengst ';
   FOrderByOpbrengstPin:=' order by vaPin.opbrengst ';
   FOrderByOpbrengstContant:=' order by vaContant.opbrengst ';
   FOrderByKassaverschil:=' order by case when kbopensluit.kassasluitbedrag is null or kbopensluit.kassaopenbedrag is null or vaContant.opbrengst is null or kbopensluit.kassasluitbedrag = '''' or kbopensluit.kassaopenbedrag = '''' or vaContant.opbrengst = '''' then 0 else kbopensluit.kassasluitbedrag - kbopensluit.kassaopenbedrag - vaContant.opbrengst end ';
   FOrderByAantalKlanten:=' order by ak.aantalklanten ';
   FOrderByAantalArtikelen:=' order by at.aantalartikelen ';
   FOrderByKassaOpmerkingen:=' order by k.opmerkingen ';
   FOrderByKassabedragBegin:=' order by kbopensluit.kassaopenbedrag ';
   FOrderByKassabedragEinde:=' order by kbopensluit.kassasluitbedrag ';

   FOrderByKassanrDescAsc:=c_Asc;
   FOrderByOpbrengstTotaalDescAsc:=c_Asc;
   FOrderByOpbrengstPinDescAsc:=c_Asc;
   FOrderByOpbrengstContantDescAsc:=c_Asc;
   FOrderByKassaverschilDescAsc:=c_Asc;
   FOrderByAantalKlantenDescAsc:=c_Asc;
   FOrderByAantalArtikelenDescAsc:=c_Asc;
   FOrderByKassaOpmerkingenDescAsc:=c_Asc;
   FOrderByKassabedragBeginDescAsc:=c_Asc;
   FOrderByKassabedragEindeDescAsc:=c_Asc;

   btnInfo01.Hint:='Een overzicht van alle kassa''s in de geselecteerde beurs.  '+c_CR+c_ExportHint;
   btnExporteerOverzichtKassas.Hint:=btnInfo01.Hint;
   mmoExportQuery.Visible:=false;
end;

procedure TfrmOverzichtKassas.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmOverzichtKassas.grdOverzichtTitleClick(
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

    if ((sColname = AnsiLowercase(FeuroString2)) or (sColname = AnsiLowercase(FcentString2))) then
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
    else if ((sColname = AnsiLowercase(FeuroString3)) or (sColname = AnsiLowercase(FcentString3))) then
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
    else if ((sColname = AnsiLowercase(FeuroString4)) or (sColname = AnsiLowercase(FcentString4))) then
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
    else if ((sColname = AnsiLowercase(FeuroString8)) or (sColname = AnsiLowercase(FcentString8))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassaverschil);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassaverschilDescAsc);
      if (FOrderByKassaverschilDescAsc = c_Asc) then
      begin
        FOrderByKassaverschilDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKassaverschilDescAsc:=c_Asc;
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
    else if ((sColname = AnsiLowercase(FeuroString6)) or (sColname = AnsiLowercase(FcentString6))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassabedragBegin);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassabedragBeginDescAsc);
      if (FOrderByKassabedragBeginDescAsc = c_Asc) then
      begin
        FOrderByKassabedragBeginDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKassabedragBeginDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString7)) or (sColname = AnsiLowercase(FcentString7))) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassabedragEinde);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassabedragEindeDescAsc);
      if (FOrderByKassabedragEindeDescAsc = c_Asc) then
      begin
        FOrderByKassabedragEindeDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKassabedragEindeDescAsc:=c_Asc;
      end;
    end
    else if (sColname = 'kassa - opmerkingen') then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassaOpmerkingen);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByKassaOpmerkingenDescAsc);
      if (FOrderByKassaOpmerkingenDescAsc = c_Asc) then
      begin
        FOrderByKassaOpmerkingenDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByKassaOpmerkingenDescAsc:=c_Asc;
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

