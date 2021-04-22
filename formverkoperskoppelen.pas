unit formverkoperskoppelen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  CheckLst, StdCtrls, Buttons,
  c_appsettings;

type

  { TfrmVerkoperskoppelen }

  TfrmVerkoperskoppelen = class(TForm)
    btnInfo01: TBitBtn;
    btnSchuifGekoppeldeVerkoperNaarOngekoppeldenLijst: TBitBtn;
    btnSchuifOngekoppeldeVerkoperNaarGekoppeldenLijst: TBitBtn;
    btnVerkoperBeursKoppelingenOpslaan: TButton;
    clbGekoppeldeVerkopers: TCheckListBox;
    clbOngekoppeldeVerkopers: TCheckListBox;
    lblOngekoppeldeVerkopers: TStaticText;
    lblGekoppeldeVerkopers: TStaticText;
    pnlVerkopersKoppelenAanBeurs: TPanel;
    procedure btnSchuifGekoppeldeVerkoperNaarOngekoppeldenLijstClick(
      Sender: TObject);
    procedure btnSchuifOngekoppeldeVerkoperNaarGekoppeldenLijstClick(
      Sender: TObject);
    procedure btnVerkoperBeursKoppelingenOpslaanClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }

  public
    { public declarations }
  end;

var
  frmVerkoperskoppelen: TfrmVerkoperskoppelen;

implementation

uses
  m_tools, m_constant, c_verkoper, crt;

{$R *.lfm}

{ TfrmVerkoperskoppelen }

procedure TfrmVerkoperskoppelen.btnSchuifGekoppeldeVerkoperNaarOngekoppeldenLijstClick
  (Sender: TObject);
var
  aantaltransacties:integer;
begin
  aantaltransacties:=AppSettings.Beurs.AantalTransactiesInActieveBeurs;
  if (aantaltransacties > 0) then
  begin
    MsgWarning('Er kunnen alleen verkopers uit de huidige beurs worden gehaald zolang er nog geen transacties zijn gedaan!');
  end
  else if (aantaltransacties < 0) then
  begin
    MessageError(AppSettings.Beurs.Error);
  end
  else
  begin
    SchuifGekoppeldeVerkoperNaarOngekoppeldenLijst(clbGekoppeldeVerkopers, clbOngekoppeldeVerkopers);
  end;
end;

procedure TfrmVerkoperskoppelen.btnSchuifOngekoppeldeVerkoperNaarGekoppeldenLijstClick
  (Sender: TObject);
begin
  SchuifOngekoppeldeVerkoperNaarGekoppeldenLijst(clbGekoppeldeVerkopers, clbOngekoppeldeVerkopers);
end;

procedure TfrmVerkoperskoppelen.btnVerkoperBeursKoppelingenOpslaanClick(
  Sender: TObject);
begin
  try
    VerkoperBeursKoppelingenOpslaan(AppSettings.Beurs.BeursId, clbGekoppeldeVerkopers, clbOngekoppeldeVerkopers);
    AppSettings.Beurs.SetAantalVerkopersInActieveBeurs();
    MessageOk('De wijzigingen zijn opgeslagen');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmVerkoperskoppelen.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  m_tools.CloseOtherScreens(self);

  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  lblGekoppeldeVerkopers.Font.Size:=fsize+2;
  lblOngekoppeldeVerkopers.Font.Size:=fsize+2;

  pnlVerkopersKoppelenAanBeurs.Visible:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  pnlVerkopersKoppelenAanBeurs.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  if (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    VulVerkopersKoppelenAanBeursTabellen(AppSettings.Beurs.BeursId, clbGekoppeldeVerkopers, clbOngekoppeldeVerkopers);
  end;
end;

procedure TfrmVerkoperskoppelen.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmVerkoperskoppelen.FormCreate(Sender: TObject);
begin
end;

procedure TfrmVerkoperskoppelen.FormDestroy(Sender: TObject);
begin

end;

procedure TfrmVerkoperskoppelen.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


end.

