unit formbeurskassaoverzicht;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, c_appsettings, c_gridbeurskassa;

type
  { TfrmBeursKassaoverzicht }

  TfrmBeursKassaoverzicht = class(TForm)

    gridpanelBeursKassa: TGridBeursKassa;
    pnlBeursKassaoverzicht: TPanel;

    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure ActivateKassagrid;
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmBeursKassaoverzicht: TfrmBeursKassaoverzicht;

implementation

uses
  c_wobbelgridpanel, m_tools, m_constant, crt;

{$R *.lfm}

procedure TfrmBeursKassaoverzicht.FormCreate(Sender: TObject);
begin
//  ActivateKassagrid();
end;

procedure TfrmBeursKassaoverzicht.FormDestroy(Sender: TObject);
begin
  if (gridpanelBeursKassa <> nil) then
  begin
    gridpanelBeursKassa.Free;
  end;
end;

procedure TfrmBeursKassaoverzicht.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
//
end;

procedure TfrmBeursKassaoverzicht.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);

  ActivateKassagrid();

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
end;

procedure TfrmBeursKassaoverzicht.ActivateKassagrid();
begin
  if (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelBeursKassa = nil) then
    begin
      gridpanelBeursKassa:=TGridBeursKassa.CreateMe(Self, pnlBeursKassaoverzicht,
          pnlBeursKassaoverzicht.Top,
          2,
          pnlBeursKassaoverzicht.Height-2,
          AppSettings.Beurs.BeursId,
          AppSettings.Beurs.BeursOmschrijving);
    end
    else
    begin
      gridpanelBeursKassa.Visible:=true;
      gridpanelBeursKassa.BeursId:=AppSettings.Beurs.BeursId; //nieuw
      gridpanelBeursKassa.BeursOmschrijving:=AppSettings.Beurs.BeursOmschrijving;//nieuw
      gridpanelBeursKassa.SetGridProps; //nieuw
      gridpanelBeursKassa.FillGrid;
    end;
    gridpanelBeursKassa.SetGridStatus([WSENABLEDEDITABLE]);
  end
  else
  begin
    if (gridpanelBeursKassa <> nil) then
    begin
      gridpanelBeursKassa.Visible:=false;
    end;
  end;
end;

procedure TfrmBeursKassaoverzicht.FormDeactivate(Sender: TObject);
begin
  if (gridpanelBeursKassa <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelBeursKassa.AnyRowIsDirty) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Kassa-tabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        gridpanelBeursKassa.PostData;
      end;
    end;
  end;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

end.

