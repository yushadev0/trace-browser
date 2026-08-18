unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
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
  private
    { Private declarations }
  public
    procedure Baslat(const StartURL: string);
    // Dışarıdan tetiklenecek fonksiyon
  end;

implementation

{$R *.dfm}

procedure TTBrowserFrame.Baslat(const StartURL: string);
begin
  Chromium1.DefaultUrl := StartURL;
  // Motoru bu Frame'in içindeki ebeveyn pencereye bağla
  Chromium1.CreateBrowser(CEFWindowParent1, '');
end;

procedure TTBrowserFrame.Chromium1AfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  CEFWindowParent1.UpdateSize;
end;

end.
