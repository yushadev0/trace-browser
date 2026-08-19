unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.TitleBarCtrls, Vcl.Buttons,
  uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, System.NetEncoding,
  Vcl.ComCtrls, uBrowserFrame, System.Skia, Vcl.Skia, System.UITypes,
  System.Types, System.Generics.Collections;

type
  TMainFrm = class(TForm)
    TitleBarPanel1: TTitleBarPanel;
    Panel1: TPanel;
    edtURL: TEdit;
    skTabs: TSkPaintBox;
    pnlTarayici: TPanel;
    skNav: TSkPaintBox;
    svgGeri: TSkSvg;
    svgIleri: TSkSvg;
    svgTazele: TSkSvg;
    procedure Button1Click(Sender: TObject);
    procedure edtURLKeyPress(Sender: TObject; var Key: Char);
    procedure YeniSekmeAc(const URL: string);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnBackClick(Sender: TObject);
    procedure btnForwardClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure skTabsDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
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
  private
    FSekmeKutulari: TArray<TRectF>;
    FSekmeler: TList<TTBrowserFrame>;
    FAktifIndex: Integer;
    FSekmeSayaci: Integer;
    FArtiButonuKutusu: TRectF;

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

  YeniKapsul.Baslat(URL);
  skTabs.Redraw;
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
  CustomTitleBar.Enabled := True;
  CustomTitleBar.ShowCaption := False;
  CustomTitleBar.ShowIcon := False;
  CustomTitleBar.Height := 40;

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
  if WindowState = wsMaximized then
    CustomTitleBar.Height := 48
  else
    CustomTitleBar.Height := 40;

  TitleBarPanel1.Padding.Top := 0;
  TitleBarPanel1.Width := Self.ClientWidth;
  skTabs.Redraw;

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

procedure TMainFrm.skTabsDblClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
end;

procedure TMainFrm.skTabsDraw(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  Boya, YaziBoyasi, IkonBoyasi: ISkPaint;
  YaziFontu, CarpiFontu: ISkFont;
  SekmeKutusu: TRectF;
  SekmeGenisligi, X_Pozisyonu, UstBosluk: Single;
  i: Integer;
  SekmeMetni: string;
begin
  ACanvas.Clear($FF050505);;

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
  X_Pozisyonu := 10;

  if WindowState = wsMaximized then
    UstBosluk := 6
  else
    UstBosluk := 8;

  SetLength(FSekmeKutulari, FSekmeler.Count);

  for i := 0 to FSekmeler.Count - 1 do
  begin
    if FAktifIndex = i then
      Boya.Color := $FF3A3A3A
    else
      Boya.Color := $FF1E1E1E;

    SekmeKutusu := TRectF.Create(X_Pozisyonu, UstBosluk,
      X_Pozisyonu + SekmeGenisligi, ADest.Bottom);
    FSekmeKutulari[i] := SekmeKutusu;

    ACanvas.DrawRoundRect(SekmeKutusu, 10, 10, Boya);
    ACanvas.DrawRect(TRectF.Create(X_Pozisyonu, ADest.Bottom - 10,
      X_Pozisyonu + SekmeGenisligi, ADest.Bottom), Boya);

    ACanvas.DrawCircle(X_Pozisyonu + 20, ADest.Bottom - 15, 7, IkonBoyasi);

    SekmeMetni := FSekmeler[i].SayfaBasligi;
    ACanvas.Save;
    ACanvas.ClipRect(TRectF.Create(X_Pozisyonu + 35, 0,
      X_Pozisyonu + SekmeGenisligi - 30, skTabs.Height));
    ACanvas.DrawSimpleText(SekmeMetni, X_Pozisyonu + 35, ADest.Bottom - 10,
      YaziFontu, YaziBoyasi);
    ACanvas.Restore;

    ACanvas.DrawSimpleText('×', X_Pozisyonu + SekmeGenisligi - 22,
      ADest.Bottom - 9, CarpiFontu, YaziBoyasi);

    X_Pozisyonu := X_Pozisyonu + SekmeGenisligi + 2;
  end;

  var
    ArtiBoyasi: ISkPaint;

  ArtiBoyasi := TSkPaint.Create;
  ArtiBoyasi.AntiAlias := True;
  ArtiBoyasi.Color := $FF1E1E1E;

  if FSekmeler.Count = 0 then
    X_Pozisyonu := 10
  else
    X_Pozisyonu := X_Pozisyonu + 2;

  FArtiButonuKutusu := TRectF.Create(X_Pozisyonu, UstBosluk, X_Pozisyonu + 40,
    ADest.Bottom);

  ACanvas.DrawRoundRect(FArtiButonuKutusu, 10, 10, ArtiBoyasi);

  ACanvas.DrawRect(TRectF.Create(X_Pozisyonu, ADest.Bottom - 10,
    X_Pozisyonu + 40, ADest.Bottom), ArtiBoyasi);

  ACanvas.DrawSimpleText('+', X_Pozisyonu + 14, ADest.Bottom - 9, CarpiFontu,
    YaziBoyasi);
end;

procedure TMainFrm.skTabsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TiklananIndex, i: Integer;
  SkiaX, SkiaY, Olcek: Single;
  CarpiyaBasildiMi: Boolean;
begin
  Olcek := skTabs.ScaleFactor;
  SkiaX := X / Olcek;
  SkiaY := Y / Olcek;

  if (Button = mbLeft) and FArtiButonuKutusu.Contains(PointF(SkiaX, SkiaY)) then
  begin
    YeniSekmeAc('https://google.com');
    Exit;
  end;

  TiklananIndex := -1;
  CarpiyaBasildiMi := False;

  for i := Low(FSekmeKutulari) to High(FSekmeKutulari) do
  begin
    if FSekmeKutulari[i].Contains(PointF(SkiaX, SkiaY)) then
    begin
      TiklananIndex := i;

      if SkiaX > (FSekmeKutulari[i].Right - 30) then
        CarpiyaBasildiMi := True;

      Break;
    end;
  end;

  if TiklananIndex <> -1 then
  begin
    if (Button = mbMiddle) or ((Button = mbLeft) and CarpiyaBasildiMi) then
    begin
      FSekmeler[TiklananIndex].Chromium1.CloseBrowser(True);
      FSekmeler[TiklananIndex].Free;
      FSekmeler.Delete(TiklananIndex);

      if FSekmeler.Count > 0 then
      begin
        if TiklananIndex >= FSekmeler.Count then
          FAktifIndex := FSekmeler.Count - 1
        else
          FAktifIndex := TiklananIndex;

        AktifSekmeyiGoster;

        edtURL.Text := AktifKapsul.GuncelURL;
      end
      else
        Close;

      skTabs.Redraw;
    end
    else if (Button = mbLeft) and not CarpiyaBasildiMi then
    begin
      FAktifIndex := TiklananIndex;
      AktifSekmeyiGoster;
      skTabs.Redraw;

      edtURL.Text := AktifKapsul.GuncelURL;
    end;
  end
  else
  begin
    if Button = mbLeft then
    begin
      ReleaseCapture;
      Perform(WM_SYSCOMMAND, $F012, 0);
    end;
  end;
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
