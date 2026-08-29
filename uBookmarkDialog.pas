unit uBookmarkDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TBookmarkDialogSonuc = (bdsIptal, bdsKaydet, bdsKaldir);

  TfrmBookmarkEdit = class(TForm)
    lblBaslikEtiket: TLabel;
    edtBaslik: TEdit;
    lblURLEtiket: TLabel;
    lblURL: TLabel;
    btnKaydet: TButton;
    btnKaldir: TButton;
    btnIptal: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnKaldirClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
  private
    FSonuc: TBookmarkDialogSonuc;
  public
    class function Calistir(const AURL, ABaslikOnerisi: string;
      ADuzenlemeModu: Boolean; out AYeniBaslik: string): TBookmarkDialogSonuc;
  end;

implementation

{$R *.dfm}

class function TfrmBookmarkEdit.Calistir(const AURL, ABaslikOnerisi: string;
  ADuzenlemeModu: Boolean; out AYeniBaslik: string): TBookmarkDialogSonuc;
var
  Frm: TfrmBookmarkEdit;
begin
  Frm := TfrmBookmarkEdit.Create(nil);
  try
    Frm.lblBaslikEtiket.Caption := 'Ad:';
    Frm.lblURLEtiket.Caption := 'URL:';
    Frm.btnKaydet.Caption := 'Kaydet';
    Frm.btnIptal.Caption := 'İptal';
    Frm.btnKaldir.Caption := 'Kaldır';

    Frm.lblURL.Caption := AURL;
    Frm.lblURL.Hint := AURL;
    Frm.lblURL.ShowHint := True;
    Frm.edtBaslik.Text := ABaslikOnerisi;
    Frm.btnKaldir.Visible := ADuzenlemeModu;

    if ADuzenlemeModu then
      Frm.Caption := 'Yer İmini Düzenle'
    else
      Frm.Caption := 'Yer İmi Ekle';

    Frm.FSonuc := bdsIptal;
    Frm.ShowModal;

    Result := Frm.FSonuc;
    AYeniBaslik := Trim(Frm.edtBaslik.Text);
  finally
    Frm.Free;
  end;
end;

procedure TfrmBookmarkEdit.FormShow(Sender: TObject);
begin
  edtBaslik.SetFocus;
  edtBaslik.SelectAll;
end;

procedure TfrmBookmarkEdit.btnKaydetClick(Sender: TObject);
begin
  FSonuc := bdsKaydet;
  ModalResult := mrOk;
end;

procedure TfrmBookmarkEdit.btnKaldirClick(Sender: TObject);
begin
  FSonuc := bdsKaldir;
  ModalResult := mrOk;
end;

procedure TfrmBookmarkEdit.btnIptalClick(Sender: TObject);
begin
  FSonuc := bdsIptal;
  ModalResult := mrCancel;
end;

end.
