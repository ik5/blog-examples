program exit_proc;

{$mode objfpc}{$H+}
uses sysutils;

procedure MyExitProc;
var Error : integer;
begin
  Error := GetLastOSError; // check to see if the OS reported an error to us
  if Error <> 0 then // I always knew OS's are evil ...
    begin
      Writeln('The operating system reports an error (#', Error,') : ',
            SysErrorMessage(Error));
    end
  else begin // No OS error, so you are not evil this time, yay !!!
    if ExitCode <> 0 then // But have we made some error ourselvs ?
      begin // yes :(
        write('The program had an Error : ');
        case ExitCode of
         200,  // from Runtime
         217 : // from Exception
               writeln('Divided by zero');
         203 : writeln('Out of memory');
         233 : writeln('You wanted to quite ...');
        else // Something we did unexpected
          writeln(ExitCode);
        end;

        writeln('Sorry ...');
       end
     else // No Error from our side, yay !
       writeln('I Hope to see you again soon.');
  end;
end;

var
 HowToExit        : Integer;
 tmpa, tmpb, tmpc : integer;

begin
 AddExitProc(@MyExitProc); // Register our exit procedure
 randomize;                // initializing the random "bank"
 if ParamCount = 1 then    // do we have *a* parameter that was given to us ?
  if not TryStrToInt(ParamStr(1), HowToExit) then  // lets evaluate it
    HowToExit := random(3); // Not a number :( you bustered

 tmpa := 1; tmpb := 0; // Don't allow the compiler to stop compiling ...

 Writeln('Hi there, how are you ?');
 writeln;

 try
   case HowToExit of
    0 : Halt;                   // Normal Exit
    1 : tmpc := tmpa div tmpb;  // Divided in Zero
    2 : Error(reOutOfMemory);   // Out of memory runtime error
    else
      Error(reQuit);            // Quit signal as a runtime error
   end;
 except // Lets capture some exceptions
        // Exception is the lowest exception class, every other exception must
        // inherit from it
   on e:Exception do // Lets see what are the exception we had
    begin
     // We are checking to see what is the e class
     if e is EDivByZero   then raise; // let the exitproc handle it ...

     // EOutOfMemory will not be raised, because it is a runtime error we
     // created, however if it was an exception, then
     if e is EOutOfMemory then raise; // let the exitproc handle it ...
    end;
 end;


end.

