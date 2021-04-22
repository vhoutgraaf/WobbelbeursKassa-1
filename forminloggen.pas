unit forminloggen;

{$mode objfpc}{$H+}
{$DEFINE DEVELOP}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,
  Menus, Buttons, MaskEdit, c_appsettings;

type

  { TfrmInloggen }

  TfrmInloggen = class(TForm)
    btnInfo01: TBitBtn;
    btnInloggen: TButton;
    btnUitloggen: TButton;
    lblInlognaam: TLabel;
    lblInlogstatusDefault: TLabel;
    lblInlogstatusFault: TLabel;
    lblInlogstatusOk: TLabel;
    lblWachtwoord: TLabel;
    pnlLogin: TPanel;
    txtInlognaam: TEdit;
    txtWachtwoord: TEdit;
    procedure btnInloggenClick(Sender: TObject);
    procedure btnUitloggenClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcessMainformStuff;
    procedure SetLoginstatus;

  private
    { private declarations }

public
    { public declarations }
  end;

var
  frmInloggen: TfrmInloggen;

implementation

uses
   m_tools, m_constant, crt, formdialoog;

{$R *.lfm}

{ TfrmInloggen }

procedure TfrmInloggen.FormCreate(Sender: TObject);
begin
  {$IFDEF DEVELOP}
    //txtInlognaam.Text:='beheerder';
    //txtWachtwoord.Text:='wwbeheerder';
  {$ENDIF}
  //SetLoginstatus
  btnInfo01.Hint:='Alleen na inloggen kan het programma worden gebruikt. '+c_CR+
                  'Er zijn inlogaccounts mogelijk met twee rollen: beheerder en kassamedewerker.'+c_CR+
                  'Een beheerder mag alles; een kassamedewerker mag alleen transacties invoeren en enkele GUI-instellingen doen.';
end;

procedure TfrmInloggen.FormDestroy(Sender: TObject);
begin

end;


procedure TfrmInloggen.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmInloggen.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
//
end;

procedure TfrmInloggen.btnInloggenClick(Sender: TObject);
var
  isIngelogd: boolean;
begin
  isIngelogd := AppSettings.Vrijwilliger.Inloggen(txtInlognaam.Text, txtWachtwoord.Text);

  if not isIngelogd then
  begin
    AppSettings.WobbelLoginStatus:=[lsLoginFail];
    self.Caption:='Wobbelbeurs Kassa - Inloggen';
  end
  else
  begin
    self.Caption:='Wobbelbeurs Kassa - Uitloggen';
  end;

  SetLoginstatus;
  ProcessMainformStuff;

  if isIngelogd then
  begin
    if (AppSettings.Vrijwilliger.Error = '') then
    begin
      self.Close;
      //self.Hide;
    end;
  end;
end;

procedure TfrmInloggen.btnUitloggenClick(Sender: TObject);
var
  frmDialoog: TfrmDialoog;
begin
  if (AppSettings.Kassa.KassaStatusIsGeopend) then
  begin
    try
      frmDialoog:=TfrmDialoog.Create(nil);
      frmDialoog.SetLabeltekst('','','','De kassa is nog niet afgesloten.', 'Dit eerst doen svp voordat u kunt uitloggen.');
      frmDialoog.CancelButtonVisibility(false);
      m_tools.getPosition(frmDialoog);
      frmDialoog.ShowModal;
    finally
      if (frmDialoog<>nil) then
      begin
        frmDialoog.Free;
        frmDialoog:=nil;
      end;
    end;
    exit;
  end;

  txtInlognaam.Text:='';
  txtWachtwoord.Text:='';

  self.Caption:='Wobbelbeurs Kassa - Inloggen';

  AppSettings.Vrijwilliger.ResetVrijwilligerprops;

  AppSettings.WobbelLoginStatus:=[lsNietIngelogd];

  SetLoginstatus();

  m_tools.BackupDatabaseFile();
  ProcessMainformStuff;
end;

procedure TfrmInloggen.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  m_tools.CloseOtherScreens(self);

  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  lblInlogstatusDefault.Font.Size:=lblInlogstatusDefault.Font.Size + (fsize-c_defaultFontsize);
  lblInlogstatusFault.Font.Size:=lblInlogstatusDefault.Font.Size;
  lblInlogstatusOk.Font.Size:=lblInlogstatusDefault.Font.Size;

  SetLoginstatus;
end;

procedure TfrmInloggen.ProcessMainformStuff;
begin
  // gevaarlijk: laat het over aan het activate event in mainform
end;

procedure TfrmInloggen.SetLoginstatus;
begin

  if AppSettings.Vrijwilliger.VrijwilligerIsIngelogd then
  begin
    btnUitloggen.Enabled:=true;
    btnInloggen.Enabled:=not btnUitloggen.Enabled;
    if AppSettings.Vrijwilliger.VrijwilligerIsAdmin then
    begin
      AppSettings.WobbelLoginStatus:=[lsIngelogdAdmin]
    end
    else
    begin
      AppSettings.WobbelLoginStatus:=[lsIngelogdNoAdmin];
    end;
  end
  else
  begin
    btnUitloggen.Enabled:=false;
    btnInloggen.Enabled:=not btnUitloggen.Enabled;
  end;

  lblInlogstatusFault.Caption:='';
  lblInlogstatusDefault.Caption:='';
  lblInlogstatusOk.Caption:='';
  if (lsNietIngelogd in AppSettings.WobbelLoginStatus) or (lsNone in AppSettings.WobbelLoginStatus) then
  begin
    lblInlogstatusDefault.Caption:='Niet ingelogd';
    lblInlogstatusDefault.Left:=Round((lblInlogstatusDefault.Parent.Width-lblInlogstatusDefault.Width)/2.0);
  end
  else if (lsLoginFail in AppSettings.WobbelLoginStatus) then
  begin
    if (AppSettings.Vrijwilliger.Error = '') then
    begin
      lblInlogstatusFault.Caption:='Verkeerde inloggegevens ingevoerd';
    end
    else
    begin
      lblInlogstatusFault.Caption:='Verkeerde inloggegevens ingevoerd - ' + AppSettings.Vrijwilliger.Error;
    end;
    lblInlogstatusFault.Left:=Round((lblInlogstatusFault.Parent.Width-lblInlogstatusFault.Width)/2.0);
  end
  else if lsIngelogdAdmin in AppSettings.WobbelLoginStatus then
  begin
    if (AppSettings.Vrijwilliger.Error = '') then
    begin
      lblInlogstatusOk.Caption:='Ingelogd als beheerder';
    end
    else
    begin
      lblInlogstatusOk.Caption:='Ingelogd als beheerder - ' + AppSettings.Vrijwilliger.Error;
    end;
    lblInlogstatusOk.Left:=Round((lblInlogstatusOk.Parent.Width-lblInlogstatusOk.Width)/2.0);
  end
  else if lsIngelogdNoAdmin in AppSettings.WobbelLoginStatus then
  begin
    lblInlogstatusOk.Caption:='Ingelogd';
    lblInlogstatusOk.Left:=Round((lblInlogstatusOk.Parent.Width-lblInlogstatusOk.Width)/2.0);
  end
  else
  begin
    lblInlogstatusOk.Caption:='Vul s.v.p. gebruiksersnaam en wachtwoord in';
    lblInlogstatusOk.Left:=Round((lblInlogstatusOk.Parent.Width-lblInlogstatusOk.Width)/2.0);
  end;

end;

end.
