program Trace;

uses
  Vcl.Forms,
  SysUtils,
  Windows,
  uCEFApplication,
  uCEFInterfaces, uCEFMiscFunctions, uCEFTypes, uCEFProcessMessage,
  uMain in 'uMain.pas' {MainFrm} ,
  uBrowserFrame in 'uBrowserFrame.pas' {TBrowserFrame: TFrame} ,
  uData in 'uData.pas' {dmVeri: TDataModule} ,
  uBookmarkDialog in 'uBookmarkDialog.pas' {frmBookmarkEdit};

// Senin ana formun

{$R *.res}

procedure GlobalCEFApp_OnContextCreated(const browser: ICefBrowser; const frame: ICefFrame; const context: ICefv8Context);
var
  Msg: ICefProcessMessage;
begin
  // Sekme her oluştuğunda işletim sistemindeki PID'sini alıp merkeze fırlatıyor!
  Msg := TCefProcessMessageRef.New('TraceReportPID');
  Msg.ArgumentList.SetInt(0, GetCurrentProcessId);
  frame.SendProcessMessage(PID_BROWSER, Msg);
end;

begin
  System.IsMultiThread := True;

  GlobalCEFApp := TCefApplication.Create;

  // Güvenlik kum havuzunu kapat (alt süreç çökmelerini engeller)
  GlobalCEFApp.NoSandbox := True;

  // Dosya yollarını uygulamanın çalıştığı klasöre (ExtractFilePath) çivile
  GlobalCEFApp.FrameworkDirPath := ExtractFilePath(ParamStr(0));
  GlobalCEFApp.ResourcesDirPath := ExtractFilePath(ParamStr(0));
  GlobalCEFApp.LocalesDirPath := ExtractFilePath(ParamStr(0)) + 'locales';

  // Chrome'un kendi "indirme balonu" (adres çubuğunun sağında beliren,
  // ilerlemeyi gösteren yuvarlak animasyon + mini panel) UI'ını kapat.
  // İndirmeleri artık kendi trace://downloads sayfamızda gösteriyoruz,
  // Chromium'un yerleşik indirme arayüzüyle çakışmasını istemiyoruz.
  GlobalCEFApp.DisableFeatures := 'DownloadBubble,DownloadBubbleV2';

  GlobalCEFApp.OnContextCreated := GlobalCEFApp_OnContextCreated;
  if GlobalCEFApp.StartMainProcess then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TMainFrm, MainFrm);
    Application.CreateForm(TdmVeri, dmVeri);
    Application.Run;
  end;

  GlobalCEFApp.Free;
  GlobalCEFApp := nil;

end.
