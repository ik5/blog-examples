program signals;

{$IFDEF FPC}
 {$IFNDEF UNIX}
   {$ERROR This program can be compiled only on/for Unix/Linux based systems.}
 {$ENDIF}

 {$mode fpc}{$H+}
{$ENDIF}

uses
  BaseUnix;

var
  i : Byte;

procedure SignalCapture(signal : longint); cdecl;
begin
  i := 0;
  writeln;
  case signal of
    SIGHUP  : writeln('Reloading configuration ...');
    SIGINT  : writeln('^C - it''s not the way to stop me');
    SIGQUIT : begin
               writeln('Bye Bye ...');
               halt;
              end;
    SIGKILL : writeln('You can''t see me :(');
    SIGTerm : writeln('You can''t stop rock n'' roll');
    else
      writeln('Unknown signal: ', signal);
  end;
  writeln;
end;

procedure AddTrap(signal : longint);
var
  na, // store the new action
  oa  // store the old action
      : PSigActionRec;
begin
  new(na);
  new(oa);

  na^.sa_Handler := SigActionHandler(@SignalCapture);
  fillchar(na^.Sa_Mask,sizeof(na^.sa_mask),#0);
  na^.Sa_Flags := 0;
  {$ifdef Linux}               // Linux specific
    na^.Sa_Restorer := Nil;
  {$endif}
  if FPSigaction(signal, na, oa) <> 0 then
    begin
     if Signal <> SIGKILL then // ignore if SIGKILL
       begin
        writeln(stderr, 'Error: ', fpgeterrno, '.');
        halt(1);
       end;
    end;

  Dispose(na);
  Dispose(oa);
end;

begin
  //FpSignal(SIGHUP, @SignalCapture); // Old way to set a trap

  // Newer way to set a trap to this nasty signals :)
  AddTrap(SIGHUP);
  AddTrap(SIGINT);
  AddTrap(SIGQUIT);
  AddTrap(SIGTerm);
  AddTrap(SIGKILL);

  Writeln('You can send signal to my pid: ', FpGetpid);
  writeln;
  i := 0;

  while true do
   begin
     if i = 6 then
       begin
         writeln;
         i := 0;
       end;
     write('ZzZzZzZz... ');
     FpSleep(2);
     inc(i);
   end;
end.

