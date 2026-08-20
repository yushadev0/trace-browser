unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.ComCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFWinControl,
  System.Net.HttpClient, System.Net.URLClient, System.Threading, System.Skia,
  Vcl.Skia, System.NetEncoding;

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
    procedure Chromium1LoadingStateChange(Sender: TObject;
      const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
  private
    { Private declarations }
  public
    GuncelURL: String;
    SayfaBasligi: string;
    Favicon: ISkImage;
    GuncelX: Single;
    HedefX: Single;
    SayfaYukleniyor: Boolean;
    GuncelY: Single;
    HedefY: Single;
    HizY: Single;
    KapanisAsamasinda: Boolean;

    procedure Baslat(const StartURL: string);
    procedure FaviconGuncelle(const GelenURL: string);
  end;

implementation

{$R *.dfm}

uses uMain;

procedure TTBrowserFrame.Baslat(const StartURL: string);
begin
  Chromium1.DefaultUrl := StartURL;
  Chromium1.CreateBrowser(CEFWindowParent1, '');
  SayfaYukleniyor := True;

  GuncelY := 50;
  HizY := 0;
  KapanisAsamasinda := False;
end;

procedure TTBrowserFrame.Chromium1AddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if (frame <> nil) and frame.IsMain then
  begin
    GuncelURL := url;
    FaviconGuncelle(url);
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

procedure TTBrowserFrame.Chromium1LoadingStateChange(Sender: TObject;
const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
begin
  SayfaYukleniyor := isLoading;
end;

procedure TTBrowserFrame.Chromium1TitleChange(Sender: TObject;
const browser: ICefBrowser; const title: ustring);
var
  YeniBaslik: string;
begin
  YeniBaslik := title;

  TThread.Queue(nil,
    procedure
    begin
      SayfaBasligi := YeniBaslik;

    end);
end;

procedure TTBrowserFrame.FaviconGuncelle(const GelenURL: string);
var
  Kapsul: TTBrowserFrame;
  HedefURL: string;
begin
  if GelenURL = '' then
    Exit;
  Kapsul := Self;

  // URL'yi parçalamıyoruz! API'nin hata vermemesi için tamamını güvenli formata kodluyoruz.
  HedefURL := TNetEncoding.url.EncodeQuery(GelenURL);

  TThread.CreateAnonymousThread(
    procedure
    var
      Http: THTTPClient;
      Ms: TMemoryStream;
      YeniIkon: ISkImage;
    begin
      Http := THTTPClient.Create;
      Ms := TMemoryStream.Create;
      try
        try
          Http.Get('https://www.google.com/s2/favicons?domain=' + HedefURL +
            '&sz=128', Ms);

          if Ms.Size > 0 then
          begin
            Ms.Position := 0;
            YeniIkon := TSkImage.MakeFromEncodedStream(Ms);

            TThread.Queue(nil,
              procedure
              begin
                Kapsul.Favicon := YeniIkon;

              end);
          end;
        except
        end;
      finally
        Ms.Free;
        Http.Free;
      end;
    end).Start;
end;

end.
