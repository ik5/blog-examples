unit untmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls;

type

  { TfrmDBCreate }

  TfrmDBCreate = class(TForm)
    btnCreate: TButton;
    edtPassword: TEdit;
    edtUserName: TEdit;
    edtHost: TEdit;
    edtDatabaseName: TEdit;
    FBConnection: TIBConnection;
    lblPassword: TLabel;
    lblUserName: TLabel;
    lblHost: TLabel;
    lblDatabaseName: TLabel;
    procedure btnCreateClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmDBCreate: TfrmDBCreate;

implementation

{$R *.lfm}

{ TfrmDBCreate }

procedure TfrmDBCreate.btnCreateClick(Sender: TObject);
var Transaction : TSQLTransaction;
begin
  FBConnection.DatabaseName := edtDatabaseName.Text;
  FBConnection.CharSet      := 'UTF8';
  FBConnection.HostName     := edtHost.Text;
  FBConnection.UserName     := edtUserName.Text;
  FBConnection.Password     := edtPassword.Text;
  Transaction               := TSQLTransaction.Create(nil);
  FBConnection.Transaction  := Transaction;
  try
   FBConnection.CreateDB;
   FBConnection.ExecuteDirect('CREATE table test1 (name varchar(24) not null)');
   Transaction.Commit;
   MessageDlg('Info', 'The database was created.', mtInformation,
             [mbClose], -1);
  except
    on e : EIBDatabaseError do
     begin
       MessageDlg('Error', 'Could not create database : ' + LineEnding +
                  e.Message, mtError, [mbClose], -1);
     end;

     on e : Exception do
       begin
        MessageDlg('Error', 'Unknown error : ' + LineEnding + e.Message,
                 mtError, [mbClose], -1);
       end;
  end;
  Transaction.Free;
end;

end.

