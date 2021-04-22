unit formkassaopensluit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, DbCtrls, ExtCtrls, Buttons, c_appsettings;

type

  { TfrmKassaOpenSluit }

  TfrmKassaOpenSluit = class(TForm)
    btnInfo01: TBitBtn;
    btnStatusOpslaan: TButton;
    lblOpmerkingen: TLabel;
    txtOpmerkingen: TEdit;
    grdKassabedrag: TDBGrid;
    lblEuro: TLabel;
    lblKassabedrag: TLabel;
    lblTotaalbedrag: TLabel;
    navKassabedragGrid: TDBNavigator;
    pnlStatusOverzicht: TPanel;
    pnlStatusInvoer: TPanel;
    pnlKassabedrag: TPanel;
    radKassaOpenen: TRadioButton;
    radKassaSluiten: TRadioButton;
    rdgKassaStatus: TRadioGroup;
    txtTotaalbedrag: TEdit;
    procedure btnStatusOpslaanClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }

    FFormIsModal:boolean;
    procedure SetKassastatus;
    procedure ProcessMainformStuff;
    function PostData: boolean;
    function CheckBedrag(txt: TEdit): boolean;
    function CheckOpmerkingen(txt: TEdit): boolean;
    procedure SetTitle;
  public
    { public declarations }

    property FormIsModal: boolean read FFormIsModal write FFormIsModal;

  end;

var
  frmKassaOpenSluit: TfrmKassaOpenSluit;

implementation

uses
  m_wobbeldata, m_tools, m_constant, m_error,
  ZDataset, m_querystuff, crt;

{$R *.lfm}

{ TfrmKassaOpenSluit }

procedure TfrmKassaOpenSluit.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);

  dmWobbel.vwKassabedrag.Active:=true;

  Color:=AppSettings.GlobalBackgroundColor;
  Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

  SetKassastatus;

  txtOpmerkingen.Text:='';
  txtTotaalbedrag.Text:='';

  SetTitle;

  txtTotaalbedrag.SetFocus;
end;


procedure TfrmKassaOpenSluit.SetKassastatus;
begin
  AppSettings.Kassa.setKassaStatus(AppSettings.Beurs.BeursId);

  if (AppSettings.Kassa.KassaStatusIsGeopend) then
  begin
    radKassaSluiten.Checked:=true;
  end
  else if (AppSettings.Kassa.KassaStatusIsGesloten) then
  begin
    radKassaOpenen.Checked:=true;
  end
  else
  begin
    radKassaOpenen.Checked:=true;
  end;
end;


procedure TfrmKassaOpenSluit.btnStatusOpslaanClick(Sender: TObject);
begin
  if (CheckBedrag(txtTotaalbedrag) and (CheckOpmerkingen(txtOpmerkingen))) then
  begin
    PostData;
    ProcessMainformStuff;
    SetKassastatus;
    dmWobbel.vwKassabedrag.Refresh;

    if (AppSettings.Kassa.KassaStatusIsGesloten) then
    begin
      if (FormIsModal) then
      begin
        MessageOk('De kassa is afgesloten. De applicatie wordt gesloten.');
      end
      else
      begin
        MessageOk('De kassa is afgesloten. De applicatie kan worden gesloten.');
      end;
    end;
    self.Close;
  end;
end;

function TfrmKassaOpenSluit.CheckBedrag(txt: TEdit): boolean;
var
  len: integer;
  isOk:boolean;
  sSalvaged:string;
  s:string;
begin
  isOk:=true;
  s:=txt.Text;
  sSalvaged:=s;
  len:=Length(s);

  sSalvaged:=StringReplace(StringReplace(s, ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]), '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  if ((len>0) and not IsDouble(sSalvaged)) then
  begin
    MessageError('Geen geldig bedrag ingevoerd');
    isOk:=false;
  end;
  if (isOk) then
  begin
    sSalvaged:=FormatToMoney(sSalvaged);
  end;
  txt.Text:=sSalvaged;
  Result:=isOk;
end;

function TfrmKassaOpenSluit.CheckOpmerkingen(txt: TEdit): boolean;
var
  len: integer;
  isOk:boolean;
  sSalvaged:string;
  s:string;
begin
  isOk:=true;
  s:=txt.Text;
  sSalvaged:=s;
  len:=Length(s);

  if (len>255) then
  begin
    sSalvaged:=Copy(s, 1, 252) + '...';
  end;
  txt.Text:=sSalvaged;
  Result:=isOk;
end;


function TfrmKassaOpenSluit.PostData: boolean;
var
  q : TZQuery;
  retVal: boolean;
  stmp:string;
  kassabedragid, kassaopensluitid: integer;

  sError:string;

begin
  retVal:=true;
  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      q.SQL.Clear;

      // maak een nieuw bedrag record
      kassabedragid:=-1;
      q.SQL.Text:='insert into kassabedrag (' +
                  ' totaalbedrag, opmerkingen' +
                  ' ) values(' +
                  ' :TOTAALBEDRAG, ' +
                  ' :OPMERKINGEN)';
      q.Params.ParamByName('TOTAALBEDRAG').AsFloat := StrToFloat(txtTotaalbedrag.Text);
      q.Params.ParamByName('OPMERKINGEN').AsString := txtOpmerkingen.Text;
      q.ExecSQL();
      q.Close;

      // lijkt niet te werken binnen een transactie
      //kassabedragid:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

      q.SQL.Clear;
      q.SQL.Text:='select max(kassabedrag_id) as kassabedragid from kassabedrag';
      q.Open;
      kassabedragid:=-1;
      while not q.Eof do
      begin
        sTmp:=q.FieldByName('kassabedragid').AsString;
        if (sTmp='') then
        begin
          kassabedragid:=1;
        end
        else
        begin
          kassabedragid:=StrToInt(sTmp);
        end;
        break;
      end;
      q.Close;
      if (kassabedragid = -1) then
      begin
        Raise EWobbelError.Create('Invoerfout kassabedrag');
      end;

      // maak een nieuw kassaopensluit record
      kassaopensluitid:=-1;
      q.SQL.Text:='insert into kassaopensluit (' +
                  ' kassabedragid, kassastatusid, kassaid' +
                  ' ) values(' +
                  ' :KASSABEDRAGID, ' +
                  ' :KASSASTATUSID, ' +
                  ' :KASSAID)';
      q.Params.ParamByName('KASSABEDRAGID').AsInteger := kassabedragid;
      if (self.radKassaSluiten.Checked) then
      begin
        q.Params.ParamByName('KASSASTATUSID').AsInteger := 2;
      end
      else
      begin
        q.Params.ParamByName('KASSASTATUSID').AsInteger := 1;
      end;
      q.Params.ParamByName('KASSAID').AsInteger := AppSettings.Kassa.KassaId;
      q.ExecSQL();
      q.Close;

      // lijkt niet te werken binnen een transactie
      //kassaopensluitid:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

      q.SQL.Clear;
      q.SQL.Text:='select max(kassaopensluit_id) as kassaopensluitid from kassaopensluit';
      q.Open;
      kassaopensluitid:=-1;
      while not q.Eof do
      begin
        sTmp:=q.FieldByName('kassaopensluitid').AsString;
        if (sTmp='') then
        begin
          kassaopensluitid:=1;
        end
        else
        begin
          kassaopensluitid:=StrToInt(sTmp);
        end;
        break;
      end;
      q.Close;
      if (kassaopensluitid = -1) then
      begin
        Raise EWobbelError.Create('Invoerfout kassa openen / sluiten');
      end;

      dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
    finally
      q.Free;
      Result:=retVal;
    end;
  except
    on E: Exception do
    begin
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      sError:='Fout bij opvragen kassastatus: ' + E.Message;
      MessageError(sError);
    end;
  end;
  Result:=retVal;
end;

procedure TfrmKassaOpenSluit.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmKassaOpenSluit.FormCreate(Sender: TObject);
begin
  FFormIsModal:=false;

  btnInfo01.Hint:='Geef aan welke bedragen contant in kas zijn bij openen of sluiten.'+c_CR+
                  'Of het om openen of sluiten gaat is aan te geven in de selectievakken.'+c_CR+
                  'Als de vorige keer de kassa was gesloten staat deze alvast voorgeselecteerd op "sluiten", en viceversa.'+c_CR+
                  'Bij aanvang is "openen" voorgeselecteerd.'+c_CR+
//                  'Als als bedrag "0" wordt ingevoerd wordt het ingevoerde record genegeerd in de overzichten.'+c_CR+
                  '';
end;

procedure TfrmKassaOpenSluit.FormDestroy(Sender: TObject);
begin

end;


procedure TfrmKassaOpenSluit.FormDeactivate(Sender: TObject);
begin
  dmWobbel.vwKassabedrag.Active:=false;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmKassaOpenSluit.SetTitle;
var
  s: string;
begin
  s:='Open- en sluitbedragen van Kassa ';
  if (AppSettings.Kassa.KassaIsGekozen) then
  begin
    s:=s+' '+AppSettings.Kassa.KassaNr;
  end;
  self.lblKassabedrag.Caption := s;
end;

procedure TfrmKassaOpenSluit.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;


end.

