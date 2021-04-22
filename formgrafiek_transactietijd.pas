unit formgrafiek_transactietijd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, TAGraph, TADbSource, TASeries, Forms,
  Controls, Graphics, Dialogs, ZDataset, TAChartAxisUtils, TATransformations;

type

  { TfrmTransactiesTegenTijd }

  TfrmTransactiesTegenTijd = class(TForm)
    ChartAxisTransformations1: TChartAxisTransformations;
    ChartAxisTransformations1AutoScaleAxisTransform1: TAutoScaleAxisTransform;
    chrtTransactieTijd: TChart;
    chrtTransactieTijdBarSeries: TBarSeries;
    dsTransactieTijd: TDatasource;
    DbChartSourceTransactieTijd: TDbChartSource;
    vwTransactieTijd: TZQuery;
    procedure chrtTransactieTijdAxisList1MarkToText(var AText: String;
      AMark: Double);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmTransactiesTegenTijd: TfrmTransactiesTegenTijd;

implementation

uses
  crt, m_constant, dateutils;

{$R *.lfm}

{ TfrmTransactiesTegenTijd }

procedure TfrmTransactiesTegenTijd.FormActivate(Sender: TObject);
begin
  vwTransactieTijd.Active:=true;
end;

procedure TfrmTransactiesTegenTijd.chrtTransactieTijdAxisList1MarkToText(
  var AText: String; AMark: Double);
begin
  //AText:=FormatDateTime('yyyy-mm-dd hh:nn:ss ',JulianDateToDateTime(AMark));
  //try
  //  AText:=FormatDateTime('hh:nn:ss ',JulianDateToDateTime(AMark));
  //except
  //  on E: Exception do
  //  begin
  //  //
  //  end;
  //end;
end;

procedure TfrmTransactiesTegenTijd.FormDeactivate(Sender: TObject);
begin
  vwTransactieTijd.Active:=false;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

end.

