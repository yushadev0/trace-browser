unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.TitleBarCtrls, Vcl.Buttons, uCEFWinControl, uCEFWindowParent,
  uCEFChromiumCore, uCEFChromium, uCEFInterfaces, uCEFTypes, uCEFConstants,
  System.NetEncoding, Vcl.ComCtrls;

type
  TMainFrm = class(TForm)
    TitleBarPanel1: TTitleBarPanel;
    Panel1: TPanel;
    btnBack: TSpeedButton;
    btnForward: TSpeedButton;
    btnReload: TSpeedButton;
    edtURL: TEdit;
    SpeedButton1: TSpeedButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure edtURLKeyPress(Sender: TObject; var Key: Char);
    procedure YeniSekmeAc(const URL: string);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
  uBrowserFrame;

procedure TMainFrm.Button1Click(Sender: TObject);
begin
  ShowMessage('merhaba dünya');
end;

procedure TMainFrm.edtURLKeyPress(Sender: TObject; var Key: Char);
var
  TargetURL: string;
begin
  if Key = #13 then // Eğer klavyeden Enter tuşuna basıldıysa
  begin
    // Key := #0; // Bip sesini yut
    TargetURL := Trim(edtURL.Text);

    // Eğer metinde boşluk yoksa ve nokta (.) içeriyorsa bu muhtemelen bir URL'dir
    if (Pos(' ', TargetURL) = 0) and (Pos('.', TargetURL) > 0) then
    begin
      if (Pos('http://', TargetURL) = 0) and (Pos('https://', TargetURL) = 0)
      then
        TargetURL := 'https://' + TargetURL;
    end
    else
    begin
      TargetURL := 'https://www.google.com/search?q=' +
        TNetEncoding.URL.EncodeQuery(TargetURL);
    end;

  end;
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
  YeniSekmeAc('https://google.com');
end;

procedure TMainFrm.YeniSekmeAc(const URL: string);
var
  YeniSayfa: TTabSheet;
  TarayiciKapsulu: TTBrowserFrame;
begin
  YeniSayfa := TTabSheet.Create(PageControl1);
  YeniSayfa.PageControl := PageControl1;
  YeniSayfa.Caption := 'Yükleniyor...';

  TarayiciKapsulu := TTBrowserFrame.Create(YeniSayfa);
  TarayiciKapsulu.Parent := YeniSayfa;
  TarayiciKapsulu.Align := alClient; // Sekmeyi tamamen kaplasın

  // 3. Sekmeyi aktif hale getir
  PageControl1.ActivePage := YeniSayfa;

  // 4. Kapsülün içindeki Chromium'u verilen URL ile ateşle
  TarayiciKapsulu.Baslat(URL);
end;

end.
