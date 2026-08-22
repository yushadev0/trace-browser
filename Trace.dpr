program Trace;

uses
  Vcl.Forms,
  SysUtils,
  Windows,
  uCEFApplication,
  uMain in 'uMain.pas' {MainFrm},
  uBrowserFrame in 'uBrowserFrame.pas' {TBrowserFrame: TFrame},
  uData in 'uData.pas' {dmVeri: TDataModule};

// Senin ana formun

{$R *.res}

begin
  System.IsMultiThread := True;

  GlobalCEFApp := TCefApplication.Create;

  // Güvenlik kum havuzunu kapat (alt süreç çökmelerini engeller)
  GlobalCEFApp.NoSandbox := True;

  // Dosya yollarını uygulamanın çalıştığı klasöre (ExtractFilePath) çivile
  GlobalCEFApp.FrameworkDirPath     := ExtractFilePath(ParamStr(0));
  GlobalCEFApp.ResourcesDirPath     := ExtractFilePath(ParamStr(0));
  GlobalCEFApp.LocalesDirPath       := ExtractFilePath(ParamStr(0)) + 'locales';

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
