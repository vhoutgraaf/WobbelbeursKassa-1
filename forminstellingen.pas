unit forminstellingen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,
  Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, Buttons, c_appsettings, c_wobbelbuttonpanel;

type

  { TfrmInstellingen }

  TfrmInstellingen = class(TForm)
    btnInfo01: TBitBtn;
    btnGlobalFontsizeOpslaan: TButton;
    btnInfo02: TBitBtn;
    btnKleurenOpslaan: TButton;

    pnlActiefGridBGColor:TWobbelButtonPanel;
    pnlInactiefGridBGColor:TWobbelButtonPanel;

    dlgColor: TColorDialog;
    grpKleuren: TGroupBox;
    grpGlobalFontsize: TGroupBox;
    lblBGColorActiefGrid: TLabel;
    lblBGColorInactiefGrid: TLabel;
    speFontgrootte: TSpinEdit;

    procedure btnGlobalFontsizeOpslaanClick(Sender: TObject);
    procedure btnKleurenOpslaanClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }
    procedure pnlActiefGridBGColorClick(Sender: TObject);
    procedure pnlInactiefGridBGColorClick(Sender: TObject);


  public
    { public declarations }
  end;

var
  frmInstellingen: TfrmInstellingen;

implementation

uses
  Crt, IniFiles, m_tools, m_constant,
  strutils;
{$R *.lfm}

{ TfrmInstellingen }



procedure TfrmInstellingen.FormCreate(Sender: TObject);
begin
  pnlActiefGridBGColor:=TWobbelButtonPanel.CreateMe(self, grpKleuren, 6, 246, 33, 160, 'Actief grid');
  pnlActiefGridBGColor.Hint:='De achtergrondkleur van actieve deelschermen bij Transacties krijgen de hier ingestelde kleur.';
  pnlActiefGridBGColor.OnClick:=@pnlActiefGridBGColorClick;

  pnlInactiefGridBGColor:=TWobbelButtonPanel.CreateMe(self, grpKleuren, 54, 246, 33, 160, 'Inactief grid');
  pnlInactiefGridBGColor.Hint:='De achtergrondkleur van inactieve deelschermen bij Transacties krijgen de hier ingestelde kleur.';
  pnlInactiefGridBGColor.OnClick:=@pnlInactiefGridBGColorClick;

  btnInfo01.Hint:='Geef aan wat de algemene lettergrootte is in Wobbelkassa. '+c_CR+'De teksten en waarden in de tabellen krijgen niet de hier ingestelde waarde: zij hebben elk hun eigen instelmogelijkheid..';
  btnInfo02.Hint:='Geef aan welke kleuren moeten wordne gebruikt als achtergrond van de transactietabellen.';
end;

procedure TfrmInstellingen.FormDestroy(Sender: TObject);
begin
  if (pnlActiefGridBGColor <> nil) then
  begin
    pnlActiefGridBGColor.Free;
  end;
  if (pnlInactiefGridBGColor <> nil) then
  begin
    pnlInactiefGridBGColor.Free;
  end;
end;


procedure TfrmInstellingen.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmInstellingen.FormActivate(Sender: TObject);
var
  Ini:TINIFile;
  R,G,B:Byte;
  RGB:string;
begin
  pnlActiefGridBGColor.ActivateButtonPanel(true);
  pnlInactiefGridBGColor.ActivateButtonPanel(true);

  try
    Ini := TINIFile.Create(GetDefaultWobbelInifilename);
    RGB:=INI.ReadString('ACHTERGROND','GridBackgroundColorInactiveRGB',c_defaultGridBackgroundColorInactiveAsString);
    R:=Byte(StrToInt(ExtractDelimited(1,RGB,[','])));
    G:=Byte(StrToInt(ExtractDelimited(2,RGB,[','])));
    B:=Byte(StrToInt(ExtractDelimited(3,RGB,[','])));
    pnlInactiefGridBGColor.Color:=RGBToColor(R, G, B);

    RGB:=INI.ReadString('ACHTERGROND','GridBackgroundColorActiveRGB',c_defaultGridBackgroundColorActiveAsString);
    R:=Byte(StrToInt(ExtractDelimited(1,RGB,[','])));
    G:=Byte(StrToInt(ExtractDelimited(2,RGB,[','])));
    B:=Byte(StrToInt(ExtractDelimited(3,RGB,[','])));
    pnlActiefGridBGColor.Color:=RGBToColor(R, G, B);

    speFontgrootte.Value:=INI.ReadFloat('FONTS','GlobalFontsize',c_defaultFontsize);

  finally
    Ini.Free;
  end;

  m_tools.CloseOtherScreens(self);

  //speFontgrootte.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsIngelogd;
  //btnGlobalFontsizeOpslaan.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsIngelogd;

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
end;


procedure TfrmInstellingen.btnGlobalFontsizeOpslaanClick(Sender: TObject);
begin
  try
    Appsettings.AdjustGlobalFontSize(speFontgrootte.Value);
    MessageOk('De wijzigingen zijn opgeslagen');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmInstellingen.btnKleurenOpslaanClick(Sender: TObject);
var
  R,G,B:Byte;
  RGB:string;
begin
  try
    R:=Graphics.Red(pnlActiefGridBGColor.Color);
    B:=Graphics.Blue(pnlActiefGridBGColor.Color);
    G:=Graphics.Green(pnlActiefGridBGColor.Color);
    RGB:=IntToStr(R) + ',' + IntToStr(G) + ',' + IntToStr(B);
    m_tools.SetValueInIniFile('ACHTERGROND','GridBackgroundColorActiveRGB',RGB);
    AppSettings.GridBackgroundColorActive:=pnlActiefGridBGColor.Color;

    R:=Graphics.Red(pnlInactiefGridBGColor.Color);
    B:=Graphics.Blue(pnlInactiefGridBGColor.Color);
    G:=Graphics.Green(pnlInactiefGridBGColor.Color);
    RGB:=IntToStr(R) + ',' + IntToStr(G) + ',' + IntToStr(B);
    m_tools.SetValueInIniFile('ACHTERGROND','GridBackgroundColorInactiveRGB',RGB);
    AppSettings.GridBackgroundColorInactive:=pnlInactiefGridBGColor.Color;

    MessageOk('De achtergondkleuren zijn opgeslagen.', 'Wobbel');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmInstellingen.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
//
end;

procedure TfrmInstellingen.pnlActiefGridBGColorClick(Sender: TObject);
begin
  if (dlgColor.Execute) then
  begin
    pnlActiefGridBGColor.Color:=dlgColor.Color;
  end;
end;

procedure TfrmInstellingen.pnlInactiefGridBGColorClick(Sender: TObject);
begin
  if (dlgColor.Execute) then
  begin
    pnlInactiefGridBGColor.Color:=dlgColor.Color;
  end;
end;


end.

