{ Do what ever you want with this code except claim it your own ! }
program brute_force;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, untMain
  { you can add units after this };

begin
  Application.Title:='brute force';
  {$IF defined(RequireDerivedFormResource)}
  RequireDerivedFormResource := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

