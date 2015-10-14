unit formoverzichtverkopers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBGrids, DbCtrls, Buttons, ComCtrls;

const
  c_Asc = ' Asc ';
  c_Desc = ' Desc ';

type

  { TfrmOverzichtVerkopers }

  TfrmOverzichtVerkopers = class(TForm)
    btnExporteerOverzichtVerkopers: TButton;
    btnInfo01: TBitBtn;
    btnToon: TButton;
    chkGetallenMaalHonderd: TCheckBox;
    grdOverzicht: TDBGrid;
    lblMunteenheid: TLabel;
    lblPgBar: TLabel;
    lblVerkoperoverzichttitel: TLabel;
    mmoExportQuery: TMemo;
    navOverzicht: TDBNavigator;
    pgBar: TProgressBar;
    pnlOverzichtVerkopers: TPanel;
    procedure btnExporteerOverzichtVerkopersClick(Sender: TObject);
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
    FeuroString5:string;
    FeuroString6:string;

    FcentString2:string;
    FcentString3:string;
    FcentString4:string;
    FcentString5:string;
    FcentString6:string;

    FOrderByVerkopercode:string;
    FOrderByVerkopercodeDescAsc:string;

    FOrderByOngekorteopbrengst:string;
    FOrderByOngekorteopbrengstDescAsc:string;

    FOrderByGekorteopbrengst:string;
    FOrderByGekorteopbrengstDescAsc:string;

  public
    { public declarations }
  end;

var
  frmOverzichtVerkopers: TfrmOverzichtVerkopers;

implementation

{$R *.lfm}

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  m_error, crt;

{ TfrmOverzichtVerkopers }

procedure TfrmOverzichtVerkopers.FormActivate(Sender: TObject);
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

  FSql:=string(dmWobbel.vwOverzicht.SQL.GetText);
  mmoExportQuery.Text:=FSql;

  pgBar.Position:=0;
  lblPgBar.Caption:='';
  pgBar.Visible:=false;
  lblPgBar.Visible:=false;

  //dmWobbel.vwOverzicht.Active:=true;
end;

procedure TfrmOverzichtVerkopers.btnExporteerOverzichtVerkopersClick(
  Sender: TObject);
var
  xlsname:string;
  goOn:boolean;
  fnameExt:string;
  fname:string;
begin
  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;
  pgBar.Visible:=true;
  lblPgBar.Visible:=true;

  mmoExportQuery.Text:=FSql;
  pgBar.Position:=0;
  m_tools.ExporteerQuery(pgBar, lblPgBar, FSQL, 'Opbrengst per inbrenger');
end;

procedure TfrmOverzichtVerkopers.btnToonClick(Sender: TObject);
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

procedure TfrmOverzichtVerkopers.chkGetallenMaalHonderdChange(Sender: TObject);
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

procedure TfrmOverzichtVerkopers.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmOverzichtVerkopers.SetBasequery;
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

  end;
end;


procedure TfrmOverzichtVerkopers.FormCreate(Sender: TObject);
var
  sqlbase1, sqlbase2:string;
  fieldsInCenten, fields: string;
begin
  FcentString2:='CENTEN: Totaal artikelprijzen zonder kortingen';
  FcentString3:='CENTEN: Opbrengst inbrenger (75% van totaal zonder kortingen)';
  FcentString4:='CENTEN: Opbrengst inbrenger (afgerond op 50 cent)';
  FcentString5:='CENTEN: Opbrengst aan kassa';
  FcentString6:='CENTEN: Opbrengst voor Wobbel';

  FeuroString2:='Totaal artikelprijzen zonder kortingen';
  FeuroString3:='Opbrengst inbrenger (75% van totaal zonder kortingen)';
  FeuroString4:='Opbrengst inbrenger (afgerond op 50 cent)';
  FeuroString5:='Opbrengst aan kassa';
  FeuroString6:='Opbrengst voor Wobbel';

  sqlbase1:=' select ' +
  ' b.datum as Beursdatum, v.verkopercode as Inbrengercode, ';

  fieldsInCenten:=' cast(round(100*round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else va.totaalstickerprijs end,2),0) as int) as '''+FcentString2+''', ' +
        ' cast(round(100*round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else 0.75 * va.totaalstickerprijs end,2),0) as int) as '''+FcentString3+''', ' +
        ' cast(round(100*round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else ' +
        '   case when (cast(100*0.75 * va.totaalstickerprijs as int)-cast(0.75 * va.totaalstickerprijs as int)*100) between 0 and 24 then 1.0*(cast(0.75 * va.totaalstickerprijs as int)) else ' +
	'     case when (cast(100*0.75 * va.totaalstickerprijs as int)-cast(0.75 * va.totaalstickerprijs as int)*100) between 25 and 74 then 1.0*(cast(0.75 * va.totaalstickerprijs as int)+0.50) else ' +
	'       1.0*(cast(0.75 * va.totaalstickerprijs as int)+1) ' +
	'     end ' +
	'   end ' +
        ' end, 2),0) as int) as '''+FcentString4+''', ' +
        '  cast(round(100*round(case when va.totaalgekorteprijs is null or va.totaalgekorteprijs = '''' then 0 else va.totaalgekorteprijs end,2),0) as int) as '''+FcentString5+''',  ' +
        '  cast(round(100*round(case when va.totaalgekorteprijs is null or va.totaalgekorteprijs = '''' then 0 else va.totaalgekorteprijs - 0.75 * va.totaalstickerprijs end,2),0) as int) as '''+FcentString6+''',  ';

  fields:=' round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else va.totaalstickerprijs end,2) as '''+FeuroString2+''', ' +
        ' round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else 0.75 * va.totaalstickerprijs end,2) as '''+FeuroString3+''', ' +
        ' round(case when va.totaalstickerprijs is null or va.totaalstickerprijs = '''' then 0 else ' +
        '   case when (cast(100*0.75 * va.totaalstickerprijs as int)-cast(0.75 * va.totaalstickerprijs as int)*100) between 0 and 24 then 1.0*(cast(0.75 * va.totaalstickerprijs as int)) else ' +
	'     case when (cast(100*0.75 * va.totaalstickerprijs as int)-cast(0.75 * va.totaalstickerprijs as int)*100) between 25 and 74 then 1.0*(cast(0.75 * va.totaalstickerprijs as int)+0.50) else ' +
	'       1.0*(cast(0.75 * va.totaalstickerprijs as int)+1) ' +
	'     end ' +
	'   end ' +
        ' end, 2) as '''+FeuroString4+''', ' +
        '  round(case when va.totaalgekorteprijs is null or va.totaalgekorteprijs = '''' then 0 else va.totaalgekorteprijs end,2) as '''+FeuroString5+''',  ' +
        '  round(case when va.totaalgekorteprijs is null or va.totaalgekorteprijs = '''' then 0 else va.totaalgekorteprijs - 0.75 * va.totaalstickerprijs end,2) as '''+FeuroString6+''',  ';

  sqlbase2:=' n.aanhef as Aanhef, n.voorletters as Voorletters,n.tussenvoegsel,n.achternaam, ' +
        ' n.straat,n.huisnr,n.huisnrtoevoeging,n.postcode,n.woonplaats, ' +
        ' n.telefoonmobiel1,n.telefoonmobiel2,n.telefoonvast, n.email, ' +
        ' case when v.saldobetalingcontant = 1 then ''Ja'' else ''Nee'' end as UitbetalingContant, ' +
        ' v.rekeningnummer, v.rekeningopnaam, v.rekeningbanknaam, v.rekeningplaats, ' +
        ' b.opmerkingen as beursopmerkingen, ' +
        ' v.opmerkingen as Verkoperopmerkingen ' +
        ' from verkoper as v ' +
        ' inner join beurs_verkoper as bv on bv.verkoperid=v.verkoper_id ' +
        ' inner join beurs as b on bv.beursid=b.beurs_id and b.isactief=1 ' +
        ' left join naw as n on n.naw_id=v.nawid ' +
        ' left join ( ' +
        ' 	select ' +
        ' 	b.beurs_id, v.verkoper_id, ' +
        '       sum(a.prijs) as totaalstickerprijs, ' +
        '       sum(ta.kortingsfactor*a.prijs) as totaalgekorteprijs ' +
        ' 	from verkoper as v ' +
        ' 	left join artikel as a on v.verkoper_id=a.verkoperid ' +
        ' 	left join transactieartikel as ta on a.artikel_id=ta.artikelid ' +
        ' 	left join transactie as t on ta.transactieid=t.transactie_id ' +
        ' 	left join kassa as k on t.kassaid=k.kassa_id ' +
        ' 	left join beurs as b on k.beursid=b.beurs_id ' +
        ' 	where b.isactief=1 and b.beurs_id is not null ' +
        ' 	group by b.beurs_id, v.verkopercode ' +
        ' ) as va on va.verkoper_id = v.verkoper_id ';

  FSqlBaseInCenten:=sqlbase1 + fieldsInCenten + sqlbase2;
  FSqlBase:=sqlbase1 + fields + sqlbase2;

  FOrderByVerkopercode:=' order by v.verkopercode ';
  FOrderByOngekorteopbrengst:=' order by va.totaalstickerprijs ';
  FOrderByGekorteopbrengst:=' order by va.totaalgekorteprijs ';

  FOrderByVerkopercodeDescAsc:=c_Asc;
  FOrderByOngekorteopbrengstDescAsc:=c_Asc;
  FOrderByGekorteopbrengstDescAsc:=c_Asc;

  btnInfo01.Hint:='Een overzicht van alle Inbrengers en hun opbrengsten in de geselecteerde beurs. '+c_CR+c_ExportHint;
  btnExporteerOverzichtVerkopers.Hint:=btnInfo01.Hint;
  mmoExportQuery.Visible:=false;
end;


procedure TfrmOverzichtVerkopers.FormDeactivate(Sender: TObject);
begin
  pgBar.Position:=0;
  lblPgBar.Caption:='';

  dmWobbel.vwOverzicht.Active:=false;
  grdOverzicht.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  dmWobbel.vwOverzicht.Active:=false;
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;



procedure TfrmOverzichtVerkopers.grdOverzichtTitleClick(
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
    else if ((sColname = AnsiLowercase(FeuroString2)) or (sColname = AnsiLowercase(FcentString2)) or
             (sColname = AnsiLowercase(FeuroString3)) or (sColname = AnsiLowercase(FcentString3)) or
             (sColname = AnsiLowercase(FeuroString4)) or (sColname = AnsiLowercase(FcentString4))
    ) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOngekorteopbrengst);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByOngekorteopbrengstDescAsc);
      if (FOrderByOngekorteopbrengstDescAsc = c_Asc) then
      begin
        FOrderByOngekorteopbrengstDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByOngekorteopbrengstDescAsc:=c_Asc;
      end;
    end
    else if ((sColname = AnsiLowercase(FeuroString5)) or (sColname = AnsiLowercase(FcentString5)) or
             (sColname = AnsiLowercase(FeuroString6)) or (sColname = AnsiLowercase(FcentString6))
    ) then
    begin
      dmWobbel.vwOverzicht.SQL.Append(FOrderByGekorteopbrengst);
      dmWobbel.vwOverzicht.SQL.Append(FOrderByGekorteopbrengstDescAsc);
      if (FOrderByGekorteopbrengstDescAsc = c_Asc) then
      begin
        FOrderByGekorteopbrengstDescAsc:=c_Desc;
      end
      else
      begin
        FOrderByGekorteopbrengstDescAsc:=c_Asc;
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

