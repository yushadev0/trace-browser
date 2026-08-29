unit uData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdmVeri = class(TDataModule)
    FDConn: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    qryArama: TFDQuery;
    qryGecmis: TFDQuery;
    qryIndirmeler: TFDQuery;
    qryGorevler: TFDQuery;
    qryYerIsaretleri: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GecmiseEkle(const AURL, ATitle: string);
    procedure OnerileriGetir(const AnahtarKelime: string; Liste: TStrings);
    procedure RaporKaydet(const ABaslik, ADosyaYolu, ATur: string);
    function RaporlariYukle: string;
    function RaporDosyaYolu(ARaporID: Integer): string;
    procedure RaporSil(ARaporID: Integer);
    procedure RaporBasliginiGuncelle(ARaporID: Integer;
      const AYeniBaslik: string);
    procedure AyarYaz(const AKey, AValue: string);
    function AyarOku(const AKey, AVarsayilan: string): string;
    procedure VeriSil(const ATur: string);
    procedure OturumSekmeleriniKaydet(URLs: TStringList);
    function OturumSekmeleriniYukle: TStringList;
    function EmailOzetOku(const AMessageID: string;
      out AOncelik, AOzet: string): Boolean;
    procedure EmailOzetYaz(const AMessageID, ASender, ASubject, AOncelik,
      AOzet: string);
    function YerIsaretiVarMi(const AURL: string): Boolean;
    procedure YerIsaretiEkle(const AURL, ATitle: string);
    procedure YerIsaretiSil(const AURL: string);
    procedure YerIsaretiBasligiGuncelle(const AURL, AYeniBaslik: string);
    function IndirmeKaydiBul(ACefId: Cardinal): Integer;
    function IndirmeBaslat(ACefId: Cardinal; const AFileName, AFilePath,
      ASourceUrl: string; ATotalBytes, AReceivedBytes: Int64): Integer;
    procedure IndirmeGuncelle(ADbId: Integer; const AFileName, AFilePath,
      ASourceUrl: string; ATotalBytes, AReceivedBytes: Int64;
      const AStatus: string);
    function IndirmeYoluGetir(ADbId: Integer): string;
  end;

var
  dmVeri: TdmVeri;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TdmVeri.DataModuleCreate(Sender: TObject);
var
  DBYolu: string;
begin
  DBYolu := ExtractFilePath(ParamStr(0)) + 'TraceDB.sqlite';

  FDConn.Params.Clear;
  FDConn.Params.Add('DriverID=SQLite');
  FDConn.Params.Add('Database=' + DBYolu);
  FDConn.Params.Add('LockingMode=Normal');
  FDConn.Params.Add('StringFormat=Unicode');

  FDConn.Connected := True;

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS History (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  URL TEXT NOT NULL UNIQUE,' +
    // Aynı URL'yi tekrar kaydetmemek için UNIQUE
    '  Title TEXT,' + '  VisitCount INTEGER DEFAULT 1,' +
    '  LastVisit DATETIME' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Downloads (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  CefId INTEGER,' +
    '  FileName TEXT,' + '  FilePath TEXT,' + '  SourceUrl TEXT,' +
    '  TotalBytes INTEGER,' + '  ReceivedBytes INTEGER,' + '  Status TEXT,' +
    '  DownloadDate DATETIME' + ')');
  // Eski veritabanlarında CefId/SourceUrl/ReceivedBytes sütunları
  // olmayabilir (bkz. IndirmeBaslat/IndirmeKaydiBul); zaten varsa SQLite
  // hata verir, sessizce yutuyoruz.
  try
    FDConn.ExecSQL('ALTER TABLE Downloads ADD COLUMN CefId INTEGER');
  except
  end;
  try
    FDConn.ExecSQL('ALTER TABLE Downloads ADD COLUMN SourceUrl TEXT');
  except
  end;
  try
    FDConn.ExecSQL('ALTER TABLE Downloads ADD COLUMN ReceivedBytes INTEGER');
  except
  end;

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Bookmarks (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  URL TEXT NOT NULL UNIQUE,' +
    '  Title TEXT,' + '  OrderIndex INTEGER DEFAULT 0,' +
    '  AddedDate DATETIME' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Tasks (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  TaskName TEXT,' +
    '  IsCompleted BOOLEAN DEFAULT 0,' + '  CreatedAt DATETIME' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Reports (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  Title TEXT,' +
    '  FilePath TEXT,' + '  ReportType TEXT,' +
    '  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Settings (' +
    '  Key TEXT PRIMARY KEY,' + '  Value TEXT' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS SessionTabs (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  URL TEXT NOT NULL' + ')');

  // AI e-posta özetleme önbelleği: aynı e-posta (Message-ID ile, IMAP UID
  // gibi mailbox'a bağlı olmayan, kalıcı/global benzersiz kimlik) her yeni
  // sekme açılışında tekrar Gemini'ye gönderilip API kotası harcamasın diye.
  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS EmailAICache (' +
    '  MessageID TEXT PRIMARY KEY,' + '  Sender TEXT,' + '  Subject TEXT,' +
    '  Priority TEXT,' + '  Summary TEXT,' +
    '  CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP' + ')');

end;

procedure TdmVeri.GecmiseEkle(const AURL, ATitle: string);
begin
  // Gereksiz veya boş sayfaları veritabanına çöplük yapmamak için güvenlik filtresi
  if (AURL = '') or (AURL = 'about:blank') or (Pos('devtools://', AURL) > 0)
  then
    Exit;

  // SİHİRLİ SORGGU: ON CONFLICT(URL) DO UPDATE
  // Bu kod sayesinde veritabanında URL yoksa yeni ekler, varsa sadece sayacı ve tarihi günceller!
  FDConn.ExecSQL('INSERT INTO History (URL, Title, VisitCount, LastVisit) ' +
    'VALUES (:U, :T, 1, :D) ' + 'ON CONFLICT(URL) DO UPDATE SET ' +
    '  VisitCount = VisitCount + 1, ' + '  LastVisit = :D, ' + '  Title = :T',
    [AURL, ATitle, Now]);
end;

procedure TdmVeri.OnerileriGetir(const AnahtarKelime: string; Liste: TStrings);
begin
  Liste.Clear;

  if Trim(AnahtarKelime) = '' then
    Exit;

  // Arama sorgusunu hazırlıyoruz.
  // Hem URL içinde hem de Başlık (Title) içinde arama yapacağız.
  // En çok ziyaret edilenleri (VisitCount) ve en son girilenleri en üste dizeceğiz. (LIMIT 5 ile en iyi 5 sonuç)
  qryArama.Close;
  qryArama.SQL.Text := 'SELECT URL, Title FROM History ' +
    'WHERE URL LIKE :Kelime OR Title LIKE :Kelime ' +
    'ORDER BY VisitCount DESC, LastVisit DESC ' + 'LIMIT 5';

  // Kullanıcının yazdığı kelimenin sağına ve soluna % ekleyerek "İçerenleri Bul" diyoruz
  qryArama.ParamByName('Kelime').AsString := '%' + AnahtarKelime + '%';
  qryArama.Open;

  while not qryArama.Eof do
  begin
    Liste.Add(qryArama.FieldByName('Title').AsString + ' - ' +
      qryArama.FieldByName('URL').AsString);
    qryArama.Next;
  end;
end;

procedure TdmVeri.RaporKaydet(const ABaslik, ADosyaYolu, ATur: string);
begin
  FDConn.ExecSQL
    ('INSERT INTO Reports (Title, FilePath, ReportType, CreatedAt) VALUES (:T, :F, :R, datetime(''now''))',
    [ABaslik, ADosyaYolu, ATur]);
end;

function TdmVeri.RaporlariYukle: string;
var
  qry: TFDQuery;
  JSKod, Baslik, Tur, Tarih: string;
begin
  JSKod := '';
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text :=
      'SELECT ID, Title, ReportType, CreatedAt FROM Reports ORDER BY ID DESC';
    qry.Open;
    while not qry.Eof do
    begin
      Baslik := StringReplace(qry.FieldByName('Title').AsString, '''', '\''',
        [rfReplaceAll]);
      Tur := qry.FieldByName('ReportType').AsString;
      Tarih := qry.FieldByName('CreatedAt').AsString;
      JSKod := JSKod + Format('addReportCard(%d, ''%s'', ''%s'', ''%s''); ',
        [qry.FieldByName('ID').AsInteger, Baslik, Tur, Tarih]);
      qry.Next;
    end;
  finally
    qry.Free;
  end;
  Result := JSKod;
end;

function TdmVeri.RaporDosyaYolu(ARaporID: Integer): string;
var
  qry: TFDQuery;
begin
  Result := '';
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT FilePath FROM Reports WHERE ID = :ID';
    qry.ParamByName('ID').AsInteger := ARaporID;
    qry.Open;
    if not qry.Eof then
      Result := qry.FieldByName('FilePath').AsString;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.RaporSil(ARaporID: Integer);
begin
  FDConn.ExecSQL('DELETE FROM Reports WHERE ID = :ID', [ARaporID]);
end;

procedure TdmVeri.RaporBasliginiGuncelle(ARaporID: Integer;
  const AYeniBaslik: string);
begin
  FDConn.ExecSQL('UPDATE Reports SET Title = :T WHERE ID = :ID',
    [AYeniBaslik, ARaporID]);
end;

procedure TdmVeri.AyarYaz(const AKey, AValue: string);
begin
  FDConn.ExecSQL('INSERT INTO Settings (Key, Value) VALUES (:K, :V) ' +
    'ON CONFLICT(Key) DO UPDATE SET Value = :V', [AKey, AValue]);
end;

function TdmVeri.AyarOku(const AKey, AVarsayilan: string): string;
var
  qry: TFDQuery;
begin
  Result := AVarsayilan;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT Value FROM Settings WHERE Key = :K';
    qry.ParamByName('K').AsString := AKey;
    qry.Open;
    if not qry.Eof then
      Result := qry.FieldByName('Value').AsString;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.VeriSil(const ATur: string);
var
  qry: TFDQuery;
begin
  if (ATur = 'history') or (ATur = 'all') then
    FDConn.ExecSQL('DELETE FROM History');
  if (ATur = 'downloads') or (ATur = 'all') then
    FDConn.ExecSQL('DELETE FROM Downloads');
  if (ATur = 'reports') or (ATur = 'all') then
  begin
    qry := TFDQuery.Create(nil);
    try
      qry.Connection := FDConn;
      qry.SQL.Text := 'SELECT FilePath FROM Reports';
      qry.Open;
      while not qry.Eof do
      begin
        var
        FP := qry.FieldByName('FilePath').AsString;
        if (FP <> '') and FileExists(FP) then
          DeleteFile(FP);
        qry.Next;
      end;
    finally
      qry.Free;
    end;
    FDConn.ExecSQL('DELETE FROM Reports');
  end;
  if (ATur = 'settings') or (ATur = 'preferences') or (ATur = 'all') then
    FDConn.ExecSQL('DELETE FROM Settings');
end;

procedure TdmVeri.OturumSekmeleriniKaydet(URLs: TStringList);
var
  i: Integer;
begin
  FDConn.ExecSQL('DELETE FROM SessionTabs');
  if not Assigned(URLs) then
    Exit;
  for i := 0 to URLs.Count - 1 do
    FDConn.ExecSQL('INSERT INTO SessionTabs (URL) VALUES (:U)', [URLs[i]]);
end;

function TdmVeri.OturumSekmeleriniYukle: TStringList;
var
  qry: TFDQuery;
begin
  Result := TStringList.Create;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT URL FROM SessionTabs ORDER BY ID';
    qry.Open;
    while not qry.Eof do
    begin
      Result.Add(qry.FieldByName('URL').AsString);
      qry.Next;
    end;
  finally
    qry.Free;
  end;
end;

function TdmVeri.EmailOzetOku(const AMessageID: string;
  out AOncelik, AOzet: string): Boolean;
var
  qry: TFDQuery;
begin
  Result := False;
  AOncelik := '';
  AOzet := '';
  if AMessageID = '' then
    Exit; // Message-ID yoksa önbellek anlamsız, her seferinde yeniden özetle
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text :=
      'SELECT Priority, Summary FROM EmailAICache WHERE MessageID = :M';
    qry.ParamByName('M').AsWideString := AMessageID;
    qry.Open;
    if not qry.Eof then
    begin
      AOncelik := qry.FieldByName('Priority').AsWideString;
      AOzet := qry.FieldByName('Summary').AsWideString;
      Result := True;
    end;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.EmailOzetYaz(const AMessageID, ASender, ASubject, AOncelik,
  AOzet: string);
var
  qry: TFDQuery;
begin
  if AMessageID = '' then
    Exit;
  // NOT: ExecSQL(sql, [array of const]) yerine bilinçli olarak TFDQuery +
  // AsWideString kullanıyoruz. "array of const" ile Türkçe'ye özgü
  // karakterler (ş, ı, ğ, ç — ö/ü hayatta kalıyor ama bunlar kayboluyor,
  // klasik ANSI/Windows-1252 üzerinden geçiş belirtisi) veritabanına
  // bozuk yazılıyordu; AsWideString bu ara adımı atlayıp Unicode'u
  // doğrudan bağlıyor.
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'INSERT INTO EmailAICache ' +
      '(MessageID, Sender, Subject, Priority, Summary, CreatedAt) ' +
      'VALUES (:M, :S, :SU, :P, :O, datetime(''now'')) ' +
      'ON CONFLICT(MessageID) DO UPDATE SET ' +
      '  Priority = :P2, Summary = :O2, Sender = :S2, Subject = :SU2';
    qry.ParamByName('M').AsWideString := AMessageID;
    qry.ParamByName('S').AsWideString := ASender;
    qry.ParamByName('SU').AsWideString := ASubject;
    qry.ParamByName('P').AsWideString := AOncelik;
    qry.ParamByName('O').AsWideString := AOzet;
    qry.ParamByName('S2').AsWideString := ASender;
    qry.ParamByName('SU2').AsWideString := ASubject;
    qry.ParamByName('P2').AsWideString := AOncelik;
    qry.ParamByName('O2').AsWideString := AOzet;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

function TdmVeri.YerIsaretiVarMi(const AURL: string): Boolean;
var
  qry: TFDQuery;
begin
  Result := False;
  if AURL = '' then
    Exit;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT COUNT(*) AS Adet FROM Bookmarks WHERE URL = :U';
    qry.ParamByName('U').AsWideString := AURL;
    qry.Open;
    Result := qry.FieldByName('Adet').AsInteger > 0;
    qry.Close;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.YerIsaretiEkle(const AURL, ATitle: string);
var
  qry: TFDQuery;
begin
  if AURL = '' then
    Exit;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'INSERT OR IGNORE INTO Bookmarks ' +
      '(URL, Title, OrderIndex, AddedDate) VALUES ' +
      '(:U, :T, (SELECT COALESCE(MAX(OrderIndex), 0) + 1 FROM Bookmarks), ' +
      'datetime(''now''))';
    qry.ParamByName('U').AsWideString := AURL;
    qry.ParamByName('T').AsWideString := ATitle;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.YerIsaretiSil(const AURL: string);
var
  qry: TFDQuery;
begin
  if AURL = '' then
    Exit;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'DELETE FROM Bookmarks WHERE URL = :U';
    qry.ParamByName('U').AsWideString := AURL;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.YerIsaretiBasligiGuncelle(const AURL, AYeniBaslik: string);
var
  qry: TFDQuery;
begin
  if AURL = '' then
    Exit;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'UPDATE Bookmarks SET Title = :T WHERE URL = :U';
    qry.ParamByName('T').AsWideString := AYeniBaslik;
    qry.ParamByName('U').AsWideString := AURL;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

function TdmVeri.IndirmeKaydiBul(ACefId: Cardinal): Integer;
var
  qry: TFDQuery;
begin
  Result := -1;
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT ID FROM Downloads WHERE CefId = :C';
    qry.ParamByName('C').AsInteger := ACefId;
    qry.Open;
    if not qry.Eof then
      Result := qry.FieldByName('ID').AsInteger;
    qry.Close;
  finally
    qry.Free;
  end;
end;

function TdmVeri.IndirmeBaslat(ACefId: Cardinal; const AFileName,
  AFilePath, ASourceUrl: string; ATotalBytes, AReceivedBytes: Int64): Integer;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'INSERT INTO Downloads ' +
      '(CefId, FileName, FilePath, SourceUrl, TotalBytes, ReceivedBytes, ' +
      'Status, DownloadDate) ' +
      'VALUES (:C, :FN, :FP, :U, :TB, :RB, ''in_progress'', datetime(''now''))';
    qry.ParamByName('C').AsInteger := ACefId;
    qry.ParamByName('FN').AsWideString := AFileName;
    qry.ParamByName('FP').AsWideString := AFilePath;
    qry.ParamByName('U').AsWideString := ASourceUrl;
    qry.ParamByName('TB').AsLargeInt := ATotalBytes;
    qry.ParamByName('RB').AsLargeInt := AReceivedBytes;
    qry.ExecSQL;

    qry.SQL.Text := 'SELECT last_insert_rowid() AS ID';
    qry.Open;
    Result := qry.FieldByName('ID').AsInteger;
    qry.Close;
  finally
    qry.Free;
  end;
end;

procedure TdmVeri.IndirmeGuncelle(ADbId: Integer; const AFileName, AFilePath,
  ASourceUrl: string; ATotalBytes, AReceivedBytes: Int64;
  const AStatus: string);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    // AFileName/AFilePath/ASourceUrl boş gelirse (CEF henüz netleştirmemişse)
    // mevcut değerin üzerine boş yazıp kaybetmiyoruz; dolu geldiği ilk
    // güncellemede otomatik yerleşiyor.
    qry.SQL.Text :=
      'UPDATE Downloads SET ' +
      'FileName = CASE WHEN LENGTH(:FN) > 0 THEN :FN ELSE FileName END, ' +
      'FilePath = CASE WHEN LENGTH(:FP) > 0 THEN :FP ELSE FilePath END, ' +
      'SourceUrl = CASE WHEN LENGTH(:U) > 0 THEN :U ELSE SourceUrl END, ' +
      'TotalBytes = :TB, ReceivedBytes = :RB, Status = :S WHERE ID = :ID';
    qry.ParamByName('FN').AsWideString := AFileName;
    qry.ParamByName('FP').AsWideString := AFilePath;
    qry.ParamByName('U').AsWideString := ASourceUrl;
    qry.ParamByName('TB').AsLargeInt := ATotalBytes;
    qry.ParamByName('RB').AsLargeInt := AReceivedBytes;
    qry.ParamByName('S').AsWideString := AStatus;
    qry.ParamByName('ID').AsInteger := ADbId;
    qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

function TdmVeri.IndirmeYoluGetir(ADbId: Integer): string;
var
  qry: TFDQuery;
begin
  Result := '';
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := FDConn;
    qry.SQL.Text := 'SELECT FilePath FROM Downloads WHERE ID = :ID';
    qry.ParamByName('ID').AsInteger := ADbId;
    qry.Open;
    if not qry.Eof then
      Result := qry.FieldByName('FilePath').AsString;
    qry.Close;
  finally
    qry.Free;
  end;
end;

end.
