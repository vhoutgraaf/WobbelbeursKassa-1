unit formabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    lblWKVersie: TLabel;
    mmoAbout: TMemo;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
  private
    { private declarations }

    procedure FillAbout();

  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  m_tools, m_constant,c_appsettings, crt,
  vinfo;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormActivate(Sender: TObject);
var
  Info: TVersionInfo;
begin
  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

  FillAbout;

  // oud
  lblWKVersie.Caption:=m_constant.c_AppCaption;

  // nieuw
  try
    Info := TVersionInfo.Create;
    Info.Load(HINSTANCE);
    // [0] = Major version, [1] = Minor ver, [2] = Revision, [3] = Build Number

    lblWKVersie.Caption:=m_constant.c_AppName + ' ' +
                         IntToStr(Info.FixedInfo.FileVersion[0]) + '.' +
                         IntToStr(Info.FixedInfo.FileVersion[1]) + '.' +
                         IntToStr(Info.FixedInfo.FileVersion[2]) + '.' +
                         IntToStr(Info.FixedInfo.FileVersion[3]);
  finally
    Info.Free;
  end;

end;

procedure TfrmAbout.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TfrmAbout.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmAbout.FillAbout();
begin
  mmoAbout.Font.Color:=clBlack;
  mmoAbout.Lines.Clear;
  mmoAbout.Append('');
  mmoAbout.Append('Wobbelbeurs Kassa is gemaakt met Free & Open Source Software:');
  mmoAbout.Append('- Ontwikkeltaal / omgeving: Free Pascal / Lazarus (www.freepascal.org);');
  mmoAbout.Append('- Database: SQLite (www.sqlite.org);');
  mmoAbout.Append('- Iconen: FamFamFam (www.famfamfam.com).');
  mmoAbout.Append('');
  mmoAbout.Append('');
  mmoAbout.Append('Release notes versie 1.11.0.x (maart 2014):');
  mmoAbout.Append('- Export van overzichten kan nu ook in centen in plaats van euro''s. Het decimaalscheidingsteken is dan dus verdwenen. Hiermee worden fouten voorkomen als export van de overzichten en inlezen in Excel op verschillende machines gebeurt waar het decimaalscheidingsteken niet hetzelfde is.');
  mmoAbout.Append('- Bij een nieuwe transactie is de betaalwijze niet meer voorgeselecteerd op een standaardwaarde, maar moet expliciet worden ingevuld. Als dat niet is gebeurd kan de transactie pas worden opgeslagen als een keuze is gemaakt.');
  mmoAbout.Append('- Als ingelogd is als beheerder hoeft niet meer per se eerst een kassa te worden gekozen. Een beurs is wel altijd nodig.');
  mmoAbout.Append('- Aanpassingen aan export:export van bedragen in Centen werd niet als integer veld geinterpreteerd in Excel.');
  mmoAbout.Append('');
  mmoAbout.Append('Release notes versie 1.10.0.x:');
  mmoAbout.Append('- Bug in samenvoegen van kassa''s waarbij komma''s en punten niet goed gingen in de bedragen, opgelost.');
  mmoAbout.Append('- Afbeelding toegevoegd in het transactiescherm dat verschijnt na ''opslaan'' en weer verdwijnt na weklikken van de ''ok'' popupm, ter voorkoming van misverstanden bij gebruikers.');
  mmoAbout.Append('');
  mmoAbout.Append('Release notes versie 1.9.0.x:');
  mmoAbout.Append('- Groottes van de schermen, en schaling van onderdelen in transactiescherm en hoofdscherm, aangepast zodat ook op een notebook met een schermhoogte van 600 pixels alles te lezen is.');
  mmoAbout.Append('');
  mmoAbout.Append('Release notes versie 1.8.0.x:');
  mmoAbout.Append('- Combobox in het transactieartikelgrid veranderd in een standaard inputveld omdat een bug in de gebruikte gridcomponent bij gebruik van een lookup-inputveld ervoor zorgde dat het kon voorkomen dat ingevulde tekens van volgorde veranderden. Er wordt nog steeds getest of een ingevulde inbrengercode in de lijst voorkomt.');
  mmoAbout.Append('');
  mmoAbout.Append('Release notes versie 1.7.0.x:');
  mmoAbout.Append('- Bugs bij gebruik van pijlbuttons voor navigeren in het transactieartikelgrid opgelost.');
  mmoAbout.Append('- Overbodige kolom onzichtbaar gemaakt in de beurs-tabel.');
  mmoAbout.Append('- Export naar Excel 97 (*.xls) uitgebreid met export naar Excel 2000 (*.xlsx), Open Document formaat (*.ods) en Comma Seperated Value (*.csv).');
  mmoAbout.Append('  N.B ODS-documenten zijn te lezen door Excel 2000 en hoger; CSV documenten door alle Excel versies. ');
  mmoAbout.Append('  Bij openen van een .csv bestand in Excel is het aan te bevelen om eerst een ''Opslaan als'' te doen, naar een echt Excel formaat.');
  mmoAbout.Append('  Bij (zeer) grote bestanden werken .xls, .xlsx en .ods niet meer, dan moet de tussenstap via csv worden gedaan.');
  mmoAbout.Append('  Export naar csv gaat het snelst. Export naar ods duurt het langst.');
  mmoAbout.Append('  Aan te raden is om indien mogelijk xlsx bestanden te maken.');
  mmoAbout.Append('- In de importkassa log het vermelden van de actie per artikel verwijderd en vervangen door een totaal.');
  mmoAbout.Append('- In importkassa worden nu de "datumtijdinvoeren" en "datumtijdwijzigen" van transacties mee overgenomen.');
  mmoAbout.Append('- Bij de  "Exporteer" en "Importeer kassa" knoppen is een progressbar toegevoegd.');
  mmoAbout.Append('- Het (dit) "Over.."-scherm toegevoegd.');
  mmoAbout.Append('- Versieinformatie verplaatst van het "Help"-scherm naar het "Over.."-scherm .');
  mmoAbout.SelStart:=0;
  mmoAbout.ScrollBy(0,-1000);

end;


end.

