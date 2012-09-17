unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TALegendPanel, TASeries, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Chart1: TChart;
    ColorDialog1: TColorDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1ColRowDeleted(Sender: TObject; IsColumn: Boolean;
      sIndex, tIndex: Integer);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
  private
    { private declarations }
  public
    { public declarations }
    pie : TPieSeries;
    procedure initpie;
  end;

var
  Form1: TForm1;

implementation
uses TATextElements, TAChartUtils, TALegend, TADrawerSVG, TADrawUtils,
     TADrawerCanvas;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  StringGrid1.Cells[0,StringGrid1.RowCount -1] := IntToStr(StringGrid1.RowCount -1);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if StringGrid1.RowCount > 1 then
    StringGrid1.RowCount := StringGrid1.RowCount - 1;
end;

procedure TForm1.Button3Click(Sender: TObject);
var i    : integer;
    acol : TColor;
begin
  if not Assigned(pie) then initpie; // first time applying ...
  pie.Clear; // clear existing items
  for i := 1 to StringGrid1.RowCount -1 do
   begin
     with StringGrid1 do
      begin
        if Cells[2, i] = '' then continue; // empty field
        acol := clTAColor; // set color automatic
        if Cells[3, i] <> '' then // unless we choose one ...
          acol := StringToColor(Cells[3, i]);

        // Add the values
        pie.Add(StrToFloat(Cells[2, i]), Cells[1, i], acol);
      end;
   end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var fs : TFileStream;
    id : IChartDrawer;
begin
  // Does the user want to save an image of the chart ?
  if not SaveDialog1.Execute then exit;

  case SaveDialog1.FilterIndex of // lets see what type of image they want
    1 : Chart1.SaveToBitmapFile(SaveDialog1.FileName);                          // bitmap
    2 : Chart1.SaveToFile(TJPEGImage, SaveDialog1.FileName);                    // JPeg
    3 : Chart1.SaveToFile(TPortableNetworkGraphic, SaveDialog1.FileName);       // PNG - our default
    4 : Chart1.SaveToFile(TPortableAnyMapGraphic, SaveDialog1.FileName);        // PPM
    5 : Chart1.SaveToFile(TPixmap, SaveDialog1.FileName);                       // XPM
    6 : begin                                                                   // SVG
          fs := TFileStream.Create(SaveDialog1.FileName, fmCreate);  //create a stream
          try
            id                       := TSVGDrawer.Create(fs,true);  // create an svg drawer
            id.DoChartColorToFPColor := @ChartColorSysToFPColor;     // set the default color chart of the system
            Chart1.Draw(id, Rect(0,0, Chart1.Width, Chart1.Height)); // draw it to the canvas
          finally
            fs.Free; // free the file
          end;
        end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Add the '#' string to the first fixed item
  StringGrid1.Cells[0,0] := '#';
  // Disable Delete and Apply buttons. we do not have any content yet
  Button2.Enabled        := StringGrid1.RowCount > 1;
  Button3.Enabled        := StringGrid1.RowCount > 1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(pie) then
    FreeAndNil(pie);
end;

procedure TForm1.StringGrid1ButtonClick(Sender: TObject; aCol, aRow: Integer);
begin
  if (aRow >= 1) and (aCol = 3) then // are we at the last column ?
    begin
      if ColorDialog1.Execute then // if the user selected a color, apply it
        begin
          StringGrid1.Cells[aCol, aRow] := ColorToString(ColorDialog1.Color);
        end;
    end;
end;

procedure TForm1.StringGrid1ColRowDeleted(Sender: TObject; IsColumn: Boolean;
  sIndex, tIndex: Integer);
begin
  // Decide if we need to enable or not the delete and apply buttons ...
  Button2.Enabled := StringGrid1.RowCount > 1;
  Button3.Enabled := StringGrid1.RowCount > 1;
end;

procedure TForm1.StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var num : double;
begin
  // Check to see if we are working on the Percentage column and it has a value
  if (ACol = 2) and (Value <> '') then
    begin
      if not TryStrToFloat(Value, num) then // do we have a real floating point number ?
        begin
          StringGrid1.Cells[ACol, ARow] := ''; // do not save the value if not ...
        end;
    end;
end;

procedure TForm1.initpie;
begin
  Chart1.ClearSeries; // remove any existed series
  pie          := TPieSeries.Create(Chart1); // Create a pie series
  pie.Title    := 'Pie Chart'; // Give it a name
  pie.Exploded := False; // don't allow each part to be apart from the pie
  with pie.Legend do
   begin
     Multiplicity := lmPoint; // we are working on the point
     Format       := '%2:s (%1:.2f%%)'; // the label should be printed as name (Percentage)
     GroupIndex   := 0; // add it under the "pie" group of the Chart
   end;

  with Pie.Marks do
   begin
     LabelBrush.Color  := $80FFFF; // Brash color for the label
     LinkPen.Width     := 2;
     Style             := smsLabelPercent; // Display both name and Percentage
     OverlapPolicy     := opHideNeighbour; // do not display overlay elements
     Visible           := true;
   end;

  with Chart1.Legend do // control the legend
   begin
     GroupTitles.Clear;
     GroupTitles.Add('Pie');
     Chart1.AddSeries(pie); // add the series to the chart
   end;
end;

end.

