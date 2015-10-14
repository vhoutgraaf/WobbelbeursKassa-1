unit formverkopersbeheren;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, StdCtrls, Buttons, c_appsettings, c_gridverkoper;

type
  TVerkoperInlezer = class
    private
      FError: string;


    public

      ColumnCount:integer;

      VereisteKolommen:string;

      colnr_verkopercode: integer;
      verkopercode: string;

      colnr_achternaam: integer;
      achternaam: string;

      colnr_rekeningnummer: integer;
      rekeningnummer: string;

      colnr_rekeningopnaam: integer;
      rekeningopnaam: string;

      colnr_rekeningbanknaam: integer;
      rekeningbanknaam: string;

      colnr_rekeningplaats: integer;
      rekeningplaats: string;

      colnr_email: integer;
      email: string;

      colnr_telefoonmobiel1: integer;
      telefoonmobiel1: string;

      colnr_aanhef: integer;
      aanhef: string;

      colnr_voorletters: integer;
      voorletters: string;

      colnr_tussenvoegsel: integer;
      tussenvoegsel: string;

      colnr_straat: integer;
      straat: string;

      colnr_huisnr: integer;
      huisnr: string;

      colnr_huisnrtoevoeging: integer;
      huisnrtoevoeging: string;

      colnr_postcode: integer;
      postcode: string;

      colnr_woonplaats: integer;
      woonplaats: string;

      colnr_opmerkingen: integer;
      opmerkingen: string;

      colnr_telefoonmobiel2: integer;
      telefoonmobiel2: string;

      colnr_telefoonvast: integer;
      telefoonvast: string;

      colnr_saldobetalingcontant: integer;
      saldobetalingcontant: string;

      constructor Create;
      destructor Destroy;override;

      procedure ResetAll;
      procedure ResetValues;
      function HeeftVoldoendeKolommen: boolean;
      function HeeftVoldoendeWaardes: boolean;
      procedure FillValue(sTmp: string; colNr: integer);
      procedure FillIndex(sTmp: string; colNr: integer);

  end;


type

  { TfrmVerkopersbeheren }

  TfrmVerkopersbeheren = class(TForm)
    btnImporteerVerkopers: TButton;
    btnExporteerVerkopers: TButton;
    btnInfo01: TBitBtn;
    btnInfo02: TBitBtn;

    gridpanelVerkopersbeheren: TGridVerkoper;
    grpImporteerVerkopers: TGroupBox;
    grpExporteerVerkopers: TGroupBox;
    dlgOpenVerkopers: TOpenDialog;
    Label1: TLabel;
    pnlVerkopersInvoeren: TPanel;
    pnlVerkopersbeheren: TPanel;
    dlgSaveVerkopers: TSaveDialog;


    procedure btnExporteerVerkopersClick(Sender: TObject);
    procedure btnImporteerVerkopersClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);

    procedure ActivateVerkopersBeheergrid();
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }

    function VeranderingenOpgeslagenBijVerlaten:boolean;
    function VoegToeAanGrid(VI: TVerkoperInlezer; currentRownr:integer):string;

  public
    { public declarations }
  end;

var
  frmVerkopersbeheren: TfrmVerkopersbeheren;

implementation

uses
  c_wobbelgridpanel, m_tools, m_constant, m_error,
  fpspreadsheet, xlsbiff8, laz_fpspreadsheet, crt;     // voor Excel inlezen

{$R *.lfm}

constructor TVerkoperInlezer.Create;
begin
  inherited;
  ColumnCount:=20;
  ResetAll;
  FError:='';
end;

//------------------------------------------------------------------------------
destructor TVerkoperInlezer.Destroy;
begin
  inherited Destroy;
end;

function TVerkoperInlezer.HeeftVoldoendeWaardes: boolean;
var
  isOk:boolean;
begin
  //VereisteKolommen:='Inbrengercode, Achternaam, Rekeningnummer, Straat, Huisnr, Postcode, Woonplaats';
  VereisteKolommen:='Inbrengercode';
  isOk:=true;
  isOk:=isOk and (verkopercode<>'');
//  isOk:=isOk and (achternaam<>'');
//  isOk:=isOk and (rekeningnummer<>'');
//  isOk:=isOk and (woonplaats<>'');
//  isOk:=isOk and (postcode<>'');
//  isOk:=isOk and (huisnr<>'');
//  isOk:=isOk and (straat<>'');
  Result:=isOk;
end;

function TVerkoperInlezer.HeeftVoldoendeKolommen(): boolean;
var
  isOk:boolean;
begin
  //VereisteKolommen:='Inbrengercode, Achternaam, Rekeningnummer, Straat, Huisnr, Postcode, Woonplaats';
  VereisteKolommen:='Inbrengercode';
  isOk:=true;
  isOk:=isOk and (colnr_verkopercode<>-1);
//  isOk:=isOk and (colnr_achternaam<>-1);
//  isOk:=isOk and (colnr_rekeningnummer<>-1);
//  isOk:=isOk and (colnr_woonplaats<>-1);
//  isOk:=isOk and (colnr_postcode<>-1);
//  isOk:=isOk and (colnr_huisnr<>-1);
//  isOk:=isOk and (colnr_straat<>-1);
  Result:=isOk;
end;

procedure TVerkoperInlezer.FillValue(sTmp: string; colNr: integer);
begin
  if (colNr=colnr_verkopercode) then
  begin
    verkopercode:=sTmp;
  end
  else if (colNr=colnr_achternaam) then
  begin
    achternaam:=sTmp;
  end
  else if (colNr=colnr_rekeningnummer) then
  begin
    rekeningnummer:=sTmp;
  end
  else if (colNr=colnr_rekeningopnaam) then
  begin
    rekeningopnaam:=sTmp;
  end
  else if (colNr=colnr_rekeningbanknaam) then
  begin
    rekeningbanknaam:=sTmp;
  end
  else if (colNr=colnr_rekeningplaats) then
  begin
    rekeningplaats:=sTmp;
  end
  else if (colNr=colnr_email) then
  begin
    email:=sTmp;
  end
  else if (colNr=colnr_telefoonmobiel1) then
  begin
    telefoonmobiel1:=sTmp;
  end
  else if (colNr=colnr_aanhef) then
  begin
    aanhef:=sTmp;
  end
  else if (colNr=colnr_voorletters) then
  begin
    voorletters:=sTmp;
  end
  else if (colNr=colnr_tussenvoegsel) then
  begin
    tussenvoegsel:=sTmp;
  end
  else if (colNr=colnr_straat) then
  begin
    straat:=sTmp;
  end
  else if (colNr=colnr_huisnr) then
  begin
    huisnr:=sTmp;
  end
  else if (colNr=colnr_huisnrtoevoeging) then
  begin
    huisnrtoevoeging:=sTmp;
  end
  else if (colNr=colnr_postcode) then
  begin
    postcode:=sTmp;
  end
  else if (colNr=colnr_woonplaats) then
  begin
    woonplaats:=sTmp;
  end
  else if (colNr=colnr_opmerkingen) then
  begin
    opmerkingen:=sTmp;
  end
  else if (colNr=colnr_telefoonmobiel2) then
  begin
    telefoonmobiel2:=sTmp;
  end
  else if (colNr=colnr_telefoonvast) then
  begin
    telefoonvast:=sTmp;
  end
  else if (colNr=colnr_saldobetalingcontant) then
  begin
    saldobetalingcontant:=sTmp;
  end;
end;

procedure TVerkoperInlezer.FillIndex(sTmp:string; colNr:integer);
begin
  if (stmp='verkopercode') then
  begin
    colnr_verkopercode:=colNr;
  end
  else if (stmp='achternaam') then
  begin
    colnr_achternaam:=colNr;
  end
  else if (stmp='rekeningnummer') then
  begin
    colnr_rekeningnummer:=colNr;
  end
  else if (stmp='rekeningopnaam') then
  begin
    colnr_rekeningopnaam:=colNr;
  end
  else if (stmp='rekeningbanknaam') then
  begin
    colnr_rekeningbanknaam:=colNr;
  end
  else if (stmp='rekeningplaats') then
  begin
    colnr_rekeningplaats:=colNr;
  end
  else if (stmp='email') then
  begin
    colnr_email:=colNr;
  end
  else if (stmp='telefoonmobiel1') then
  begin
    colnr_telefoonmobiel1:=colNr;
  end
  else if (stmp='aanhef') then
  begin
    colnr_aanhef:=colNr;
  end
  else if (stmp='voorletters') then
  begin
    colnr_voorletters:=colNr;
  end
  else if (stmp='tussenvoegsel') then
  begin
    colnr_tussenvoegsel:=colNr;
  end
  else if (stmp='straat') then
  begin
    colnr_straat:=colNr;
  end
  else if (stmp='huisnr') then
  begin
    colnr_huisnr:=colNr;
  end
  else if (stmp='huisnrtoevoeging') then
  begin
    colnr_huisnrtoevoeging:=colNr;
  end
  else if (stmp='postcode') then
  begin
    colnr_postcode:=colNr;
  end
  else if (stmp='woonplaats') then
  begin
    colnr_woonplaats:=colNr;
  end
  else if (stmp='opmerkingen') then
  begin
    colnr_opmerkingen:=colNr;
  end
  else if (stmp='telefoonmobiel2') then
  begin
    colnr_telefoonmobiel2:=colNr;
  end
  else if (stmp='telefoonvast') then
  begin
    colnr_telefoonvast:=colNr;
  end
  else if (stmp='saldobetalingcontant') then
  begin
    colnr_saldobetalingcontant:=colNr;
  end;
end;


procedure TVerkoperInlezer.ResetAll;
begin
  colnr_verkopercode:=-1;
  verkopercode:='';

  colnr_achternaam:=-1;
  achternaam:='';

  colnr_rekeningnummer:=-1;
  rekeningnummer:='';

  colnr_rekeningopnaam:=-1;
  rekeningopnaam:='';

  colnr_rekeningbanknaam:=-1;
  rekeningbanknaam:='';

  colnr_rekeningplaats:=-1;
  rekeningplaats:='';

  colnr_email:=-1;
  email:='';

  colnr_telefoonmobiel1:=-1;
  telefoonmobiel1:='';

  colnr_aanhef:=-1;
  aanhef:='';

  colnr_voorletters:=-1;
  voorletters:='';

  colnr_tussenvoegsel:=-1;
  tussenvoegsel:='';

  colnr_straat:=-1;
  straat:='';

  colnr_huisnr:=-1;
  huisnr:='';

  colnr_huisnrtoevoeging:=-1;
  huisnrtoevoeging:='';

  colnr_postcode:=-1;
  postcode:='';

  colnr_woonplaats:=-1;
  woonplaats:='';

  colnr_opmerkingen:=-1;
  opmerkingen:='';

  colnr_telefoonmobiel2:=-1;
  telefoonmobiel2:='';

  colnr_telefoonvast:=-1;
  telefoonvast:='';

  colnr_saldobetalingcontant:=-1;
  saldobetalingcontant:='';
end;

procedure TVerkoperInlezer.ResetValues;
begin
  verkopercode:='';
  achternaam:='';
  rekeningnummer:='';
  rekeningopnaam:='';
  rekeningbanknaam:='';
  rekeningplaats:='';
  email:='';
  telefoonmobiel1:='';
  aanhef:='';
  voorletters:='';
  tussenvoegsel:='';
  straat:='';
  huisnr:='';
  huisnrtoevoeging:='';
  postcode:='';
  woonplaats:='';
  opmerkingen:='';
  telefoonmobiel2:='';
  telefoonvast:='';
  saldobetalingcontant:='';
end;

{ TfrmVerkopersbeheren }

procedure TfrmVerkopersbeheren.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  CanClose:=true;
  if (VeranderingenOpgeslagenBijVerlaten()) then
  begin
    CanClose:=false;
  end;
end;

procedure TfrmVerkopersbeheren.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);

  ActivateVerkopersBeheergrid();

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
end;

procedure TfrmVerkopersbeheren.btnExporteerVerkopersClick(Sender: TObject);
begin
  m_tools.ExporteerQuery(nil, nil, gridpanelVerkopersbeheren.GridSql, 'Inbrengers');
end;

procedure TfrmVerkopersbeheren.btnImporteerVerkopersClick(Sender: TObject);
var
  fname:string;
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  i, ii: Integer;
  rowNr, colNr:integer;
  CurCell: PCell;
  sTmp:string;
  VI: TVerkoperInlezer;
  totalImportedCount:integer;
  sError:string;
begin
  try
    if dlgOpenVerkopers.Execute then
    begin
      fname:=dlgOpenVerkopers.Filename;
      if (fname = '') then
      begin
        MessageError('Geen bestandsnaam gekozen');
      end
      else
      begin
        VI:=TVerkoperInlezer.Create;
        MyWorkbook := TsWorkbook.Create;
        MyWorkbook.ReadFromFile(fname, sfExcel8);
        MyWorksheet := MyWorkbook.GetFirstWorksheet;
        try
          totalImportedCount:=0;

          rowNr:=0;
          colNr:=-1;
          CurCell := MyWorkSheet.GetFirstCell();
          for i := 0 to MyWorksheet.GetCellCount - 1 do
          begin
            rowNr:=CurCell^.Row;
            colNr:=CurCell^.Col;
            if (rowNr = 0) then
            begin
              sTmp:=AnsiLowerCase(UTF8ToAnsi(MyWorkSheet.ReadAsUTF8Text(rowNr, colNr)));
              VI.FillIndex(sTmp, colNr);
            end
            else
            begin
              // eerste waarde?
              if (colNr = 0) then
              begin
                if (rowNr = 1) then
                begin
                  if (not VI.HeeftVoldoendeKolommen) then
                  begin
                    raise EWobbelError.Create('Er zijn niet genoeg kolommen aanwezig. Vereist zijn: ' + VI.VereisteKolommen);
                  end
                end
                else
                begin
                  sError:=VoegToeAanGrid(VI, rownr);
                  if (sError <> '') then
                  begin
                    raise EWobbelError.Create(sError);
                  end;
                  totalImportedCount:=totalImportedCount + 1;
                  Vi.ResetValues;
                end;
              end;
              sTmp:=UTF8ToAnsi(MyWorkSheet.ReadAsUTF8Text(rowNr, colNr));
              VI.FillValue(sTmp, colNr);
            end;
            sTmp:='Row: ' + IntToStr(rowNr) + ' Col: ' + IntToStr(colNr) + ' Value: ' + UTF8ToAnsi(MyWorkSheet.ReadAsUTF8Text(rowNr, colNr));
            CurCell := MyWorkSheet.GetNextCell();
          end;

          if (rownr>0) then
          begin
            sError:=VoegToeAanGrid(VI, rownr);
            if (sError <> '') then
            begin
              raise EWobbelError.Create(sError);
            end;
            totalImportedCount:=totalImportedCount + 1;
          end;
          gridpanelVerkopersbeheren.PostData;

          if (totalImportedCount > 0) then
          begin
            MessageOk(IntToStr(totalImportedCount) + ' verkopers zijn geimporteerd van bestand "'+fname+'"');
          end;

        finally
          MyWorkbook.Free;
          VI.Free;
        end;

      end;
    end;
  except
    on E: EWobbelError do
    begin
      gridpanelVerkopersbeheren.FillGrid;
      MessageError(E.Message + ' De import is teruggedraaid. (Verbeter de fouten in het Excel bestand en probeer het nogmaals)');
    end;
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

function TfrmVerkopersBeheren.VoegToeAanGrid(VI: TVerkoperInlezer; currentRownr:integer):string;
var
  ii:integer;
  sTmp:string;
  gridRownr:integer;
  sRet:string;
begin
  sRet:='';
  if (VI.HeeftVoldoendeWaardes) then
  begin
    gridpanelVerkopersbeheren.AddARecord();
    gridRownr:=gridpanelVerkopersbeheren.WobbelGrid.Row;
    gridpanelVerkopersbeheren.SetDirtyRow(gridRownr, true);
    for ii:=gridpanelVerkopersbeheren.WobbelGrid.FixedCols to gridpanelVerkopersbeheren.WobbelGrid.ColCount - 1 do
    begin
      sTmp:=AnsiLowerCase((gridpanelVerkopersbeheren.lstColTypes[ii-1] as TWobbelGridColumnProps).DatabaseFieldname);
      if (sTmp='verkopercode') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.verkopercode;
      end
      else if (sTmp='achternaam') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.achternaam;
      end
      else if (sTmp='rekeningnummer') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.rekeningnummer;
      end
      else if (sTmp='rekeningopnaam') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.rekeningopnaam;
      end
      else if (sTmp='rekeningbanknaam') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.rekeningbanknaam;
      end
      else if (sTmp='rekeningplaats') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.rekeningplaats;
      end
      else if (sTmp='email') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.email;
      end
      else if (sTmp='telefoonmobiel1') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.telefoonmobiel1;
      end
      else if (sTmp='aanhef') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.aanhef;
      end
      else if (sTmp='voorletters') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.voorletters;
      end
      else if (sTmp='tussenvoegsel') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.tussenvoegsel;
      end
      else if (sTmp='straat') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.straat;
      end
      else if (sTmp='huisnr') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.huisnr;
      end
      else if (sTmp='huisnrtoevoeging') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.huisnrtoevoeging;
      end
      else if (sTmp='postcode') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.postcode;
      end
      else if (sTmp='woonplaats') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.woonplaats;
      end
      else if (sTmp='opmerkingen') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.opmerkingen;
      end
      else if (sTmp='telefoonmobiel2') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.telefoonmobiel2;
      end
      else if (sTmp='telefoonvast') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.telefoonvast;
      end
      else if (sTmp='saldobetalingcontant') then
      begin
        gridpanelVerkopersbeheren.WobbelGrid.Cells[ii,gridRownr]:=VI.saldobetalingcontant;
      end;
    end;
    sRet:=gridpanelVerkopersbeheren.CheckGridValues(-1);
  end
  else
  begin
    sRet:='Record # ' + IntToStr(currentRownr) + ' heeft te weinig informatie.  Vereist zijn: ' + VI.VereisteKolommen;
  end;

  Result:=sRet;
end;


procedure TfrmVerkopersbeheren.FormCreate(Sender: TObject);
begin
  btnInfo01.Hint:='Exporteer de lijst met inbrengers naar een MS Excel 97 bestand.';
  btnInfo02.Hint:='Importeer een lijst met Inbrengers, vanuit een MS Excel bestand. '+c_CR+
                  'Let op: alleen MS Excel 97 versie is getest.'+c_CR+
                  'De import wordt afgebroken zodra een fout wordt geconstateerd. Een dubbele inbrengercode geldt als fout.'+c_CR+
                  'Tip: om een Excel bestand in een geschikt formaat te krijgen om inbrengers te kunnen invoeren is het handig om eerst een export te maken en in dat bestand te gaan werken. '+c_CR+
                  'Niet alle velden in het exportbestand zijn nodig om in te vullen: vereist is alleen de Inbrengercode.';
end;

procedure TfrmVerkopersbeheren.FormDestroy(Sender: TObject);
begin
  if (gridpanelVerkopersbeheren <> nil) then
  begin
    gridpanelVerkopersbeheren.Free;
  end;
end;


function TfrmVerkopersbeheren.VeranderingenOpgeslagenBijVerlaten:boolean;
begin
  Result:=false;
  if (gridpanelVerkopersbeheren <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelVerkopersbeheren.AnyRowIsDirty) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Verkopers-beheertabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        gridpanelVerkopersbeheren.PostData;
        Result:=true;
      end
      else
      begin
        gridpanelVerkopersbeheren.FillGrid;
      end;
    end;
  end;
end;

procedure TfrmVerkopersbeheren.FormDeactivate(Sender: TObject);
begin
  VeranderingenOpgeslagenBijVerlaten;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmVerkopersbeheren.ActivateVerkopersBeheergrid();
begin
  if (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelVerkopersbeheren = nil) then
    begin
      gridpanelVerkopersbeheren:=TGridVerkoper.CreateMe(Self, pnlVerkopersbeheren,
          pnlVerkopersbeheren.Top,
          2,
          pnlVerkopersbeheren.Height-2,
          AppSettings.Beurs.BeursId);
    end
    else
    begin
      gridpanelVerkopersbeheren.Visible:=true;
      gridpanelVerkopersbeheren.BeursId:=AppSettings.Beurs.BeursId; //nieuw
      gridpanelVerkopersbeheren.SetGridProps; //nieuw
      gridpanelVerkopersbeheren.FillGrid();
    end;
    gridpanelVerkopersbeheren.SetGridStatus([WSENABLEDEDITABLE]);
  end
  else
  begin
    if (gridpanelVerkopersbeheren <> nil) then
    begin
      gridpanelVerkopersbeheren.Visible:=false;
    end;
  end;
end;



end.

