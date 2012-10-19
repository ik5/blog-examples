unit Unit1; 
// Based on http://wiki.lazarus.freepascal.org/VirtualTreeview_Example_for_Lazarus
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, VirtualTrees;

type

  { TfrmMain }

  TfrmMain = class ( TForm )
    btnAddRoot : TButton;
    btnAddChild : TButton;
    btnDelete : TButton;
    pnlBottom : TPanel;
    VST : TVirtualStringTree;
    procedure btnAddRootClick ( Sender : TObject ) ;
    procedure btnAddChildClick ( Sender : TObject ) ;
    procedure btnDeleteClick ( Sender : TObject ) ;
    procedure FormCreate ( Sender : TObject ) ;
    procedure VSTChange ( Sender : TBaseVirtualTree; Node : PVirtualNode ) ;
    procedure VSTFocusChanged ( Sender : TBaseVirtualTree; Node : PVirtualNode;
      Column : TColumnIndex ) ;
    procedure VSTFreeNode ( Sender : TBaseVirtualTree; Node : PVirtualNode ) ;
    procedure VSTGetNodeDataSize ( Sender : TBaseVirtualTree;
      var NodeDataSize : Integer ) ;
    procedure VSTGetText ( Sender : TBaseVirtualTree; Node : PVirtualNode;
      Column : TColumnIndex; TextType : TVSTTextType; var CellText : String
      ) ;
    procedure VSTNewText ( Sender : TBaseVirtualTree; Node : PVirtualNode;
      Column : TColumnIndex; NewText : String ) ;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmMain : TfrmMain;

implementation
uses LCLProc;

{$R *.lfm}

type
  PTreeData = ^TTreeData;
  TTreeData = record
    Column1,
    Column2,
    Column3  : String;
  end;

{ TfrmMain }

procedure TfrmMain.FormCreate ( Sender : TObject ) ;
var
  Column : TVirtualTreeColumn;
  i      : integer;
begin
  Randomize;
  VST.Header.Options := VST.Header.Options +[hoVisible];
  VST.Header.Style   := hsFlatButtons;
  for i := 1 to 3 do
    begin
     Column         := VST.Header.Columns.Add;
     Column.Text    := 'column #' + IntToStr(i);
     Column.Options := Column.Options + [coAllowClick, coResizable];
     Column.Width   := UTF8Length(Column.Text) + 100;
    end;

  VST.TreeOptions.MiscOptions      := VST.TreeOptions.MiscOptions +
                                       [toEditable,toGridExtensions];
  VST.TreeOptions.SelectionOptions := VST.TreeOptions.SelectionOptions +
                                       [toExtendedFocus, toMultiSelect];

end;

procedure TfrmMain.btnAddRootClick ( Sender : TObject ) ;
Var
  Data  : PTreeData;
  XNode : PVirtualNode;
  Rand  : Integer;
begin
  Rand  := Random(99);
  XNode := VST.AddChild(nil);

  if VST.AbsoluteIndex(XNode) > -1 then
  Begin
   Data := VST.GetNodeData(XNode);
   Data^.Column1 := 'One ' + IntToStr(Rand);
   Data^.Column2 := 'Two ' + IntToStr(Rand + 10);
   Data^.Column3 := 'Three ' + IntToStr(Rand - 5);
  End;

end;

procedure TfrmMain.btnAddChildClick ( Sender : TObject ) ;
var
  XNode : PVirtualNode;
  Data  : PTreeData;

begin
  if not Assigned(VST.FocusedNode) then
    exit;

  XNode := VST.AddChild(VST.FocusedNode);
  Data  := VST.GetNodeData(Xnode);

  Data^.Column1 := 'Ch 1';
  Data^.Column2 := 'Ch 2';
  Data^.Column3 := 'Ch 3';

 VST.Expanded[VST.FocusedNode] := True;

end;

procedure TfrmMain.btnDeleteClick ( Sender : TObject ) ;
begin
  VST.DeleteSelectedNodes;
end;

procedure TfrmMain.VSTChange ( Sender : TBaseVirtualTree; Node : PVirtualNode ) ;
begin
  VST.Refresh;
end;

procedure TfrmMain.VSTFocusChanged ( Sender : TBaseVirtualTree;
  Node : PVirtualNode; Column : TColumnIndex ) ;
begin
  VST.Refresh;
end;

procedure TfrmMain.VSTFreeNode ( Sender : TBaseVirtualTree; Node : PVirtualNode
  ) ;
var
  Data : PTreeData;
begin
  Data := VST.GetNodeData(Node);
  if Assigned(Data) then
    begin
      Data^.Column1 := '';
      Data^.Column2 := '';
      Data^.Column3 := '';
    end;
end;

procedure TfrmMain.VSTGetNodeDataSize ( Sender : TBaseVirtualTree;
  var NodeDataSize : Integer ) ;
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TfrmMain.VSTGetText ( Sender : TBaseVirtualTree; Node : PVirtualNode;
  Column : TColumnIndex; TextType : TVSTTextType; var CellText : String ) ;
var
  Data : PTreeData;
begin
  Data := VST.GetNodeData(Node);
  case Column of
    0 : CellText := Data^.Column1;
    1 : CellText := Data^.Column2;
    2 : CellText := Data^.Column3;
  end;
end;

procedure TfrmMain.VSTNewText ( Sender : TBaseVirtualTree; Node : PVirtualNode;
  Column : TColumnIndex; NewText : String ) ;
var
  Data : PTreeData;
begin
  Data := VST.GetNodeData(Node);
  case Column of
    0 : Data^.Column1 := NewText;
    1 : Data^.Column2 := NewText;
    2 : Data^.Column3 := NewText;
  end;
end;

end.

