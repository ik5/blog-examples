{ Do what ever you want with this code except claim it your own ! }
unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  JLabeledIntegerEdit;

type
  { TfrmMain }

  TfrmMain = class(TForm)
    btnStart: TButton;
    edtCounter: TEdit;
    lblCounterPrompt: TLabel;
    pass: TJLabeledIntegerEdit;
    procedure btnStartClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure passKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
    ToAbort : Boolean;
    procedure Counter(Data : PtrInt);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  edtCounter.Text          := '';
  ToAbort                  := False;
  btnStart.Enabled         := False;
  Application.QueueAsyncCall(@Counter,    // Do not block the main thread
                             pass.Value); // But do not create a new one ...
                                          // It's cross platform and not an OS
                                          // related such as PostMessage in
                                          // MS Windows
end;

procedure TfrmMain.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key = #27 then // If the user press on the Escape key
   ToAbort := MessageDlg('Question', 'Do you wish to abort ?',
                         mtConfirmation, mbYesNo, 0           ) = mrYes;
end;

procedure TfrmMain.passKeyPress(Sender: TObject; var Key: char);
begin
  if key = '-' then key := #0; // do not accept the minus sign
end;

procedure TfrmMain.Counter(Data: PtrInt);
var i, Delay       : Cardinal;
    Started, Ended : TDateTime;
    sum            : string;
begin
  frmMain.edtCounter.Color := clRed;
  Screen.Cursor            := crHourGlass;
  i                        := 0;
  Application.ProcessMessages; // Force the Red color and coursor change

  // Lets decide how long we want it to take according to number range
       if Data <= 9999    then Delay := 500 // 500 MS
  else if Data <= 999999  then Delay := 100 // 100 MS
  else if Data <= 9999999 then Delay := 10  //  10 MS
  else                         Delay := 1;  //   1 MS

  Started := Now;
  while (i < Data) and (not ToAbort) do // Stop only when we found the range or
   begin                                 // the user pressed on Escape
     inc(i); // i++
     frmMain.edtCounter.Text := IntToStr(i);
     Application.ProcessMessages; // Make sure that the message is processed now !
     SysUtils.Sleep(Delay);
   end;
  Ended := Now;

  sum := 'Started at ' + DateTimeToStr(Started) + LineEnding +
         'Ended at ' + DateTimeToStr(Ended);
  if i = pass.Value then begin // If we found the password ...
   frmMain.edtCounter.Color := clGreen;
   Application.ProcessMessages;
   ShowMessage('The password is: ' + IntToStr(i) + LineEnding + LineEnding + sum);
  end
  else ShowMessage('Could not find the password :('+ LineEnding + LineEnding +
                   sum);

  Screen.Cursor    := crDefault;
  btnStart.Enabled := True;
  Application.ProcessMessages; // Once again force messages ...
end;

end.

