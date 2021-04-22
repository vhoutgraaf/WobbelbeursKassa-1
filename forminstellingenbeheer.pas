unit forminstellingenbeheer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons,
  c_appsettings;

type

  { TfrmInstellingenBeheer }

  TfrmInstellingenBeheer = class(TForm)
    btnInfo01: TBitBtn;
    btnKortingspercentageOpslaan: TButton;
    cmbKortingsPercentage: TComboBox;
    grpKortingspercentage: TGroupBox;
    procedure btnKortingspercentageOpslaanClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { private declarations }

    function FindIdOfPercentageByValue(val:string; out indx:integer):boolean;

  public
    { public declarations }
  end;

var
  frmInstellingenBeheer: TfrmInstellingenBeheer;

implementation

uses
  Crt, IniFiles, m_tools, m_constant;

{$R *.lfm}

{ TfrmInstellingenBeheer }

procedure TfrmInstellingenBeheer.btnKortingspercentageOpslaanClick(
  Sender: TObject);
var
  val:string;
  ix:integer;
begin
  try
    val:=cmbKortingsPercentage.Text;
    if (FindIdOfPercentageByValue(val, ix)) then
    begin
      cmbKortingsPercentage.ItemIndex:=ix;
    end
    else
    begin
      cmbKortingsPercentage.Items.Add(val);
    end;

    //val:=cmbKortingsPercentage.Items[cmbKortingsPercentage.ItemIndex];
    m_tools.SetValueInIniFile('INIT','KortingsPercentage',val);
    AppSettings.KortingsFactor:=m_tools.PercentageToFactor(val);

    MessageOk('De wijzigingen zijn opgeslagen');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;

end;

procedure TfrmInstellingenBeheer.FormActivate(Sender: TObject);
var
  Ini:TINIFile;
  ix: integer;
  testval:string;
begin
  m_tools.CloseOtherScreens(self);

  cmbKortingsPercentage.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  btnKortingspercentageOpslaan.Enabled:=cmbKortingsPercentage.Enabled;

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

  try
    Ini := TINIFile.Create(GetDefaultWobbelInifilename);

    testval:=INI.ReadString('INIT','KortingsPercentage','0');
    if (FindIdOfPercentageByValue(testval, ix)) then
    begin
      cmbKortingsPercentage.ItemIndex:=ix;
    end
    else
    begin
      cmbKortingsPercentage.Items.Add(testval);
      if (FindIdOfPercentageByValue(testval, ix)) then
      begin
        cmbKortingsPercentage.ItemIndex:=ix;
      end;
    end;

  finally
    Ini.Free;
  end;

end;

procedure TfrmInstellingenBeheer.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmInstellingenBeheer.FormCreate(Sender: TObject);
var
  i: integer;
begin

  for i:=0 to 25 do
  begin
    cmbKortingsPercentage.Items.Add(IntToStr(i));
  end;

  btnInfo01.Hint:='Maximaal 25% korting:'+m_constant.c_CR+'Met de Inbrenger is overeengekomen dat deze 75% van de prijs op het artikel krijgt,'+m_constant.c_CR+'Eventuele korting komt voor rekening van Wobbel en is dus maximaal 25%';
end;

procedure TfrmInstellingenBeheer.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

function TfrmInstellingenBeheer.FindIdOfPercentageByValue(val:string; out indx:integer):boolean;
var
  sTest:string;
  ix:integer;
begin
  Result:=true;

  indx:=-1;
  for ix:=0 to cmbKortingsPercentage.Items.Count-1 do
  begin
    sTest:=cmbKortingsPercentage.Items[ix];
    if (sTest = val) then
    begin
      indx:=ix;
      break;
    end;
  end;
  if (indx=-1) then
  begin
    Result:=false;
  end;
end;



end.

