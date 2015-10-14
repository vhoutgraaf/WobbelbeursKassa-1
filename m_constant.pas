//------------------------------------------------------------------------------
// Name        : m_constant
// Purpose     : Implementatie van constanten.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : -
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_constant;

{$mode objfpc}{$H+}

interface

uses
  Controls,Graphics;

const
  c_AppName = 'Wobbel Beurskassa';


  // http://msdn.microsoft.com/en-us/library/aa365247.aspx#maxpath
  // Lijkt helaas niet te werken in de combinatie met FP libs
  //c_LongPathPrefix = '\\?\';
  c_LongPathPrefix = '';

  c_ErrorFileExtension = 'err';
  c_LogFileExtension = 'log';

  c_AppVersion = '1';
  c_AppSubVersion = '7';
  c_AppYear = 'Jan. 2013';

  c_AppCaption = c_AppName + ' ' + c_AppVersion + '.' + c_AppSubVersion;
  c_AppCopyright = '© Vincent Houtgraaf, ' + c_AppYear;

  c_AppSplashTime = 1000;
  c_DeactiveDelay_msec = 250;

  c_CR = chr(13);
  c_TAB = chr(9);
  // CSV separator in code bepalen: als de decimalseparator een komma is, dan een puntkomma gebruiken.
  // Is decimalseparator een punt, dan een komma gebruiken.
  // Hiermee kan je een csv-bestand meteen openen in Excel zonder te hoeven importeren.
  //c_CSVSeparator = chr(44); //(komma)
  //c_CSVSeparator = chr(59); //(puntkomma)
  c_CSVFieldBorder = chr(34); // "

  c_admin = 'beheerder';

  c_defaultFontsize = 10;

  c_defaultBackgroundColorAsString = '192,220,192';
  c_defaultGridBackgroundColorActiveAsString = '255,255,225';
  c_defaultGridBackgroundColorInactiveAsString = '212,208,200';

  c_defaultMaxAantalTransactiesNaLaatsteBackup = 5;

  c_ActivePanelColor=clOlive;
  c_InactivePanelColor=clDefault;
  c_ActivePanelCursor=crHandPoint;
  c_InactivePanelCursor=crDefault;

  c_ExportHint='Met "Exporteer" wordt een export gemaakt. '+c_CR+
    ' * Er kan een export naar Excel 97 (*.xls), Excel 2000 (*.xlsx), Open Document formaat (*.ods) en Comma Seperated Value (*.csv) worden gemaakt.'+c_CR+
    ' N.B ODS-documenten zijn te lezen door Excel 2000 en hoger; CSV documenten door alle Excel versies. ' + c_CR +
    ' * Bij openen van een .csv bestand in Excel is het aan te bevelen om eerst een ''Opslaan als'' te doen, naar een echt Excel formaat.' + c_CR +
    ' * Bij (zeer) grote bestanden werken .xls, .xlsx en .ods niet meer, dan moet de tussenstap via csv worden gedaan.'+c_CR+
    ' * Bij export moet bovendien rekening worden gehouden met het volgende:'+c_CR+
    '   Wanneer export op een andere computer wordt gedaan dan waar het exportbestand weer wordt geïmporteerd, EN er is '+c_CR+
    '   een verschil in het decimaalscheidingsteken tussen de twee computers (op de één een komma, op de ander een punt) '+c_CR+
    '   dan worden de decimale bedragen uit de export mogelijk niet goed geïnterpreteerd. '+c_CR+
    '   Bij export/import naar/van .xls lijkt dit geen probleem te zijn bij gebruik van een Excel versie hoger dan 2003. '+c_CR+
    '   Een .csv bestand kan eerst worden aangepast door in een tekstverwerker (notepad, textpad o.i.d; géén Word) punten door komma''s of vice versa  '+c_CR+
    '   te vervangen vóórdat het bestand wordt geïmporteerd.'+c_CR+
    ' * Export naar csv gaat het snelst.'+c_CR+
    ' * Export naar ods duurt het langst.'+c_CR+
    ' * Aan te raden is om indien mogelijk xls bestanden te maken.';

type
  TStrMessage = record
    Msg: Cardinal;
    Str: string;
  end;

type
   TLoginstatus = (Default, Ok, Fault);

type
   TKassastatus = (Open, Gesloten);

const
  c_Yes                            = 'Yes';
  c_No                             = 'No';
  c_NotApplicable                  = '-';
  c_NoValueFound                   = '';
  c_Empty                          = '';

implementation

initialization

end.

