unit formhelp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmHelp }

  TfrmHelp = class(TForm)
    mmoHelp01: TMemo;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
  private
    { private declarations }

    procedure FillHelp();
  public
    { public declarations }
  end; 

var
  frmHelp: TfrmHelp;

implementation

uses
  m_tools, m_constant,c_appsettings, crt;

{$R *.lfm}

{ TfrmHelp }

procedure TfrmHelp.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
//
end;

procedure TfrmHelp.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmHelp.FormActivate(Sender: TObject);
begin
  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

  FillHelp;
end;

procedure TfrmHelp.FillHelp();
begin
  mmoHelp01.Font.Color:=clBlack;
  mmoHelp01.Lines.Clear;
  mmoHelp01.Append('');
  mmoHelp01.Append('Dit is Wobbelkassa, de applicatie waarmee een kassa kan worden gedraaid op de Wobbelbeurs.');
  mmoHelp01.Append('');
  mmoHelp01.Append('Het doel is om alle transacties (onder een transactie wordt verstaan alle artikelen die worden verkocht aan een koper in één keer en waarvoor één rekening wordt gemaakt) in te voeren in Wobbelkassa, waarna de resultaten van alle gebruikte kassa''s in een beurs kunnen worden samengevoegd en opgeslagen worden in een formaat dat in een spreadsheet programma kan worden ingelezen.');
  mmoHelp01.Append('');
  mmoHelp01.Append('Om de kassa te gebruiken moet eerst worden ingelogd.');
  mmoHelp01.Append('De juiste beurs (er kunnen in principe meerdere beuren worden opgeslagen in de database) en kassa (iedere kassa heeft zijn eigen versie van deze applicatie) moeten worden geselecteerd voordat er kan worden gewerkt met Wobbelkassa.');
  mmoHelp01.Append('');
  mmoHelp01.Append('Na inloggen moet de kassa worden geopend: het contant aanwezige bedrag bij de kassa moet worden ingevoerd.');
  mmoHelp01.Append('Na uitloggen of afsluiten van de applicatie moet de kassa worden gesloten: het contant aanwezige geld moet weer worden ingevoerd. Dit is nodig om extra checks te kunnen uitvoeren als het nodig is, na samenvoegen van alle kassa''s.');

end;

end.

