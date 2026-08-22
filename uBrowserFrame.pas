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
    procedure CEFWindowParent1Enter(Sender: TObject);
    procedure Chromium1BeforeBrowse(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; const request: ICefRequest;
      user_gesture, isRedirect: Boolean; out Result: Boolean);
    procedure Chromium1PreKeyEvent(Sender: TObject; const browser: ICefBrowser;
      const event: PCefKeyEvent; osEvent: TCefEventHandle;
      out isKeyboardShortcut, Result: Boolean);
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
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

uses uMain, uData;

procedure TTBrowserFrame.Baslat(const StartURL: string);
begin
  Chromium1.DefaultUrl := StartURL;
  Chromium1.CreateBrowser(CEFWindowParent1, '');
  SayfaYukleniyor := True;

  GuncelY := 50;
  HizY := 0;
  KapanisAsamasinda := False;
end;

procedure TTBrowserFrame.CEFWindowParent1Enter(Sender: TObject);
begin
  MainFrm.lstOneriler.Visible := False;
end;

procedure TTBrowserFrame.Chromium1AddressChange(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const url: ustring);
begin
  if (frame <> nil) and frame.IsMain then
  begin
    if Pos('data:text/html', url) = 1 then
      Exit;

    GuncelURL := url;
    FaviconGuncelle(url);

    MainFrm.FAdresiKodDegistiriyor := True;
    MainFrm.edtURL.Text := url;
    MainFrm.FAdresiKodDegistiriyor := False;
  end;
end;

procedure TTBrowserFrame.Chromium1AfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  CEFWindowParent1.UpdateSize;
end;

procedure TTBrowserFrame.Chromium1BeforeBrowse(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; user_gesture, isRedirect: Boolean;
  out Result: Boolean);
var
  HedefURL, DosyaYolu, HTMLIcerik, DataURI, DB_ID: string;
  StringList: TStringList;
  Kapsul: TTBrowserFrame;
begin
  Result := False;
  HedefURL := request.url;
  Kapsul := Self;

  // 1. HTML İÇİNDEN GELEN ÖZEL KOMUTLARI YAKALA (tracecmd://)
  if Pos('tracecmd://', HedefURL) = 1 then
  begin
    Result := True; // Yönlendirmeyi İptal Et

    // A. TÜMÜNÜ TEMİZLE KOMUTU
    if Pos('tracecmd://clear-all?type=history', HedefURL) > 0 then
    begin
      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('DELETE FROM History'); // Veritabanından uçur

      frame.ExecuteJavaScript
        ('document.querySelectorAll(".history-item").forEach(e => e.remove()); checkEmpty();',
        '', 0);
    end
    else if Pos('tracecmd://clear-all?type=downloads', HedefURL) > 0 then
    begin
      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('DELETE FROM Downloads'); // Veritabanından uçur

      frame.ExecuteJavaScript
        ('document.querySelectorAll(".download-card").forEach(e => e.remove()); document.getElementById("empty-state").classList.add("show");',
        '', 0);
    end

    // B. KLASÖRDE GÖSTER KOMUTU
    else if Pos('tracecmd://show-folder?id=', HedefURL) > 0 then
    begin
      DB_ID := Copy(HedefURL, Length('tracecmd://show-folder?id=') + 1,
        Length(HedefURL));
      // Şimdilik sadece yakalayalım, ShellExecute klasör açma kodunu birazdan bağlayacağız
    end

    // C. TEKİL ÖĞE SİLME KOMUTU (Çarpı Tuşu) - DOĞRU YERE TAŞINDI!
    else if Pos('tracecmd://remove?type=history&id=', HedefURL) > 0 then
    begin
      DB_ID := Copy(HedefURL, Length('tracecmd://remove?type=history&id=') + 1,
        Length(HedefURL));
      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('DELETE FROM History WHERE ID = ' + DB_ID);
    end
    else if Pos('tracecmd://remove?type=downloads&id=', HedefURL) > 0 then
    begin
      DB_ID := Copy(HedefURL, Length('tracecmd://remove?type=downloads&id=') +
        1, Length(HedefURL));
      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('DELETE FROM Downloads WHERE ID = ' + DB_ID);
    end
    else if Pos('tracecmd://task-add?text=', HedefURL) > 0 then
    begin
      var RawTask := Copy(HedefURL, Length('tracecmd://task-add?text=') + 1, Length(HedefURL));
      var TaskMetni := TNetEncoding.URL.Decode(RawTask);

      // SQL için tırnakları düzelt (Escape)
      var SQLTask := StringReplace(TaskMetni, '''', '''''', [rfReplaceAll]);

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        // 1. Veritabanına Ekle
        dmVeri.FDConn.ExecSQL('INSERT INTO Tasks (TaskName, IsCompleted, CreatedAt) VALUES (''' + SQLTask + ''', 0, datetime(''now''))');

        // 2. Eklenen o görevin ID'sini geri al
        var YeniID: Integer := 0;
        with dmVeri.qryGorevler do
        begin
          Close;
          SQL.Text := 'SELECT MAX(ID) AS SonID FROM Tasks';
          Open;
          YeniID := FieldByName('SonID').AsInteger;
        end;

        // 3. JS için tırnakları escape et (\')
        var JSTask := StringReplace(TaskMetni, '''', '\''', [rfReplaceAll]);

        // 4. SAYFAYI YENİLEMEK YERİNE: Arka planda JS fırlatıp kartı DOM'a ekle ve Input kutusunu temizle!
        var JSCode := Format('addTaskCard(%d, ''%s'', false); document.getElementById("newTaskInput").value = "";', [YeniID, JSTask]);
        frame.ExecuteJavaScript(JSCode, '', 0);
      end;
    end

    else if Pos('tracecmd://task-toggle?id=', HedefURL) > 0 then
    begin
      // Gelen format: tracecmd://task-toggle?id=5&state=1
      var
      Params := Copy(HedefURL, Length('tracecmd://task-toggle?id=') + 1,
        Length(HedefURL));
      var
      P_ID := Copy(Params, 1, Pos('&state=', Params) - 1);
      var
      P_State := Copy(Params, Pos('&state=', Params) + 7, Length(Params));

      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('UPDATE Tasks SET IsCompleted = ' + P_State +
          ' WHERE ID = ' + P_ID);
    end

    else if Pos('tracecmd://task-delete?id=', HedefURL) > 0 then
    begin
      DB_ID := Copy(HedefURL, Length('tracecmd://task-delete?id=') + 1,
        Length(HedefURL));

      if Assigned(MainFrm) and Assigned(dmVeri) then
        dmVeri.FDConn.ExecSQL('DELETE FROM Tasks WHERE ID = ' + DB_ID);
    end;

    Exit; // İşlem tamam, çık
  end

  // 2. YEREL HTML SAYFALARIMIZI YAKALA VE DATA URI OLARAK AÇ (trace://)
  else if Pos('trace://', HedefURL) = 1 then
  begin
    Result := True; // Chromium'un internette bu adresi aramasını YASAKLA!

    if Pos('trace://history', HedefURL) > 0 then
      DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\history.html'
    else if Pos('trace://downloads', HedefURL) > 0 then
      DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\downloads.html'
    else if Pos('trace://newtab', HedefURL) > 0 then
      DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\newtab.html';

    if FileExists(DosyaYolu) then
    begin
      StringList := TStringList.Create;
      try
        StringList.LoadFromFile(DosyaYolu, TEncoding.UTF8);
        HTMLIcerik := StringList.Text;

        // Data URI Şifrelemesi
        DataURI := TNetEncoding.Base64.Encode(HTMLIcerik);
        DataURI := StringReplace(DataURI, #13, '', [rfReplaceAll]);
        DataURI := StringReplace(DataURI, #10, '', [rfReplaceAll]);
        DataURI := 'data:text/html;charset=utf-8;base64,' + DataURI;

        TThread.Queue(nil,
          procedure
          begin
            Kapsul.GuncelURL := HedefURL;

            if Assigned(MainFrm) then
            begin
              MainFrm.FAdresiKodDegistiriyor := True;
              MainFrm.edtURL.Text := HedefURL;
              MainFrm.FAdresiKodDegistiriyor := False;
            end;

            if Assigned(Kapsul.Chromium1) then
              Kapsul.Chromium1.LoadURL(DataURI);
          end);
      finally
        StringList.Free;
      end;
    end;
  end;
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

procedure TTBrowserFrame.Chromium1LoadEnd(Sender: TObject;
const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  JSKod, JSBaslik, JSUrl, JSZaman, JSMeta: string;
  // YENİ DEĞİŞKENLER:
  KayitTarihi: TDateTime;
  SonTarihMetni, MevcutTarihMetni: string;
begin
  if (frame <> nil) and frame.IsMain then
  begin

    if Pos('trace://history', GuncelURL) > 0 then
    begin
      JSKod := '';
      SonTarihMetni := ''; // Döngü başında hafızayı sıfırla

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        try
          with dmVeri.qryGecmis do
          begin
            Close;
            SQL.Text :=
              'SELECT ID, LastVisit, Title, URL FROM History ORDER BY LastVisit DESC LIMIT 100';
            Open;

            while not EOF do
            begin

              // 1. ZAMAN VE TARİH METNİNİ HAZIRLA
              if not FieldByName('LastVisit').IsNull then
              begin
                KayitTarihi := FieldByName('LastVisit').AsDateTime;
                JSZaman := FormatDateTime('hh:nn', KayitTarihi);

                // Bugün / Dün / Diğer Günler ayrıştırması
                if Trunc(KayitTarihi) = Trunc(Date) then
                  MevcutTarihMetni := 'Bugün - ' +
                    FormatDateTime('dd mmmm yyyy dddd', KayitTarihi)
                else if Trunc(KayitTarihi) = Trunc(Date) - 1 then
                  MevcutTarihMetni := 'Dün - ' +
                    FormatDateTime('dd mmmm yyyy dddd', KayitTarihi)
                else
                  MevcutTarihMetni := FormatDateTime('dd mmmm yyyy dddd',
                    KayitTarihi);
              end
              else
              begin
                JSZaman := '--:--';
                MevcutTarihMetni := 'Bilinmeyen Tarih';
              end;

              // 2. EĞER TARİH DEĞİŞTİYSE, ARAYA BİR BAŞLIK (HEADER) SIKIŞTIR!
              if MevcutTarihMetni <> SonTarihMetni then
              begin
                SonTarihMetni := MevcutTarihMetni; // Hafızayı güncelle

                // JavaScript'e, kartı eklemeden hemen önce başlığı eklemesini söylüyoruz
                JSKod := JSKod +
                  Format('document.getElementById("empty-state").insertAdjacentHTML("beforebegin", ''<div class="date-header">%s</div>''); ',
                  [MevcutTarihMetni]);
              end;

              // 3. KARTIN KENDİSİNİ EKLE
              JSBaslik := StringReplace(FieldByName('Title').AsString, '''',
                '\''', [rfReplaceAll]);
              JSUrl := StringReplace(FieldByName('URL').AsString, '''', '\''',
                [rfReplaceAll]);

              if JSBaslik = '' then
                JSBaslik := JSUrl;

              JSKod := JSKod +
                Format('addHistoryCard(%d, ''%s'', ''%s'', ''%s''); ',
                [FieldByName('ID').AsInteger, JSZaman, JSBaslik, JSUrl]);

              Next;
            end;
          end;
        except
          on E: Exception do
            OutputDebugString(PChar('History Veritabanı Hatası: ' + E.Message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);
    end
    else if Pos('trace://downloads', GuncelURL) > 0 then
    begin
      JSKod := '';

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        try
          with dmVeri.qryIndirmeler do
          begin
            Close;
            SQL.Text :=
              'SELECT ID, FileName, FilePath, TotalBytes, Status, DownloadDate FROM Downloads ORDER BY ID DESC';
            Open;

            while not EOF do
            begin
              // JS'yi bozmaması için tek tırnakları temizliyoruz
              JSBaslik := StringReplace(FieldByName('FileName').AsString, '''',
                '\''', [rfReplaceAll]);

              // HATA 1 DÜZELTİLDİ: URL yerine FilePath sütununu okuyoruz
              JSUrl := StringReplace(FieldByName('FilePath').AsString, '''',
                '\''', [rfReplaceAll]);

              // HATA 2 DÜZELTİLDİ ve MB'a ÇEVRİLDİ: FileSize yerine TotalBytes okuyoruz
              var
              BoyutMB := FieldByName('TotalBytes').AsLargeInt / (1024 * 1024);
              var
              BoyutMetni := FormatFloat('0.## MB', BoyutMB);

              JSMeta := Format('%s &middot; <span class="status">%s</span>',
                [BoyutMetni, FieldByName('Status').AsString]);

              // Dev JS zincirine kartı ekle
              JSKod := JSKod +
                Format('addDownloadCard(%d, ''%s'', ''%s'', ''%s''); ',
                [FieldByName('ID').AsInteger, JSBaslik, JSUrl, JSMeta]);

              Next;
            end;
          end;
        except
          on E: Exception do
            OutputDebugString(PChar('Downloads Veritabanı Hatası: ' +
              E.Message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);
    end
    else if Pos('trace://newtab', GuncelURL) > 0 then
    begin
      JSKod := '';

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        try
          with dmVeri.qryGorevler do
          // Kendi sorgu bileşeninin ismini kontrol et
          begin
            Close;
            SQL.Text :=
              'SELECT ID, TaskName, IsCompleted FROM Tasks ORDER BY ID ASC';
            Open;

            while not EOF do
            begin
              // JS'yi bozmaması için tek tırnakları temizliyoruz
              JSBaslik := StringReplace(FieldByName('TaskName').AsString, '''',
                '\''', [rfReplaceAll]);

              // Veritabanındaki Boolean (0 veya 1) verisini JS için 'true' / 'false' metnine çeviriyoruz
              var
              IsCompStr := 'false';
              if FieldByName('IsCompleted').AsBoolean then
                IsCompStr := 'true';

              // Dev JS zincirine kartı ekle
              JSKod := JSKod + Format('addTaskCard(%d, ''%s'', %s); ',
                [FieldByName('ID').AsInteger, JSBaslik, IsCompStr]);
              Next;
            end;
          end;
        except
          on E: Exception do
            OutputDebugString(PChar('Görevler Veritabanı Hatası: ' +
              E.Message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);
    end;

  end;
end;

procedure TTBrowserFrame.Chromium1LoadingStateChange(Sender: TObject;
const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
begin
  SayfaYukleniyor := isLoading;
end;

procedure TTBrowserFrame.Chromium1PreKeyEvent(Sender: TObject;
const browser: ICefBrowser; const event: PCefKeyEvent; osEvent: TCefEventHandle;
out isKeyboardShortcut, Result: Boolean);
begin
  Result := False; // Varsayılan olarak tuşlara izin ver

  if (event <> nil) and ((event^.kind = KEYEVENT_RAWKEYDOWN) or
    (event^.kind = KEYEVENT_KEYDOWN)) then
  begin
    // Eğer CTRL tuşuna basılı tutuluyorsa
    if (event^.modifiers and EVENTFLAG_CONTROL_DOWN) <> 0 then
    begin

      // H Tuşuna basıldıysa (Ctrl + H -> Geçmiş)
      if event^.windows_key_code = $48 then // H harfinin Hex kodu
      begin
        Result := True; // Kısayolu YUT! (Chromium'un kendi sayfasını engelle)

        TThread.Queue(nil,
          procedure
          begin
            // Kendi şık geçmiş sayfamızı yeni sekmede aç
            if Assigned(MainFrm) then
              MainFrm.YeniSekmeAc('trace://history');
          end);
      end

      // J Tuşuna basıldıysa (Ctrl + J -> İndirilenler)
      else if event^.windows_key_code = $4A then // J harfinin Hex kodu
      begin
        Result := True; // Kısayolu YUT!

        TThread.Queue(nil,
          procedure
          begin
            // Kendi şık indirilenler sayfamızı yeni sekmede aç
            if Assigned(MainFrm) then
              MainFrm.YeniSekmeAc('trace://downloads');
          end);
      end

      // W Tuşuna basıldıysa (Ctrl + W -> Sekmeyi Kapat)
      else if event^.windows_key_code = $57 then // W harfinin Hex kodu
      begin
        Result := True;
        // Kısayolu YUT! Chromium'un sayfayı patlatmasını engelle!

        TThread.Queue(nil,
          procedure
          begin
            if Assigned(MainFrm) then
            begin
              // Aktif olan sekmeyi kapatma emrini gönderiyoruz!
              MainFrm.SekmeyiKapat(MainFrm.FAktifIndex);
            end;
          end);
      end;

    end;
  end;
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

      // YENİ: Sadece URL "trace://" ile BAŞLAMIYORSA geçmişe kaydet!
      if Assigned(dmVeri) and (Pos('trace://', GuncelURL) <> 1) then
        dmVeri.GecmiseEkle(GuncelURL, SayfaBasligi);

      if Assigned(Application.MainForm) and (Application.MainForm is TMainFrm)
      then
        MainFrm.Caption := 'Trace - ' + SayfaBasligi;
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
