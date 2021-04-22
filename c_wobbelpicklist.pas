unit c_wobbelpicklist;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

type
  TPicklistItem = class;

  TPicklistItem = class
    private
      FID: integer;
      FOmschrijving: string;
      FOpmerkingen : string;
      FNaam:string;
    Public
      Constructor Create(ID : integer; Omschrijving, Opmerkingen : string);
      Constructor Create(ID : integer; Naam, Omschrijving, Opmerkingen : string);
      Property ID : integer read FID;
      Property Omschrijving : String read FOmschrijving;
      Property Opmerkingen : String read FOpmerkingen;
      Property Naam : String read FNaam;
  end;

implementation

uses
  m_tools, m_wobbelglobals;

//TPicklistItem
Constructor TPicklistItem.Create(ID : integer; Omschrijving, Opmerkingen : string);
begin
  inherited Create;
  FID := ID;
  FOmschrijving := Omschrijving;
  FOpmerkingen := Opmerkingen;
  FNaam := MakePicklistItemDescription(Omschrijving, Opmerkingen);
end;

Constructor TPicklistItem.Create(ID : integer; Naam, Omschrijving, Opmerkingen : string);
begin
  inherited Create;
  FID := ID;
  FOmschrijving := Omschrijving;
  FOpmerkingen := Opmerkingen;
  FNaam := Naam;
end;


end.

