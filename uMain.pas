unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.TitleBarCtrls, Vcl.Buttons,
  uCEFWinControl, uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, System.NetEncoding,
  Vcl.ComCtrls, uBrowserFrame, System.Skia, Vcl.Skia, System.UITypes,
  System.UIConsts, System.Types, System.Generics.Collections,
  System.Net.HttpClient, System.Net.URLClient, System.Threading,
  Winapi.PsAPI, Winapi.TlHelp32, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.pngimage, uBookmarkDialog, System.IOUtils;

type
  TCPURecord = record
    SystemTime: UInt64;
    ProcessTime: UInt64;
  end;

  TMainFrm = class(TForm)
    Panel1: TPanel;
    edtURL: TEdit;
    pnlTarayici: TPanel;
    skNav: TSkPaintBox;
    svgGeri: TSkSvg;
    svgIleri: TSkSvg;
    svgTazele: TSkSvg;
    svgGorevYon: TSkSvg;
    svgAyarlar: TSkSvg;
    svgYildiz: TSkSvg;
    Panel2: TPanel;
    skTabs: TSkAnimatedPaintBox;
    TitleBarPanel1: TTitleBarPanel;
    tmrArama: TTimer;
    lstOneriler: TListBox;
    tmrOdak: TTimer;
    tmrTaskMgr: TTimer;
    pnlBookmarks: TPanel;
    imgFavicons: TImageList;
    SkSvg1: TSkSvg;
    svgIndirilenler: TSkSvg;
    svgGecmis: TSkSvg;
    procedure svgIndirilenlerClick(Sender: TObject);
    procedure svgGecmisClick(Sender: TObject);
    procedure edtURLKeyPress(Sender: TObject; var Key: Char);
    procedure YeniSekmeAc(const URL: string);
    procedure FormShow(Sender: TObject);
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
    procedure svgGorevYonClick(Sender: TObject);
    procedure svgAyarlarClick(Sender: TObject);
    procedure svgYildizClick(Sender: TObject);
    procedure skTabsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure skTabsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure skTabsMouseLeave(Sender: TObject);
    procedure skTabsAnimationDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AProgress: Double; const AOpacity: Single);
    procedure edtURLChange(Sender: TObject);
    procedure edtURLEnter(Sender: TObject);
    procedure tmrAramaTimer(Sender: TObject);
    procedure lstOnerilerDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstOnerilerClick(Sender: TObject);
    procedure edtURLKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtURLExit(Sender: TObject);
    procedure tmrOdakTimer(Sender: TObject);
    procedure tmrTaskMgrTimer(Sender: TObject);
    procedure AppExceptionHandler(Sender: TObject; E: Exception);
  private
    FSekmeKutulari: TArray<TRectF>;

    FSekmeSayaci: Integer;
    FArtiButonuKutusu: TRectF;
    FSurukleniyor: Boolean;
    FSuruklenenIndex: Integer;
    FSuruklemeFarki: Single;
    FCPUZamanlari: TDictionary<Cardinal, TCPURecord>;
    FNetZamanlari: TDictionary<Cardinal, UInt64>;
    FBookmarkSurukleBtn: TSpeedButton;
    FBookmarkSurukleBaslangic: TPoint;
    FBookmarkSuruklemeOldu: Boolean;
    FIndirmeAnimForm: TForm;
    FIndirmeAnimSekil: TShape;
    FIndirmeAnimTimer: TTimer;
    FIndirmeAnimBaslangic: TPointF;
    FIndirmeAnimBitis: TPointF;
    FIndirmeAnimAdim: Integer;

    procedure IndirmeAnimasyonuTimerTick(Sender: TObject);
    procedure YerIsaretleriniYukle;
    procedure BookmarkClick(Sender: TObject);
    procedure BookmarkMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BookmarkMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure BookmarkMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BookmarkSiralamaKaydet;
    procedure YerImiIkonunuYukle(ABtn: TSpeedButton; const AURL: string);
  public
    FAdresiKodDegistiriyor: Boolean;
    FAktifIndex: Integer;
    FSekmeler: TList<TTBrowserFrame>;
    FKaranlıkTema: Boolean;
    // Theme colors (Skia ARGB format)
    TemaNavArka: Cardinal;
    TemaNavHap: Cardinal;
    TemaSekmeArka: Cardinal;
    TemaAktifSekme: Cardinal;
    TemaPasifSekme: Cardinal;
    TemaMetin: Cardinal;
    TemaYukleyici: Cardinal;

    procedure TemayiUygula(Karanlik: Boolean);
    function AktifKapsul: TTBrowserFrame;
    procedure AktifSekmeyiGoster;
    procedure YildizDurumunuGuncelle;
    procedure SekmeyiKapat(SekmeIndex: Integer);
    function RAMKullaniminiGetir(PID: Cardinal): Double;
    procedure GorevYoneticisiniGuncelle;
    function CPUKullaniminiGetir(PID: Cardinal): Double;
    function AgHiziniGetir(PID: Cardinal): Double;
    procedure IndirmeAnimasyonuBaslat;
    procedure IndirmeSekmeleriniYenile;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses uData;

// Tema renkleri (TemaMetin vb.) Skia için ARGB Cardinal olarak tutuluyor
// ($AARRGGBB, ör. FFFFFFFF = opak beyaz). Klasik VCL TColor ise imzalı ve
// BGR sıralı bir değerdir. Bir Cardinal'i (özellikle üst byte'ı $FF olan,
// yani tam opak olan HER rengi) doğrudan bir TColor'a atamak, range
// checking altında "Range check error" ile çöker: değer aralık kontrolünde
// işaretsiz yorumlanıp Integer'ın üst sınırını aşıyor. Bu yüzden yer imi
// butonlarının rengini ayarlarken bu dönüşümü kullanıyoruz.
function ARGBtenTColora(const AARGB: Cardinal): TColor;
begin
  Result := RGB((AARGB shr 16) and $FF, (AARGB shr 8) and $FF, AARGB and $FF);
end;

// Yer imi hatalarını ayıklamak için geçici tanı kaydı. Deseni
// uBrowserFrame.pas'taki ImapLog ile aynı: hiçbir zaman ana akışı bozmaz.
procedure BookmarkLog(const Msg: string);
begin
  try
    TFile.AppendAllText(ExtractFilePath(ParamStr(0)) + 'bookmark_debug.log',
      FormatDateTime('hh:nn:ss.zzz', Now) + '  ' + Msg + sLineBreak,
      TEncoding.UTF8);
  except
    // Log yazımı asla ana akışı bozmasın.
  end;
end;

procedure TMainFrm.AppExceptionHandler(Sender: TObject; E: Exception);
begin
  BookmarkLog('YAKALANMAMIŞ İSTİSNA: ' + E.ClassName + ': ' + E.Message);
  Application.ShowException(E);
end;

procedure TMainFrm.TemayiUygula(Karanlik: Boolean);
begin
  FKaranlıkTema := Karanlik;
  if Karanlik then
  begin
    TemaNavArka := $FF3A3A3A;
    TemaNavHap := $FF1E1E1E;
    TemaSekmeArka := $FF050505;
    TemaAktifSekme := $FF3A3A3A;
    TemaPasifSekme := $FF1E1E1E;
    TemaMetin := $FFFFFFFF;
    TemaYukleyici := $FF0078D7;
    Color := $00050505;
    Panel1.Color := $00050505;
    Panel2.Color := $00050505;
    pnlTarayici.Color := $00050505;
    edtURL.Color := $001E1E1E;
    edtURL.Font.Color := clWhite;
    lstOneriler.Color := $00242120;
    svgGeri.Svg.OverrideColor := $FFF5F5F5;
    svgIleri.Svg.OverrideColor := $FFF5F5F5;
    svgTazele.Svg.OverrideColor := $FFF5F5F5;
    svgGorevYon.Svg.OverrideColor := $FFF5F5F5;
    if Assigned(svgAyarlar) then
      svgAyarlar.Svg.OverrideColor := $FFF5F5F5;
    if Assigned(svgIndirilenler) then
      svgIndirilenler.Svg.OverrideColor := $FFF5F5F5;
    if Assigned(svgGecmis) then
      svgGecmis.Svg.OverrideColor := $FFF5F5F5;
    CustomTitleBar.BackgroundColor := $00050505;
    CustomTitleBar.InactiveBackgroundColor := $00050505;
    CustomTitleBar.ButtonBackgroundColor := $00050505;
    CustomTitleBar.ButtonInactiveBackgroundColor := $00050505;
    CustomTitleBar.ForegroundColor := clWhite;
    CustomTitleBar.InactiveForegroundColor := clWhite;
    CustomTitleBar.ButtonForegroundColor := clWhite;
    CustomTitleBar.ButtonInactiveForegroundColor := clWhite;
  end
  else
  begin
    TemaNavArka := $FFF1F3F4;
    TemaNavHap := $FFFFFFFF;
    TemaSekmeArka := $FFF1F3F4;
    TemaAktifSekme := $FFFFFFFF;
    TemaPasifSekme := $FFE4E6E9;
    TemaMetin := $FF202124;
    TemaYukleyici := $FF1A73E8;
    Color := $00F1F3F4;
    Panel1.Color := $00F1F3F4;
    Panel2.Color := $00F1F3F4;
    pnlTarayici.Color := $00F1F3F4;
    edtURL.Color := $00FFFFFF;
    edtURL.Font.Color := clBlack;
    lstOneriler.Color := $00FFFFFF;
    svgGeri.Svg.OverrideColor := $FF3C4043;
    svgIleri.Svg.OverrideColor := $FF3C4043;
    svgTazele.Svg.OverrideColor := $FF3C4043;
    svgGorevYon.Svg.OverrideColor := $FF3C4043;
    if Assigned(svgAyarlar) then
      svgAyarlar.Svg.OverrideColor := $FF3C4043;
    if Assigned(svgIndirilenler) then
      svgIndirilenler.Svg.OverrideColor := $FF3C4043;
    if Assigned(svgGecmis) then
      svgGecmis.Svg.OverrideColor := $FF3C4043;
    CustomTitleBar.BackgroundColor := $00F1F3F4;
    CustomTitleBar.InactiveBackgroundColor := $00F1F3F4;
    CustomTitleBar.ButtonBackgroundColor := $00F1F3F4;
    CustomTitleBar.ButtonInactiveBackgroundColor := $00F1F3F4;
    CustomTitleBar.ForegroundColor := clBlack;
    CustomTitleBar.InactiveForegroundColor := clBlack;
    CustomTitleBar.ButtonForegroundColor := clBlack;
    CustomTitleBar.ButtonInactiveForegroundColor := clBlack;
  end;
  if Assigned(skNav) then
    skNav.Redraw;
  if Assigned(skTabs) then
    skTabs.Redraw;

  // 2. SVG İkonların (OverrideColor) değişimini anında ekrana yansıt:
  if Assigned(svgGeri) then
    svgGeri.Repaint;
  if Assigned(svgIleri) then
    svgIleri.Repaint;
  if Assigned(svgTazele) then
    svgTazele.Repaint;
  if Assigned(svgGorevYon) then
    svgGorevYon.Repaint;
  if Assigned(svgAyarlar) then
    svgAyarlar.Repaint;
  if Assigned(svgIndirilenler) then
    svgIndirilenler.Repaint;
  if Assigned(svgGecmis) then
    svgGecmis.Repaint;

  // 3. Arka plan panellerinin (Adres çubuğu arkası vs.) renk değişimini zorla:
  if Assigned(Panel1) then
    Panel1.Repaint;
  if Assigned(Panel2) then
    Panel2.Repaint;
  if Assigned(pnlTarayici) then
    pnlTarayici.Repaint;
  if Assigned(edtURL) then
    edtURL.Repaint;

  if HandleAllocated then
    Perform(CM_CUSTOMSTYLECHANGED, 0, 0);
end;

function TMainFrm.RAMKullaniminiGetir(PID: Cardinal): Double;
var
  hProc: THandle;
  PMC: TProcessMemoryCounters;
begin
  Result := 0;
  // İşlemden sadece "Bilgi Okuma" yetkisi alıyoruz
  hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
    False, PID);
  if hProc <> 0 then
  begin
    try
      // PsAPI ile işlemin bellek haritasını (Working Set) çıkar
      if GetProcessMemoryInfo(hProc, @PMC, SizeOf(PMC)) then
      begin
        // Byte olarak gelen veriyi Megabyte (MB) cinsine çevir
        Result := PMC.WorkingSetSize / (1024 * 1024);
      end;
    finally
      CloseHandle(hProc);
    end;
  end;
end;

function TMainFrm.CPUKullaniminiGetir(PID: Cardinal): Double;
var
  hProc: THandle;
  CreationTime, ExitTime, KernelTime, UserTime: TFileTime;
  SysIdle, SysKernel, SysUser: TFileTime;
  SysTimeStr, ProcTimeStr: UInt64;
  EskiZaman, YeniZaman: TCPURecord;
  SysFark, ProcFark: UInt64;

  // FileTime yapısını güvenli bir şekilde 64-Bit tam sayıya (UInt64) çeviren dönüştürücü
  function FT2U64(const FT: TFileTime): UInt64;
  var
    LI: ULARGE_INTEGER;
  begin
    LI.LowPart := FT.dwLowDateTime;
    LI.HighPart := FT.dwHighDateTime;
    Result := LI.QuadPart;
  end;

begin
  Result := 0;
  // İşleme erişim yetkisi al
  hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
    False, PID);
  if hProc = 0 then
    Exit;

  try
    // 1. Hem bu PID'nin hem de tüm bilgisayarın (Sistemin) harcadığı süreleri çek!
    if GetProcessTimes(hProc, CreationTime, ExitTime, KernelTime, UserTime) and
      GetSystemTimes(SysIdle, SysKernel, SysUser) then
    begin

      // Bitsel operatörler (shl, or) yerine güvenli ULARGE_INTEGER dönüşümü kullanıyoruz
      SysTimeStr := FT2U64(SysKernel) + FT2U64(SysUser);
      ProcTimeStr := FT2U64(KernelTime) + FT2U64(UserTime);

      YeniZaman.SystemTime := SysTimeStr;
      YeniZaman.ProcessTime := ProcTimeStr;

      // 2. Eğer bu PID'nin bir saniye önceki halini hatırlıyorsak, aradaki FARKI bul!
      if FCPUZamanlari.TryGetValue(PID, EskiZaman) then
      begin
        SysFark := YeniZaman.SystemTime - EskiZaman.SystemTime;
        ProcFark := YeniZaman.ProcessTime - EskiZaman.ProcessTime;

        if SysFark > 0 then
          Result := (ProcFark / SysFark) * 100.0;
        // Görev Yöneticisi CPU Yüzdesi!
      end;

      // 3. Bir sonraki saniye kullanmak üzere bu yeni değerleri hafızaya yaz
      FCPUZamanlari.AddOrSetValue(PID, YeniZaman);
    end;
  finally
    CloseHandle(hProc);
  end;
end;

function TMainFrm.AgHiziniGetir(PID: Cardinal): Double;
var
  hProc: THandle;
  IoCounters: TIOCounters;
  EskiBytes, YeniBytes, Fark: UInt64;
begin
  Result := 0;
  hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
    False, PID);
  if hProc = 0 then
    Exit;

  try
    if GetProcessIoCounters(hProc, IoCounters) then
    begin
      YeniBytes := IoCounters.ReadTransferCount;

      if FNetZamanlari.TryGetValue(PID, EskiBytes) then
      begin
        if YeniBytes > EskiBytes then
        begin
          Fark := YeniBytes - EskiBytes;
          Result := Fark / 1024.0;
        end;
      end;

      FNetZamanlari.AddOrSetValue(PID, YeniBytes);
    end;
  finally
    CloseHandle(hProc);
  end;
end;

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
  YildizDurumunuGuncelle;
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

procedure TMainFrm.edtURLChange(Sender: TObject);
begin
  if FAdresiKodDegistiriyor then
    Exit; // SİHİRLİ KİLİT BURADA!

  tmrArama.Enabled := False;

  if Trim(edtURL.Text) = '' then
  begin
    Exit;
  end;

  tmrArama.Enabled := True;
end;

procedure TMainFrm.edtURLEnter(Sender: TObject);
begin
  if Trim(edtURL.Text) <> '' then
    tmrArama.Enabled := True;
end;

procedure TMainFrm.edtURLExit(Sender: TObject);
var
  FareNoktasi: TPoint;
begin
  if lstOneriler.Visible then
  begin
    // Farenin ekrandaki konumunu formumuzun iç koordinatlarına çeviriyoruz
    FareNoktasi := ScreenToClient(Mouse.CursorPos);

    // Eğer fare o an ListBox'ın sınırları içinde DEĞİLSE gizle!
    if not lstOneriler.BoundsRect.Contains(FareNoktasi) then
      lstOneriler.Visible := False;
  end;
end;

procedure TMainFrm.edtURLKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  SecilenMetin, YeniURL: string;
  TirePos: Integer;
begin
  // Ctrl+K → Görev Yöneticisi (liste açık olmasa da çalışmalı)
  if (ssCtrl in Shift) and (Key = Ord('K')) then
  begin
    Key := 0;
    YeniSekmeAc('trace://taskmgr');
    Exit;
  end;
  // Ctrl+, → Ayarlar
  if (ssCtrl in Shift) and (Key = $BC) then
  begin
    Key := 0;
    YeniSekmeAc('trace://settings');
    Exit;
  end;

  // Eğer liste görünmüyorsa ok tuşlarına karışma
  if not lstOneriler.Visible then
    Exit;
  if lstOneriler.Items.Count = 0 then
    Exit;

  // AŞAĞI veya YUKARI tuşuna basıldıysa
  if (Key = VK_DOWN) or (Key = VK_UP) then
  begin
    // 1. Yeni Satırı Seç
    if Key = VK_DOWN then
    begin
      if lstOneriler.ItemIndex < lstOneriler.Items.Count - 1 then
        lstOneriler.ItemIndex := lstOneriler.ItemIndex + 1
      else
        lstOneriler.ItemIndex := 0; // Sona geldiyse başa dön
    end
    else if Key = VK_UP then
    begin
      if lstOneriler.ItemIndex > 0 then
        lstOneriler.ItemIndex := lstOneriler.ItemIndex - 1
      else
        lstOneriler.ItemIndex := lstOneriler.Items.Count - 1;
      // Baştaysa sona dön
    end;

    Key := 0; // TEdit'in kendi ok tuşu davranışını iptal et (İmleç sağa/sola kaymasın)

    // 2. Seçilen Satırdaki URL'yi Adres Çubuğuna Doldur (Chrome gibi!)
    SecilenMetin := lstOneriler.Items[lstOneriler.ItemIndex];
    TirePos := LastDelimiter('-', SecilenMetin);

    if TirePos > 0 then
      YeniURL := Trim(Copy(SecilenMetin, TirePos + 1, Length(SecilenMetin)))
    else
      YeniURL := SecilenMetin;

    // Arama sayacı tetiklenmesin diye kilitliyoruz
    FAdresiKodDegistiriyor := True;
    edtURL.Text := YeniURL;
    edtURL.SelStart := Length(edtURL.Text); // İmleci yazının en sonuna al
    FAdresiKodDegistiriyor := False;
  end;
end;

procedure TMainFrm.edtURLKeyPress(Sender: TObject; var Key: Char);
var
  TargetURL: string;
begin
  if Key = #13 then
  begin
    Key := #0; // Sesi (ding) engelle
    tmrArama.Enabled := False; // Sayacı iptal et

    // YENİ: Eğer liste açıksa ve bir satır seçilmişse (ok tuşlarıyla)
    if lstOneriler.Visible and (lstOneriler.ItemIndex <> -1) then
    begin
      // ListBox'ın kendi tıklama olayını tetikle ve çık!
      lstOnerilerClick(nil);
      Exit;
    end;

    lstOneriler.Visible := False;
    TargetURL := Trim(edtURL.Text);

    // 1. YENİ KALKAN: Eğer yazılan şey bizim özel trace:// komutumuzsa, ona hiç dokunma!
    if Pos('trace://', TargetURL) = 1 then
    begin
      // Olduğu gibi bırak, aşağıda doğrudan Chromium'a gidecek
    end
    // 2. Normal site mi? (İçinde boşluk yok ve nokta var)
    else if (Pos(' ', TargetURL) = 0) and (Pos('.', TargetURL) > 0) then
    begin
      if (Pos('http://', TargetURL) = 0) and (Pos('https://', TargetURL) = 0)
      then
        TargetURL := 'https://' + TargetURL;
    end
    // 3. Hiçbirine uymuyorsa Google'da ara!
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
  URLs: TStringList;
begin
  skTabs.Animation.Enabled := False;

  if Assigned(dmVeri) then
  begin
    URLs := TStringList.Create;
    try
      for i := 0 to FSekmeler.Count - 1 do
        if Assigned(FSekmeler[i]) and (FSekmeler[i].GuncelURL <> '') and
          (Pos('trace://', FSekmeler[i].GuncelURL) <> 1) then
          URLs.Add(FSekmeler[i].GuncelURL);
      dmVeri.OturumSekmeleriniKaydet(URLs);
    finally
      URLs.Free;
    end;
  end;

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
var
  TemaAdi: string;
begin
  FSekmeler := TList<TTBrowserFrame>.Create;
  FAktifIndex := -1;
  FSekmeSayaci := 0;
  FCPUZamanlari := TDictionary<Cardinal, TCPURecord>.Create;
  FNetZamanlari := TDictionary<Cardinal, UInt64>.Create;
  Application.OnException := AppExceptionHandler;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  FSekmeler.Free;
  FCPUZamanlari.Free;
  FNetZamanlari.Free;
end;

procedure TMainFrm.FormResize(Sender: TObject);
var
  DugmeSolUst: TPoint;
begin
  if Assigned(svgGorevYon) then
    svgGorevYon.Left := Panel1.Width - 16 - svgGorevYon.Width;
  if Assigned(svgAyarlar) and Assigned(svgGorevYon) then
    svgAyarlar.Left := svgGorevYon.Left - 12 - svgAyarlar.Width;
  if Assigned(svgYildiz) and Assigned(svgAyarlar) then
    svgYildiz.Left := svgAyarlar.Left - 12 - svgYildiz.Width;
  if Assigned(svgYildiz) then
    edtURL.Width := svgYildiz.Left - 10 - edtURL.Left
  else if Assigned(svgAyarlar) then
    edtURL.Width := svgAyarlar.Left - 10 - edtURL.Left
  else
    edtURL.Width := Panel1.Width - 194;

  // Başlık çubuğundaki İndirilenler/Geçmiş ikonlarını sistemin
  // simge durumuna küçült/büyüt/kapat düğmelerinin hemen soluna yerleştir.
  if Assigned(TitleBarPanel1) and Assigned(svgIndirilenler) and
    Assigned(svgGecmis) and TitleBarPanel1.HandleAllocated then
  begin
    DugmeSolUst := TitleBarPanel1.ScreenToClient
      (CustomTitleBar.CaptionButtonsRect.TopLeft);
    svgIndirilenler.Top := (TitleBarPanel1.Height - svgIndirilenler.Height)
      div 2;
    svgGecmis.Top := svgIndirilenler.Top;
    svgIndirilenler.Left := DugmeSolUst.X - 16 - svgIndirilenler.Width;
    svgGecmis.Left := svgIndirilenler.Left - 8 - svgGecmis.Width;
  end;
end;

procedure TMainFrm.FormShow(Sender: TObject);
var
  BaslangicModu: string;
  KayitliURLler: TStringList;
  i: Integer;
  TemaAdi: string;
begin
  BaslangicModu := 'new_tab';
  if Assigned(dmVeri) then
    BaslangicModu := dmVeri.AyarOku('startup_mode', 'new_tab');

  if BaslangicModu = 'restore' then
  begin
    KayitliURLler := dmVeri.OturumSekmeleriniYukle;
    try
      if KayitliURLler.Count > 0 then
      begin
        for i := 0 to KayitliURLler.Count - 1 do
          YeniSekmeAc(KayitliURLler[i]);
        Exit;
      end;
    finally
      KayitliURLler.Free;
    end;
  end;

  YeniSekmeAc('trace://newtab');

  TemaAdi := 'dark';
  if Assigned(dmVeri) then
    TemaAdi := dmVeri.AyarOku('theme', 'dark');
  TemayiUygula(TemaAdi = 'dark');

  YerIsaretleriniYukle;
  YildizDurumunuGuncelle;
end;

procedure TMainFrm.lstOnerilerClick(Sender: TObject);
var
  TamMetin, HedefURL: string;
  TirePos: Integer;
begin
  if lstOneriler.ItemIndex = -1 then
    Exit;

  TamMetin := lstOneriler.Items[lstOneriler.ItemIndex];
  TirePos := LastDelimiter('-', TamMetin);

  if TirePos > 0 then
  begin
    HedefURL := Trim(Copy(TamMetin, TirePos + 1, Length(TamMetin)));

    // Kodla değiştiği için bayrağı kullanıyoruz ki sonsuz döngü olmasın
    FAdresiKodDegistiriyor := True;
    edtURL.Text := HedefURL;
    FAdresiKodDegistiriyor := False;

    lstOneriler.Visible := False; // İşimiz bitti, gizle

    if AktifKapsul <> nil then
      AktifKapsul.Chromium1.LoadURL(HedefURL);
  end;
end;

procedure TMainFrm.lstOnerilerDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  TamMetin, Baslik, URL: string;
  TirePos: Integer;
  Tuval: TCanvas;
begin
  Tuval := (Control as TListBox).Canvas;
  TamMetin := (Control as TListBox).Items[Index];

  // Metni Başlık ve URL olarak ikiye bölüyoruz
  TirePos := LastDelimiter('-', TamMetin);
  if TirePos > 0 then
  begin
    Baslik := Trim(Copy(TamMetin, 1, TirePos - 1));
    URL := Trim(Copy(TamMetin, TirePos + 1, Length(TamMetin)));
  end
  else
    Baslik := TamMetin;

  // 1. ARKA PLAN BOYANMASI (Üzerine gelince renk değişimi)
  if odSelected in State then
    Tuval.Brush.Color := $00343130 // Hover (Üzerine gelince) Açık Gri
  else
    Tuval.Brush.Color := $00242120; // Normal Koyu Gri

  Tuval.FillRect(Rect);

  // 2. İKON ÇİZİMİ
  Tuval.Font.Name := 'Segoe UI Emoji';
  Tuval.Font.Size := 12;
  Tuval.Font.Color := $00EDEAE8;
  Tuval.TextOut(Rect.Left + 10, Rect.Top + 12, '🕒');

  // 3. BAŞLIK ÇİZİMİ
  Tuval.Font.Name := 'Segoe UI';
  Tuval.Font.Size := 11;
  Tuval.Font.Color := $00EDEAE8; // Beyazımsı Gri
  Tuval.TextOut(Rect.Left + 40, Rect.Top + 4, Baslik);

  // 4. URL ÇİZİMİ
  Tuval.Font.Size := 9;
  Tuval.Font.Color := $00F8B48A; // BGR formatında Mavi
  Tuval.TextOut(Rect.Left + 40, Rect.Top + 24, URL);
end;

procedure TMainFrm.skNavDraw(ASender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  HapBoyasi: ISkPaint;
  HapKutusu: TRectF;
begin
  ACanvas.Clear(TemaNavArka);

  HapBoyasi := TSkPaint.Create;
  HapBoyasi.AntiAlias := True;
  HapBoyasi.Color := TemaNavHap;

  if Assigned(svgAyarlar) then
    HapKutusu := TRectF.Create(125, 5, svgAyarlar.Left - 12, ADest.Bottom - 5)
  else
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

  ACanvas.Clear(TemaSekmeArka);

  Boya := TSkPaint.Create;
  Boya.AntiAlias := True;
  YaziBoyasi := TSkPaint.Create;
  YaziBoyasi.AntiAlias := True;
  YaziBoyasi.Color := TemaMetin;
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
      Boya.Color := TemaAktifSekme
    else
      Boya.Color := TemaPasifSekme;

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
      LoaderBoyasi.Color := TemaYukleyici;
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
  ArtiBoyasi.Color := TemaPasifSekme;

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
  lstOneriler.Visible := False;
  if Button <> mbLeft then
    Exit;

  SkiaX := X / skTabs.ScaleFactor;
  SkiaY := Y / skTabs.ScaleFactor;

  // 2. ARTI BUTONU
  if FArtiButonuKutusu.Contains(PointF(SkiaX, SkiaY)) then
  begin
    YeniSekmeAc('trace://newtab');
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
        SekmeyiKapat(i);
        Break;
      end
      else
      begin
        // SEKMEYE TIKLANDI (Sürükleme Başlat)
        FAktifIndex := i;
        AktifSekmeyiGoster;
        if AktifKapsul <> nil then
        begin
          FAdresiKodDegistiriyor := True;
          edtURL.Text := AktifKapsul.GuncelURL;
          FAdresiKodDegistiriyor := False;
        end;

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

procedure TMainFrm.svgGeriClick(Sender: TObject);
begin
  lstOneriler.Visible := False;
  if (AktifKapsul <> nil) and AktifKapsul.Chromium1.CanGoBack then
    AktifKapsul.Chromium1.GoBack;
end;

procedure TMainFrm.svgIleriClick(Sender: TObject);
begin
  lstOneriler.Visible := False;
  if (AktifKapsul <> nil) and AktifKapsul.Chromium1.CanGoForward then
    AktifKapsul.Chromium1.GoForward;
end;

procedure TMainFrm.svgTazeleClick(Sender: TObject);
begin
  lstOneriler.Visible := False;
  if (AktifKapsul <> nil) then
    AktifKapsul.Chromium1.Reload;
end;

procedure TMainFrm.svgGorevYonClick(Sender: TObject);
begin
  YeniSekmeAc('trace://taskmgr');
end;

procedure TMainFrm.svgIndirilenlerClick(Sender: TObject);
begin
  YeniSekmeAc('trace://downloads');
end;

procedure TMainFrm.svgGecmisClick(Sender: TObject);
begin
  YeniSekmeAc('trace://history');
end;

procedure TMainFrm.svgAyarlarClick(Sender: TObject);
begin
  YeniSekmeAc('trace://settings');
end;

procedure TMainFrm.tmrAramaTimer(Sender: TObject);
var
  OneriListesi: TStringList;
begin
  tmrArama.Enabled := False;
  if not edtURL.Focused then
    Exit; // Kullanıcı başka yere tıkladıysa iptal

  OneriListesi := TStringList.Create;
  try
    if Assigned(dmVeri) then
      dmVeri.OnerileriGetir(edtURL.Text, OneriListesi);

    if OneriListesi.Count > 0 then
    begin
      lstOneriler.Items.Assign(OneriListesi);

      // Boyut ve Konum Ayarları
      lstOneriler.Height := (lstOneriler.Items.Count * lstOneriler.ItemHeight);
      lstOneriler.Width := edtURL.Width;
      lstOneriler.Left := Panel1.Left + edtURL.Left;
      lstOneriler.Top := Panel1.Top + Panel1.Height;

      lstOneriler.BringToFront;
      lstOneriler.Visible := True;
      tmrOdak.Enabled := True;
    end
    else
      lstOneriler.Visible := False;
  finally
    OneriListesi.Free;
  end;
end;

procedure TMainFrm.tmrOdakTimer(Sender: TObject);
var
  GTI: TGUITHREADINFO;
begin
  // Eğer liste zaten gizliyse boşuna çalışma
  if not lstOneriler.Visible then
  begin
    tmrOdak.Enabled := False;
    Exit;
  end;

  // Windows'tan "Klavye/Fare odağı tam olarak kimin elinde?" bilgisini al
  GTI.cbSize := SizeOf(TGUITHREADINFO);
  if GetGUIThreadInfo(0, GTI) then
  begin
    // Eğer odak Adres Çubuğunda DEĞİLSE ve ListBox'ın kendisinde DEĞİLSE...
    // (Yani Chromium'a, sekmelere veya başka bir programa tıklandıysa)
    if (GTI.hwndFocus <> edtURL.Handle) and (GTI.hwndFocus <> lstOneriler.Handle)
    then
    begin
      lstOneriler.Visible := False; // Acımasızca gizle!
      tmrOdak.Enabled := False; // Avcıyı uykuya al
    end;
  end;
end;

procedure TMainFrm.tmrTaskMgrTimer(Sender: TObject);
begin
  GorevYoneticisiniGuncelle;
end;

procedure TMainFrm.SekmeyiKapat(SekmeIndex: Integer);
begin
  if (SekmeIndex < 0) or (SekmeIndex >= FSekmeler.Count) then
    Exit;
  if FSekmeler[SekmeIndex].KapanisAsamasinda then
    Exit;

  // ÇARPIYA BASILDI (Hemen silme, aşağı düşme emri ver)
  FSekmeler[SekmeIndex].KapanisAsamasinda := True;
  FSekmeler[SekmeIndex].HedefY := skTabs.Height + 20;
  // Tuvalin altına hedef koy

  // Eğer kapanan aktif sekme ise, anında başka bir sekmeyi aktif yap
  if FAktifIndex = SekmeIndex then
  begin
    var
    YeniAktif := -1;

    // Önce sola doğru ara
    for var j := SekmeIndex - 1 downto 0 do
      if not FSekmeler[j].KapanisAsamasinda then
      begin
        YeniAktif := j;
        Break;
      end;

    // Bulamazsa sağa doğru ara
    if YeniAktif = -1 then
      for var j := SekmeIndex + 1 to FSekmeler.Count - 1 do
        if not FSekmeler[j].KapanisAsamasinda then
        begin
          YeniAktif := j;
          Break;
        end;

    FAktifIndex := YeniAktif;
    AktifSekmeyiGoster;

    if AktifKapsul <> nil then
    begin
      FAdresiKodDegistiriyor := True;
      edtURL.Text := AktifKapsul.GuncelURL;
      FAdresiKodDegistiriyor := False;
    end
    else
    begin
      // Eğer son sekme kapandıysa adres çubuğunu temizle
      FAdresiKodDegistiriyor := True;
      edtURL.Text := '';
      FAdresiKodDegistiriyor := False;
    end;
  end;
end;

procedure TMainFrm.GorevYoneticisiniGuncelle;
var
  SnapProcHandle: THandle;
  ProcEntry: TProcessEntry32;
  NextProc: Boolean;
  ExeName: string;
  MainPID: Cardinal;
  RamMB, CpuYuzde, NetKB: Double;
  JSKod, RamClass, CpuClass, GorevAdi: string;
  TaskMgrKapsul: TTBrowserFrame;
  ActivePIDs: string;
  PID: Cardinal;
  SekmeBulundu: Boolean;
  i: Integer;
begin
  // 1. Görev Yöneticisi Açık Mı?
  TaskMgrKapsul := nil;
  for i := 0 to FSekmeler.Count - 1 do
  begin
    if Pos('trace://taskmgr', FSekmeler[i].GuncelURL) > 0 then
    begin
      TaskMgrKapsul := FSekmeler[i];
      Break;
    end;
  end;

  if TaskMgrKapsul = nil then
    Exit;

  ExeName := ExtractFileName(Application.ExeName);
  MainPID := GetCurrentProcessId;
  JSKod := '';
  ActivePIDs := '';

  // 2. TÜM İŞLEMLERİ TOPLA VE IPC (PID) ÜZERİNDEN KESİN OLARAK İSİMLENDİR
  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if SnapProcHandle <> INVALID_HANDLE_VALUE then
  begin
    try
      ProcEntry.dwSize := SizeOf(ProcEntry);
      NextProc := Process32First(SnapProcHandle, ProcEntry);

      while NextProc do
      begin
        if SameText(StrPas(ProcEntry.szExeFile), ExeName) then
        begin
          PID := ProcEntry.th32ProcessID;

          // Aktif PID'leri virgülle ayırarak listeye ekle (Çöp toplayıcı için)
          if ActivePIDs = '' then
            ActivePIDs := IntToStr(PID)
          else
            ActivePIDs := ActivePIDs + ',' + IntToStr(PID);

          RamMB := RAMKullaniminiGetir(PID);
          CpuYuzde := CPUKullaniminiGetir(PID);
          NetKB := AgHiziniGetir(PID);

          RamClass := 'normal';
          if RamMB > 250 then
            RamClass := 'warn';
          if RamMB > 500 then
            RamClass := 'danger';
          CpuClass := 'normal';
          if CpuYuzde > 5.0 then
            CpuClass := 'warn';
          if CpuYuzde > 15.0 then
            CpuClass := 'danger';

          var
            NetStr: string;
          if NetKB > 1024 then
            NetStr := FormatFloat('0.0 MB/s', NetKB / 1024.0)
          else
            NetStr := FormatFloat('0.0 KB/s', NetKB);

          // YENİ: KESİN (DETERMINISTIC) İSİMLENDİRME!
          if PID = MainPID then
            GorevAdi := 'Trace Ana İşlem (Browser Core)'
          else
          begin
            SekmeBulundu := False;

            // Bu PID, IPC ile bize rapor veren sekmelerden birine mi ait?
            for i := 0 to FSekmeler.Count - 1 do
            begin
              if FSekmeler[i].FRendererPID = PID then
              begin
                GorevAdi := 'Sekme: ' + FSekmeler[i].SayfaBasligi;

                if (GorevAdi = 'Sekme: ') or (GorevAdi = 'Sekme: Yükleniyor...')
                then
                  GorevAdi := 'Sekme: ' +
                    ExtractFileName(FSekmeler[i].GuncelURL);

                SekmeBulundu := True;
                Break;
              end;
            end;

            // Eğer listedeki sekmelerden biri değilse, bu kesinlikle GPU veya Network'tür.
            if not SekmeBulundu then
              GorevAdi := 'Trace Alt İşlemi (GPU / Ağ / Crashpad)';
          end;

          // JS Komutunu oluştur
          JSKod := JSKod +
            Format('updateProcess(%d, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s''); ',
            [PID, GorevAdi, FormatFloat('0.0', CpuYuzde) + '%',
            FormatFloat('0.0 MB', RamMB), NetStr, CpuClass, RamClass]);
        end;
        NextProc := Process32Next(SnapProcHandle, ProcEntry);
      end;
    finally
      CloseHandle(SnapProcHandle);
    end;
  end;

  // 3. Ölü (Kapanan) İşlemleri Animasyonla Temizleme Emri
  if ActivePIDs <> '' then
    JSKod := JSKod + Format('cleanupDeadProcesses([%s]); ', [ActivePIDs]);

  // JS'yi Gönder!
  if Assigned(TaskMgrKapsul.Chromium1.Browser) then
    TaskMgrKapsul.Chromium1.Browser.MainFrame.ExecuteJavaScript(JSKod, '', 0);
end;

type
  // DELPHI HACK: TControl'ün korumalı (protected) üyelerine erişmek için sahte bir kırıcı sınıf!
  TControlHack = class(TControl);
  // Aynı numara: TCustomControl.Canvas da protected, metin genişliği
  // ölçmek için erişmemiz lazım.
  TCanvasControlHack = class(TCustomControl);

procedure TMainFrm.YerIsaretleriniYukle;
var
  Btn: TSpeedButton;
  BId: Integer;
  BUrl, BTitle: string;
begin
  // Önce mevcut tüm butonları ve ikonları temizle
  while pnlBookmarks.ControlCount > 0 do
    pnlBookmarks.Controls[0].Free;
  imgFavicons.Clear;
  // Az önce Free edilmiş bir butona sarkan işaretçi kalmasın
  FBookmarkSurukleBtn := nil;

  if not Assigned(dmVeri) then
    Exit;

  try
    dmVeri.qryYerIsaretleri.Close;
    dmVeri.qryYerIsaretleri.SQL.Text :=
      'SELECT ID, URL, Title FROM Bookmarks ORDER BY OrderIndex ASC, ID ASC';
    dmVeri.qryYerIsaretleri.Open;

    while not dmVeri.qryYerIsaretleri.Eof do
    begin
      BId := dmVeri.qryYerIsaretleri.FieldByName('ID').AsInteger;
      BUrl := dmVeri.qryYerIsaretleri.FieldByName('URL').AsString;
      BTitle := dmVeri.qryYerIsaretleri.FieldByName('Title').AsString;

      // 1. DİNAMİK BUTON OLUŞTURMA
      Btn := TSpeedButton.Create(pnlBookmarks);
      Btn.Parent := pnlBookmarks;
      Btn.Align := alLeft;
      // Başlık boşsa (kullanıcı bilerek boş bırakmışsa) hiç metin koyma;
      // sadece ikon için dar bir buton yerleşsin, boş başlık payı bırakılmasın.
      if BTitle <> '' then
        Btn.Caption := ' ' + BTitle
      else
        Btn.Caption := '';
      Btn.Hint := BUrl;
      Btn.ShowHint := True;
      Btn.Tag := BId;
      Btn.Flat := True;
      Btn.Margins.SetBounds(2, 2, 2, 2);
      Btn.AlignWithMargins := True;
      // Genişlik hiç ayarlanmıyordu; TSpeedButton'ın varsayılan (dar)
      // genişliğinde başlık metni neredeyse tamamen kırpılıyordu.
      // TSpeedButton.AutoSize yalnızca glyph'e göre boyutlanıyor, başlık
      // metnini hesaba katmıyor; bu yüzden genişliği metne göre elle
      // hesaplıyoruz (ikon + kenar boşlukları için de pay bırakarak).
      Btn.Height := 24;
      if BTitle <> '' then
      begin
        TCanvasControlHack(pnlBookmarks).Canvas.Font.Assign(Btn.Font);
        Btn.Width :=
          TCanvasControlHack(pnlBookmarks).Canvas.TextWidth(Btn.Caption) + 34;
      end
      else
        Btn.Width := 28; // Sadece ikon: metin payı olmadan dar buton
      // TemaMetin bir Skia ARGB Cardinal'i; ham haliyle TColor'a atamak
      // range check error ile çöküyordu (bkz. ARGBtenTColora yorumu).
      Btn.Font.Color := ARGBtenTColora(TemaMetin);

      // 2. SÜRÜKLE BIRAK VE TIKLAMA OLAYLARINI BAĞLA (TControlHack ile duvarı aşıyoruz!)
      // NOT: Önce DragMode=dmAutomatic + VCL'in kendi OleDrag altyapısı (Begin/
      // OnDragOver/OnDragDrop) denendi; TSpeedButton bir TGraphicControl
      // olduğundan gerçek bir pencere kolu (HWND) yok ve fare capture'ı hep
      // ebeveyn panelde kalıyor: BeginDrag çağrısı sürüklemeyi hiç
      // başlatmıyor, mesaj sıradan geri buton'a ulaşıp normal bir tıklama
      // gibi işleniyordu (istenen sürükleme yerine her seferinde yeni sekme
      // açılıyordu). Bu yüzden sürükleme tamamen elle yönetiliyor: MouseDown
      // başlangıç noktasını kaydeder, MouseMove eşiği aşan hareketi görünce
      // butonu doğrudan hedefin yanına taşır, MouseUp sırayı kaydeder ve bir
      // sürükleme gerçekleştiyse OnClick'in sekme açmasını engeller.
      TControlHack(Btn).OnMouseDown := BookmarkMouseDown;
      TControlHack(Btn).OnMouseMove := BookmarkMouseMove;
      TControlHack(Btn).OnMouseUp := BookmarkMouseUp;

      // Tıklama olayı public olduğu için normal atanabilir
      Btn.OnClick := BookmarkClick;

      // 3. İKONU AYRI BİR PROSEDÜRDE, GÜVENLİ ŞEKİLDE YÜKLE
      YerImiIkonunuYukle(Btn, BUrl);

      dmVeri.qryYerIsaretleri.Next;
    end;
  finally
    // DİKKAT: .Free yerine sadece .Close dedik. Bileşeni yok etmek programı çökertir!
    dmVeri.qryYerIsaretleri.Close;
  end;
end;

// Bir yer imi butonu için favicon indirir ve ImageList'e ekler.
//
// ÖNEMLİ (bir önceki sürümdeki "range check error"nin gerçek kök nedeni):
// VCL'in TCanvas/TBitmap/TImageList nesneleri thread-safe DEĞİLDİR. Bir
// önceki denemede TBitmap oluşturma, yeniden boyutlandırma ve Canvas'a çizme
// işlemleri arka plan thread'inde yapılıyordu; bu, GDI kaynaklarının eş
// zamanlı/senkronizasyonsuz kullanımına yol açıp rastgele ama tekrarlayan
// "range check error" çökmelerine sebep oluyordu.
//
// Doğru desen: arka plan thread'i SADECE ağdan ham baytları indirir.
// TPngImage/TBitmap/TCanvas/TImageList'e dokunan HER ŞEY, TThread.Queue ile
// ana (UI) thread'ine postalanıp orada çalıştırılır.
procedure TMainFrm.YerImiIkonunuYukle(ABtn: TSpeedButton; const AURL: string);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Http: THTTPClient;
      Ms: TMemoryStream;
      IkonUrl: string;
      Indirildi: Boolean;
    begin
      Ms := TMemoryStream.Create;
      Indirildi := False;
      try
        Http := THTTPClient.Create;
        try
          IkonUrl := 'https://www.google.com/s2/favicons?domain=' +
            TNetEncoding.URL.EncodeQuery(AURL) + '&sz=16';
          Http.Get(IkonUrl, Ms);
          Indirildi := Ms.Size > 0;
        finally
          Http.Free;
        end;
      except
        on E: Exception do
        begin
          BookmarkLog('YerImiIkonunuYukle: indirme HATASI: ' + E.ClassName +
            ': ' + E.Message);
          Indirildi := False;
        end;
      end;

      if not Indirildi then
      begin
        Ms.Free;
        Exit;
      end;

      Ms.Position := 0;

      // Ms'nin sahipliğini ana thread'e devrediyoruz; orada serbest
      // bırakılacak (aşağıdaki Queue kapanışına bakınız).
      TThread.Queue(nil,
          procedure
          var
            Png: TPngImage;
            Bmp: TBitmap;
            YeniIndex: Integer;
            HalaGecerli: Boolean;
            i: Integer;
          begin
            try
              try
                // Buton, bu asenkron işlem sürerken yer imi barı yeniden
                // yüklendiği için zaten Free edilmiş olabilir (ör. arka
                // arkaya hızlıca yer imi eklenip kaldırılması). ABtn artık
                // geçersiz bir işaretçi olabileceğinden ASLA doğrudan
                // sorgulanmaz (Assigned bunu yakalayamaz); bunun yerine hâlâ
                // pnlBookmarks'ın gerçek bir alt kontrolü mü diye canlı
                // listeden bakıyoruz.
                HalaGecerli := False;
                for i := 0 to pnlBookmarks.ControlCount - 1 do
                  if pnlBookmarks.Controls[i] = ABtn then
                  begin
                    HalaGecerli := True;
                    Break;
                  end;
                if not HalaGecerli then
                  Exit;

                Png := TPngImage.Create;
                try
                  Png.LoadFromStream(Ms);

                  // Google'ın favicon servisi &sz=16 istesek bile HER ZAMAN
                  // tam 16x16 döndürmüyor (bazı siteler için farklı boyut
                  // veya "globe" yedek ikonu gelebiliyor). TImageList.Add,
                  // eklenen bitmap'in genişliğinin kendi çerçeve genişliğinin
                  // katı olmasını bekler; boyut uyuşmazlığında dahili
                  // hesaplama taşıp "range check error" ile çöküyordu. Bu
                  // yüzden indirilen görseli her zaman ImageList'in kendi
                  // boyutuna göre yeniden çiziyoruz.
                  Bmp := TBitmap.Create;
                  try
                    Bmp.PixelFormat := pf32bit;
                    Bmp.SetSize(imgFavicons.Width, imgFavicons.Height);
                    Bmp.Canvas.Brush.Color := clBtnFace;
                    Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
                    Bmp.Canvas.StretchDraw(Rect(0, 0, Bmp.Width, Bmp.Height),
                      Png);

                    YeniIndex := imgFavicons.Add(Bmp, nil);
                    ABtn.Images := imgFavicons;
                    ABtn.ImageIndex := YeniIndex;
                  finally
                    Bmp.Free;
                  end;
                finally
                  Png.Free;
                end;
              except
                on E: Exception do
                  // Bozuk/çözülemeyen bir simge varsa sessizce yok say; buton
                  // ikon olmadan, sadece başlık metniyle çalışmaya devam eder.
                  // Yine de tanı için logluyoruz.
                  BookmarkLog('Queue: YAKALANAN HATA: ' + E.ClassName + ': ' +
                    E.Message);
              end;
            finally
              Ms.Free;
            end;
          end);
    end).Start;
end;

// BUTONA TIKLANDIĞINDA SAYFAYI AÇ
// NOT: Bu tıklama aslında bir sürüklemenin bitişiyse (bkz.
// FBookmarkSuruklemeOldu) sekme açmıyoruz; VCL, MouseUp'tan sonra normal
// tıklamalarla aynı şekilde Click'i tetiklemeye devam ediyor.
procedure TMainFrm.BookmarkClick(Sender: TObject);
var
  Btn: TSpeedButton;
begin
  if FBookmarkSuruklemeOldu then
    Exit;

  Btn := Sender as TSpeedButton;
  if Btn.Hint <> '' then
    YeniSekmeAc(Btn.Hint);
end;

// SÜRÜKLEMENİN BAŞLANGIÇ NOKTASINI KAYDET (henüz sürükleme başlatma)
procedure TMainFrm.BookmarkMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FBookmarkSurukleBtn := Sender as TSpeedButton;
    FBookmarkSurukleBaslangic := FBookmarkSurukleBtn.ClientToScreen(Point(X, Y));
    FBookmarkSuruklemeOldu := False;
  end;
end;

// FARE EŞİĞİ AŞACAK KADAR HAREKET ETTİYSE BUTONU HEDEFİN YANINA TAŞI
//
// NOT (önceki denemenin neden çalışmadığı): TSpeedButton bir TGraphicControl
// olduğu için kendi pencere koluna (HWND) sahip değil; fare "capture"ı hep
// ebeveyn panelde (pnlBookmarks) kalıyor. VCL'in kendi TControl.BeginDrag /
// OnDragOver / OnDragDrop altyapısını (Immediate=True ile) burada manuel
// tetiklemeye çalışmak bu yüzden sürüklemeyi gerçekten başlatmıyordu — fare
// bırakıldığında olay hâlâ butona normal bir tıklama gibi ulaşıp her seferinde
// yeni sekme açıyordu. Bunun yerine sürüklemeyi tamamen kendimiz, doğrudan
// Left konumlarıyla oynayarak yönetiyoruz; VCL'in OLE tabanlı sürükle-bırak
// mekanizmasına hiç girmiyoruz.
procedure TMainFrm.BookmarkMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Kaynak: TSpeedButton;
  Guncel: TPoint;
  Hedef: TControl;
begin
  if not Assigned(FBookmarkSurukleBtn) or (Sender <> FBookmarkSurukleBtn) then
    Exit;
  if not (ssLeft in Shift) then
    Exit;

  Kaynak := FBookmarkSurukleBtn;
  Guncel := Kaynak.ClientToScreen(Point(X, Y));

  if not FBookmarkSuruklemeOldu then
  begin
    if (Abs(Guncel.X - FBookmarkSurukleBaslangic.X) < Mouse.DragThreshold) and
       (Abs(Guncel.Y - FBookmarkSurukleBaslangic.Y) < Mouse.DragThreshold) then
      Exit; // Eşik aşılmadı, muhtemelen sadece bir tıklama
    FBookmarkSuruklemeOldu := True;
  end;

  // Farenin şu an üzerinde olduğu butonu bul; onun soluna/sağına geç
  Hedef := pnlBookmarks.ControlAtPos(pnlBookmarks.ScreenToClient(Guncel),
    False, True);
  if (Hedef is TSpeedButton) and (Hedef <> Kaynak) then
  begin
    // VCL'de Align = alLeft olan objelerin yerini değiştirmek için Left
    // değerleriyle oynamak yeterlidir!
    if Kaynak.Left > Hedef.Left then
      Kaynak.Left := TSpeedButton(Hedef).Left - 1 // Sola taşı
    else
      Kaynak.Left := TSpeedButton(Hedef).Left + TSpeedButton(Hedef).Width + 1;
      // Sağa taşı
  end;
end;

// SÜRÜKLEME BİTTİYSE YENİ SIRALAMAYI KAYDET
procedure TMainFrm.BookmarkMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (Sender = FBookmarkSurukleBtn) then
  begin
    if FBookmarkSuruklemeOldu then
      BookmarkSiralamaKaydet;
    FBookmarkSurukleBtn := nil;
  end;
end;

// YENİ SIRALAMAYI VERİTABANINA YAZ
procedure TMainFrm.BookmarkSiralamaKaydet;
var
  i: Integer;
  Btn: TSpeedButton;
begin
  if not Assigned(dmVeri) then
    Exit;

  // Paneldeki butonların fiziksel (Z-order) sırasına bakıp veritabanını güncelliyoruz
  for i := 0 to pnlBookmarks.ControlCount - 1 do
  begin
    if pnlBookmarks.Controls[i] is TSpeedButton then
    begin
      Btn := TSpeedButton(pnlBookmarks.Controls[i]);
      // Btn.Tag içinde kayıtlı olan DB ID'sini kullanarak OrderIndex'i güncelliyoruz
      dmVeri.FDConn.ExecSQL
        ('UPDATE Bookmarks SET OrderIndex = :O WHERE ID = :ID', [i, Btn.Tag]);
    end;
  end;
end;

procedure TMainFrm.YildizDurumunuGuncelle;
const
  SVG_DOLU = '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path fill="#000000" d="M12 2L14.9 8.6L22 9.2L16.7 13.9L18.2 21L12 ' +
    '17.3L5.8 21L7.3 13.9L2 9.2L9.1 8.6Z"/></svg>';
  SVG_BOS = '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">' +
    '<path fill="none" stroke="#000000" stroke-width="1.5" ' +
    'stroke-linejoin="round" d="M12 2L14.9 8.6L22 9.2L16.7 13.9L18.2 21L12 ' +
    '17.3L5.8 21L7.3 13.9L2 9.2L9.1 8.6Z"/></svg>';
var
  MevcutURL: string;
  Isaretli: Boolean;
begin
  if not Assigned(svgYildiz) then
    Exit;

  MevcutURL := '';
  if AktifKapsul <> nil then
    MevcutURL := AktifKapsul.GuncelURL;

  Isaretli := Assigned(dmVeri) and (MevcutURL <> '') and
    (Pos('trace://', MevcutURL) <> 1) and dmVeri.YerIsaretiVarMi(MevcutURL);

  if Isaretli then
  begin
    svgYildiz.Svg.Source := SVG_DOLU;
    svgYildiz.Svg.OverrideColor := claGold;
  end
  else
  begin
    svgYildiz.Svg.Source := SVG_BOS;
    svgYildiz.Svg.OverrideColor := claWhitesmoke;
  end;

  svgYildiz.Enabled := (MevcutURL <> '') and (Pos('trace://', MevcutURL) <> 1);
end;

procedure TMainFrm.svgYildizClick(Sender: TObject);
var
  MevcutURL, OnerilenBaslik, YeniBaslik: string;
  DuzenlemeModu: Boolean;
  Sonuc: TBookmarkDialogSonuc;
begin
  if AktifKapsul = nil then
    Exit;
  if not Assigned(dmVeri) then
    Exit;

  MevcutURL := AktifKapsul.GuncelURL;
  if (MevcutURL = '') or (Pos('trace://', MevcutURL) = 1) then
    Exit;

  DuzenlemeModu := dmVeri.YerIsaretiVarMi(MevcutURL);

  OnerilenBaslik := Trim(AktifKapsul.SayfaBasligi);
  if (OnerilenBaslik = '') or (OnerilenBaslik = 'Yükleniyor...') then
    OnerilenBaslik := MevcutURL;

  Sonuc := TfrmBookmarkEdit.Calistir(MevcutURL, OnerilenBaslik, DuzenlemeModu,
    YeniBaslik);

  case Sonuc of
    bdsKaydet:
      begin
        // NOT: Burada boş başlığı MevcutURL ile doldurmuyoruz; kullanıcı
        // adı bilerek boş bırakmışsa yer imi barında sadece ikon gösterilir
        // (bkz. YerIsaretleriniYukle).
        if DuzenlemeModu then
          dmVeri.YerIsaretiBasligiGuncelle(MevcutURL, YeniBaslik)
        else
          dmVeri.YerIsaretiEkle(MevcutURL, YeniBaslik);
      end;
    bdsKaldir:
      dmVeri.YerIsaretiSil(MevcutURL);
    bdsIptal:
      Exit; // Hiçbir şey değişmedi, arayüzü yenilemeye gerek yok
  end;

  YildizDurumunuGuncelle;
  YerIsaretleriniYukle;
end;

// İndirme başladığında, farenin (tıklanan bağlantıya yakın) o anki ekran
// konumundan başlık çubuğundaki İndirilenler ikonuna doğru küçük bir daireyi
// uçurur. CEF indirme olaylarına tıklama koordinatını iletmediği için farenin
// o anki konumu elimizdeki en iyi yaklaşıklıktır.
//
// NOT: CEF'in içerik alanı (TCEFWindowParent) gerçek bir native pencere
// (kendi HWND'i var). Normal bir VCL grafik kontrolü (TGraphicControl,
// TSkSvg dahil) hiçbir zaman bir native child pencerenin ÜSTÜNDE görünmez
// ("airspace" sorunu) — fare çoğunlukla CEF içeriğinin üzerinde olduğundan
// animasyon orada tamamen gizli kalırdı. Bu yüzden animasyonu MainFrm'in bir
// alt kontrolü olarak değil, her zaman üstte kalan, saydam arka planlı ayrı
// küçük bir pencerede (TForm) gösteriyoruz.
procedure TMainFrm.IndirmeAnimasyonuBaslat;
var
  FareEkran, HedefEkran: TPoint;
begin
  if not Assigned(svgIndirilenler) or not svgIndirilenler.Visible or
    not HandleAllocated then
    Exit;

  GetCursorPos(FareEkran);
  HedefEkran := TitleBarPanel1.ClientToScreen(Point(svgIndirilenler.Left +
    svgIndirilenler.Width div 2, svgIndirilenler.Top +
    svgIndirilenler.Height div 2));

  // Popup formun Left/Top'u (üst seviye pencere olduğu için) ekran
  // koordinatlarında; bu yüzden burada bir ScreenToClient dönüşümü yok.
  FIndirmeAnimBaslangic := TPointF.Create(FareEkran);
  FIndirmeAnimBitis := TPointF.Create(HedefEkran);

  if not Assigned(FIndirmeAnimForm) then
  begin
    FIndirmeAnimForm := TForm.CreateNew(Self);
    FIndirmeAnimForm.BorderStyle := bsNone;
    FIndirmeAnimForm.FormStyle := fsStayOnTop;
    FIndirmeAnimForm.Position := poDesigned;
    FIndirmeAnimForm.Color := clFuchsia;
    FIndirmeAnimForm.TransparentColor := True;
    FIndirmeAnimForm.TransparentColorValue := clFuchsia;

    FIndirmeAnimSekil := TShape.Create(FIndirmeAnimForm);
    FIndirmeAnimSekil.Parent := FIndirmeAnimForm;
    FIndirmeAnimSekil.Align := alClient;
    FIndirmeAnimSekil.Shape := stCircle;
    FIndirmeAnimSekil.Pen.Style := psClear;
  end;
  FIndirmeAnimSekil.Brush.Color := ARGBtenTColora(TemaYukleyici);

  FIndirmeAnimForm.SetBounds(Round(FIndirmeAnimBaslangic.X - 15),
    Round(FIndirmeAnimBaslangic.Y - 15), 30, 30);
  FIndirmeAnimForm.Show;

  if not Assigned(FIndirmeAnimTimer) then
  begin
    FIndirmeAnimTimer := TTimer.Create(Self);
    FIndirmeAnimTimer.OnTimer := IndirmeAnimasyonuTimerTick;
    FIndirmeAnimTimer.Interval := 15;
  end;

  FIndirmeAnimAdim := 0;
  FIndirmeAnimTimer.Enabled := True;
end;

procedure TMainFrm.IndirmeAnimasyonuTimerTick(Sender: TObject);
const
  TOPLAM_ADIM = 45;
var
  T, Yumusatilmis, X, Y, Boyut: Single;
begin
  Inc(FIndirmeAnimAdim);
  T := FIndirmeAnimAdim / TOPLAM_ADIM;
  if T >= 1 then
  begin
    FIndirmeAnimTimer.Enabled := False;
    if Assigned(FIndirmeAnimForm) then
      FIndirmeAnimForm.Hide;
    Exit;
  end;

  // Kübik ease-out (1-(1-t)^3): başta hızlı, sona doğru yavaşlayan hareket
  Yumusatilmis := 1 - Sqr(1 - T) * (1 - T);

  X := FIndirmeAnimBaslangic.X + (FIndirmeAnimBitis.X -
    FIndirmeAnimBaslangic.X) * Yumusatilmis;
  Y := FIndirmeAnimBaslangic.Y + (FIndirmeAnimBitis.Y -
    FIndirmeAnimBaslangic.Y) * Yumusatilmis;

  // Hedefe yaklaştıkça küçülerek "emiliyormuş" hissi ver
  Boyut := 30 - (18 * Yumusatilmis);
  FIndirmeAnimForm.SetBounds(Round(X - Boyut / 2), Round(Y - Boyut / 2),
    Round(Boyut), Round(Boyut));
end;

// "trace://downloads" sayfasını açık tutan sekmeleri yeniden yükler; bu
// sekmenin LoadEnd olayı veritabanındaki güncel listeyi zaten yeniden enjekte
// ediyor (bkz. uBrowserFrame.pas Chromium1LoadEnd).
procedure TMainFrm.IndirmeSekmeleriniYenile;
var
  i: Integer;
begin
  if not Assigned(FSekmeler) then
    Exit;
  for i := 0 to FSekmeler.Count - 1 do
    if Pos('trace://downloads', FSekmeler[i].GuncelURL) > 0 then
      FSekmeler[i].Chromium1.Reload;
end;

end.
