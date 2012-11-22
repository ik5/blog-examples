unit unthash_example;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DCPcrypt2;

type

  { TfrmSHAExample }

  TfrmSHAExample = class(TForm)
    btnSHA256: TButton;
    btnSHA384: TButton;
    btnSHA512: TButton;
    edtText: TEdit;
    edtResult: TEdit;
    lblResult: TLabel;
    lblText: TLabel;
    procedure btnSHA256Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    hashes : array[0..2] of TDCP_hash;

  end;

var
  frmSHAExample: TfrmSHAExample;

implementation
uses DCPsha512, DCPsha256;

{$R *.lfm}

{ TfrmSHAExample }

procedure TfrmSHAExample.btnSHA256Click(Sender: TObject);
var l, t, i : Byte;
    answer  : array of Byte;
    s       : string;
begin
  t := TComponent(Sender).Tag;

  SetLength(answer, hashes[t].HashSize div 8);
  hashes[t].Init;
  hashes[t].Update(edtText.Text, Length(edtText.Text));
  hashes[t].Final(answer[0]);

  s := '';
  for i := 0 to Length(answer) -1 do
    begin
      s := s + IntToHex(answer[i],2);
    end;

  edtResult.Text := s;
end;

procedure TfrmSHAExample.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i : Byte;
begin
  for i := Low(hashes) to High(hashes) do
    hashes[i].Free;
end;

procedure TfrmSHAExample.FormCreate(Sender: TObject);
begin
  hashes[0] := TDCP_sha256.Create(nil);
  hashes[1] := TDCP_sha384.Create(nil);
  hashes[2] := TDCP_sha512.Create(nil);
end;

end.

