unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TALegendPanel, TASeries, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnAddItem: TButton;
    btnRemoveLastItem: TButton;
    btnApply: TButton;
    btnExport: TButton;
    Chart: TChart;
    ColorDialog: TColorDialog;
    pnlBottom: TPanel;
    SaveDialog: TSaveDialog;
    spltBottom: TSplitter;
    sgGraphDetails: TStringGrid;
    procedure btnAddItemClick(Sender: TObject);
    procedure btnRemoveLastItemClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgGraphDetailsButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure sgGraphDetailsColRowDeleted(Sender: TObject; IsColumn: Boolean;
      sIndex, tIndex: Integer);
    procedure sgGraphDetailsSetEditText(Sender: TObject; ACol, ARow: Integer;
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

procedure TForm1.btnAddItemClick(Sender: TObject);
begin
  sgGraphDetails.RowCount := sgGraphDetails.RowCount + 1;
  sgGraphDetails.Cells[0,sgGraphDetails.RowCount -1] := IntToStr(sgGraphDetails.RowCount -1);

end;

procedure TForm1.btnRemoveLastItemClick(Sender: TObject);
begin
  if sgGraphDetails.RowCount > 1 then
    sgGraphDetails.RowCount := sgGraphDetails.RowCount - 1;
end;

procedure TForm1.btnApplyClick(Sender: TObject);
var i    : integer;
    acol : TColor;
begin
  if not Assigned(pie) then initpie; // first time applying ...
  pie.Clear; // clear existing items
  for i := 1 to sgGraphDetails.RowCount -1 do
   begin
     with sgGraphDetails do
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

procedure TForm1.btnExportClick(Sender: TObject);
var fs : TFileStream;
    id : IChartDrawer;
begin
  // Does the user want to save an image of the chart ?
  if not SaveDialog.Execute then exit;

  case SaveDialog.FilterIndex of // lets see what type of image they want
    1 : Chart.SaveToBitmapFile(SaveDialog.FileName);                          // bitmap
    2 : Chart.SaveToFile(TJPEGImage, SaveDialog.FileName);                    // JPeg
    3 : Chart.SaveToFile(TPortableNetworkGraphic, SaveDialog.FileName);       // PNG - our default
    4 : Chart.SaveToFile(TPortableAnyMapGraphic, SaveDialog.FileName);        // PPM
    5 : Chart.SaveToFile(TPixmap, SaveDialog.FileName);                       // XPM
    6 : begin                                                                   // SVG
          fs := TFileStream.Create(SaveDialog.FileName, fmCreate);  //create a stream
          try
            id                       := TSVGDrawer.Create(fs,true);  // create an svg drawer
            id.DoChartColorToFPColor := @ChartColorSysToFPColor;     // set the default color chart of the system
            Chart.Draw(id, Rect(0,0, Chart.Width, Chart.Height)); // draw it to the canvas
          finally
            fs.Free; // free the file
          end;
        end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Add the '#' string to the first fixed item
  sgGraphDetails.Cells[0,0] := '#';
  // Disable Delete and Apply buttons. we do not have any content yet
  btnRemoveLastItem.Enabled        := sgGraphDetails.RowCount > 1;
  btnApply.Enabled        := sgGraphDetails.RowCount > 1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(pie) then
    FreeAndNil(pie);
end;

procedure TForm1.sgGraphDetailsButtonClick(Sender: TObject; aCol, aRow: Integer);
begin
  if (aRow >= 1) and (aCol = 3) then // are we at the last column ?
    begin
      if ColorDialog.Execute then // if the user selected a color, apply it
        begin
          sgGraphDetails.Cells[aCol, aRow] := ColorToString(ColorDialog.Color);
        end;
    end;
end;

procedure TForm1.sgGraphDetailsColRowDeleted(Sender: TObject; IsColumn: Boolean;
  sIndex, tIndex: Integer);
begin
  // Decide if we need to enable or not the delete and apply buttons ...
  Button2.Enabled := sgGraphDetails.RowCount > 1;
  btnApply.Enabled := sgGraphDetails.RowCount > 1;
end;

procedure TForm1.sgGraphDetailsSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var num : double;
begin
  // Check to see if we are working on the Percentage column and it has a value
  if (ACol = 2) and (Value <> '') then
    begin
      if not TryStrToFloat(Value, num) then // do we have a real floating point number ?
        begin
          sgGraphDetails.Cells[ACol, ARow] := ''; // do not save the value if not ...
        end;
    end;
end;

procedure TForm1.initpie;
begin
  Chart.ClearSeries; // remove any existed series
  pie          := TPieSeries.Create(Chart); // Create a pie series
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

  with Chart.Legend do // control the legend
   begin
     GroupTitles.Clear;
     GroupTitles.Add('Pie');
     Chart.AddSeries(pie); // add the series to the chart
   end;
end;

end.

