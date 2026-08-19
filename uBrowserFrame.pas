unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.ComCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uCEFWindowParent, uCEFChromiumCore, uCEFChromium, // Mevcut bileşenler
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFWinControl;
// Eklediğimiz kütüphaneler

type
  TTBrowserFrame = class(TFrame)
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    procedure Chromium1AfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1TitleChange(Sender: TObject; const browser: ICefBrowser;
      const title: ustring);
    procedure Chromium1AddressChange(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
    procedure Chromium1BeforePopup(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; popup_id: Integer;
      const targetUrl, targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
      var client: ICefClient; var settings: TCefBrowserSettings;
      var extra_info: ICefDictionaryValue;
      var noJavascriptAccess, Result: Boolean);
  private
    { Private declarations }
  public
    GuncelURL: String;
    SayfaBasligi: string;

    procedure Baslat(const StartURL: string);
  end;

implementation

{$R *.dfm}

uses uMain;

procedure TTBrowserFrame.Baslat(const StartURL: string);
begin
  Chromium1.DefaultUrl := StartURL;
  // Motoru bu Frame'in içindeki ebeveyn pencereye bağla
  Chromium1.CreateBrowser(CEFWindowParent1, '');
end;

procedure TTBrowserFrame.Chromium1AddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if (frame <> nil) and frame.IsMain then
  begin
    GuncelURL := url;
    MainFrm.edtURL.Text := url;
  end;
end;

procedure TTBrowserFrame.Chromium1AfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  CEFWindowParent1.UpdateSize;
end;

procedure TTBrowserFrame.Chromium1BeforePopup(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; popup_id: Integer;
  const targetUrl, targetFrameName: ustring;
  targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
  const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo;
  var client: ICefClient; var settings: TCefBrowserSettings;
  var extra_info: ICefDictionaryValue; var noJavascriptAccess, Result: Boolean);
var
  YeniURL: string;
begin
  Result := True;

  YeniURL := targetUrl;

  if YeniURL <> '' then
  begin
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(Application.MainForm) and (Application.MainForm is TMainFrm)
        then
          TMainFrm(Application.MainForm).YeniSekmeAc(YeniURL);
      end);
  end;
end;

procedure TTBrowserFrame.Chromium1TitleChange(Sender: TObject;
const browser: ICefBrowser; const title: ustring);
var
  YeniBaslik: string;
begin
  YeniBaslik := title; // Gelen başlığı (ustring) standart string'e alıyoruz

  TThread.Queue(nil,
    procedure
    begin
      SayfaBasligi := YeniBaslik;

      if Assigned(Application.MainForm) and (Application.MainForm is TMainFrm)
      then
        MainFrm.Caption := 'Trace - ' + SayfaBasligi;
      TMainFrm(Application.MainForm).skTabs.Redraw;
    end);
end;

end.
