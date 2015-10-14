unit formbeursoverzicht;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, c_appsettings, c_gridbeurs;

type

  { TfrmBeursoverzicht }

  TfrmBeursoverzicht = class(TForm)

    gridpanelBeurs: TGridBeurs;
    pnlBeurs: TPanel;

    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure ActivateBeursgrid;
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmBeursoverzicht: TfrmBeursoverzicht;

implementation

uses
  c_wobbelgridpanel, m_tools, m_constant, crt;

{$R *.lfm}

procedure TfrmBeursoverzicht.FormCreate(Sender: TObject);
begin
//  ActivateBeursgrid();
end;

procedure TfrmBeursoverzicht.FormDestroy(Sender: TObject);
begin
  if (gridpanelBeurs <> nil) then
  begin
    gridpanelBeurs.Free;
  end;
end;


procedure TfrmBeursoverzicht.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmBeursoverzicht.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);

  ActivateBeursgrid();

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

end;

procedure TfrmBeursoverzicht.ActivateBeursgrid();
begin
  if (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelBeurs = nil) then
    begin
      gridpanelBeurs:=TGridBeurs.CreateMe(Self, pnlBeurs,
          pnlBeurs.Top,
          2,
          pnlBeurs.Height-2);
    end
    else
    begin
      gridpanelBeurs.Visible:=true;
      gridpanelBeurs.FillGrid;
    end;
    gridpanelBeurs.SetGridStatus([WSENABLEDEDITABLE]);
  end
  else
  begin
    if (gridpanelBeurs <> nil) then
    begin
      gridpanelBeurs.Visible:=false;
    end;
  end;
end;

procedure TfrmBeursoverzicht.FormDeactivate(Sender: TObject);
begin
  if (gridpanelBeurs <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelBeurs.AnyRowIsDirty) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Beurs-tabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        gridpanelBeurs.PostData;
      end;
    end;
  end;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


end.

