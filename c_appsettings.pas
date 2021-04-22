//------------------------------------------------------------------------------
// Name        : c_appsettings
// Purpose     : Implementatie van TAppSettings.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : - Deze klasse bevat de settings en statussen zoals die voor de
//                 applicatie gelden.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------


unit c_appsettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  Graphics,
  c_beurs, c_vrijwilliger, c_kassa, c_verkoper;

type
  TWobbelLoginstatus = set of (lsNietIngelogd, lsIngelogdAdmin, lsIngelogdNoAdmin, lsLoginFail, lsNone);

type

  TAppSettings = class

    private

      FWobbelLoginStatus: TWobbelLoginstatus;

      FBeurs: TBeurs;
      FVrijwilliger: TVrijwilliger;
      FKassa: TKassa;
      FVerkoper: TVerkoper;

      FAantalTransactiesNaLaatsteBackup: integer;
      FMaxAantalTransactiesNaLaatsteBackup: integer;

      FDebugStatus:boolean;

      FGlobalFontSize: integer;
      FGlobalBackgroundColor:TColor;
      FGridBackgroundColorInactive:TColor;
      FGridBackgroundColorActive:TColor;

      // Eventuele korting op het artikel uitgedrukt als factor. factor 1.0 = geen korting,factor 0.5 = 50% korting
      FKortingsFactor:double;

      FErrorFileExtension: string;
      FLogFileExtension: string;

      function GetGlobalBackgroundColor:TColor;
      procedure SetGlobalBackgroundColor(newColor:TColor);

      function GetGridBackgroundColorInactive:TColor;
      procedure SetGridBackgroundColorInactive(newColor:TColor);

      function GetGridBackgroundColorActive:TColor;
      procedure SetGridBackgroundColorActive(newColor:TColor);

    public
      constructor Create;
      destructor Destroy;override;

      property WobbelLoginStatus: TWobbelLoginstatus read FWobbelLoginStatus write FWobbelLoginStatus;

      property Beurs: TBeurs read FBeurs write FBeurs;
      property Vrijwilliger: TVrijwilliger read FVrijwilliger write FVrijwilliger;
      property Kassa: TKassa read FKassa write FKassa;
      property Verkoper: TVerkoper read FVerkoper write FVerkoper;

      property AantalTransactiesNaLaatsteBackup: Integer read FAantalTransactiesNaLaatsteBackup write FAantalTransactiesNaLaatsteBackup;
      property MaxAantalTransactiesNaLaatsteBackup: Integer read FMaxAantalTransactiesNaLaatsteBackup write FMaxAantalTransactiesNaLaatsteBackup;

      property GlobalFontSize: Integer read FGlobalFontSize write FGlobalFontSize;
      procedure AdjustGlobalFontSize(newsize:Integer);

      property KortingsFactor: double read FKortingsFactor write FKortingsFactor;
      property GlobalBackgroundColor: TColor read GetGlobalBackgroundColor write SetGlobalBackgroundColor;

      property GridBackgroundColorInactive: TColor read FGridBackgroundColorInactive write SetGridBackgroundColorInactive;
      property GridBackgroundColorActive: TColor read FGridBackgroundColorActive write SetGridBackgroundColorActive;

      property DebugStatus: Boolean read FDebugStatus;

      function GetLogFileExtension:string;
      function GetErrorFileExtension:string;
end;

var
  AppSettings: TAppSettings;

//------------------------------------------------------------------------------
implementation

uses
  IniFiles,
  strutils,
  m_Constant,
  m_tools;

//------------------------------------------------------------------------------
constructor TAppSettings.Create;
var
  INI:TINIFile;
  R,G,B:Byte;
  RGB:string;
begin
  inherited;

  FAantalTransactiesNaLaatsteBackup:=0;
  try
    INI := TINIFile.Create(GetDefaultWobbelInifilename);
    FMaxAantalTransactiesNaLaatsteBackup := INI.ReadInteger('INIT','MaxAantalTransactiesNaLaatsteBackup',c_defaultMaxAantalTransactiesNaLaatsteBackup);
    FGlobalFontSize := INI.ReadInteger('FONTS','GlobalFontsize',c_defaultFontsize);
    KortingsFactor:=m_tools.PercentageToFactor(INI.ReadFloat('INIT','KortingsPercentage',0));

    RGB:=INI.ReadString('ACHTERGROND','GlobalBackgroundColorRGB',c_defaultBackgroundColorAsString);
    R:=Byte(StrToInt(ExtractDelimited(1,RGB,[','])));
    G:=Byte(StrToInt(ExtractDelimited(2,RGB,[','])));
    B:=Byte(StrToInt(ExtractDelimited(3,RGB,[','])));
    // kleurtje ....
    //FGlobalBackgroundColor:=RGBToColor(R, G, B);
    // .... of de default?
    FGlobalBackgroundColor:=clDefault;


    RGB:=INI.ReadString('ACHTERGROND','GridBackgroundColorInactiveRGB',c_defaultGridBackgroundColorInactiveAsString);
    R:=Byte(StrToInt(ExtractDelimited(1,RGB,[','])));
    G:=Byte(StrToInt(ExtractDelimited(2,RGB,[','])));
    B:=Byte(StrToInt(ExtractDelimited(3,RGB,[','])));
    FGridBackgroundColorInactive:=RGBToColor(R, G, B);


    RGB:=INI.ReadString('ACHTERGROND','GridBackgroundColorActiveRGB',c_defaultGridBackgroundColorActiveAsString);
    R:=Byte(StrToInt(ExtractDelimited(1,RGB,[','])));
    G:=Byte(StrToInt(ExtractDelimited(2,RGB,[','])));
    B:=Byte(StrToInt(ExtractDelimited(3,RGB,[','])));
    FGridBackgroundColorActive:=RGBToColor(R, G, B);

    FDebugStatus:=INI.ReadBool('INIT','DebugStatus',false);

  finally
    Ini.Free;
  end;

  FWobbelLoginStatus:=[lsNietIngelogd];

  FBeurs:=TBeurs.Create;
  //FBeurs.setBeursProperties;

  FVrijwilliger:=TVrijwilliger.Create;
  FVerkoper:=TVerkoper.Create;

  FKassa:=TKassa.Create;
  //FKassa.setKassaProperties(FBeurs.BeursId);

end;


//------------------------------------------------------------------------------
destructor TAppSettings.Destroy;
begin
  if (FBeurs <> nil) then
  begin
    FBeurs.Free;
  end;
  if (FVrijwilliger <> nil) then
  begin
    FVrijwilliger.Free;
  end;
  if (FKassa <> nil) then
  begin
    FKassa.Free;
  end;
  if (FVerkoper <> nil) then
  begin
    FVerkoper.Free;
  end;
  inherited Destroy;
end;

procedure TAppSettings.AdjustGlobalFontSize(newsize:Integer);
begin
  //
  FGlobalFontSize:=newsize;
  if (FGlobalFontSize<5) then
  begin
    FGlobalFontSize:=5;
  end;
  m_tools.SetValueInIniFile('FONTS','GlobalFontSize',IntToStr(FGlobalFontSize));
end;

//------------------------------------------------------------------------------
function TAppSettings.GetLogFileExtension:string;
begin
  FLogFileExtension:=c_LogFileExtension;
  GetLogFileExtension := FLogFileExtension;
end;

//------------------------------------------------------------------------------
function TAppSettings.GetErrorFileExtension:string;
begin
  FErrorFileExtension:=c_ErrorFileExtension;
  GetErrorFileExtension := FErrorFileExtension;
end;

function TAppSettings.GetGlobalBackgroundColor:TColor;
begin
  Result:=FGlobalBackgroundColor;
end;

procedure TAppSettings.SetGlobalBackgroundColor(newColor:TColor);
begin
  FGlobalBackgroundColor:=newColor;
  m_tools.SetValueInIniFile('ACHTERGROND','GlobalBackgroundColorRGB',IntToStr(Red(newColor))+','+IntToStr(Green(newColor))+','+IntToStr(Blue(newColor)));//'clMoneyGreen');
end;

function TAppSettings.GetGridBackgroundColorInactive:TColor;
begin
  Result:=FGridBackgroundColorInactive;
end;

procedure TAppSettings.SetGridBackgroundColorInactive(newColor:TColor);
begin
  FGridBackgroundColorInactive:=newColor;
  m_tools.SetValueInIniFile('ACHTERGROND','GridBackgroundColorInactiveRGB',IntToStr(Red(newColor))+','+IntToStr(Green(newColor))+','+IntToStr(Blue(newColor)));
end;


function TAppSettings.GetGridBackgroundColorActive:TColor;
begin
  Result:=FGridBackgroundColorActive;
end;

procedure TAppSettings.SetGridBackgroundColorActive(newColor:TColor);
begin
  FGridBackgroundColorActive:=newColor;
  m_tools.SetValueInIniFile('ACHTERGROND','GridBackgroundColorActiveRGB',IntToStr(Red(newColor))+','+IntToStr(Green(newColor))+','+IntToStr(Blue(newColor)));
end;



//------------------------------------------------------------------------------
initialization
  //AppSettings:=TAppSettings.Create;

//------------------------------------------------------------------------------
finalization
// wordt opgeruimd in de destroyer van het object waarin-ie wordt aangemaakt: TForm
  //if (AppSettings <> nil) then
  //begin
  //  AppSettings.Free;
  //end;

end.

