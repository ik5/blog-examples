unit unitBlog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function life_universe_and_everyting : byte;
procedure raise_exception;

implementation

function life_universe_and_everyting: byte;
begin
  Result := 42;
end;

procedure raise_exception;
begin
  raise EInOutError.create('Do not access any I/O');
end;

end.

