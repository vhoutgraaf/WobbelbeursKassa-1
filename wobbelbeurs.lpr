program wobbelbeurs;

{$mode objfpc}{$H+}

uses
  SysUtils,
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, laz_fpspreadsheet, lazcontrols, tachartlazaruspkg, formmain,
  zcomponent, c_appsettings, m_constant, m_error, m_querystuff, m_wobbeldata,
  formsplash, crt, c_beurs, m_tools, c_vrijwilliger, c_verkoper,
  c_wobbelgridpanel, c_gridverkoper, c_gridvrijwilliger, m_wobbelglobals,
  formhelp, c_kassa, c_gridbeurskassa, c_gridbeurs, formdialoog,
  c_gridtransactie, c_gridtransactieartikel, forminstellingen,
  formbeursoverzicht, formbeurskassaoverzicht, formaccounts, formbetaalwijze,
  formartikeltype, forminloggen, formverkopersbeheren, formverkoperskoppelen,
  formtransacties, formdatabase, c_wobbelbuttonpanel, formkassaopensluit,
  formimportkassa, formoverzichtkassas, formoverzichtverkopers,
  forminstellingenbeheer, formoverzichtverkoperperkassa, formoverzichtbeurs,
  formoverzichttransactiesperverkop, formoverzichttotaalexport, vinfo,
  formabout, formgrafiek_transactietijd, framewachten,
formbetaalwijzeinvullen;

{$R *.res}

var
  CloseSplashScreen: Boolean;

  trcdir:string;
begin

  c_vrijwilliger.UserIsSuperAdmin:=false;
  Application.Title:='Wobbelbeurs Kassa';
  // <Deze uitcommentarieren in de productieversie>
  trcdir:=ExtractFilePath (Application.ExeName) + 'logs';
  if (not DirectoryExists(trcdir)) then
  begin
    CreateDir(trcdir);
  end;
  SetHeapTraceOutput (trcdir + DirectorySeparator + 'wobbletrclog.trc');
  // <Deze uitcommentarieren in de productieversie>

  Application.initialize;

  CloseSplashScreen := False;
  frmSplash:=TfrmSplash.Create(Application);
  frmSplash.ShowOnTop;
  frmSplash.show;
  frmSplash.update;
  CloseSplashScreen:=False;
  Application.ProcessMessages;

  Delay(m_constant.c_AppSplashTime);

  Application.CreateForm(TdmWobbel, dmWobbel);
  Application.CreateForm(TfrmMain, frmMain);

  if CloseSplashScreen then
  begin
    frmSplash.Close;
    frmSplash.hide;
    frmSplash.free;
  end;
  Application.CreateForm(TfrmHelp, frmHelp);
  Application.CreateForm(TfrmDialoog, frmDialoog);
  Application.CreateForm(TfrmInstellingen, frmInstellingen);
  Application.CreateForm(TfrmBeursoverzicht, frmBeursoverzicht);
  Application.CreateForm(TfrmBeursKassaoverzicht, frmBeursKassaoverzicht);
  Application.CreateForm(TfrmAccounts, frmAccounts);
  Application.CreateForm(TfrmBetaalwijze, frmBetaalwijze);
  Application.CreateForm(TfrmArtikeltype, frmArtikeltype);
  Application.CreateForm(TfrmInloggen, frmInloggen);
  Application.CreateForm(TfrmVerkopersbeheren, frmVerkopersbeheren);
  Application.CreateForm(TfrmVerkoperskoppelen, frmVerkoperskoppelen);
  Application.CreateForm(TfrmTransacties, frmTransacties);
  Application.CreateForm(TfrmDatabase, frmDatabase);
  Application.CreateForm(TfrmKassaOpenSluit, frmKassaOpenSluit);
  Application.CreateForm(TfrmImportKassa, frmImportKassa);
  Application.CreateForm(TfrmOverzichtKassas, frmOverzichtKassas);
  Application.CreateForm(TfrmOverzichtVerkopers, frmOverzichtVerkopers);
  Application.CreateForm(TfrmInstellingenBeheer, frmInstellingenBeheer);
  Application.CreateForm(TfrmOverzichtVerkoperPerKassa,
    frmOverzichtVerkoperPerKassa);
  Application.CreateForm(TfrmOverzichtBeurs, frmOverzichtBeurs);
  Application.CreateForm(TfrmOverzichtTransactiesPerVerkoper,
    frmOverzichtTransactiesPerVerkoper);
  Application.CreateForm(TfrmOverzichtTotaalExport, frmOverzichtTotaalExport);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmTransactiesTegenTijd, frmTransactiesTegenTijd);
  Application.CreateForm(TfrmBetaalwijzeInvullen, frmBetaalwijzeInvullen);
  Application.Run;


end.


