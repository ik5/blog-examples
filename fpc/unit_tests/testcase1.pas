unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TBlogExampleTestUnit }

  TBlogExampleTestUnit= class(TTestCase)
  published
    procedure TestLifeUniverseAndEverything;
    procedure TestRaiseException;
  end;

implementation
uses unitBlog;

resourcestring
  errInvalidValue      = 'The value %d is invalid, expected %d';
  errNoException       = 'No Exception was raised';

{ TBlogExampleTestUnit }

procedure TBlogExampleTestUnit.TestLifeUniverseAndEverything;
var Value, expected : Byte;
begin
  Value    := life_universe_and_everyting;
  expected := 42;
  AssertEquals(Format(errInvalidValue, [Value, expected]), expected, Value);
end;

procedure TBlogExampleTestUnit.TestRaiseException;
begin
  try
    raise_exception;
    Fail(errNoException);
  except
    on e: Exception do
      begin
        CheckEquals('EInOutError', e.ClassName);
      end;
  end;
end;

initialization

  RegisterTest(TBlogExampleTestUnit);
end.

