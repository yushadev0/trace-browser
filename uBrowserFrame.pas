unit uBrowserFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.ComCtrls,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uCEFWindowParent, uCEFChromiumCore, uCEFChromium,
  uCEFInterfaces, uCEFTypes, uCEFConstants, uCEFWinControl,
  System.Net.HttpClient, System.Net.URLClient, System.Threading, System.Skia,
  Vcl.Skia, System.NetEncoding, System.JSON, Winapi.ShellAPI, IdIMAP4,
  IdSSLOpenSSL, IdMessage, IdText, IdExplicitTLSClientServerBase,
  System.IOUtils, IdSSLOpenSSLHeaders, Vcl.Clipbrd;

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
    procedure Chromium1ProcessMessageReceived(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      sourceProcess: TCefProcessId; const message: ICefProcessMessage;
      out Result: Boolean);
    procedure Chromium1OpenUrlFromTab(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const targetUrl: ustring; targetDisposition: TCefWindowOpenDisposition;
      userGesture: Boolean; out Result: Boolean);
    procedure Chromium1BeforeContextMenu(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure Chromium1ContextMenuCommand(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: TCefEventFlags; out Result: Boolean);
    procedure Chromium1FullscreenModeChange(Sender: TObject;
      const browser: ICefBrowser; fullscreen: Boolean);
    procedure Chromium1BeforeDownload(Sender: TObject;
      const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const suggestedName: ustring; const callback: ICefBeforeDownloadCallback;
      var aResult: Boolean);
    procedure Chromium1DownloadUpdated(Sender: TObject;
      const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
      const callback: ICefDownloadItemCallback);
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
    FRendererPID: Cardinal;

    procedure Baslat(const StartURL: string);
    procedure FaviconGuncelle(const GelenURL: string);

  end;

implementation

{$R *.dfm}

uses uMain, uData;

// Diske DOĞRUDAN yazan, CEF/JS iletişimine hiç bağımlı olmayan tanı kaydı.
// IMAP bağlantı denemesi konsola/UI'a hiçbir şey yansıtmazsa bile bu dosya
// hangi adıma kadar ilerlendiğini (ya da hiç girilmediğini) kesin olarak
// gösterir: Win32\Debug\imap_debug.log
procedure ImapLog(const Msg: string);
begin
  try
    TFile.AppendAllText(ExtractFilePath(ParamStr(0)) + 'imap_debug.log',
      FormatDateTime('hh:nn:ss.zzz', Now) + '  ' + Msg + sLineBreak,
      TEncoding.UTF8);
  except
    // Log yazımı asla ana akışı bozmasın.
  end;
end;

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

    if MainFrm.AktifKapsul = Self then
      MainFrm.YildizDurumunuGuncelle;
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
  LFrame: ICefFrame;
begin
  Result := False;
  HedefURL := request.url;
  Kapsul := Self;
  LFrame := frame;

  if Pos('test-imap', HedefURL) > 0 then
    ImapLog('*** Chromium1BeforeBrowse cagrildi *** HedefURL=[' + HedefURL +
      '] IsMain=' + BoolToStr(frame.IsMain, True));

  // ÖNEMLİ: IMAP komutları (test-imap / ai-fetch-emails) buraya, prosedürün
  // en başına, KOŞULSUZ ULAŞILABİLİR bir yere taşındı. Eskiden aşağıdaki dev
  // "tracecmd://" if-elseif zincirinin İÇİNDE, en sonda yer alıyorlardı; o
  // zincirde bir yerlerde (muhtemelen çok eski bir düzenlemeden kalma bir
  // begin/end dengesizliği yüzünden) hiçbir zaman çalıştırılamıyorlardı —
  // imap_debug.log ile kanıtlandı: "Test Et" tıklanınca BeforeBrowse doğru
  // URL ile çağrılıyordu ama test-imap dalının İLK satırı bile hiç
  // yazdırılmıyordu. Artık bu iki komut, o belirsiz zincire hiç girmeden,
  // kendi Exit'leriyle işini bitirip çıkıyor.
  if Pos('tracecmd://test-imap', HedefURL) > 0 then
  begin
    Result := True;
    ImapLog('=== test-imap: handler girildi, HedefURL=' + HedefURL);

    // Butona her basıldığında hemen görsel/konsol geri bildirimi ver
    // (arka plan thread'i başlamadan ÖNCE, ana CEF thread'inde senkron çalışır)
    frame.ExecuteJavaScript
      ('console.log(''[Trace IMAP] Test baslatiliyor...''); ' +
      'if (typeof setImapStatus === ''function'') setImapStatus(''testing'', ''Test ediliyor...'');',
      '', 0);
    ImapLog('test-imap: senkron JS geri bildirimi gonderildi, arka plan thread baslatiliyor');

    TThread.CreateAnonymousThread(
      procedure
      var
        IMAP: TIdIMAP4;
        SSL: TIdSSLIOHandlerSocketOpenSSL;
        S_EAddr, S_EPass, S_EImap, Host: string;
        Port: Integer;
        Parts: TArray<string>;
      begin
        ImapLog('test-imap: arka plan thread basladi');
        try
          if not Assigned(dmVeri) then
          begin
            ImapLog('test-imap: dmVeri atanmamis, cikiliyor');
            Exit;
          end;
          S_EAddr := Trim(dmVeri.AyarOku('email_address', ''));
          // Google, uygulama şifresini "xxxx xxxx xxxx xxxx" şeklinde
          // boşluklu gösterir; kullanıcılar genelde boşluklu kopyalar ama
          // gerçek şifrede boşluk yoktur — IMAP kimlik doğrulaması bu
          // yüzden sessizce reddedilmesin diye boşlukları temizliyoruz.
          S_EPass := StringReplace(Trim(dmVeri.AyarOku('email_password', '')),
            ' ', '', [rfReplaceAll]);
          S_EImap := dmVeri.AyarOku('email_imap', 'imap.gmail.com:993');
          ImapLog('test-imap: ayarlar okundu -> adres=' + S_EAddr +
            ' sunucu=' + S_EImap + ' sifre_uzunluk=' + IntToStr(Length
            (S_EPass)));

          if (S_EAddr = '') or (S_EPass = '') then
          begin
            ImapLog('test-imap: adres veya sifre bos, cikiliyor');
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  ('console.error(''[Trace IMAP] E-posta veya Uygulama Sifresi bos.''); ' +
                  'showToast(''❌ Hata: E-posta veya Uygulama Şifresi boş!''); ' +
                  'if (typeof setImapStatus === ''function'') setImapStatus(''error'', ''E-posta veya Uygulama Şifresi boş'');',
                  '', 0);
              end);
            if Assigned(dmVeri) then
            begin
              dmVeri.AyarYaz('email_imap_status', 'error');
              dmVeri.AyarYaz('email_imap_status_msg',
                'E-posta veya Uygulama Şifresi boş');
            end;
            Exit;
          end;

          Parts := S_EImap.Split([Char(':')]);
          Host := Trim(Parts[0]);
          Port := 993;
          if Length(Parts) > 1 then
            Port := StrToIntDef(Trim(Parts[1]), 993);
          ImapLog('test-imap: host=' + Host + ' port=' + IntToStr(Port));

          if Host = '' then
          begin
            ImapLog('test-imap: host bos, cikiliyor');
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  ('console.error(''[Trace IMAP] IMAP sunucu adresi bos.''); ' +
                  'showToast(''❌ Hata: IMAP Sunucu:Port alanı boş!''); ' +
                  'if (typeof setImapStatus === ''function'') setImapStatus(''error'', ''IMAP sunucu adresi boş'');',
                  '', 0);
              end);
            dmVeri.AyarYaz('email_imap_status', 'error');
            dmVeri.AyarYaz('email_imap_status_msg', 'IMAP sunucu adresi boş');
            Exit;
          end;

          ImapLog('test-imap: IMAP/SSL nesneleri olusturuluyor');
          IMAP := TIdIMAP4.Create(nil);
          SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
          ImapLog('test-imap: IMAP/SSL nesneleri olusturuldu');
          try
            SSL.SSLOptions.Method := sslvTLSv1_2;
            SSL.SSLOptions.Mode := sslmClient;
            IMAP.IOHandler := SSL;
            IMAP.Host := Host;
            IMAP.Port := Port;
            IMAP.Username := S_EAddr;
            IMAP.Password := S_EPass;
            IMAP.UseTLS := utUseImplicitTLS;
            IMAP.ConnectTimeout := 12000;
            IMAP.ReadTimeout := 12000;
            ImapLog('test-imap: IMAP ayarlandi, Connect cagriliyor (timeout=12s)');

            try
              IMAP.Connect;
              ImapLog('test-imap: IMAP.Connect DONDU - basarili');
              TThread.Queue(nil,
                procedure
                begin
                  LFrame.ExecuteJavaScript
                    ('console.log(''[Trace IMAP] Baglanti basarili.''); ' +
                    'showToast(''✓ IMAP Bağlantısı Başarılı! Yapay zeka e-postaları okuyabilir.''); ' +
                    'if (typeof setImapStatus === ''function'') setImapStatus(''ok'', ''Bağlantı başarılı'');',
                    '', 0);
                end);
              dmVeri.AyarYaz('email_imap_status', 'ok');
              dmVeri.AyarYaz('email_imap_status_msg', 'Bağlantı başarılı');
              IMAP.Disconnect;
              ImapLog('test-imap: IMAP.Disconnect tamamlandi');
            except
              on E: Exception do
              begin
                var
                RawMsg := Host + ':' + IntToStr(Port) + ' - ' + E.ClassName +
                  ': ' + E.message;
                if E is EIdOSSLCouldNotLoadSSLLibrary then
                  RawMsg := RawMsg + ' | Detay: ' + WhichFailedToLoad;
                ImapLog('test-imap: IMAP.Connect HATA -> ' + RawMsg);
                var
                ErrMsg := StringReplace(RawMsg, '''', '\''', [rfReplaceAll]);
                ErrMsg := StringReplace(ErrMsg, #13#10, ' ', [rfReplaceAll]);
                TThread.Queue(nil,
                  procedure
                  begin
                    LFrame.ExecuteJavaScript
                      (Format('console.error(''[Trace IMAP] Baglanti hatasi: %s''); '
                      + 'showToast(''❌ Bağlantı Hatası: %s''); ' +
                      'if (typeof setImapStatus === ''function'') setImapStatus(''error'', ''%s'');',
                      [ErrMsg, ErrMsg, ErrMsg]), '', 0);
                  end);
                dmVeri.AyarYaz('email_imap_status', 'error');
                dmVeri.AyarYaz('email_imap_status_msg', RawMsg);
              end;
            end;
          finally
            ImapLog('test-imap: IMAP/SSL nesneleri serbest birakiliyor');
            SSL.Free;
            IMAP.Free;
          end;
        except
          on E: Exception do
          begin
            // Bağlantı denemesinden önce/dışında oluşan beklenmedik hatalar
            // (ör. IMAP/SSL nesnesi oluşturma, DB erişimi) artık sessizce yutulmuyor.
            ImapLog('test-imap: DIS TRY HATA -> ' + E.ClassName + ': ' +
              E.message);
            var
            ErrMsg := StringReplace(E.ClassName + ': ' + E.message, '''',
              '\''', [rfReplaceAll]);
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  (Format('console.error(''[Trace IMAP] Beklenmedik hata: %s''); '
                  + 'showToast(''❌ Beklenmedik Hata: %s''); ' +
                  'if (typeof setImapStatus === ''function'') setImapStatus(''error'', ''%s'');',
                  [ErrMsg, ErrMsg, ErrMsg]), '', 0);
              end);
            if Assigned(dmVeri) then
            begin
              dmVeri.AyarYaz('email_imap_status', 'error');
              dmVeri.AyarYaz('email_imap_status_msg', ErrMsg);
            end;
          end;
        end;
        ImapLog('test-imap: arka plan thread bitti');
      end).Start;
    ImapLog('test-imap: TThread.CreateAnonymousThread(...).Start cagrisi dondu');
    Exit;
  end;

  if Pos('tracecmd://ai-fetch-emails', HedefURL) > 0 then
  begin
    Result := True;

    frame.ExecuteJavaScript
      ('console.log(''[Trace AI-Mail] Otomatik e-posta taramasi baslatiliyor...''); '
      + 'if (typeof setEmailStatus === ''function'') setEmailStatus(''checking'', ''Kontrol ediliyor...'');',
      '', 0);

    TThread.CreateAnonymousThread(
      procedure
      var
        IMAP: TIdIMAP4;
        SSL: TIdSSLIOHandlerSocketOpenSSL;
        Msg: TIdMessage;
        UIDList: TStringList;
        SearchInfo: TIdIMAP4SearchRecArray;
        S_EAddr, S_EPass, S_EImap, S_ApiKey, S_Dil, Host, Sender, Subject,
          MailBody: string;
        Port, i, u, Toplam, Islenen, Bulunan: Integer;
        Parts: TArray<string>;
        Http: THTTPClient;
        Stream: TStringStream;
        RespJSON, OzetJSON, ReqJSON: TJSONObject;
        AI_Ozet, AI_Oncelik, JSKod: string;
        MesajID, CacheOncelik, CacheOzet, TarihStr: string;
        CacheVarMi: Boolean;
      begin
        Bulunan := 0;
        try
          if not Assigned(dmVeri) then
            Exit;
          S_EAddr := Trim(dmVeri.AyarOku('email_address', ''));
          // Bkz. test-imap handler'ındaki not: uygulama şifresindeki
          // boşluklar (Google'ın gösterim biçimi) IMAP'e gönderilmeden
          // önce temizlenir.
          S_EPass := StringReplace(Trim(dmVeri.AyarOku('email_password', '')),
            ' ', '', [rfReplaceAll]);
          S_EImap := dmVeri.AyarOku('email_imap', 'imap.gmail.com:993');
          S_ApiKey := dmVeri.AyarOku('api_key', '');
          S_Dil := dmVeri.AyarOku('language', 'tr');
          if (S_EAddr = '') or (S_EPass = '') then
          begin
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  ('console.warn(''[Trace AI-Mail] IMAP bilgileri girilmemis.''); '
                  + 'if (typeof setEmailStatus === ''function'') setEmailStatus(''unconfigured'', ''IMAP hesabı ayarlanmadı'');',
                  '', 0);
              end);
            Exit;
          end;

          if S_ApiKey = '' then
          begin
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  ('console.warn(''[Trace AI-Mail] Gemini API anahtari girilmemis.''); '
                  + 'showToast(''❌ AI özetleme için Ayarlar > Gemini API Anahtarı gerekli.''); '
                  + 'if (typeof setEmailStatus === ''function'') setEmailStatus(''unconfigured'', ''Gemini API anahtarı eksik'');',
                  '', 0);
              end);
            Exit;
          end;

          Parts := S_EImap.Split([Char(':')]);
          Host := Trim(Parts[0]);
          Port := 993;
          if Length(Parts) > 1 then
            Port := StrToIntDef(Trim(Parts[1]), 993);

        IMAP := TIdIMAP4.Create(nil);
        SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
        UIDList := TStringList.Create;
        Msg := TIdMessage.Create(nil);
        Http := THTTPClient.Create;
        try
          SSL.SSLOptions.Method := sslvTLSv1_2;
          SSL.SSLOptions.Mode := sslmClient;
          IMAP.IOHandler := SSL;
          IMAP.Host := Host;
          IMAP.Port := Port;
          IMAP.Username := S_EAddr;
          IMAP.Password := S_EPass;
          IMAP.UseTLS := utUseImplicitTLS;
          IMAP.ConnectTimeout := 15000;

          try
            IMAP.Connect;
            if IMAP.SelectMailBox('INBOX') then
            begin
              SetLength(SearchInfo, 1);
              SearchInfo[0].SearchKey := skUnseen;
              IMAP.UIDSearchMailBox(SearchInfo);

              UIDList.Clear;
              for u := 0 to Length(IMAP.MailBox.SearchResult) - 1 do
                UIDList.Add(IntToStr(IMAP.MailBox.SearchResult[u]));
              ImapLog('ai-fetch-emails: okunmamis e-posta sayisi=' +
                IntToStr(UIDList.Count));

              // Artık sabit bir sınır yok — bulunan tüm okunmamış e-postalar
              // işleniyor; ilerleme her e-posta sonrası UI'a bildiriliyor.
              Toplam := UIDList.Count;
              Islenen := 0;
              TThread.Queue(nil,
                procedure
                begin
                  LFrame.ExecuteJavaScript
                    (Format
                    ('if (typeof setEmailProgress === ''function'') setEmailProgress(0, %d);',
                    [Toplam]), '', 0);
                end);

              for i := UIDList.Count - 1 downto 0 do
              begin
                Msg.Clear;
                if IMAP.UIDRetrieve(UIDList[i], Msg) then
                begin
                  // UIDRetrieve mesajı sunucuda otomatik \Seen yapar; kullanıcı
                  // kendi Gmail uygulamasında da okunmamış görebilsin diye
                  // işimiz bitince tekrar okunmadı olarak işaretliyoruz.
                  IMAP.UIDStoreFlags(UIDList[i], sdRemoveSilent, [mfSeen]);

                  Sender := StringReplace(Msg.From.Address, '\', '\\',
                    [rfReplaceAll]);
                  Sender := StringReplace(Sender, '''', '\''',
                    [rfReplaceAll]);
                  Subject := StringReplace(Msg.Subject, '\', '\\',
                    [rfReplaceAll]);
                  Subject := StringReplace(Subject, '''', '\''',
                    [rfReplaceAll]);
                  MailBody := '';

                  if Msg.MessageParts.Count = 0 then
                    MailBody := Msg.Body.Text
                  else
                    for var j := 0 to Msg.MessageParts.Count - 1 do
                      if (Msg.MessageParts[j] is TIdText) and
                        SameText(TIdText(Msg.MessageParts[j]).ContentType,
                        'text/plain') then
                      begin
                        MailBody := TIdText(Msg.MessageParts[j]).Body.Text;
                        Break;
                      end;

                  // Not: TJSONObject.ToString kendi kaçışlamasını yapacağı
                  // için burada elle tırnak/backslash kaçışlamaya gerek yok
                  // (eski ham string birleştirme yöntemi, mail içeriğinde
                  // beklenmedik karakterler olduğunda JSON'u sessizce
                  // bozup Gemini isteğinin başarısız olmasına yol açıyordu).
                  MailBody := Copy(MailBody, 1, 4000);
                  MailBody := StringReplace(MailBody, #13#10, ' ',
                    [rfReplaceAll]);
                  MailBody := StringReplace(MailBody, #10, ' ',
                    [rfReplaceAll]);

                  MesajID := Msg.MsgId;
                  CacheVarMi := Assigned(dmVeri) and
                    dmVeri.EmailOzetOku(MesajID, CacheOncelik, CacheOzet);

                  if Msg.Date <> 0 then
                    TarihStr := FormatDateTime('dd.mm.yyyy hh:nn', Msg.Date)
                  else
                    TarihStr := '';

                  ImapLog('ai-fetch-emails: isleniyor -> gonderen=' + Sender +
                    ' konu=' + Subject + ' govde_uzunluk=' +
                    IntToStr(Length(MailBody)) + ' onbellekte=' +
                    BoolToStr(CacheVarMi, True));

                  if CacheVarMi then
                  begin
                    // Bu e-posta daha önce özetlenmiş — Gemini'ye tekrar
                    // sormadan (API kotasını korumak için) önbellekten al.
                    AI_Oncelik := CacheOncelik;
                    AI_Ozet := StringReplace(CacheOzet, '\', '\\',
                      [rfReplaceAll]);
                    AI_Ozet := StringReplace(AI_Ozet, '''', '\''',
                      [rfReplaceAll]);
                    AI_Ozet := StringReplace(AI_Ozet, #13#10, ' ',
                      [rfReplaceAll]);
                    AI_Ozet := StringReplace(AI_Ozet, #10, ' ',
                      [rfReplaceAll]);
                    AI_Oncelik := StringReplace(AI_Oncelik, '''', '',
                      [rfReplaceAll]);

                    JSKod := Format
                      ('addEmailCard(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', true);',
                      [Sender, Subject, AI_Ozet, AI_Oncelik, TarihStr]);
                    Inc(Bulunan);
                    TThread.Queue(nil,
                      procedure
                      begin
                        LFrame.ExecuteJavaScript(JSKod, '', 0);
                      end);
                  end
                  else
                  begin
                    var
                    ApiUrl := 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key='
                      + S_ApiKey;

                    var
                    Talimat: string;
                    if S_Dil = 'en' then
                      Talimat :=
                        'You are Trace browser''s email triage assistant. Analyze the email the user '
                        + 'provides and respond ONLY with a single raw JSON object (no markdown, no '
                        + 'code fences) in exactly this shape: {"priority":"High|Medium|Low",' +
                        '"summary":"..."}. The "summary" must be at most 2 sentences describing what '
                        + 'action, if any, is needed.'
                    else
                      Talimat :=
                        'Sen Trace tarayıcısının e-posta önceliklendirme asistanısın. Kullanıcının ' +
                        'verdiği e-postayı analiz et ve SADECE şu şekilde ham bir JSON nesnesiyle ' +
                        'cevap ver (markdown yok, kod bloğu yok): {"priority":"Yüksek|Orta|Düşük",' +
                        '"summary":"..."}. "summary" alanı en fazla 2 cümle olmalı ve gerekiyorsa ne ' +
                        'yapılması gerektiğini açıklamalı.';

                    // "Raporlama" (tracecmd://ai-ask) ile AYNI istek yapısı:
                    // systemInstruction + contents[role=user], TJSONObject
                    // üzerinden kurulur (Format/string birleştirme değil).
                    ReqJSON := TJSONObject.Create;
                    try
                      var
                      SysInstrJSON := TJSONObject.Create;
                      var
                      SysPartsArr := TJSONArray.Create;
                      var
                      SysPart := TJSONObject.Create;
                      SysPart.AddPair('text', Talimat);
                      SysPartsArr.AddElement(SysPart);
                      SysInstrJSON.AddPair('parts', SysPartsArr);
                      ReqJSON.AddPair('systemInstruction', SysInstrJSON);

                      var
                      ContentsArr := TJSONArray.Create;
                      var
                      ContentObj := TJSONObject.Create;
                      var
                      ContentPartsArr := TJSONArray.Create;
                      var
                      ContentPart := TJSONObject.Create;
                      ContentPart.AddPair('text', MailBody);
                      ContentPartsArr.AddElement(ContentPart);
                      ContentObj.AddPair('parts', ContentPartsArr);
                      ContentObj.AddPair('role', 'user');
                      ContentsArr.AddElement(ContentObj);
                      ReqJSON.AddPair('contents', ContentsArr);

                      var
                      GenConfig := TJSONObject.Create;
                      GenConfig.AddPair('response_mime_type',
                        'application/json');
                      ReqJSON.AddPair('generationConfig', GenConfig);

                      Stream := TStringStream.Create(ReqJSON.ToString,
                        TEncoding.UTF8);
                      try
                        Http.ContentType := 'application/json';
                        var
                        Resp := Http.Post(ApiUrl, Stream);
                        ImapLog('ai-fetch-emails: Gemini yaniti -> HTTP ' +
                          IntToStr(Resp.StatusCode));
                        if Resp.StatusCode = 200 then
                        begin
                          RespJSON := TJSONObject.ParseJSONValue
                            (Resp.ContentAsString(TEncoding.UTF8))
                            as TJSONObject;
                          if Assigned(RespJSON) then
                            try
                              AI_Ozet := RespJSON.GetValue<TJSONArray>
                                ('candidates').Items[0]
                                .GetValue<TJSONObject>('content')
                                .GetValue<TJSONArray>('parts')
                                .Items[0].GetValue<string>('text');

                              if S_Dil = 'en' then
                                AI_Oncelik := 'Medium'
                              else
                                AI_Oncelik := 'Orta';

                              OzetJSON := TJSONObject.ParseJSONValue(AI_Ozet)
                                as TJSONObject;
                              if Assigned(OzetJSON) then
                                try
                                  AI_Oncelik := OzetJSON.GetValue<string>
                                    ('priority', AI_Oncelik);
                                  AI_Ozet := OzetJSON.GetValue<string>
                                    ('summary', AI_Ozet);
                                finally
                                  OzetJSON.Free;
                                end;

                              ImapLog('ai-fetch-emails: ozet basarili -> ' +
                                'oncelik=' + AI_Oncelik + ' ozet_uzunluk=' +
                                IntToStr(Length(AI_Ozet)));

                              // Önbelleğe HAM (JS-kaçışlama öncesi) metni
                              // yazıyoruz ki ileride tekrar okunduğunda
                              // kaçışlama iki kez uygulanmasın.
                              if Assigned(dmVeri) then
                                dmVeri.EmailOzetYaz(MesajID, Sender, Subject,
                                  AI_Oncelik, AI_Ozet);

                              AI_Ozet := StringReplace(AI_Ozet, '\', '\\',
                                [rfReplaceAll]);
                              AI_Ozet := StringReplace(AI_Ozet, '''', '\''',
                                [rfReplaceAll]);
                              AI_Ozet := StringReplace(AI_Ozet, #13#10, ' ',
                                [rfReplaceAll]);
                              AI_Ozet := StringReplace(AI_Ozet, #10, ' ',
                                [rfReplaceAll]);
                              AI_Oncelik := StringReplace(AI_Oncelik, '''', '',
                                [rfReplaceAll]);

                              JSKod := Format
                                ('addEmailCard(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', false);',
                                [Sender, Subject, AI_Ozet, AI_Oncelik,
                                TarihStr]);
                              Inc(Bulunan);
                              TThread.Queue(nil,
                                procedure
                                begin
                                  LFrame.ExecuteJavaScript(JSKod, '', 0);
                                end);
                            finally
                              RespJSON.Free;
                            end
                          else
                            ImapLog
                              ('ai-fetch-emails: Gemini yaniti JSON olarak parse edilemedi');
                        end
                        else
                        begin
                          var
                          HttpErrMsg := StringReplace('HTTP ' + IntToStr
                            (Resp.StatusCode) + ' - ' +
                            Copy(Resp.ContentAsString(TEncoding.UTF8), 1, 300),
                            '''', '\''', [rfReplaceAll]);
                          HttpErrMsg := StringReplace(HttpErrMsg, #13#10, ' ',
                            [rfReplaceAll]);
                          ImapLog('ai-fetch-emails: Gemini HATA -> ' +
                            HttpErrMsg);
                          TThread.Queue(nil,
                            procedure
                            begin
                              LFrame.ExecuteJavaScript
                                (Format
                                ('console.error(''[Trace AI-Mail] Gemini istegi basarisiz: %s'');',
                                [HttpErrMsg]), '', 0);
                            end);
                        end;
                      finally
                        Stream.Free;
                      end;
                    finally
                      ReqJSON.Free;
                    end;
                  end;
                end;
                Inc(Islenen);
                var
                IslenenSuAn := Islenen;
                TThread.Queue(nil,
                  procedure
                  begin
                    LFrame.ExecuteJavaScript
                      (Format
                      ('if (typeof setEmailProgress === ''function'') setEmailProgress(%d, %d);',
                      [IslenenSuAn, Toplam]), '', 0);
                  end);
              end;
            end;
            IMAP.Disconnect;

            var
            SonucMsg: string;
            if Bulunan > 0 then
              SonucMsg := IntToStr(Bulunan) + ' e-posta özetlendi'
            else
              SonucMsg := 'Yeni/okunmamış e-posta yok';
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  (Format('console.log(''[Trace AI-Mail] %s''); ' +
                  'if (typeof setEmailStatus === ''function'') setEmailStatus(''ok'', ''%s'');',
                  [SonucMsg, SonucMsg]), '', 0);
              end);
            dmVeri.AyarYaz('email_imap_status', 'ok');
            dmVeri.AyarYaz('email_imap_status_msg', SonucMsg);
          except
            on E: Exception do
            begin
              var
              RawMsg := Host + ':' + IntToStr(Port) + ' - ' + E.ClassName +
                ': ' + E.message;
              var
              ErrMsg := StringReplace(RawMsg, '''', '\''', [rfReplaceAll]);
              ErrMsg := StringReplace(ErrMsg, #13#10, ' ', [rfReplaceAll]);
              TThread.Queue(nil,
                procedure
                begin
                  LFrame.ExecuteJavaScript
                    (Format('console.error(''[Trace AI-Mail] Hata: %s''); ' +
                    'if (typeof setEmailStatus === ''function'') setEmailStatus(''error'', ''%s'');',
                    [ErrMsg, ErrMsg]), '', 0);
                end);
              if Assigned(dmVeri) then
              begin
                dmVeri.AyarYaz('email_imap_status', 'error');
                dmVeri.AyarYaz('email_imap_status_msg', RawMsg);
              end;
            end;
          end;
        finally
          Http.Free;
          Msg.Free;
          UIDList.Free;
          SSL.Free;
          IMAP.Free;
        end;
        except
          on E: Exception do
          begin
            // IMAP/SSL nesnesi oluşturma, DB erişimi vb. beklenmedik hatalar
            // artık sessizce yutulmuyor.
            var
            ErrMsg := StringReplace(E.ClassName + ': ' + E.message, '''',
              '\''', [rfReplaceAll]);
            TThread.Queue(nil,
              procedure
              begin
                LFrame.ExecuteJavaScript
                  (Format('console.error(''[Trace AI-Mail] Beklenmedik hata: %s''); '
                  + 'if (typeof setEmailStatus === ''function'') setEmailStatus(''error'', ''%s'');',
                  [ErrMsg, ErrMsg]), '', 0);
              end);
            if Assigned(dmVeri) then
            begin
              dmVeri.AyarYaz('email_imap_status', 'error');
              dmVeri.AyarYaz('email_imap_status_msg', ErrMsg);
            end;
          end;
        end;
      end).Start;
    Exit;
  end;

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
      TThread.Queue(nil,
        procedure
        var
          DosyaYolu: string;
        begin
          if not Assigned(dmVeri) then
            Exit;
          DosyaYolu := dmVeri.IndirmeYoluGetir(StrToIntDef(DB_ID, -1));
          if DosyaYolu = '' then
            Exit;
          if FileExists(DosyaYolu) then
            // /select ile dosyayı Gezgin'de seçili şekilde göster
            ShellExecute(0, 'open', 'explorer.exe',
              PChar('/select,"' + DosyaYolu + '"'), nil, SW_SHOWNORMAL)
          else if DirectoryExists(ExtractFilePath(DosyaYolu)) then
            // Dosya silinmiş/taşınmışsa en azından klasörü aç
            ShellExecute(0, 'open', 'explorer.exe',
              PChar('"' + ExtractFilePath(DosyaYolu) + '"'), nil,
              SW_SHOWNORMAL);
        end);
    end

    // B2. PANOYA KOPYALA KOMUTU
    // NOT: navigator.clipboard.writeText sessizce başarısız oluyordu (CEF'in
    // file:// bağlamında Clipboard API'si için izin/secure-context sorunu
    // olabilir) — kullanıcı hiçbir hata görmeden panoya hiçbir şey
    // kopyalanmıyordu. Bunun yerine native VCL panosunu kullanıyoruz; bu
    // tarayıcı izinlerinden tamamen bağımsız, her zaman çalışır.
    else if Pos('tracecmd://copy-to-clipboard?text=', HedefURL) > 0 then
    begin
      var
      KopyalanacakMetin := TNetEncoding.URL.Decode
        (Copy(HedefURL, Length('tracecmd://copy-to-clipboard?text=') + 1,
        MaxInt));
      TThread.Queue(nil,
        procedure
        begin
          Clipboard.AsText := KopyalanacakMetin;
        end);
    end

    // B3. TAMAMLANMIŞ İNDİRMELERİN DOSYASI HÂLÂ DİSKTE Mİ KONTROLÜ
    // (downloads.html periyodik olarak bunu çağırıp "Silindi" görünümünü
    // gerçek zamanlı güncelliyor)
    else if Pos('tracecmd://check-deleted?ids=', HedefURL) > 0 then
    begin
      var
      IdListesi := Copy(HedefURL, Length('tracecmd://check-deleted?ids=') + 1,
        MaxInt);
      TThread.Queue(nil,
        procedure
        var
          Parcalar: TArray<string>;
          Parca, Yol, JS: string;
          IdDegeri: Integer;
        begin
          if not Assigned(dmVeri) then
            Exit;
          JS := '';
          Parcalar := IdListesi.Split([',']);
          for Parca in Parcalar do
          begin
            IdDegeri := StrToIntDef(Parca, -1);
            if IdDegeri < 0 then
              Continue;
            Yol := dmVeri.IndirmeYoluGetir(IdDegeri);
            if (Yol <> '') and not FileExists(Yol) then
              JS := JS + Format('markDeleted(%d); ', [IdDegeri]);
          end;
          if JS <> '' then
            frame.ExecuteJavaScript(JS, '', 0);
        end);
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
      var
      RawTask := Copy(HedefURL, Length('tracecmd://task-add?text=') + 1,
        Length(HedefURL));
      var
      TaskMetni := TNetEncoding.url.Decode(RawTask);

      // SQL için tırnakları düzelt (Escape)
      var
      SQLTask := StringReplace(TaskMetni, '''', '''''', [rfReplaceAll]);

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        // 1. Veritabanına Ekle
        dmVeri.FDConn.ExecSQL
          ('INSERT INTO Tasks (TaskName, IsCompleted, CreatedAt) VALUES (''' +
          SQLTask + ''', 0, datetime(''now''))');

        // 2. Eklenen o görevin ID'sini geri al
        var
          YeniID: Integer := 0;
        with dmVeri.qryGorevler do
        begin
          Close;
          SQL.Text := 'SELECT MAX(ID) AS SonID FROM Tasks';
          Open;
          YeniID := FieldByName('SonID').AsInteger;
          Close; // Açık bırakılırsa sonraki bir yazma "database is locked" verebilir
        end;

        // 3. JS için tırnakları escape et (\')
        var
        JSTask := StringReplace(TaskMetni, '''', '\''', [rfReplaceAll]);

        // 4. SAYFAYI YENİLEMEK YERİNE: Arka planda JS fırlatıp kartı DOM'a ekle ve Input kutusunu temizle!
        var
        JSCode := Format
          ('addTaskCard(%d, ''%s'', false); document.getElementById("newTaskInput").value = "";',
          [YeniID, JSTask]);
        frame.ExecuteJavaScript(JSCode, '', 0);
      end;
    end

    else if Pos('tracecmd://task-toggle?id=', HedefURL) > 0 then
    begin
      // Gelen format: tracecmd://task-toggle?id=5&state=1
      var
      params := Copy(HedefURL, Length('tracecmd://task-toggle?id=') + 1,
        Length(HedefURL));
      var
      P_ID := Copy(params, 1, Pos('&state=', params) - 1);
      var
      P_State := Copy(params, Pos('&state=', params) + 7, Length(params));

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
    end
    else if Pos('tracecmd://taskmgr-kill?pid=', HedefURL) > 0 then
    begin
      var
      PIDStr := Copy(HedefURL, Length('tracecmd://taskmgr-kill?pid=') + 1,
        Length(HedefURL));
      var
      HedefPID := StrToIntDef(PIDStr, 0);

      if HedefPID > 0 then
      begin
        // 1. EĞER KULLANICI ANA BROWSER'I (TRACE.EXE) SONLANDIRMAK İSTİYORSA
        if HedefPID = GetCurrentProcessId then
        begin
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(MainFrm) then
                MainFrm.Close;
              // CEF4Delphi'nin güvenli kapatma protokolünü tetikle!
            end);
        end
        else
        begin
          // YENİ: Vurmadan önce, bu PID'ye sahip bir sekme var mı diye bak ve UI'dan kapat!
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(MainFrm) then
              begin
                for var i := MainFrm.FSekmeler.Count - 1 downto 0 do
                begin
                  // IPC'den gelen kesin PID'ye bakıyoruz!
                  if MainFrm.FSekmeler[i].FRendererPID = HedefPID then
                  begin
                    MainFrm.SekmeyiKapat(i);
                    // Sekme tuvalden animasyonla aşağı düşsün
                    Break;
                  end;
                end;
              end;
            end);

          // 2. ALT İŞLEMLER (SEKMELER/GPU) İÇİN ACIMASIZ KILL SERBEST
          var
            hProc: THandle := OpenProcess(PROCESS_TERMINATE, False, HedefPID);
          if hProc <> 0 then
          begin
            TerminateProcess(hProc, 0);
            CloseHandle(hProc);
          end;
        end;
      end;
    end // F. YAPAY ZEKA (AI) İLE SOHBET
    else if Pos('tracecmd://report-open?id=', HedefURL) > 0 then
    begin
      var
      RaporIDStr := Copy(HedefURL, Length('tracecmd://report-open?id=') + 1,
        Length(HedefURL));
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://report?id=' + RaporIDStr);
        end);
    end
    else if Pos('tracecmd://report-delete?id=', HedefURL) > 0 then
    begin
      var
      RaporSilID := StrToIntDef
        (Copy(HedefURL, Length('tracecmd://report-delete?id=') + 1,
        Length(HedefURL)), 0);
      if (RaporSilID > 0) and Assigned(dmVeri) then
      begin
        var
        MDDosyaYolu := dmVeri.RaporDosyaYolu(RaporSilID);
        if FileExists(MDDosyaYolu) then
          DeleteFile(MDDosyaYolu);
        dmVeri.RaporSil(RaporSilID);
      end;
    end
    else if Pos('tracecmd://open-reports-folder', HedefURL) > 0 then
    begin
      var
      FolderPath := ExtractFilePath(ParamStr(0)) + 'reports\';
      TThread.Queue(nil,
        procedure
        begin
          ForceDirectories(FolderPath);
          var
            SI: TStartupInfo;
          var
            PI: TProcessInformation;
          ZeroMemory(@SI, SizeOf(SI));
          SI.cb := SizeOf(SI);
          var
          Cmd := 'explorer.exe "' + FolderPath + '"';
          if CreateProcess(nil, PChar(Cmd), nil, nil, False, 0, nil, nil, SI, PI)
          then
          begin
            CloseHandle(PI.hThread);
            CloseHandle(PI.hProcess);
          end;
        end);
    end
    else if Pos('tracecmd://open-reports', HedefURL) > 0 then
    begin
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://reports');
        end);
    end

    else if Pos('tracecmd://settings-set?', HedefURL) > 0 then
    begin
      var
      ParamBlok := Copy(HedefURL, Pos('tracecmd://settings-set?', HedefURL) +
        Length('tracecmd://settings-set?'), MaxInt);
      var
      kv_k := Pos('k=', ParamBlok);
      var
      kv_v := Pos('&v=', ParamBlok);
      if (kv_k > 0) and (kv_v > 0) then
      begin
        var
        SettingKey := Copy(ParamBlok, kv_k + 2, kv_v - kv_k - 2);
        var
        SettingValue := TNetEncoding.url.Decode
          (Copy(ParamBlok, kv_v + 3, MaxInt));
        if Assigned(dmVeri) then
          dmVeri.AyarYaz(SettingKey, SettingValue);
        if SettingKey = 'theme' then
        begin
          var
          ThemeVal := SettingValue;
          TThread.Queue(nil,
            procedure
            var
              j: Integer;
              ThemeJS: string;
            begin
              if not Assigned(MainFrm) or not Assigned(dmVeri) then
                Exit;
              ThemeJS := Format('applyTheme(''%s'');',
                [dmVeri.AyarOku('theme', 'dark')]);
              for j := 0 to MainFrm.FSekmeler.Count - 1 do
                if Assigned(MainFrm.FSekmeler[j]) and
                  ((Pos('trace://reports', MainFrm.FSekmeler[j].GuncelURL) > 0)
                  or (Pos('trace://taskmgr', MainFrm.FSekmeler[j].GuncelURL) >
                  0) or (Pos('trace://history', MainFrm.FSekmeler[j].GuncelURL)
                  > 0) or (Pos('trace://downloads',
                  MainFrm.FSekmeler[j].GuncelURL) > 0)) then
                  MainFrm.FSekmeler[j].Chromium1.ExecuteJavaScript(ThemeJS, '');
            end);
        end;

        // Halihazırda açık olan trace://newtab sekmelerine değişikliği anında yansıt
        if (SettingKey = 'greeting_name') or
          (SettingKey = 'greeting_salutation') or (SettingKey = 'theme') or
          (SettingKey = 'language') then
        begin
          TThread.Queue(nil,
            procedure
            var
              j: Integer;
              NT_Name, NT_Sal, NT_Theme, NT_Lang, JS: string;
            begin
              if not Assigned(MainFrm) or not Assigned(dmVeri) then
                Exit;
              NT_Name := StringReplace(dmVeri.AyarOku('greeting_name',
                'Yu' + #351 + 'a'), '''', '\''', [rfReplaceAll]);
              NT_Sal := StringReplace(dmVeri.AyarOku('greeting_salutation',
                'Merhaba'), '''', '\''', [rfReplaceAll]);
              NT_Theme := dmVeri.AyarOku('theme', 'dark');
              NT_Lang := dmVeri.AyarOku('language', 'tr');
              JS := Format
                ('applyUserSettings({name:''%s'',sal:''%s'',theme:''%s'',lang:''%s''});',
                [NT_Name, NT_Sal, NT_Theme, NT_Lang]);
              for j := 0 to MainFrm.FSekmeler.Count - 1 do
                if Assigned(MainFrm.FSekmeler[j]) and
                  (Pos('trace://newtab', MainFrm.FSekmeler[j].GuncelURL) > 0)
                then
                  MainFrm.FSekmeler[j].Chromium1.ExecuteJavaScript(JS, '');
            end);
        end;

        // Tema değiştiyse, açık olan Raporlarım / Görev Yöneticisi sekmelerine de anında yansıt
        if SettingKey = 'theme' then
        begin
          TThread.Queue(nil,
            procedure
            var
              j: Integer;
              ThemeJS: string;
            begin
              if not Assigned(MainFrm) or not Assigned(dmVeri) then
                Exit;
              ThemeJS := Format('applyTheme(''%s'');',
                [dmVeri.AyarOku('theme', 'dark')]);
              for j := 0 to MainFrm.FSekmeler.Count - 1 do
                if Assigned(MainFrm.FSekmeler[j]) and
                  ((Pos('trace://reports', MainFrm.FSekmeler[j].GuncelURL) > 0)
                  or (Pos('trace://taskmgr', MainFrm.FSekmeler[j].GuncelURL)
                  > 0)) then
                  MainFrm.FSekmeler[j].Chromium1.ExecuteJavaScript(ThemeJS, '');
            end);
        end;
      end;
    end

    else if Pos('tracecmd://settings-clear?type=', HedefURL) > 0 then
    begin
      var
      DataType := Copy(HedefURL, Length('tracecmd://settings-clear?type=') +
        1, MaxInt);
      var
      ClearOK := True;
      try
        if Assigned(dmVeri) then
          dmVeri.VeriSil(DataType);
      except
        ClearOK := False;
      end;
      var
      DT2 := DataType;
      var
      OK2 := ClearOK;
      frame.ExecuteJavaScript(Format('onDataCleared(''%s'',%s);',
        [DT2, BoolToStr(OK2, True).ToLower]), '', 0);
    end

    else if Pos('tracecmd://set-default-browser', HedefURL) > 0 then
    begin
      TThread.Queue(nil,
        procedure
        begin
          ShellExecute(0, 'open', 'ms-settings:defaultapps', nil, nil,
            SW_SHOWNORMAL);
        end);
    end

    else if Pos('tracecmd://open-downloads-folder', HedefURL) > 0 then
    begin
      TThread.Queue(nil,
        procedure
        begin
          var
          FolderPath := '';
          if Assigned(dmVeri) then
            FolderPath := dmVeri.AyarOku('downloads_path', '');
          if FolderPath = '' then
            FolderPath := ExtractFilePath(ParamStr(0)) + 'downloads\';
          ForceDirectories(FolderPath);
          var
            SI: TStartupInfo;
          var
            PI: TProcessInformation;
          ZeroMemory(@SI, SizeOf(SI));
          SI.cb := SizeOf(SI);
          var
            Cmd: string := 'explorer.exe "' + FolderPath + '"';
          if CreateProcess(nil, PChar(Cmd), nil, nil, False, 0, nil, nil, SI, PI)
          then
          begin
            CloseHandle(PI.hThread);
            CloseHandle(PI.hProcess);
          end;
        end);
    end

    else if Pos('tracecmd://open-url?url=', HedefURL) > 0 then
    begin
      var
      OpenTargetURL := TNetEncoding.url.Decode
        (Copy(HedefURL, Length('tracecmd://open-url?url=') + 1, MaxInt));
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc(OpenTargetURL);
        end);
    end

    else if Pos('tracecmd://ai-ask?q=', HedefURL) > 0 then
    begin
      var
      RawQuery := Copy(HedefURL, Length('tracecmd://ai-ask?q=') + 1,
        Length(HedefURL));
      var
      HistoryJSON := '';
      var
      SepPos := Pos('&h=', RawQuery);
      if SepPos > 0 then
      begin
        HistoryJSON := TNetEncoding.url.Decode(Copy(RawQuery, SepPos + 3,
          Length(RawQuery)));
        RawQuery := Copy(RawQuery, 1, SepPos - 1);
      end;
      var
      Soru := TNetEncoding.url.Decode(RawQuery);

      // Read user API key and language before spawning background thread
      var
      KullaniciApiKey := '';
      var
      KullaniciDil := 'tr';
      if Assigned(dmVeri) then
      begin
        KullaniciApiKey := dmVeri.AyarOku('api_key', '');
        KullaniciDil := dmVeri.AyarOku('language', 'tr');
      end;

      var
      API_URL_FINAL :=
        'https://generativelanguage.googleapis.com/v1beta/models/' +
        'gemini-3.5-flash-lite:generateContent?key=' + KullaniciApiKey;

      TThread.CreateAnonymousThread(
        procedure
        var
          API_URL: string;
          Http: THTTPClient;
          Stream: TStringStream;
          RequestJSON, SystemInstrJSON, ContentJSON, PartJSON: TJSONObject;
          PartsArray, ContentsArray, SysPartsArray, ToolsArray: TJSONArray;
          Response: IHTTPResponse;
          Cevap, JSKod, RawCevap, SoruLower, SistemTalimat: string;
          JSONResp: TJSONObject;
          IsReport, IsInternetSearch, IsEditReport: Boolean;
          DuzenleRaporID: Integer;
          RaporDizini, DosyaAdi, DosyaYolu, RaporBaslik, ATur: string;
          MevcutRaporMetni: string;
          SL: TStringList;
          SoruJS, RawCevapJS: string;
        begin
          API_URL := API_URL_FINAL;

          SoruLower := LowerCase(Soru);

          IsEditReport := (Pos('raporu d' + #252 + 'zenle', SoruLower) > 0) or
            (Pos('raporu duzenle', SoruLower) > 0) or
            (Pos('rapora ekle', SoruLower) > 0) or
            (Pos('rapora ekleme', SoruLower) > 0) or
            (Pos('raporu g' + #252 + 'ncelle', SoruLower) > 0) or
            (Pos('raporu guncelle', SoruLower) > 0) or
            (Pos('raporu revize', SoruLower) > 0) or
            (Pos('raporu d' + #252 + 'zelt', SoruLower) > 0);

          IsInternetSearch := (Pos('internette', SoruLower) > 0) and
            (Pos('raporla', SoruLower) > 0);
          IsReport := (not IsEditReport) and
            (IsInternetSearch or (Pos('rapor olu', SoruLower) > 0) or
            (Pos('rapor yap', SoruLower) > 0) or (Pos('rapora d', SoruLower) >
            0) or (Pos('rapor kaydet', SoruLower) > 0) or
            (Pos('raporla ve kaydet', SoruLower) > 0));

          // Düzenleme modunda: rapor ID'sini bul ve mevcut içeriği oku
          DuzenleRaporID := 0;
          MevcutRaporMetni := '';
          DosyaYolu := '';
          if IsEditReport then
          begin
            var
            IdPos := Pos('id', SoruLower);
            if IdPos > 0 then
            begin
              var
              DigitStart := 0;
              for var k := IdPos to Length(SoruLower) do
              begin
                if CharInSet(SoruLower[k], ['0' .. '9']) then
                begin
                  DigitStart := k;
                  Break;
                end;
              end;
              if DigitStart > 0 then
              begin
                var
                NumStr := '';
                for var k := DigitStart to Length(SoruLower) do
                begin
                  if CharInSet(SoruLower[k], ['0' .. '9']) then
                    NumStr := NumStr + SoruLower[k]
                  else
                    Break;
                end;
                DuzenleRaporID := StrToIntDef(NumStr, 0);
              end;
            end;
            if (DuzenleRaporID > 0) and Assigned(dmVeri) then
            begin
              DosyaYolu := dmVeri.RaporDosyaYolu(DuzenleRaporID);
              if (DosyaYolu <> '') and FileExists(DosyaYolu) then
              begin
                SL := TStringList.Create;
                try
                  SL.LoadFromFile(DosyaYolu, TEncoding.UTF8);
                  MevcutRaporMetni := SL.Text;
                finally
                  SL.Free;
                end;
              end;
            end;
          end;

          if IsInternetSearch then
          begin
            if KullaniciDil = 'en' then
              SistemTalimat :=
                'You are Trace browser''s autonomous research assistant. ' +
                'Search the web and prepare an up-to-date, comprehensive report on the topic. '
                + 'Cite sources in Markdown link format. Use clear, fluent English. '
                + 'Always write your answer in Markdown format.'
            else
              SistemTalimat :=
                'Sen Trace tarayıcısının otonom araştırma asistanısın. ' +
                'Web araması yaparak konuyla ilgili güncel ve kapsamlı bir rapor hazırla. '
                + 'Kaynakları Markdown link formatında belirt. Net ve akıcı Türkçe kullan. '
                + 'Yanıtını her zaman Markdown formatında yaz.';
          end
          else if IsEditReport then
          begin
            if KullaniciDil = 'en' then
              SistemTalimat :=
                'You are Trace browser''s research assistant. Edit the report '
                + 'the user provides. Make the requested changes and additions, and return the '
                + 'updated report, including the title, in complete Markdown format.'
            else
              SistemTalimat :=
                'Sen Trace tarayıcısının araştırma asistanısın. Kullanıcının ' +
                'verdiği mevcut raporu düzenleyeceksin. İstenen değişiklikleri ve eklemeleri yap, '
                + 'raporun güncel halini başlık dahil tam ve eksiksiz Markdown formatında ver.';
          end
          else
          begin
            if KullaniciDil = 'en' then
              SistemTalimat :=
                'You are Trace browser''s autonomous research assistant. Track the '
                + 'conversation history and answer according to context. The user may ask you to turn '
                + 'the previous answer into a report; in that case create a comprehensive Markdown report. '
                + 'Answer directly, clearly, and fluently in English. Always use Markdown format.'
            else
              SistemTalimat :=
                'Sen Trace tarayıcısının otonom araştırma asistanısın. Konuşma '
                + 'geçmişini takip et ve bağlama göre cevap ver. Kullanıcı önceki cevabı rapora '
                + 'dönüştürmeni isteyebilir; o zaman kapsamlı Markdown rapor oluştur. '
                + 'Doğrudan, net ve akıcı Türkçe ile cevap ver. Format olarak daima Markdown kullan.';
          end;

          Http := THTTPClient.Create;
          RequestJSON := TJSONObject.Create;
          try
            SystemInstrJSON := TJSONObject.Create;
            SysPartsArray := TJSONArray.Create;
            var
            SysPart := TJSONObject.Create;
            SysPart.AddPair('text', SistemTalimat);
            SysPartsArray.AddElement(SysPart);
            SystemInstrJSON.AddPair('parts', SysPartsArray);
            RequestJSON.AddPair('systemInstruction', SystemInstrJSON);

            ContentsArray := TJSONArray.Create;

            if HistoryJSON <> '' then
            begin
              var
              HistValue := TJSONObject.ParseJSONValue(HistoryJSON);
              if Assigned(HistValue) and (HistValue is TJSONArray) then
                try
                  var
                  HistArr := HistValue as TJSONArray;
                  for var i := 0 to HistArr.Count - 1 do
                  begin
                    var
                    HistItem := HistArr.Items[i] as TJSONObject;
                    var
                    HRole := HistItem.GetValue<string>('r');
                    var
                    HText := HistItem.GetValue<string>('t');
                    var
                    HContent := TJSONObject.Create;
                    var
                    HParts := TJSONArray.Create;
                    var
                    HPart := TJSONObject.Create;
                    HPart.AddPair('text', HText);
                    HParts.AddElement(HPart);
                    HContent.AddPair('parts', HParts);
                    HContent.AddPair('role', HRole);
                    ContentsArray.AddElement(HContent);
                  end;
                finally
                  HistValue.Free;
                end;
            end;

            // Düzenleme modunda mevcut raporu context olarak enjekte et
            if IsEditReport and (MevcutRaporMetni <> '') then
            begin
              var
              RapCtxU := TJSONObject.Create;
              var
              RapCtxUP := TJSONArray.Create;
              var
              RapCtxUPt := TJSONObject.Create;
              RapCtxUPt.AddPair('text',
                'İşte düzenlemeni istediğim mevcut rapor:' + #10#10 +
                MevcutRaporMetni);
              RapCtxUP.AddElement(RapCtxUPt);
              RapCtxU.AddPair('parts', RapCtxUP);
              RapCtxU.AddPair('role', 'user');
              ContentsArray.AddElement(RapCtxU);

              var
              RapCtxM := TJSONObject.Create;
              var
              RapCtxMP := TJSONArray.Create;
              var
              RapCtxMPt := TJSONObject.Create;
              RapCtxMPt.AddPair('text',
                'Raporu inceledim. İstediğin değişiklikleri söyle, düzenlenmiş halini vereceğim.');
              RapCtxMP.AddElement(RapCtxMPt);
              RapCtxM.AddPair('parts', RapCtxMP);
              RapCtxM.AddPair('role', 'model');
              ContentsArray.AddElement(RapCtxM);
            end;

            ContentJSON := TJSONObject.Create;
            PartsArray := TJSONArray.Create;
            PartJSON := TJSONObject.Create;
            PartJSON.AddPair('text', Soru);
            PartsArray.AddElement(PartJSON);
            ContentJSON.AddPair('parts', PartsArray);
            ContentJSON.AddPair('role', 'user');
            ContentsArray.AddElement(ContentJSON);
            RequestJSON.AddPair('contents', ContentsArray);

            if IsInternetSearch then
            begin
              ToolsArray := TJSONArray.Create;
              var
              SearchTool := TJSONObject.Create;
              SearchTool.AddPair('google_search', TJSONObject.Create);
              ToolsArray.AddElement(SearchTool);
              RequestJSON.AddPair('tools', ToolsArray);
            end;

            Stream := TStringStream.Create(RequestJSON.ToString,
              TEncoding.UTF8);
            try
              Http.ContentType := 'application/json';
              try
                Response := Http.Post(API_URL, Stream);

                if Response.StatusCode = 200 then
                begin
                  JSONResp := TJSONObject.ParseJSONValue
                    (Response.ContentAsString(TEncoding.UTF8)) as TJSONObject;
                  if Assigned(JSONResp) then
                    try
                      Cevap := JSONResp.GetValue<TJSONArray>('candidates')
                        .Items[0].GetValue<TJSONObject>('content')
                        .GetValue<TJSONArray>('parts').Items[0]
                        .GetValue<string>('text');

                      RawCevap := Cevap;

                      // Rapor başlığını AI yanıtının ilk # satırından çıkar
                      RaporBaslik := '';
                      SL := TStringList.Create;
                      try
                        SL.Text := RawCevap;
                        for var i := 0 to SL.Count - 1 do
                        begin
                          var
                          Line := Trim(SL[i]);
                          if (Length(Line) > 2) and (Line[1] = '#') and
                            (Line[2] <> '#') then
                          begin
                            RaporBaslik := Trim(Copy(Line, 2, Length(Line)));
                            Break;
                          end;
                        end;
                        if RaporBaslik = '' then
                          RaporBaslik := Copy(Soru, 1, 80);

                        if IsReport then
                        begin
                          RaporDizini := ExtractFilePath(ParamStr(0)) +
                            'reports\';
                          ForceDirectories(RaporDizini);
                          DosyaAdi := FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now)
                            + '_rapor.md';
                          DosyaYolu := RaporDizini + DosyaAdi;
                          SL.SaveToFile(DosyaYolu, TEncoding.UTF8);
                          if Assigned(dmVeri) then
                          begin
                            ATur := 'standart';
                            if IsInternetSearch then
                              ATur := 'web-arama';
                            TThread.Queue(nil,
                              procedure
                              begin
                                if Assigned(dmVeri) then
                                begin
                                  dmVeri.RaporKaydet(RaporBaslik,
                                    DosyaYolu, ATur);
                                end;
                              end);
                          end;
                        end
                        else if IsEditReport and (DuzenleRaporID > 0) and
                          (DosyaYolu <> '') and (MevcutRaporMetni <> '') then
                        begin
                          SL.SaveToFile(DosyaYolu, TEncoding.UTF8);
                          if Assigned(dmVeri) then
                            dmVeri.RaporBasliginiGuncelle(DuzenleRaporID,
                              RaporBaslik);
                        end;
                      finally
                        SL.Free;
                      end;

                      // Görüntüleme için escape (sıra önemli: önce \ sonra ')
                      Cevap := StringReplace(Cevap, '\', '\\', [rfReplaceAll]);
                      Cevap := StringReplace(Cevap, '''', '\' + '''',
                        [rfReplaceAll]);
                      Cevap := StringReplace(Cevap, #13#10, '\n',
                        [rfReplaceAll]);
                      Cevap := StringReplace(Cevap, #10, '\n', [rfReplaceAll]);

                      SoruJS := StringReplace(Soru, '\', '\\', [rfReplaceAll]);
                      SoruJS := StringReplace(SoruJS, '''', '\' + '''',
                        [rfReplaceAll]);
                      SoruJS := StringReplace(SoruJS, #13#10, '\n',
                        [rfReplaceAll]);
                      SoruJS := StringReplace(SoruJS, #10, '\n',
                        [rfReplaceAll]);

                      RawCevapJS := StringReplace(RawCevap, '\', '\\',
                        [rfReplaceAll]);
                      RawCevapJS := StringReplace(RawCevapJS, '''', '\' + '''',
                        [rfReplaceAll]);
                      RawCevapJS := StringReplace(RawCevapJS, #13#10, '\n',
                        [rfReplaceAll]);
                      RawCevapJS := StringReplace(RawCevapJS, #10, '\n',
                        [rfReplaceAll]);

                      JSKod := Format
                        ('conversationHistory.push({r:''user'',t:''%s''}); ' +
                        'conversationHistory.push({r:''model'',t:''%s''}); ' +
                        'receiveAIResponse(''%s'');',
                        [SoruJS, RawCevapJS, Cevap]);

                      if IsReport then
                        JSKod := JSKod + ' receiveReportSaved();'
                      else if IsEditReport and (DuzenleRaporID > 0) and
                        (MevcutRaporMetni <> '') then
                        JSKod := JSKod + ' receiveReportUpdated();';

                      frame.ExecuteJavaScript(JSKod, '', 0);
                    finally
                      JSONResp.Free;
                    end;
                end
                else
                begin
                  JSKod := Format('receiveAIResponse(''%s'');',
                    ['Bağlantı Hatası: ' + Response.StatusCode.ToString + ' - '
                    + Response.StatusText]);
                  frame.ExecuteJavaScript(JSKod, '', 0);
                end;
              except
                on E: Exception do
                begin
                  JSKod := Format('receiveAIResponse(''%s'');',
                    ['Sistem Hatası: ' + StringReplace(E.message, '''', '\''',
                    [rfReplaceAll])]);
                  frame.ExecuteJavaScript(JSKod, '', 0);
                end;
              end;
            finally
              Stream.Free;
            end;
          finally
            RequestJSON.Free;
            Http.Free;
          end;
        end).Start;
    end;

    Exit; // İşlem tamam, çık
  end

  // 2. YEREL HTML SAYFALARIMIZI YAKALA VE DATA URI OLARAK AÇ (trace://)
  else if Pos('trace://', HedefURL) = 1 then
  begin
    Result := True;

    // Dinamik rapor görüntüleyici
    if Pos('trace://report?id=', HedefURL) = 1 then
    begin
      var
      RaporID := StrToIntDef(Copy(HedefURL, Length('trace://report?id=') + 1,
        Length(HedefURL)), 0);
      var
      ErrTitle := '';
      var
      ErrMsg := '';
      var
      MDYolu := '';

      // Rapor g&#246;r&#252;nt&#252;leyicinin renklerini kullan&#305;c&#305;n&#305;n se&#231;ti&#287;i temaya g&#246;re belirle
      var
      RV_Isik := False;
      if Assigned(dmVeri) then
        RV_Isik := dmVeri.AyarOku('theme', 'dark') = 'light';
      var
        RV_Bg, RV_Bg2, RV_CodeBg, RV_Border, RV_Text, RV_Text2, RV_Accent,
          RV_Accent2, RV_Danger, RV_BtnHoverText: string;
      if RV_Isik then
      begin
        RV_Bg := '#F8F9FA';
        RV_Bg2 := '#FFFFFF';
        RV_CodeBg := '#F1F3F4';
        RV_Border := '#dadce0';
        RV_Text := '#202124';
        RV_Text2 := '#5f6368';
        RV_Accent := '#1a73e8';
        RV_Accent2 := '#4285f4';
        RV_Danger := '#d93025';
        RV_BtnHoverText := '#FFFFFF';
      end
      else
      begin
        RV_Bg := '#202124';
        RV_Bg2 := '#292a2d';
        RV_CodeBg := '#1e1e1e';
        RV_Border := '#3c4043';
        RV_Text := '#E8EAED';
        RV_Text2 := '#9aa0a6';
        RV_Accent := '#8AB4F8';
        RV_Accent2 := '#aecbfa';
        RV_Danger := '#f28b82';
        RV_BtnHoverText := '#202124';
      end;

      if RaporID <= 0 then
      begin
        ErrTitle := 'Ge&#231;ersiz Rapor ID&#39;si';
        ErrMsg := 'L&#252;tfen ge&#231;erli bir rapor ID&#39;si girin.';
      end
      else if not Assigned(dmVeri) then
      begin
        ErrTitle := 'Veritaban&#305; Hatas&#305;';
        ErrMsg := 'Veritaban&#305; ba&#287;lant&#305;s&#305; kurulamad&#305;.';
      end
      else
      begin
        MDYolu := dmVeri.RaporDosyaYolu(RaporID);
        if MDYolu = '' then
        begin
          ErrTitle := 'Rapor Bulunamad&#305;';
          ErrMsg := 'ID <b>' + IntToStr(RaporID) +
            '</b> olan rapor sistemde kay&#305;tl&#305; de&#287;il.<br>' +
            'Rapor silinmi&#351; ya da ID yanl&#305;&#351; olabilir.';
        end
        else if not FileExists(MDYolu) then
        begin
          ErrTitle := 'Dosya Bulunamad&#305;';
          ErrMsg := 'ID <b>' + IntToStr(RaporID) +
            '</b> olan raporun dosyas&#305; diskte mevcut de&#287;il.<br>' +
            'Dosya el ile silinmi&#351; olabilir.';
        end;
      end;

      if ErrTitle <> '' then
      begin
        var
        ErrHTML :=
          '<!DOCTYPE html><html lang="tr"><head><meta charset="UTF-8"><title>' +
          ErrTitle + '</title>' + '<style>body{background:' + RV_Bg + ';color:'
          + RV_Text + ';font-family:"Segoe UI",sans-serif;' +
          'display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;}'
          + '.box{padding:40px;max-width:480px;}.icon{font-size:52px;margin-bottom:20px;}'
          + 'h2{color:' + RV_Danger +
          ';margin:0 0 12px;font-size:20px;}p{color:' + RV_Text2 +
          ';font-size:14px;line-height:1.6;}' +
          '.btn{display:inline-block;margin-top:24px;color:' + RV_Accent +
          ';padding:9px 20px;' + 'border:1px solid ' + RV_Accent +
          ';border-radius:8px;cursor:pointer;font-size:13px;transition:all .15s;}'
          + '.btn:hover{background:' + RV_Accent + ';color:' + RV_BtnHoverText +
          ';}' + '</style></head><body><div class="box">' +
          '<div class="icon">&#128196;</div><h2>' + ErrTitle + '</h2><p>' +
          ErrMsg + '</p>' +
          '<div class="btn" onclick="window.location.href=''tracecmd://open-reports''">&#8592; Raporlar&#305;ma D&#246;n</div>'
          + '</div></body></html>';
        var
        ErrBase64 := TNetEncoding.Base64.Encode(ErrHTML);
        ErrBase64 := StringReplace(ErrBase64, #13, '', [rfReplaceAll]);
        ErrBase64 := StringReplace(ErrBase64, #10, '', [rfReplaceAll]);
        var
        ErrDataURI := 'data:text/html;charset=utf-8;base64,' + ErrBase64;
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
              Kapsul.Chromium1.LoadURL(ErrDataURI);
          end);
      end
      else if MDYolu <> '' then
      begin
        var
        MDList := TStringList.Create;
        try
          MDList.LoadFromFile(MDYolu, TEncoding.UTF8);
          var
          MDMetin := MDList.Text;
          MDMetin := StringReplace(MDMetin, '&', '&amp;', [rfReplaceAll]);
          MDMetin := StringReplace(MDMetin, '<', '&lt;', [rfReplaceAll]);
          MDMetin := StringReplace(MDMetin, '>', '&gt;', [rfReplaceAll]);

          var
          ViewerHTML :=
            '<!DOCTYPE html><html lang="tr"><head><meta charset="UTF-8"><title>Rapor</title>'
            + '<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></'
            + 'script>' + '<style>body{background:' + RV_Bg + ';color:' +
            RV_Text + ';font-family:"Segoe UI",sans-serif;' +
            'padding:40px;max-width:900px;margin:0 auto;line-height:1.7;}' +
            'h1,h2,h3{color:' + RV_Accent + ';}h4,h5,h6{color:' + RV_Accent2 +
            ';}' + 'code{background:' + RV_CodeBg +
            ';padding:2px 6px;border-radius:4px;font-family:monospace;font-size:.9em;}'
            + 'pre{background:' + RV_CodeBg +
            ';padding:14px;border-radius:8px;border:1px solid ' + RV_Border +
            ';overflow-x:auto;}' + 'pre code{background:transparent;padding:0;}'
            + 'a{color:' + RV_Accent + ';}' +
            'blockquote{border-left:3px solid ' + RV_Accent +
            ';margin:0 0 16px 0;padding:8px 16px;color:' + RV_Text2 +
            ';background:' + RV_Bg2 + ';border-radius:0 6px 6px 0;}' +
            'table{border-collapse:collapse;width:100%;margin-bottom:16px;}' +
            'th,td{border:1px solid ' + RV_Border +
            ';padding:8px 14px;text-align:left;}' + 'th{background:' + RV_Bg2 +
            ';color:' + RV_Accent + ';}' +
            'hr{border:none;border-top:1px solid ' + RV_Border +
            ';margin:24px 0;}' +
            '::-webkit-scrollbar{width:6px}::-webkit-scrollbar-thumb{background:'
            + RV_Border + ';border-radius:3px}' + '</style></head><body>' +
            '<pre id="raw" style="display:none">' + MDMetin + '</pre>' +
            '<div id="content"></div>' +
            '<script>document.getElementById("content").innerHTML=marked.parse(document.getElementById("raw").textContent);</'
            + 'script>' + '</body></html>';

          var
          ViewerBase64 := TNetEncoding.Base64.Encode(ViewerHTML);
          ViewerBase64 := StringReplace(ViewerBase64, #13, '', [rfReplaceAll]);
          ViewerBase64 := StringReplace(ViewerBase64, #10, '', [rfReplaceAll]);
          var
          ViewerDataURI := 'data:text/html;charset=utf-8;base64,' +
            ViewerBase64;

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
                Kapsul.Chromium1.LoadURL(ViewerDataURI);
            end);
        finally
          MDList.Free;
        end;
      end;
    end
    else
    begin
      // Statik HTML dosyaları
      if Pos('trace://history', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\history.html'
      else if Pos('trace://downloads', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\downloads.html'
      else if Pos('trace://newtab', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\newtab.html'
      else if Pos('trace://taskmgr', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\taskmgr.html'
      else if Pos('trace://reports', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\reports.html'
      else if Pos('trace://settings', HedefURL) > 0 then
        DosyaYolu := ExtractFilePath(ParamStr(0)) + 'html\settings.html';

      if FileExists(DosyaYolu) then
      begin
        StringList := TStringList.Create;
        try
          StringList.LoadFromFile(DosyaYolu, TEncoding.UTF8);
          HTMLIcerik := StringList.Text;
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
         finally
           // Açık kalan bir okuma cursor'u, aynı bağlantı üzerinden yapılan
           // sonraki bir yazma (ör. indirme kaydı ekleme/güncelleme) ile
           // çakışıp SQLite'ta "database is locked" hatasına yol açabiliyordu.
           dmVeri.qryGecmis.Close;
         end;
        except
          on E: Exception do
            OutputDebugString(PChar('History Veritabanı Hatası: ' + E.message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);
      if Assigned(dmVeri) then
        frame.ExecuteJavaScript(Format('applyTheme(''%s'');',
          [dmVeri.AyarOku('theme', 'dark')]), '', 0);
    end
    else if Pos('trace://downloads', GuncelURL) > 0 then
    begin
      JSKod := '';

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        try
         try
          with dmVeri.qryIndirmeler do
          begin
            Close;
            SQL.Text :=
              'SELECT ID, FileName, FilePath, SourceUrl, TotalBytes, ReceivedBytes, Status, DownloadDate FROM Downloads ORDER BY ID DESC';
            Open;

            while not EOF do
            begin
              // JS'yi bozmaması için tek tırnakları temizliyoruz
              JSBaslik := StringReplace(FieldByName('FileName').AsString, '''',
                '\''', [rfReplaceAll]);

              // Kartta yerel disk yolu değil, indirmenin geldiği kaynak
              // adresi (SourceUrl) gösteriliyor.
              JSUrl := StringReplace(FieldByName('SourceUrl').AsString, '''',
                '\''', [rfReplaceAll]);

              // HATA 2 DÜZELTİLDİ ve MB'a ÇEVRİLDİ: FileSize yerine TotalBytes okuyoruz
              var
              BoyutMB := FieldByName('TotalBytes').AsLargeInt / (1024 * 1024);
              var
              BoyutMetni := FormatFloat('0.## MB', BoyutMB);

              JSMeta := Format('%s &middot; <span class="status">%s</span>',
                [BoyutMetni, FieldByName('Status').AsString]);

              // İlerleme yüzdesi: sadece hâlâ devam eden indirmeler için
              // anlamlı; diğer durumlarda -1 gönderip JS'nin çubuğu hiç
              // çizmemesini sağlıyoruz.
              var
              YuzdeTamam := -1;
              if (FieldByName('Status').AsString = 'in_progress') and
                (FieldByName('TotalBytes').AsLargeInt > 0) then
                YuzdeTamam := Round(FieldByName('ReceivedBytes')
                  .AsLargeInt / FieldByName('TotalBytes').AsLargeInt * 100);

              // Tamamlanmış bir indirmenin dosyası sonradan silinmiş veya
              // taşınmış olabilir; bunu her sayfa yüklemesinde diskten
              // kontrol edip karta "Silindi" etiketi olarak yansıtıyoruz.
              var
              SilindiMi := (FieldByName('Status').AsString = 'completed') and
                (FieldByName('FilePath').AsString <> '') and
                not FileExists(FieldByName('FilePath').AsString);

              // Dev JS zincirine kartı ekle
              JSKod := JSKod +
                Format('addDownloadCard(%d, ''%s'', ''%s'', ''%s'', %d, %s, ''%s''); ',
                [FieldByName('ID').AsInteger, JSBaslik, JSUrl, JSMeta,
                YuzdeTamam, LowerCase(BoolToStr(SilindiMi, True)),
                FieldByName('Status').AsString]);

              Next;
            end;
          end;
         finally
           // Açık kalan bir okuma cursor'u, aynı bağlantı üzerinden yapılan
           // sonraki bir yazma (ör. indirme ilerlemesi güncelleme) ile
           // çakışıp SQLite'ta "database is locked" hatasına yol açabiliyordu.
           dmVeri.qryIndirmeler.Close;
         end;
        except
          on E: Exception do
            OutputDebugString(PChar('Downloads Veritabanı Hatası: ' +
              E.message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);

      if Assigned(dmVeri) then
        frame.ExecuteJavaScript(Format('applyTheme(''%s'');',
          [dmVeri.AyarOku('theme', 'dark')]), '', 0);
    end
    else if Pos('trace://reports', GuncelURL) > 0 then
    begin
      JSKod := '';
      if Assigned(MainFrm) and Assigned(dmVeri) then
        JSKod := dmVeri.RaporlariYukle;
      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0)
      else
        frame.ExecuteJavaScript('checkEmpty();', '', 0);
      if Assigned(dmVeri) then
        frame.ExecuteJavaScript(Format('applyTheme(''%s'');',
          [dmVeri.AyarOku('theme', 'dark')]), '', 0);
    end
    else if Pos('trace://taskmgr', GuncelURL) > 0 then
    begin
      if Assigned(dmVeri) then
        frame.ExecuteJavaScript(Format('applyTheme(''%s'');',
          [dmVeri.AyarOku('theme', 'dark')]), '', 0);
    end
    else if Pos('trace://settings', GuncelURL) > 0 then
    begin
      if Assigned(dmVeri) then
      begin
        // ÖNEMLİ: JS tek tırnaklı string'e gömülecek her değerde önce ters
        // bölü ('\') sonra tek tırnak kaçışlanmalı. Sıra tersine çevrilirse
        // (ör. yol sonu '\' hemen ardından kapanış tırnağı geliyorsa) '\''
        // JS tarafında "kaçışlanmış tırnak" sanılır ve string kapanmaz —
        // tüm loadSettings(...) çağrısı bozulur (örn. varsayılan indirme
        // yolu her zaman '\' ile bitiyor).
        var
        S_ApiKey := StringReplace(StringReplace(dmVeri.AyarOku('api_key', ''),
          '\', '\\', [rfReplaceAll]), '''', '\''', [rfReplaceAll]);
        var
        S_Theme := dmVeri.AyarOku('theme', 'dark');
        var
        S_Name := StringReplace(StringReplace(dmVeri.AyarOku('greeting_name',
          'Yu' + #351 + 'a'), '\', '\\', [rfReplaceAll]), '''', '\''',
          [rfReplaceAll]);
        var
        S_Sal := StringReplace(StringReplace(dmVeri.AyarOku
          ('greeting_salutation', 'Merhaba'), '\', '\\', [rfReplaceAll]),
          '''', '\''', [rfReplaceAll]);
        var
        S_Lang := dmVeri.AyarOku('language', 'tr');
        var
        S_DlPath := StringReplace(StringReplace(dmVeri.AyarOku
          ('downloads_path', ExtractFilePath(ParamStr(0)) + 'downloads\'),
          '\', '\\', [rfReplaceAll]), '''', '\''', [rfReplaceAll]);
        var
        S_DlShow := dmVeri.AyarOku('downloads_show_folder', '1');
        var
        S_Start := dmVeri.AyarOku('startup_mode', 'new_tab');
        var
        S_ESvc := dmVeri.AyarOku('email_service', 'gmail');
        var
        S_EAddr := StringReplace(StringReplace(dmVeri.AyarOku
          ('email_address', ''), '\', '\\', [rfReplaceAll]), '''', '\''',
          [rfReplaceAll]);

        // YENİ EKLENEN IMAP DEĞİŞKENLERİ
        var
        S_EPass := StringReplace(StringReplace(dmVeri.AyarOku
          ('email_password', ''), '\', '\\', [rfReplaceAll]), '''', '\''',
          [rfReplaceAll]);
        var
        S_EImap := StringReplace(StringReplace(dmVeri.AyarOku('email_imap',
          'imap.gmail.com:993'), '\', '\\', [rfReplaceAll]), '''', '\''',
          [rfReplaceAll]);
        var
        S_EStatus := dmVeri.AyarOku('email_imap_status', 'untested');
        var
        S_EStatusMsg := StringReplace(dmVeri.AyarOku('email_imap_status_msg',
          ''), '\', '\\', [rfReplaceAll]);
        S_EStatusMsg := StringReplace(S_EStatusMsg, '''', '\''',
          [rfReplaceAll]);
        S_EStatusMsg := StringReplace(S_EStatusMsg, #13#10, ' ',
          [rfReplaceAll]);
        S_EStatusMsg := StringReplace(S_EStatusMsg, #10, ' ', [rfReplaceAll]);

        var
        SettingsJS :=
          Format('loadSettings({api_key:''%s'',theme:''%s'',greeting_name:''%s'','
          + 'greeting_salutation:''%s'',language:''%s'',downloads_path:''%s'','
          + 'downloads_show_folder:''%s'',startup_mode:''%s'',email_service:''%s'',email_address:''%s'','
          + 'email_password:''%s'',email_imap:''%s'',email_imap_status:''%s'','
          + 'email_imap_status_msg:''%s''});',
          [S_ApiKey, S_Theme, S_Name, S_Sal, S_Lang, S_DlPath, S_DlShow,
          S_Start, S_ESvc, S_EAddr, S_EPass, S_EImap, S_EStatus,
          S_EStatusMsg]);

        frame.ExecuteJavaScript(SettingsJS, '', 0);
      end;
    end

    else if Pos('trace://newtab', GuncelURL) > 0 then
    begin
      JSKod := '';

      if Assigned(MainFrm) and Assigned(dmVeri) then
      begin
        try
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
         finally
           // Açık kalan bir okuma cursor'u, aynı bağlantı üzerinden yapılan
           // sonraki bir yazma (ör. yeni görev ekleme) ile çakışıp SQLite'ta
           // "database is locked" hatasına yol açabiliyordu — her yeni sekme
           // "trace://newtab" açtığında bu sorgu hiç kapanmıyordu.
           dmVeri.qryGorevler.Close;
         end;
        except
          on E: Exception do
            OutputDebugString(PChar('Görevler Veritabanı Hatası: ' +
              E.message));
        end;
      end;

      if JSKod <> '' then
        frame.ExecuteJavaScript(JSKod, '', 0);

      // Inject user settings (greeting, theme, language) into newtab
      if Assigned(dmVeri) then
      begin
        var
        NT_Name := StringReplace(dmVeri.AyarOku('greeting_name',
          'Yu' + #351 + 'a'), '''', '\''', [rfReplaceAll]);
        var
        NT_Sal := StringReplace(dmVeri.AyarOku('greeting_salutation',
          'Merhaba'), '''', '\''', [rfReplaceAll]);
        var
        NT_Theme := dmVeri.AyarOku('theme', 'dark');
        var
        NT_Lang := dmVeri.AyarOku('language', 'tr');
        frame.ExecuteJavaScript
          (Format('applyUserSettings({name:''%s'',sal:''%s'',theme:''%s'',lang:''%s''});',
          [NT_Name, NT_Sal, NT_Theme, NT_Lang]), '', 0);
      end;
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
var
  AKapsul: TTBrowserFrame;
begin
  Result := False;
  AKapsul := Self;

  if (event = nil) then
    Exit;
  if not((event^.kind = KEYEVENT_RAWKEYDOWN) or (event^.kind = KEYEVENT_KEYDOWN))
  then
    Exit;

  var
  Ctrl := (event^.modifiers and EVENTFLAG_CONTROL_DOWN) <> 0;
  var
  Shift := (event^.modifiers and EVENTFLAG_SHIFT_DOWN) <> 0;
  var
  vk := event^.windows_key_code;

  // ── F tuşları (modifier gerektirmez) ──────────────────────────────────────

  if not Ctrl and not Shift then
  begin
    // F6 / Ctrl+L → adres çubuğuna odaklan (aşağıda Ctrl dalında da)
    if vk = $75 then // VK_F6
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
          begin
            MainFrm.edtURL.SetFocus;
            MainFrm.edtURL.SelectAll;
          end;
        end);
      Exit;
    end;

    // F11 → tam ekran geçişi (sekme + nav barını gizle/göster)
    if vk = $7A then // VK_F11
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
          begin
            MainFrm.Panel1.Visible := not MainFrm.Panel1.Visible;
            MainFrm.Panel2.Visible := not MainFrm.Panel2.Visible;
          end;
        end);
      Exit;
    end;

    // F12 → DevTools
    if vk = $7B then // VK_F12
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          AKapsul.Chromium1.ShowDevTools(Point(0, 0));
        end);
      Exit;
    end;
  end;

  // ── CTRL kısayolları ──────────────────────────────────────────────────────

  if Ctrl then
  begin
    // Ctrl+L → adres çubuğuna odaklan
    if vk = $4C then // L
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
          begin
            MainFrm.edtURL.SetFocus;
            MainFrm.edtURL.SelectAll;
          end;
        end);
    end

    // Ctrl+T / Ctrl+N → yeni sekme
    else if (vk = $54) or (vk = $4E) then // T veya N
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://newtab');
        end);
    end

    // Ctrl+H → Geçmiş
    else if vk = $48 then // H
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://history');
        end);
    end

    // Ctrl+J → İndirilenler
    else if vk = $4A then // J
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://downloads');
        end);
    end

    // Ctrl+K → Görev Yöneticisi
    else if vk = $4B then // K
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://taskmgr');
        end);
    end

    // Ctrl+, → Ayarlar
    else if vk = $BC then // OEM_COMMA
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc('trace://settings');
        end);
    end

    // Ctrl+W → Aktif sekmeyi kapat
    else if vk = $57 then // W
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.SekmeyiKapat(MainFrm.FAktifIndex);
        end);
    end

    // Ctrl+Tab → sonraki sekmeye geç
    else if not Shift and (vk = $09) then // Tab
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) and (MainFrm.FSekmeler.Count > 1) then
          begin
            var
            Sonraki := (MainFrm.FAktifIndex + 1) mod MainFrm.FSekmeler.Count;
            MainFrm.FAktifIndex := Sonraki;
            MainFrm.AktifSekmeyiGoster;
            MainFrm.skTabs.Invalidate;
          end;
        end);
    end

    // Ctrl+Shift+Tab → önceki sekmeye geç
    else if Shift and (vk = $09) then // Shift+Tab
    begin
      Result := True;
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) and (MainFrm.FSekmeler.Count > 1) then
          begin
            var
            Onceki := (MainFrm.FAktifIndex - 1 + MainFrm.FSekmeler.Count)
              mod MainFrm.FSekmeler.Count;
            MainFrm.FAktifIndex := Onceki;
            MainFrm.AktifSekmeyiGoster;
            MainFrm.skTabs.Invalidate;
          end;
        end);
    end;
  end;
end;

// Orta tıklama veya Ctrl+tıklama ile yeni sekmede aç
procedure TTBrowserFrame.Chromium1OpenUrlFromTab(Sender: TObject;
const browser: ICefBrowser; const frame: ICefFrame; const targetUrl: ustring;
targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
out Result: Boolean);
var
  YeniURL: string;
begin
  Result := True;
  YeniURL := targetUrl;
  if YeniURL <> '' then
    TThread.Queue(nil,
      procedure
      begin
        if Assigned(MainFrm) then
          MainFrm.YeniSekmeAc(YeniURL);
      end);
end;

// Sağ tıklama menüsüne "Yeni sekmede aç" ekle
procedure TTBrowserFrame.Chromium1BeforeContextMenu(Sender: TObject;
const browser: ICefBrowser; const frame: ICefFrame;
const params: ICefContextMenuParams; const model: ICefMenuModel);
const
  CM_YENI_SEKME = 26501;
begin
  if (Integer(params.TypeFlags) and 4) <> 0 then // CM_TYPEFLAG_LINK = 4
  begin
    model.InsertItemAt(0, CM_YENI_SEKME, 'Yeni sekmede a' + #231);
    model.InsertSeparatorAt(1);
  end;
end;

// Menü komutunu işle
procedure TTBrowserFrame.Chromium1ContextMenuCommand(Sender: TObject;
const browser: ICefBrowser; const frame: ICefFrame;
const params: ICefContextMenuParams; commandId: Integer;
eventFlags: TCefEventFlags; out Result: Boolean);
const
  CM_YENI_SEKME = 26501;
var
  LinkURL: string;
begin
  Result := False;
  if commandId = CM_YENI_SEKME then
  begin
    Result := True;
    LinkURL := params.LinkURL;
    if LinkURL <> '' then
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(MainFrm) then
            MainFrm.YeniSekmeAc(LinkURL);
        end);
  end;
end;

// Web sayfası tam ekran talep ettiğinde nav/tab barlarını gizle
procedure TTBrowserFrame.Chromium1FullscreenModeChange(Sender: TObject;
const browser: ICefBrowser; fullscreen: Boolean);
begin
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(MainFrm) then
      begin
        MainFrm.Panel1.Visible := not fullscreen;
        MainFrm.Panel2.Visible := not fullscreen;
      end;
    end);
end;

// AKlasor içinde ADosyaAdi zaten varsa, Chrome/Windows'un yaptığı gibi
// dosya adının sonuna " (1)", " (2)" ... ekleyerek boş bir isim bulur.
// Böylece aynı dosya tekrar indirildiğinde öncekinin üzerine yazılmaz.
function BenzersizIndirmeYolu(const AKlasor, ADosyaAdi: string): string;
var
  Ad, Uzanti, AdayYol: string;
  Sayac: Integer;
begin
  Result := IncludeTrailingPathDelimiter(AKlasor) + ADosyaAdi;
  if not FileExists(Result) then
    Exit;

  Ad := TPath.GetFileNameWithoutExtension(ADosyaAdi);
  Uzanti := TPath.GetExtension(ADosyaAdi);
  Sayac := 1;
  repeat
    AdayYol := IncludeTrailingPathDelimiter(AKlasor) +
      Format('%s (%d)%s', [Ad, Sayac, Uzanti]);
    Inc(Sayac);
  until not FileExists(AdayYol);
  Result := AdayYol;
end;

// İndirme başlamadan hemen önce çağrılır: nereye kaydedileceğine biz karar
// veriyoruz (ayarlardaki indirme klasörü + önerilen dosya adı), "Farklı
// Kaydet" diyaloğunu hiç göstermiyoruz.
//
// NOT: Burada downloadItem hakkında bilgi SAKLAMIYORUZ — CEF'in resmi
// MiniBrowser örneği de böyle yapıyor. downloadItem'ın kendisi bu fonksiyon
// dışında geçerliliğini yitirebiliyor (bkz. CEF dokümantasyonu); doğru yol,
// her Chromium1DownloadUpdated çağrısında downloadItem'ın o anki
// FullPath/SuggestedFileName alanlarını doğrudan okumak.
procedure TTBrowserFrame.Chromium1BeforeDownload(Sender: TObject;
const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
const suggestedName: ustring; const callback: ICefBeforeDownloadCallback;
var aResult: Boolean);
var
  IndirmeKlasoru, HedefYol: string;
begin
  aResult := True;

  IndirmeKlasoru := '';
  if Assigned(dmVeri) then
    IndirmeKlasoru := dmVeri.AyarOku('downloads_path', '');
  if IndirmeKlasoru = '' then
    IndirmeKlasoru := ExtractFilePath(ParamStr(0)) + 'downloads\';

  ForceDirectories(IndirmeKlasoru);
  HedefYol := BenzersizIndirmeYolu(IndirmeKlasoru, suggestedName);

  callback.Cont(HedefYol, False);
end;

// İndirme ilerledikçe (başladığında, her ilerleme adımında, bittiğinde veya
// iptal edildiğinde) tekrar tekrar çağrılır. CEF'in kendi Id'sini (CefId)
// veritabanı satırıyla eşleştirip ilk çağrıda INSERT, sonrasında UPDATE
// yapıyoruz; ayrıca ilk çağrıda İndirilenler animasyonunu, ilk/son çağrıda da
// açık İndirilenler sekmelerinin yenilenmesini tetikliyoruz.
//
// NOT: DosyaAdi/TamYol her çağrıda downloadItem'ın KENDİ property'lerinden
// (SuggestedFileName/FullPath) DOĞRUDAN okunuyor — ayrı bir Id-eşleştirme
// haritası KULLANMIYORUZ (bkz. Chromium1BeforeDownload'daki not). FullPath
// ilk bir-iki çağrıda henüz netleşmemiş (boş) olabilir; bu durumda
// IndirmeGuncelle çağrısı FilePath'i boşsa dokunmadan bırakıyor, path
// netleştiği an bir sonraki güncellemede otomatik yazılıyor.
procedure TTBrowserFrame.Chromium1DownloadUpdated(Sender: TObject;
const browser: ICefBrowser; const downloadItem: ICefDownloadItem;
const callback: ICefDownloadItemCallback);
var
  CefId: Cardinal;
  TamYol, DosyaAdi, KaynakUrl, Durum: string;
  ToplamBayt, AlinanBayt: Int64;
begin
  if not Assigned(downloadItem) or not downloadItem.IsValid then
    Exit;

  CefId := downloadItem.Id;
  TamYol := downloadItem.FullPath;
  DosyaAdi := downloadItem.SuggestedFileName;
  if DosyaAdi = '' then
    DosyaAdi := ExtractFileName(TamYol);
  KaynakUrl := downloadItem.Url;
  ToplamBayt := downloadItem.TotalBytes;
  AlinanBayt := downloadItem.ReceivedBytes;

  if downloadItem.IsCanceled then
    Durum := 'cancelled'
  else if downloadItem.IsComplete then
    Durum := 'completed'
  else
    Durum := 'in_progress';

  TThread.Queue(nil,
    procedure
    var
      DbId: Integer;
      IlkKez: Boolean;
    begin
      if not Assigned(dmVeri) then
        Exit;

      IlkKez := False;
      try
        DbId := dmVeri.IndirmeKaydiBul(CefId);
        IlkKez := DbId < 0;
        if IlkKez then
          dmVeri.IndirmeBaslat(CefId, DosyaAdi, TamYol, KaynakUrl, ToplamBayt,
            AlinanBayt)
        else
          dmVeri.IndirmeGuncelle(DbId, DosyaAdi, TamYol, KaynakUrl, ToplamBayt,
            AlinanBayt, Durum);
      except
        // Bir veritabanı hatası (ör. geçici "database is locked") animasyon
        // ve sekme yenileme gibi arkasından gelen UI tepkilerini asla
        // engellemesin; en azından ekranda bir şeyler olduğu görülsün.
        on E: Exception do
          OutputDebugString(PChar('İndirme veritabanı hatası: ' + E.Message));
      end;

      if Assigned(MainFrm) then
      begin
        if IlkKez then
          MainFrm.IndirmeAnimasyonuBaslat;
        if IlkKez or (Durum <> 'in_progress') then
          MainFrm.IndirmeSekmeleriniYenile;
      end;
    end);
end;

procedure TTBrowserFrame.Chromium1ProcessMessageReceived(Sender: TObject;
const browser: ICefBrowser; const frame: ICefFrame;
sourceProcess: TCefProcessId; const message: ICefProcessMessage;
out Result: Boolean);
begin
  Result := False;

  // Eğer Render işlemi bize PID'sini fısıldıyorsa, onu yakala!
  if message.Name = 'TraceReportPID' then
  begin
    FRendererPID := message.ArgumentList.GetInt(0);
    Result := True;
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

initialization
  // CEF, güvenlik amacıyla process'in DLL arama davranışını kısıtlıyor
  // olabilir; bu yüzden Indy'nin "sadece dosya adıyla ara" (ssleay32.dll /
  // libeay32.dll) varsayılan davranışı, DLL'ler tam da uygulamanın kendi
  // klasöründe dururken bile "EIdOSSLCouldNotLoadSSLLibrary" ile
  // başarısız olabiliyordu. Tam yolu açıkça vererek bu belirsizliği
  // ortadan kaldırıyoruz.
  IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));

end.
