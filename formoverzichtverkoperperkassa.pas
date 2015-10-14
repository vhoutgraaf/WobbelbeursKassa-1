unit formoverzichtverkoperperkassa;

{$mode objfpc}{$H+}

interface

uses
Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
c_Asc = ' Asc ';
c_Desc = ' Desc ';


type

  { TfrmOverzichtVerkoperPerKassa }

  TfrmOverzichtVerkoperPerKassa = class(TForm)
    btnExporteerOverzichtVerkoperPerKassa: TButton;
    btnInfo01: TBitBtn;
    btnToon: TButton;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblMunteenheid: TLabel;
    lblPgBar: TLabel;
    lblVerkoperPerKassaOverzichttitel: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pgBar: TProgressBar;
    pnlOverzichtVerkoperPerKassa: TPanel;
    procedure btnExporteerOverzichtVerkoperPerKassaClick(Sender: TObject);
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

    FeuroString3:string;
    FeuroString4:string;
    FeuroString5:string;

    FcentString3:string;
    FcentString4:string;
    FcentString5:string;

    FOrderByKassanr:string;
    FOrderByKassanrDescAsc:string;

    FOrderByVerkoperopbrengst:string;
    FOrderByVerkoperopbrengstDescAsc:string;

    FOrderByVerkopercode:string;
    FOrderByVerkopercodeDescAsc:string;

    FOrderByBetaalwijze:string;
    FOrderByBetaalwijzeDescAsc:string;

    FOrderByKassaOpmerkingen:string;
    FOrderByKassaOpmerkingenDescAsc:string;

  public
    { public declarations }
  end;

var
  frmOverzichtVerkoperPerKassa: TfrmOverzichtVerkoperPerKassa;

implementation

{$R *.lfm}

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt;

{ TfrmOverzichtVerkoperPerKassa }

procedure TfrmOverzichtVerkoperPerKassa.btnExporteerOverzichtVerkoperPerKassaClick
  (Sender: TObject);
begin
  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;
  pgBar.Visible:=true;
  lblPgBar.Visible:=true;

  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Opbrengst per inbrenger per kassa');
end;

procedure TfrmOverzichtVerkoperPerKassa.btnToonClick(Sender: TObject);
begin
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;

  dmWobbel.vwOverzicht.Active:=true;
end;

procedure TfrmOverzichtVerkoperPerKassa.chkGetallenMaalHonderdChange(
  Sender: TObject);
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

procedure TfrmOverzichtVerkoperPerKassa.FormActivate(Sender: TObject);
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

procedure TfrmOverzichtVerkoperPerKassa.SetBasequery;
var
  displayformat: string;
begin
  if (chkGetallenMaalHonderd.Checked) then
  begin
    lblMunteenheid.Visible:=true;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBaseInCenten);
    displayformat:='';

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

  end
  else
  begin
    lblMunteenheid.Visible:=false;
    dmWobbel.vwOverzicht.SQL.Append(FSqlBase);
    displayformat:='0.00';

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

  end;

end;


procedure TfrmOverzichtVerkoperPerKassa.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtVerkoperPerKassa.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FeuroString3:='Opbrengst (100%)';
  FeuroString4:='Opbrengst (75%)';
  FeuroString5:='Opbrengst (25%)';

  FcentString3:='CENTEN: Opbrengst (100%)';
  FcentString4:='CENTEN: Opbrengst (75%)';
  FcentString5:='CENTEN: Opbrengst (25%)';

  sqlbase1:=' select ' +
        ' b.datum as Beursdatum,  ' +
        ' k.kassanr, ' +
        ' v.verkopercode as inbrengercode, ';

  fieldsInCenten:=' cast(round(100*round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else va.verkoperopbrengst end,2),0) as int) as '''+FcentString3+''',  ' +
        ' cast(round(100*round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else va.verkoperopbrengst0.75 * va.verkoperopbrengst end,2),0) as int) as '''+FcentString4+''',  ' +
        ' cast(round(100*round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else 0.25 * va.verkoperopbrengst end,2),0) as int) as '''+FcentString5+''', ';

  fields:=' round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else va.verkoperopbrengst end,2) as '''+FeuroString3+''',  ' +
        ' round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else va.verkoperopbrengst0.75 * va.verkoperopbrengst end,2) as '''+FeuroString4+''',  ' +
        ' round(case when va.verkoperopbrengst is null or va.verkoperopbrengst = '''' then 0 else 0.25 * va.verkoperopbrengst end,2) as '''+FeuroString5+''', ';

  sqlbase2:=' n.aanhef as Aanhef, n.voorletters as Voorletters,n.tussenvoegsel as Tussenvoegsel,n.achternaam as Achternaam, ' +
        ' b.opmerkingen as Beursopmerkingen, k.opmerkingen as Kassaopmerkingen, '  +
        ' v.opmerkingen as Verkoperopmerkingen, ' +
        ' n.straat,n.huisnr,n.huisnrtoevoeging,n.postcode,n.woonplaats, ' +
        ' n.telefoonmobiel1,n.telefoonmobiel2,n.telefoonvast, n.email, ' +
        ' case when v.saldobetalingcontant = 1 then ''Ja'' else case when v.saldobetalingcontant is null then '''' else ''Nee'' end end as UitbetalingContant, ' +
        ' v.rekeningnummer, v.rekeningopnaam, v.rekeningbanknaam, v.rekeningplaats ' +
        ' from beurs as b ' +
        ' inner join kassa as k on k.beursid=b.beurs_id ' +
        ' left join ( ' +
        '       select ' +
        '       k.kassa_id, v.verkoper_id, sum(ta.kortingsfactor*a.prijs) as verkoperopbrengst ' +
        '       from verkoper as v ' +
        '       left join artikel as a on v.verkoper_id=a.verkoperid ' +
        '       left join transactieartikel as ta on a.artikel_id=ta.artikelid ' +
        '       left join transactie as t on ta.transactieid=t.transactie_id ' +
        '       left join kassa as k on t.kassaid=k.kassa_id ' +
        '       left join beurs as b on k.beursid=b.beurs_id ' +
        '       where b.isactief=1 and b.beurs_id is not null ' +
        '       group by k.kassa_id, v.verkoper_id ' +
        ' ) as va on va.kassa_id = k.kassa_id ' +
        ' left join verkoper as v on v.verkoper_id=va.verkoper_id ' +
        ' left join naw as n on n.naw_id=v.nawid ' +
        ' where b.isactief=1 ';

   FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
   FSqlBase:=sqlbase1 + fields + sqlbase2;

   FOrderByKassanr:=' order by k.kassanr ';
   FOrderByVerkopercode:=' order by v.verkopercode ';
   FOrderByVerkoperopbrengst:=' order by va.verkoperopbrengst ';
   FOrderByKassaOpmerkingen:=' order by kassaopmerkingen ';
   FOrderByBetaalwijze:=' order by betaalwijze ';



   FOrderByKassanrDescAsc:=c_Asc;
   FOrderByVerkopercodeDescAsc:=c_Asc;
   FOrderByVerkoperopbrengstDescAsc:=c_Asc;
   FOrderByKassaOpmerkingenDescAsc:=c_Asc;
   FOrderByBetaalwijzeDescAsc:=c_Asc;

   btnInfo01.Hint:='Een overzicht van alle Inbrengers en hun opbrengsten in de geselecteerde beurs, per kassa. '+c_CR+c_ExportHint;
   btnExporteerOverzichtVerkoperPerKassa.Hint:=btnInfo01.Hint;
   mmoExportQuery.Visible:=false;

end;

procedure TfrmOverzichtVerkoperPerKassa.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmOverzichtVerkoperPerKassa.grdOverzichtTitleClick
  (Column: TColumn);
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
             (sColname = AnsiLowercase(FeuroString4)) or (sColname = AnsiLowercase(FcentString4)) or
             (sColname = AnsiLowercase(FeuroString5)) or (sColname = AnsiLowercase(FcentString5))
    ) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkoperopbrengst);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByVerkoperopbrengstDescAsc);
      if (FOrderByVerkoperopbrengstDescAsc = c_Asc) then
      begin
        FOrderByVerkoperopbrengstDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByVerkoperopbrengstDescAsc:=c_Asc;
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
    else if (sColname = 'kassaopmerkingen') then
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

