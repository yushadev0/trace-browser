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
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GecmiseEkle(const AURL, ATitle: string);
    procedure OnerileriGetir(const AnahtarKelime: string; Liste: TStrings);
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
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  FileName TEXT,' +
    '  FilePath TEXT,' + '  TotalBytes INTEGER,' + '  Status TEXT,' +
    '  DownloadDate DATETIME' + ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Bookmarks (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' + '  URL TEXT NOT NULL UNIQUE,' +
    '  Title TEXT,' + '  AddedDate DATETIME' + ')');

    FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS Tasks (' +
    '  ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  TaskName TEXT,' +
    '  IsCompleted BOOLEAN DEFAULT 0,' +
    '  CreatedAt DATETIME' + ')');

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

  // Çıkan sonuçları listeye doldur
  while not qryArama.Eof do
  begin
    // Listede şık dursun diye: "Google - https://google.com" formatında ekliyoruz
    Liste.Add(qryArama.FieldByName('Title').AsString + ' - ' +
      qryArama.FieldByName('URL').AsString);
    qryArama.Next;
  end;
end;

end.
