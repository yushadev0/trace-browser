unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.TitleBarCtrls, Vcl.Buttons,
  uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, System.NetEncoding,
  Vcl.ComCtrls, uBrowserFrame, System.Skia, Vcl.Skia, System.UITypes,
  System.Types, System.Generics.Collections, System.Net.HttpClient,
  System.Net.URLClient, System.Threading;

type
  TMainFrm = class(TForm)
    Panel1: TPanel;
    edtURL: TEdit;
    pnlTarayici: TPanel;
    skNav: TSkPaintBox;
    svgGeri: TSkSvg;
    svgIleri: TSkSvg;
    svgTazele: TSkSvg;
    Panel2: TPanel;
    skTabs: TSkAnimatedPaintBox;
    TitleBarPanel1: TTitleBarPanel;
    procedure Button1Click(Sender: TObject);
    procedure edtURLKeyPress(Sender: TObject; var Key: Char);
    procedure YeniSekmeAc(const URL: string);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnBackClick(Sender: TObject);
    procedure btnForwardClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure skTabsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure skTabsDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure skNavDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure skNavMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure svgGeriClick(Sender: TObject);
    procedure svgIleriClick(Sender: TObject);
    procedure svgTazeleClick(Sender: TObject);
    procedure skTabsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure skTabsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure skTabsMouseLeave(Sender: TObject);
    procedure skTabsAnimationDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AProgress: Double; const AOpacity: Single);
  private
    FSekmeKutulari: TArray<TRectF>;
    FSekmeler: TList<TTBrowserFrame>;
    FAktifIndex: Integer;
    FSekmeSayaci: Integer;
    FArtiButonuKutusu: TRectF;
    FSurukleniyor: Boolean;
    FSuruklenenIndex: Integer;
    FSuruklemeFarki: Single;

    procedure AktifSekmeyiGoster;
  public
    function AktifKapsul: TTBrowserFrame;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

function TMainFrm.AktifKapsul: TTBrowserFrame;
begin
  if (FAktifIndex >= 0) and (FAktifIndex < FSekmeler.Count) then
    Result := FSekmeler[FAktifIndex]
  else
    Result := nil;
end;

procedure TMainFrm.AktifSekmeyiGoster;
var
  i: Integer;
begin
  for i := 0 to FSekmeler.Count - 1 do
    FSekmeler[i].Visible := (i = FAktifIndex);
end;

procedure TMainFrm.YeniSekmeAc(const URL: string);
var
  YeniKapsul: TTBrowserFrame;
begin
  YeniKapsul := TTBrowserFrame.Create(Self);

  Inc(FSekmeSayaci);
  YeniKapsul.Name := 'Sekme_' + IntToStr(FSekmeSayaci);

  YeniKapsul.Parent := pnlTarayici;
  YeniKapsul.Align := alClient;
  YeniKapsul.SayfaBasligi := 'Yükleniyor...';

  FSekmeler.Add(YeniKapsul);
  FAktifIndex := FSekmeler.Count - 1;
  AktifSekmeyiGoster;

  YeniKapsul.GuncelX := -1;
  YeniKapsul.Baslat(URL);
end;

procedure TMainFrm.btnBackClick(Sender: TObject);
begin
  if (AktifKapsul.Chromium1.CanGoBack) then
    AktifKapsul.Chromium1.GoBack;
end;

procedure TMainFrm.btnForwardClick(Sender: TObject);
begin
  if AktifKapsul.Chromium1.CanGoForward then
    AktifKapsul.Chromium1.GoForward;
end;

procedure TMainFrm.btnReloadClick(Sender: TObject);
begin
  AktifKapsul.Chromium1.Reload;
end;

procedure TMainFrm.Button1Click(Sender: TObject);
begin
  ShowMessage('merhaba dünya');
end;

procedure TMainFrm.edtURLKeyPress(Sender: TObject; var Key: Char);
var
  TargetURL: string;
begin
  if Key = #13 then
  begin
    Key := #0;
    TargetURL := Trim(edtURL.Text);

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

    AktifKapsul.Chromium1.LoadURL(TargetURL);
  end;
end;

procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
begin
  skTabs.Animation.Enabled := False;
  for i := FSekmeler.Count - 1 downto 0 do
  begin
    if Assigned(FSekmeler[i]) then
    begin
      FSekmeler[i].Chromium1.CloseBrowser(True);
      FSekmeler[i].Free;
    end;
  end;
  FSekmeler.Clear;

  CanClose := True;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  FSekmeler := TList<TTBrowserFrame>.Create;
  FAktifIndex := -1;
  FSekmeSayaci := 0;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  FSekmeler.Free;
end;

procedure TMainFrm.FormResize(Sender: TObject);
begin
  edtURL.Width := Panel1.Width - 230;
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
  YeniSekmeAc('https://google.com');
end;

procedure TMainFrm.skNavDraw(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  HapBoyasi: ISkPaint;
  HapKutusu: TRectF;
begin
  ACanvas.Clear($FF3A3A3A);

  HapBoyasi := TSkPaint.Create;
  HapBoyasi.AntiAlias := True;
  HapBoyasi.Color := $FF1E1E1E;

  HapKutusu := TRectF.Create(125, 5, ADest.Right - 15, ADest.Bottom - 5);
  ACanvas.DrawRoundRect(HapKutusu, HapKutusu.Height / 2, HapKutusu.Height / 2,
    HapBoyasi);
end;

procedure TMainFrm.skNavMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Olcek, SkiaX, SkiaY: Single;
begin
  Olcek := skNav.ScaleFactor;
  SkiaX := X / Olcek;
  SkiaY := Y / Olcek;

  if Button = mbLeft then
  begin
  end;
end;

procedure TMainFrm.skTabsAnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
var
  Boya, YaziBoyasi, IkonBoyasi, LoaderBoyasi, ArtiBoyasi: ISkPaint;
  YaziFontu, CarpiFontu: ISkFont;
  SekmeKutusu: TRectF;
  SekmeGenisligi, UstBosluk, X_Hesap, SonX: Single;
  i: Integer;
  SekmeMetni: string;
  LoaderAcisi: Single;
  Kapsul: TTBrowserFrame;
begin
  if not Assigned(FSekmeler) then
    Exit;

  ACanvas.Clear($FF050505);

  Boya := TSkPaint.Create;
  Boya.AntiAlias := True;
  YaziBoyasi := TSkPaint.Create;
  YaziBoyasi.AntiAlias := True;
  YaziBoyasi.Color := $FFFFFFFF;
  IkonBoyasi := TSkPaint.Create;
  IkonBoyasi.AntiAlias := True;
  IkonBoyasi.Color := $FF888888;
  YaziFontu := TSkFont.Create(TSkTypeface.MakeFromName('Segoe UI',
    TSkFontStyle.Normal), 13);
  CarpiFontu := TSkFont.Create(TSkTypeface.MakeFromName('Segoe UI',
    TSkFontStyle.Bold), 16);

  SekmeGenisligi := 200;
  if WindowState = wsMaximized then
    UstBosluk := 6
  else
    UstBosluk := 8;

  // 0. AŞAĞI DÜŞEN (ANİMASYONU BİTEN) SEKMELERİ ÇÖPE AT
  for i := FSekmeler.Count - 1 downto 0 do
  begin
    if FSekmeler[i].KapanisAsamasinda and
      (FSekmeler[i].GuncelY > skTabs.Height + 10) then
    begin
      Kapsul := FSekmeler[i];
      FSekmeler.Delete(i);

      if FAktifIndex > i then
        Dec(FAktifIndex);

      TThread.Queue(nil,
        procedure
        begin
          Kapsul.Chromium1.CloseBrowser(True);
          Kapsul.Free;
          if MainFrm.FSekmeler.Count = 0 then
            MainFrm.Close; // Sekme kalmadıysa programı kapat
        end);
    end;
  end;

  SetLength(FSekmeKutulari, FSekmeler.Count);

  // 1. FİZİK: X ve Y eksenleri için yay (spring) ve yumuşatma hesaplamaları
  X_Hesap := 10;
  for i := 0 to FSekmeler.Count - 1 do
  begin
    // --- Bouncy (Yay) Fiziği (Y Ekseni) ---
    if not FSekmeler[i].KapanisAsamasinda then
      FSekmeler[i].HedefY := UstBosluk;

    // Hız = (Hız + (Mesafe * Sertlik)) * Sürtünme
    FSekmeler[i].HizY :=
      (FSekmeler[i].HizY + (FSekmeler[i].HedefY - FSekmeler[i].GuncelY) *
      0.25) * 0.70;
    FSekmeler[i].GuncelY := FSekmeler[i].GuncelY + FSekmeler[i].HizY;

    // --- Yatay Kayma Fiziği (X Ekseni) ---
    if not FSekmeler[i].KapanisAsamasinda then
    begin
      FSekmeler[i].HedefX := X_Hesap;
      X_Hesap := X_Hesap + SekmeGenisligi + 2;
    end;

    if FSekmeler[i].GuncelX = -1 then
      FSekmeler[i].GuncelX := FSekmeler[i].HedefX;
    // Yeni sekme X ekseninde direkt otursun (Y'den fırlayacak)

    if not(FSurukleniyor and (i = FSuruklenenIndex)) then
    begin
      if Abs(FSekmeler[i].GuncelX - FSekmeler[i].HedefX) > 0.1 then
        FSekmeler[i].GuncelX := FSekmeler[i].GuncelX +
          ((FSekmeler[i].HedefX - FSekmeler[i].GuncelX) * 0.3)
      else
        FSekmeler[i].GuncelX := FSekmeler[i].HedefX;
    end;
  end;

  // 2. ÇİZİM: Sekmeleri kendi GuncelX ve GuncelY konumlarında çiz!
  for i := 0 to FSekmeler.Count - 1 do
  begin
    ACanvas.Save;

    // SİHİRLİ DOKUNUŞ: Sekmenin Y eksenindeki değişimine göre bütün çizimi kaydır
    ACanvas.Translate(0, FSekmeler[i].GuncelY - UstBosluk);

    if FAktifIndex = i then
      Boya.Color := $FF3A3A3A
    else
      Boya.Color := $FF1E1E1E;

    // Kutu (UstBosluk değerini GuncelY simüle ettiği için burada sabit tutuyoruz)
    SekmeKutusu := TRectF.Create(FSekmeler[i].GuncelX, UstBosluk,
      FSekmeler[i].GuncelX + SekmeGenisligi, ADest.Bottom);
    FSekmeKutulari[i] := SekmeKutusu;

    ACanvas.DrawRoundRect(SekmeKutusu, 10, 10, Boya);
    ACanvas.DrawRect(TRectF.Create(FSekmeler[i].GuncelX, ADest.Bottom - 10,
      FSekmeler[i].GuncelX + SekmeGenisligi, ADest.Bottom), Boya);
    ACanvas.DrawRect(TRectF.Create(FSekmeler[i].GuncelX, ADest.Bottom - 10,
      FSekmeler[i].GuncelX + SekmeGenisligi, ADest.Bottom + 50), Boya);

    // Favicon & Loader
    if FSekmeler[i].SayfaYukleniyor then
    begin
      LoaderBoyasi := TSkPaint.Create;
      LoaderBoyasi.style := TSkPaintStyle.Stroke;
      LoaderBoyasi.StrokeWidth := 2;
      LoaderBoyasi.Color := $FF0078D7;
      LoaderBoyasi.AntiAlias := True;
      LoaderAcisi := (GetTickCount64 mod 1000) / 1000 * 360;
      ACanvas.Save;
      ACanvas.Translate(FSekmeler[i].GuncelX + 20, ADest.Bottom - 15);
      ACanvas.Rotate(LoaderAcisi);
      ACanvas.DrawArc(TRectF.Create(-6, -6, 6, 6), 0, 270, False, LoaderBoyasi);
      ACanvas.Restore;
    end
    else if FSekmeler[i].Favicon <> nil then
    begin
      ACanvas.Save;
      ACanvas.ClipRoundRect
        (TSkRoundRect.Create(TRectF.Create(FSekmeler[i].GuncelX + 12,
        ADest.Bottom - 23, FSekmeler[i].GuncelX + 28, ADest.Bottom - 7), 4, 4),
        TSkClipOp.Intersect, True);
      ACanvas.DrawImageRect(FSekmeler[i].Favicon,
        TRectF.Create(FSekmeler[i].GuncelX + 12, ADest.Bottom - 23,
        FSekmeler[i].GuncelX + 28, ADest.Bottom - 7),
        TSkSamplingOptions.Create(TSkFilterMode.Linear, TSkMipmapMode.Linear));
      ACanvas.Restore;
    end
    else
      ACanvas.DrawCircle(FSekmeler[i].GuncelX + 20, ADest.Bottom - 15, 7,
        IkonBoyasi);

    // Metin ve Çarpı
    SekmeMetni := FSekmeler[i].SayfaBasligi;
    ACanvas.Save;
    ACanvas.ClipRect(TRectF.Create(FSekmeler[i].GuncelX + 35, 0,
      FSekmeler[i].GuncelX + SekmeGenisligi - 30, skTabs.Height));
    ACanvas.DrawSimpleText(SekmeMetni, FSekmeler[i].GuncelX + 35,
      ADest.Bottom - 10, YaziFontu, YaziBoyasi);
    ACanvas.Restore;
    ACanvas.DrawSimpleText('×', FSekmeler[i].GuncelX + SekmeGenisligi - 22,
      ADest.Bottom - 9, CarpiFontu, YaziBoyasi);

    // Çizim bittikten sonra tuvali normal konumuna geri al!
    ACanvas.Restore;
  end;

  // 3. ARTI BUTONU
  ArtiBoyasi := TSkPaint.Create;
  ArtiBoyasi.AntiAlias := True;
  ArtiBoyasi.Color := $FF1E1E1E;

  if FSekmeler.Count = 0 then
    X_Hesap := 10
  else
  begin
    SonX := 10;
    for i := FSekmeler.Count - 1 downto 0 do
    begin
      if not FSekmeler[i].KapanisAsamasinda then
      begin
        SonX := FSekmeler[i].GuncelX + SekmeGenisligi;
        Break;
      end;
    end;
    X_Hesap := SonX + 2;
  end;

  FArtiButonuKutusu := TRectF.Create(X_Hesap, UstBosluk, X_Hesap + 40,
    ADest.Bottom);
  ACanvas.DrawRoundRect(FArtiButonuKutusu, 10, 10, ArtiBoyasi);
  ACanvas.DrawRect(TRectF.Create(X_Hesap, ADest.Bottom - 10, X_Hesap + 40,
    ADest.Bottom), ArtiBoyasi);
  ACanvas.DrawSimpleText('+', X_Hesap + 14, ADest.Bottom - 9, CarpiFontu,
    YaziBoyasi);
end;

procedure TMainFrm.skTabsDblClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
end;

procedure TMainFrm.skTabsMouseDown(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
var
  SkiaX, SkiaY: Single;
  i: Integer;
  SekmeyeTiklandi: Boolean; // Yeni takip değişkeni
begin
  if Button <> mbLeft then
    Exit;

  SkiaX := X / skTabs.ScaleFactor;
  SkiaY := Y / skTabs.ScaleFactor;

  // 2. ARTI BUTONU
  if FArtiButonuKutusu.Contains(PointF(SkiaX, SkiaY)) then
  begin
    YeniSekmeAc('https://google.com');
    Exit;
  end;

  // 3. SEKMELER
  SekmeyeTiklandi := False;
  for i := 0 to FSekmeler.Count - 1 do
  begin
    if FSekmeKutulari[i].Contains(PointF(SkiaX, SkiaY)) then
    begin
      SekmeyeTiklandi := True; // Bir sekmeye tıklandığını not ettik

      if SkiaX > (FSekmeKutulari[i].Right - 30) then
      begin
        // ÇARPIYA BASILDI (Hemen silme, aşağı düşme emri ver)
        FSekmeler[i].KapanisAsamasinda := True;
        FSekmeler[i].HedefY := skTabs.Height + 20; // Tuvalin altına hedef koy

        // Eğer kapanan aktif sekme ise, anında başka bir sekmeyi aktif yap
        if FAktifIndex = i then
        begin
          var
          YeniAktif := -1;
          for var j := i - 1 downto 0 do
            if not FSekmeler[j].KapanisAsamasinda then
            begin
              YeniAktif := j;
              Break;
            end;
          if YeniAktif = -1 then
            for var j := i + 1 to FSekmeler.Count - 1 do
              if not FSekmeler[j].KapanisAsamasinda then
              begin
                YeniAktif := j;
                Break;
              end;

          FAktifIndex := YeniAktif;
          AktifSekmeyiGoster;
          if AktifKapsul <> nil then
            edtURL.Text := AktifKapsul.GuncelURL;
        end;
        Break;
      end
      else
      begin
        // SEKMEYE TIKLANDI (Sürükleme Başlat)
        FAktifIndex := i;
        AktifSekmeyiGoster;
        if AktifKapsul <> nil then
          edtURL.Text := AktifKapsul.GuncelURL;

        FSuruklenenIndex := i;
        FSurukleniyor := True;
        FSuruklemeFarki := SkiaX - FSekmeler[i].GuncelX;
        Break;
      end;
    end;
  end;

  // 4. EĞER HİÇBİR YERE TIKLANMADIYSA (BOŞLUK) PENCEREYİ SÜRÜKLE
  if not SekmeyeTiklandi then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TMainFrm.skTabsMouseLeave(Sender: TObject);
begin
  FSurukleniyor := False;
end;

procedure TMainFrm.skTabsMouseMove(Sender: TObject; Shift: TShiftState;
X, Y: Integer);
var
  SkiaX, SkiaY: Single;
  i, HedefIndex: Integer;
  HedefKutu: TRectF;
begin
  SkiaX := X / skTabs.ScaleFactor;
  SkiaY := Y / skTabs.ScaleFactor;

  // 2. EĞER SÜRÜKLENMİYORSA BURADAN SONRA ÇIK
  if not FSurukleniyor then
    Exit;

  // --- SEKME SÜRÜKLEME FİZİĞİ ---
  FSekmeler[FSuruklenenIndex].GuncelX := SkiaX - FSuruklemeFarki;

  HedefIndex := -1;
  for i := 0 to FSekmeler.Count - 1 do
  begin
    if FSekmeler[i].KapanisAsamasinda then
      Continue;

    if i = FSuruklenenIndex then
      Continue;

    HedefKutu := TRectF.Create(FSekmeler[i].HedefX, 10,
      FSekmeler[i].HedefX + 200, skTabs.Height);
    if HedefKutu.Contains(PointF(SkiaX, SkiaY)) then
    begin
      HedefIndex := i;
      Break;
    end;
  end;

  if HedefIndex <> -1 then
  begin
    FSekmeler.Exchange(FSuruklenenIndex, HedefIndex);
    if FAktifIndex = FSuruklenenIndex then
      FAktifIndex := HedefIndex
    else if FAktifIndex = HedefIndex then
      FAktifIndex := FSuruklenenIndex;

    FSuruklenenIndex := HedefIndex;
  end;
end;

procedure TMainFrm.skTabsMouseUp(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    FSurukleniyor := False;
end;

procedure TMainFrm.SpeedButton1Click(Sender: TObject);
begin
  YeniSekmeAc('https://google.com');
end;

procedure TMainFrm.svgGeriClick(Sender: TObject);
begin
  if (AktifKapsul <> nil) and AktifKapsul.Chromium1.CanGoBack then
    AktifKapsul.Chromium1.GoBack;
end;

procedure TMainFrm.svgIleriClick(Sender: TObject);
begin
  if (AktifKapsul <> nil) and AktifKapsul.Chromium1.CanGoForward then
    AktifKapsul.Chromium1.GoForward;
end;

procedure TMainFrm.svgTazeleClick(Sender: TObject);
begin
  if (AktifKapsul <> nil) then
    AktifKapsul.Chromium1.Reload;
end;

end.
