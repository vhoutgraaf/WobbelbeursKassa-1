unit formartikeltype;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls, DBGrids, DbCtrls, c_appsettings, db;

type

  { TfrmArtikeltype }

  TfrmArtikeltype = class(TForm)
    grdArtikeltype: TDBGrid;
    lblArtikeltypeTitel: TLabel;
    navArtikeltypeGrid: TDBNavigator;
    pnlArtikeltype: TPanel;

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }

    function VeranderingenOpgeslagenBijVerlaten:boolean;

  public
    { public declarations }
  end;

var
  frmArtikeltype: TfrmArtikeltype;

implementation

uses
  m_wobbeldata, m_tools, m_constant, crt;

{$R *.lfm}

procedure TfrmArtikeltype.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
//
end;

procedure TfrmArtikeltype.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
  CanClose:=true;
  if (VeranderingenOpgeslagenBijVerlaten()) then
  begin
    CanClose:=false;
  end;
end;

procedure TfrmArtikeltype.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);
  dmWobbel.tblArtikeltype.Active:=true;

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
end;

procedure TfrmArtikeltype.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmArtikeltype.FormDestroy(Sender: TObject);
begin

end;


function TfrmArtikeltype.VeranderingenOpgeslagenBijVerlaten:boolean;
begin
  Result:=false;
  if (grdArtikeltype <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if ((grdArtikeltype.DataSource.State = dsEdit)
         or (grdArtikeltype.DataSource.State = dsInsert)) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Artikeltype-tabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        grdArtikeltype.DataSource.DataSet.Post;
        Result:=true;
      end
      else
      begin
        grdArtikeltype.DataSource.DataSet.Cancel;
      end;
    end;
  end;
end;

procedure TfrmArtikeltype.FormDeactivate(Sender: TObject);
begin
  VeranderingenOpgeslagenBijVerlaten;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


end.

