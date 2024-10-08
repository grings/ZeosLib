{*********************************************************}
{                                                         }
{                 Zeos Database Objects                   }
{               UpdateSql property editor                 }
{                                                         }
{        Originally written by Janos Fegyverneki          }
{                                                         }
{*********************************************************}

{@********************************************************}
{    Copyright (c) 1999-2020 Zeos Development Group       }
{                                                         }
{ License Agreement:                                      }
{                                                         }
{ This library is distributed in the hope that it will be }
{ useful, but WITHOUT ANY WARRANTY; without even the      }
{ implied warranty of MERCHANTABILITY or FITNESS FOR      }
{ A PARTICULAR PURPOSE.  See the GNU Lesser General       }
{ Public License for more details.                        }
{                                                         }
{ The source code of the ZEOS Libraries and packages are  }
{ distributed under the Library GNU General Public        }
{ License (see the file COPYING / COPYING.ZEOS)           }
{ with the following  modification:                       }
{ As a special exception, the copyright holders of this   }
{ library give you permission to link this library with   }
{ independent modules to produce an executable,           }
{ regardless of the license terms of these independent    }
{ modules, and to copy and distribute the resulting       }
{ executable under terms of your choice, provided that    }
{ you also meet, for each linked independent module,      }
{ the terms and conditions of the license of that module. }
{ An independent module is a module which is not derived  }
{ from or based on this library. If you modify this       }
{ library, you may extend this exception to your version  }
{ of the library, but you are not obligated to do so.     }
{ If you do not wish to do so, delete this exception      }
{ statement from your version.                            }
{                                                         }
{                                                         }
{ The project web site is located on:                     }
{   https://zeoslib.sourceforge.io/ (FORUM)               }
{   http://sourceforge.net/p/zeoslib/tickets/ (BUGTRACKER)}
{   svn://svn.code.sf.net/p/zeoslib/code-0/trunk (SVN)    }
{                                                         }
{   http://www.sourceforge.net/projects/zeoslib.          }
{                                                         }
{                                                         }
{                                 Zeos Development Group. }
{********************************************************@}

unit ZUpdateSqlEditor;

interface

{$I ZComponent.inc}

uses
{$IFNDEF FPC}
  DesignEditors,
{$ELSE}
  PropEdits, Buttons, ComponentEditors,
{$ENDIF}
  Forms, DB, ExtCtrls, StdCtrls, Controls, ComCtrls,
  Classes, SysUtils, {$IFNDEF FPC}Windows, {$ELSE}LCLIntf, LResources, {$ENDIF}
  Menus, ZAbstractDataset,
{$IFDEF UNIX}
  {$IFNDEF FPC}
    QMenus, QTypes, QExtCtrls, QStdCtrls, QControls, QComCtrls,
  {$ENDIF}
{$ENDIF}
  ZSqlUpdate;

type

  TWaitMethod = procedure of object;

  TZProtectedAbstractRWTxnUpdateObjDataSet = Class(TZAbstractRWTxnUpdateObjDataSet);

  { TZUpdateSQLEditForm }

  TZUpdateSQLEditForm = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GenerateButton: TButton;
    Panel1: TPanel;
    PrimaryKeyButton: TButton;
    DefaultButton: TButton;
    UpdateTableName: TComboBox;
    FieldsPage: TTabSheet;
    SQLPage: TTabSheet;
    PageControl: TPageControl;
    KeyFieldList: TListBox;
    UpdateFieldList: TListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    SQLMemo: TMemo;
    StatementType: TRadioGroup;
    QuoteFields: TCheckBox;
    GetTableFieldsButton: TButton;
    FieldListPopup: TPopupMenu;
    miSelectAll: TMenuItem;
    miClearAll: TMenuItem;
    OkButton: TButton;
    CancelButton: TButton;
    HelpButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure StatementTypeClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure DefaultButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure PrimaryKeyButtonClick(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure GetTableFieldsButtonClick(Sender: TObject);
    procedure SettingsChanged(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure UpdateTableNameChange(Sender: TObject);
    procedure UpdateTableNameClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure ClearAllClick(Sender: TObject);
    procedure SQLMemoKeyPress(Sender: TObject; var Key: Char);
  private
    StmtIndex: Integer;
    DataSet: TZProtectedAbstractRWTxnUpdateObjDataSet;
    QuoteChar: string;
    ConnectionOpened: Boolean;
    UpdateSQL: TZUpdateSQL;
    FSettingsChanged: Boolean;
    FDatasetDefaults: Boolean;
    SQLText: array[TUpdateKind] of TStrings;
    function QuoteIfChecked(const Ident: string): string;
    function GetTableRef(const TabName: string): string;
    function Edit: Boolean;
    procedure GenWhereClause(const TabAlias: string; KeyFields, SQL: TStrings);
    procedure GenDeleteSQL(const TableName: string; KeyFields, SQL: TStrings);
    procedure GenInsertSQL(const TableName: string; UpdateFields, SQL: TStrings);
    procedure GenModifySQL(const TableName: string; KeyFields, UpdateFields,
      SQL: TStrings);
    procedure GenerateSQL;
    procedure GetDataSetFieldNames;
    procedure GetTableFieldNames;
    procedure InitGenerateOptions;
    procedure InitUpdateTableNames;
    procedure SetButtonStates;
    procedure SelectPrimaryKeyFields;
    procedure SetDefaultSelections;
    procedure ShowWait(WaitMethod: TWaitMethod);
  end;

{ TSQLParser }

  TSQLToken = (stSymbol, stAlias, stNumber, stComma, stEQ, stOther, stLParen,
    stRParen, stEnd, stSemiColon);

  TSQLParser = class
  private
    FText: string;
    FSourcePtr: PChar;
    FTokenPtr: PChar;
    FTokenString: string;
    FToken: TSQLToken;
    FSymbolQuoted: Boolean;
    FQuoteString: string;
    function NextToken: TSQLToken;
    function TokenSymbolIs(const S: string): Boolean;
    procedure Reset;
  public
    constructor Create(const Text, QuoteString: string);
    procedure GetSelectTableNames(List: TStrings);
    procedure GetUpdateTableName(var TableName: string);
    procedure GetUpdateFields(List: TStrings);
    procedure GetWhereFields(List: TStrings);
  end;

  TZUpdateSqlEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure Edit; override;
  end;

function EditUpdateSQL(AZUpdateSQL: TZUpdateSQL): Boolean;

resourcestring
  SSQLDataSetOpen = 'Unable to determine field names for %s';
  SNoDataSet = 'No dataset association';
  SSQLGenSelect = 'Must select at least one key field and one update field';
  SSQLNotGenerated = 'Update SQL statements not generated, exit anyway?';

implementation

{$IFNDEF FPC}
{$R *.dfm}
{$ENDIF}

uses Dialogs, {$IFNDEF FPC}LibHelp, {$ENDIF}TypInfo, ZCompatibility, ZSqlMetadata,
  ZDbcIntfs, ZTokenizer, ZGenericSqlAnalyser, ZSelectSchema, ZDbcMetadata, ZExceptions;

{ TZUpdateSqlEditor }

procedure TZUpdateSqlEditor.ExecuteVerb(Index: Integer);
begin
  if Index = 0 then
    EditUpdateSQL(TZUpdateSQL(Component));
end;

{$IFDEF FPC} {$PUSH} {$WARN 5024 off : Parameter "Index" not used} {$ENDIF}
function TZUpdateSqlEditor.GetVerb(Index: Integer): string;
begin
  Result := 'UpdateSql editor...';
end;
{$IFDEF FPC} {$POP} {$ENDIF}

function TZUpdateSqlEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TZUpdateSqlEditor.Edit;
begin
  if EditUpdateSQL(TZUpdateSQL(Component)) then
    Designer.Modified;
end;

{ Global Interface functions }

function EditUpdateSQL(AZUpdateSQL: TZUpdateSQL): Boolean;
begin
  with TZUpdateSQLEditForm.Create(Application) do
  try
    UpdateSQL := AZUpdateSQL;
    Result := Edit;
  finally
    Free;
  end;
end;

{ Utility Routines }

procedure GetSelectedItems(ListBox: TListBox; List: TStrings);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to ListBox.Items.Count - 1 do
    if ListBox.Selected[I] then
      List.AddObject(ListBox.Items[I], ListBox.Items.Objects[I]);
end;

function SetSelectedItems(ListBox: TListBox; List: TStrings): Integer;
var
  I: Integer;
begin
  Result := 0;
  ListBox.Items.BeginUpdate;
  try
    for I := 0 to ListBox.Items.Count - 1 do
      if List.IndexOf(ListBox.Items[I]) > -1 then
      begin
        ListBox.Selected[I] := True;
        Inc(Result);
      end
      else
        ListBox.Selected[I] := False;
    if ListBox.Items.Count > 0 then
      ListBox.TopIndex := 0;
  finally
    ListBox.Items.EndUpdate;
  end;
end;

procedure SelectAll(ListBox: TListBox);
var
  I: Integer;
begin
  ListBox.Items.BeginUpdate;
  try
    ListBox.SelectAll;

    if ListBox.Items.Count > 0 then
      ListBox.TopIndex := 0;
  finally
    ListBox.Items.EndUpdate;
  end;
end;

procedure GetDataKeyNames(Dataset: TDataset; const ErrorName: string; List: TStrings);
var
  I: Integer;
begin
  with Dataset do
  try
    FieldDefs.Update;
    List.BeginUpdate;
    try
      List.Clear;
      for I := 0 to FieldDefs.Count - 1 do
      {$IFNDEF FPC}
        if not (FieldDefs[I].DataType in [Low(TBlobType)..High(TBlobType)]) then
      {$ELSE}
        if not (FieldDefs[I].DataType in [ftBlob..ftTypedBinary]) then
      {$ENDIF}
          List.AddObject(FieldDefs[I].Name, {%H-}Pointer(Ord(not FieldDefs[I].Required)));
    finally
      List.EndUpdate;
    end;
  except
    if ErrorName <> '' then
      MessageDlg(Format(SSQLDataSetOpen, [ErrorName]), mtError, [mbOK], 0);
  end;
end;

procedure GetDataFieldNames(Dataset: TDataset; const ErrorName: string; List: TStrings);
var
  I: Integer;
begin
  with Dataset do
  try
    FieldDefs.Update;
    List.BeginUpdate;
    try
      List.Clear;
      for I := 0 to FieldDefs.Count - 1 do
        List.AddObject(FieldDefs[I].Name, {%H-}Pointer(not FieldDefs[I].Required));
    finally
      List.EndUpdate;
    end;
  except
    if ErrorName <> '' then
      MessageDlg(Format(SSQLDataSetOpen, [ErrorName]), mtError, [mbOK], 0);
  end;
end;

procedure ParseUpdateSQL(const SQL, QuoteString: string; var TableName: string;
  UpdateFields: TStrings; WhereFields: TStrings);
begin
  with TSQLParser.Create(SQL, QuoteString) do
  try
    GetUpdateTableName(TableName);
    if Assigned(UpdateFields) then
    begin
      Reset;
      GetUpdateFields(UpdateFields);
    end;
    if Assigned(WhereFields) then
    begin
      Reset;
      GetWhereFields(WhereFields);
    end;
  finally
    Free;
  end;
end;

{ TSQLParser }

constructor TSQLParser.Create(const Text, QuoteString: string);
begin
  FText := Text;
  FSourcePtr := PChar(Text);
  FQuoteString := QuoteString;
  if FQuoteString = '' then
    FQuoteString := '""';
  if Length(FQuoteString) = 1 then
    FQuoteString := FQuoteString + FQuoteString;
  NextToken;
end;

function TSQLParser.NextToken: TSQLToken;
var
  P, P2, TokenStart: PChar;
  IsParam: Boolean;

  {$IFNDEF FPC}
  function IsKatakana(const Chr: Byte): Boolean;
  begin
    Result := (SysLocale.PriLangID = LANG_JAPANESE) and (Chr in [$A1..$DF]);
  end;
  {$ENDIF}

begin
  if FToken = stEnd then SysUtils.Abort;
  FTokenString := '';
  FSymbolQuoted := False;
  P := FSourcePtr;
  while (P^ <> #0) and (P^ <= ' ') do Inc(P);
  FTokenPtr := P;
  case P^ of
    'A'..'Z', 'a'..'z', '_', '$', #127..#255:
      begin
        TokenStart := P;
        if not SysLocale.FarEast then
        begin
          Inc(P);
          while CharInSet(P^, ['A'..'Z', 'a'..'z', '0'..'9', '_', '"', '$', #127..#255] ) do Inc(P);
          if P^ = '.' then Inc(P);//!!! This must be added for syslocale fareast also
        end
        else
          begin
            while TRUE do
            begin
              if CharInSet(P^, ['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '"', '$']) or
                 {$IFNDEF FPC}IsKatakana(Byte(P^)){$ELSE}False{$ENDIF} then
                Inc(P)
              else
                if CharInSet(P^, LeadBytes) then
                  Inc(P, 2)
                else
                  Break;
            end;
          end;
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := stSymbol;
      end;
    '-', '0'..'9':
      begin
        TokenStart := P;
        Inc(P);
        while CharInSet(P^, ['0'..'9', '.', 'e', 'E', '+', '-'] )do Inc(P);
        SetString(FTokenString, TokenStart, P - TokenStart);
        FToken := stNumber;
      end;
    ',':
      begin
        Inc(P);
        FToken := stComma;
      end;
    ';':
      begin
        Inc(P);
        FToken := stSemiColon;
      end;
    '=':
      begin
        Inc(P);
        FToken := stEQ;
      end;
    '(':
      begin
        Inc(P);
        FToken := stLParen;
      end;
    ')':
      begin
        Inc(P);
        FToken := stRParen;
      end;
    #0:
      FToken := stEnd;
  else begin
      P2 := Pointer(FQuoteString);
      if P^ = P2^ then
      begin
        Inc(P);
        IsParam := P^ = ':';
        if IsParam then Inc(P);
        TokenStart := P;
        while not CharInSet(P^, [(P2+1)^, #0]) do Inc(P);
        SetString(FTokenString, TokenStart, P - TokenStart);
        Inc(P);
        if P^ = '.' then begin
          FTokenString := FTokenString + '.';
          Inc(P);
        end;
        Trim(FTokenString);
        FToken := stSymbol;
        FSymbolQuoted := True;
      end else begin
        FToken := stOther;
        Inc(P);
      end;
    end;
  end;
  FSourcePtr := P;
  P2 := Pointer(FTokenString);
  if (FToken = stSymbol) and ((P2+Length(FTokenString)-1)^ = '.') then
    FToken := stAlias;
  Result := FToken;
end;

procedure TSQLParser.Reset;
begin
  FSourcePtr := PChar(FText);
  FToken := stSymbol;
  NextToken;
end;

function TSQLParser.TokenSymbolIs(const S: string): Boolean;
begin
  Result := (FToken = stSymbol) and (CompareText(FTokenString, S) = 0);
end;

procedure TSQLParser.GetSelectTableNames(List: TStrings);
begin
  List.BeginUpdate;
  try
    List.Clear;
    if TokenSymbolIs('SELECT') then { Do not localize }
    try
      while not TokenSymbolIs('FROM') do NextToken; { Do not localize }
      NextToken;
      while FToken = stSymbol do
      begin
        List.AddObject(FTokenString, {%H-}Pointer(Integer(FSymbolQuoted)));
        if NextToken = stSymbol then NextToken;
        if FToken = stComma then NextToken
        else break;
      end;
    except
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TSQLParser.GetUpdateTableName(var TableName: string);
begin
  if TokenSymbolIs('UPDATE') and (NextToken = stSymbol) then { Do not localize }
    TableName := FTokenString else
    TableName := '';
end;

procedure TSQLParser.GetUpdateFields(List: TStrings);
begin
  List.BeginUpdate;
  try
    List.Clear;
    if TokenSymbolIs('UPDATE') then { Do not localize }
    try
      while not TokenSymbolIs('SET') do NextToken; { Do not localize }
      NextToken;
      while True do
      begin
        if FToken = stAlias then NextToken;
        if FToken <> stSymbol then Break;
        List.Add(FTokenString);
        if NextToken <> stEQ then Break;
        while NextToken <> stComma do
          if TokenSymbolIs('WHERE') or TokenSymbolIs('UPDATE') then Exit;{ Do not localize }
        NextToken;
      end;
    except
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TSQLParser.GetWhereFields(List: TStrings);
begin
  List.BeginUpdate;
  try
    List.Clear;
    if TokenSymbolIs('UPDATE') then { Do not localize }
    try
      while not TokenSymbolIs('WHERE') do NextToken; { Do not localize }
      NextToken;
      while True do
      begin
        while FToken in [stLParen, stRParen, stAlias, stOther] do NextToken;
        if FToken <> stSymbol then Break;
        List.Add(FTokenString);
        NextToken;
        if (FToken <> stEQ) and not TokenSymbolIs('IS') then Break;
        while true do
        begin
          NextToken;
          if FToken in [stEnd, stSemiColon] then Exit; //!!!!stSemiColon should be the statement separator
          if TokenSymbolIs('AND') then Break; { Do not localize }
        end;
        NextToken;
      end;
    except
    end;
  finally
    List.EndUpdate;
  end;
end;

{ TUpdateSQLEditor }

{ Private Methods }

function TZUpdateSQLEditForm.Edit: Boolean;
var
  Index: TUpdateKind;
  DataSetName: string;
begin
  Result := False;
  ConnectionOpened := False;
  if Assigned(UpdateSQL.DataSet) and (UpdateSQL.DataSet is TZAbstractRWTxnUpdateObjDataSet) then
  begin
    DataSet := TZProtectedAbstractRWTxnUpdateObjDataSet(UpdateSQL.DataSet);
    DataSetName := Format('%s%s%s', [DataSet.Owner.Name, DotSep, DataSet.Name]);
    if Assigned(DataSet.Connection) and not DataSet.Connection.Connected then
    begin
      DataSet.Connection.Connect;
      ConnectionOpened := True;
    end;
  end else
    DataSetName := SNoDataSet;
  Caption := Format('%s%s%s (%s)', [UpdateSQL.Owner.Name, DotSep, UpdateSQL.Name, DataSetName]);
  try
    for Index := Low(TUpdateKind) to High(TUpdateKind) do
    begin
      SQLText[Index] := TStringList.Create;
      SQLText[Index].Assign(UpdateSQL.SQL[Index]);
    end;
    StatementType.ItemIndex := 0;
    StatementTypeClick(Self);
    InitUpdateTableNames;
    ShowWait(InitGenerateOptions);
    PageControl.ActivePage := PageControl.Pages[0];
    if ShowModal = mrOk then
    begin
      for Index := low(TUpdateKind) to high(TUpdateKind) do
        if UpdateSQL.SQL[Index].Text <> SQLText[Index].Text then
        begin
          UpdateSQL.SQL[Index] := SQLText[Index];
          Result := True;
        end;
    end;
  finally
    for Index := Low(TUpdateKind) to High(TUpdateKind) do
      SQLText[Index].Free;
  end;
end;

procedure TZUpdateSQLEditForm.GenWhereClause(const TabAlias: string;
  KeyFields, SQL: TStrings);
var
  I: Integer;
  BindText: string;
  FieldName: string;
  OldFieldName: string;
begin
  SQL.Add('WHERE'); { Do not localize }
  for I := 0 to KeyFields.Count - 1 do
  begin
    FieldName := QuoteIfChecked(KeyFields[I]);
    OldFieldName := 'OLD_' + FieldName;
    if not Assigned(KeyFields.Objects[I]) then
      BindText := Format('  %s%s = :%s', { Do not localize }
        [TabAlias, FieldName, OldFieldName])
    else
      BindText := Format('  ((%0:s%1:s IS NULL AND :%2:s IS NULL) OR (%0:s%1:s = :%2:s))', { Do not localize }
        [TabAlias, FieldName, OldFieldName]);
    if I < KeyFields.Count - 1 then
      BindText := Format('%s AND',[BindText]); { Do not localize }
    SQL.Add(BindText);
  end;
end;

procedure TZUpdateSQLEditForm.GenDeleteSQL(const TableName: string;
  KeyFields, SQL: TStrings);
begin
  SQL.Add(Format('DELETE FROM %s', [TableName])); { Do not localize }
  GenWhereClause(GetTableRef(TableName), KeyFields, SQL);
end;

procedure TZUpdateSQLEditForm.GenInsertSQL(const TableName: string;
  UpdateFields, SQL: TStrings);

  {$IFDEF FPC} {$PUSH} {$WARN 5024 off : Parameter "Index" not used} {$ENDIF}
  procedure GenFieldList(const TabName, ParamChar: String);
  var
    L: string;
    I: integer;
    Comma: string;
    FieldName: string;
  begin
    L := '  (';
    Comma := ', ';
    for I := 0 to UpdateFields.Count - 1 do
    begin
      if I = UpdateFields.Count - 1 then Comma := '';
      FieldName := UpdateFields[I];
      if ParamChar = '' then
        FieldName := QuoteIfChecked(FieldName);
      L := Format('%s%s%s%s',[L, ParamChar, FieldName, Comma]);
      if (Length(L) > 70) and (I <> UpdateFields.Count - 1) then
      begin
        SQL.Add(L);
        L := '   ';
      end;
    end;
    SQL.Add(L+')');
  end;
  {$IFDEF FPC} {$POP} {$ENDIF}
begin
  SQL.Add(Format('INSERT INTO %s', [TableName])); { Do not localize }
  GenFieldList(GetTableRef(TableName), '');
  SQL.Add('VALUES'); { Do not localize }
  GenFieldList('', ':');
end;

procedure TZUpdateSQLEditForm.GenModifySQL(const TableName: string;
  KeyFields, UpdateFields, SQL: TStrings);
var
  I: integer;
  Comma: string;
  TableRef: string;
  FieldName: string;
begin
  SQL.Add(Format('UPDATE %s SET', [TableName]));  { Do not localize }
  Comma := ',';
  TableRef := GetTableRef(TableName);
  for I := 0 to UpdateFields.Count - 1 do
  begin
    if I = UpdateFields.Count -1 then Comma := '';
    FieldName := QuoteIfChecked(UpdateFields[I]);
    SQL.Add(Format('  %s = :%s%s',
      [FieldName, UpdateFields[I], Comma]));
  end;
  GenWhereClause(TableRef, KeyFields, SQL);
end;

procedure TZUpdateSQLEditForm.GenerateSQL;
var
  KeyFields: TStringList;
  UpdateFields: TStringList;
  TableName: string;
begin
  if (KeyFieldList.SelCount = 0) or (UpdateFieldList.SelCount = 0) then
    raise EZSQLException.Create(SSQLGenSelect);
  KeyFields := TStringList.Create;
  try
    GetSelectedItems(KeyFieldList, KeyFields);
    UpdateFields := TStringList.Create;
    try
      GetSelectedItems(UpdateFieldList, UpdateFields);
      TableName := QuoteIfChecked(UpdateTableName.Text);
      if (SQLText[ukDelete].Text <> '') or (SQLText[ukInsert].Text <> '') or (SQLText[ukModify].Text <> '') then
        if MessageDlg('The SQL property is not empty. Do you want to clear it before the generation?', mtWarning, [mbYes, mbNo], 0) = mrYes then
        begin
          SQLText[ukDelete].Clear;
          SQLText[ukInsert].Clear;
          SQLText[ukModify].Clear;
        end
        else
        begin
          SQLText[ukDelete].Text := SQLText[ukDelete].Text + '';//!!!Statement separator should be added
          SQLText[ukDelete].Add('');
          SQLText[ukInsert].Text := SQLText[ukInsert].Text + '';//!!!Statement separator should be added
          SQLText[ukInsert].Add('');
          SQLText[ukModify].Text := SQLText[ukModify].Text + '';//!!!Statement separator should be added
          SQLText[ukModify].Add('');
        end;
      GenDeleteSQL(TableName, KeyFields, SQLText[ukDelete]);
      GenInsertSQL(TableName, UpdateFields, SQLText[ukInsert]);
      GenModifySQL(TableName, KeyFields, UpdateFields,
        SQLText[ukModify]);
      SQLMemo.Modified := False;
      StatementTypeClick(Self);
      PageControl.SelectNextPage(True);
    finally
      UpdateFields.Free;
    end;
  finally
    KeyFields.Free;
  end;
end;

procedure TZUpdateSQLEditForm.GetDataSetFieldNames;
begin
  if Assigned(DataSet) and Assigned(Dataset.Connection) then
  begin
    GetDataKeyNames(DataSet, DataSet.Name, KeyFieldList.Items);
    GetDataFieldNames(DataSet, DataSet.Name, UpdateFieldList.Items);
  end;
end;

procedure TZUpdateSQLEditForm.GetTableFieldNames;
var
  ResultSet: IZResultSet;
  MetaData: IZDatabaseMetadata;
begin
  if Assigned(DataSet) and Assigned(DataSet.Connection) and Assigned(DataSet.Connection.dbcConnection)then
  begin
    KeyFieldList.Clear;
    UpdateFieldList.Clear;
    MetaData := DataSet.Connection.DbcConnection.GetMetadata;
    ResultSet := MetaData.GetColumns('', '', MetaData.AddEscapeCharToWildcards(UpdateTableName.Text), '');
    if Assigned(ResultSet) then
    begin
      while ResultSet.Next do
      begin
        if ResultSet.GetBooleanByName('SEARCHABLE') then
          KeyFieldList.Items.AddObject(ResultSet.GetStringByName('COLUMN_NAME'), {%H-}Pointer(ResultSet.GetIntByName('NULLABLE') <> 0));
        if ResultSet.GetBooleanByName('WRITABLE') then
          UpdateFieldList.Items.Add(ResultSet.GetStringByName('COLUMN_NAME')) ;
      end;
    end;
    FDatasetDefaults := False;
  end;
end;

function TZUpdateSQLEditForm.QuoteIfChecked(const Ident: string): string;
var P: PChar;
begin
  Result := Ident;
  if QuoteFields.Checked then begin
    P := Pointer(QuoteChar);
    case Length(QuoteChar) of
      1: Result := P^ + Result + P^;
      2: Result := P^ + Result + (P+1)^;
    end;
  end;
end;

function TZUpdateSQLEditForm.GetTableRef(const TabName: string): string;
begin
  if QuoteChar <> '' then
    Result :=  TabName + '.' else
    REsult := '';
end;

procedure TZUpdateSQLEditForm.InitGenerateOptions;
var
  UpdTabName: string;

  procedure InitFromDataSet;
  begin
    // If this is a Query with more than 1 table in the "from" clause then
    //  initialize the list of fields from the table rather than the dataset.
    if (UpdateTableName.Items.Count > 1) then
      GetTableFieldNames
    else
    begin
      GetDataSetFieldNames;
      FDatasetDefaults := True;
    end;
    SetDefaultSelections;
  end;

  procedure InitFromUpdateSQL;
  var
    UpdFields,
    WhFields: TStrings;
  begin
    UpdFields := TStringList.Create;
    try
      WhFields := TStringList.Create;
      try
        ParseUpdateSQL(SQLText[ukModify].Text, QuoteChar, UpdTabName, UpdFields, WhFields);
        GetDataSetFieldNames;
        if SetSelectedItems(UpdateFieldList, UpdFields) < 1 then
          SelectAll(UpdateFieldList);
        if SetSelectedItems(KeyFieldList, WhFields) < 1 then
          SelectAll(KeyFieldList);
      finally
        WhFields.Free;
      end;
    finally
      UpdFields.Free;
    end;
  end;

begin
  // If there are existing update SQL statements, try to initialize the
  // dialog with the fields that correspond to them.
  if SQLText[ukModify].Count > 0 then
  begin
    ParseUpdateSQL(SQLText[ukModify].Text, QuoteChar, UpdTabName, nil, nil);
    // If the table name from the update statement is not part of the
    // dataset, then initialize from the dataset instead.
    if (UpdateTableName.Items.Count > 0) and
       (UpdateTableName.Items.IndexOf(UpdTabName) > -1) then
    begin
      UpdateTableName.Text := UpdTabName;
      InitFromUpdateSQL;
    end else
    begin
      InitFromDataSet;
      UpdateTableName.Items.Add(UpdTabName);
    end;
  end else
    InitFromDataSet;
  SetButtonStates;
end;

type
  THackDataSet = class(TZAbstractRWDataSet);

procedure TZUpdateSQLEditForm.InitUpdateTableNames;
var
  I: Integer;
  TableName: string;
  Tokenizer: IZTokenizer;
  StatementAnalyser: IZStatementAnalyser;
  SelectSchema: IZSelectSchema;
begin
  QuoteChar := '""';
  if Assigned(DataSet) and Assigned(DataSet.Connection) and DataSet.Connection.Connected then begin
    QuoteChar := DataSet.Connection.DbcConnection.GetMetadata.GetDatabaseInfo.
      GetIdentifierQuoteString;
    if Length(QuoteChar) = 1 then
      QuoteChar := QuoteChar + QuoteChar;
    { Parses the Select statement and retrieves a schema object. }
    Tokenizer := DataSet.Connection.DbcConnection.GetTokenizer;
    StatementAnalyser := DataSet.Connection.DbcConnection.GetStatementAnalyser;
    SelectSchema := StatementAnalyser.DefineSelectSchemaFromQuery(Tokenizer,
      THackDataSet(DataSet).SQL.Text);
    if Assigned(SelectSchema) then begin
      UpdateTableName.Clear;
      for I := 0 to SelectSchema.TableCount - 1 do
        UpdateTableName.Items.Add(SelectSchema.Tables[I].Table);//!!!Schema support
    end;
  end else if Assigned(Dataset) then begin
    TableName := '';
    if SQLText[ukModify].Count > 0 then
      ParseUpdateSql(SQLText[ukModify].Text, QuoteChar, TableName, nil, nil);
    if TableName <> '' then
      UpdateTableName.Items.Add(TableName);
  end;
  if UpdateTableName.Items.Count > 0 then
     UpdateTableName.ItemIndex := 0;
end;

procedure TZUpdateSQLEditForm.SetButtonStates;
begin
  GetTableFieldsButton.Enabled := UpdateTableName.Text <> '';
  PrimaryKeyButton.Enabled := GetTableFieldsButton.Enabled and
    (KeyFieldList.Items.Count > 0);
  GenerateButton.Enabled := GetTableFieldsButton.Enabled and
    (UpdateFieldList.Items.Count > 0) and (KeyFieldList.Items.Count > 0);
  DefaultButton.Enabled := Assigned(DataSet) and not FDatasetDefaults;
end;

procedure TZUpdateSQLEditForm.SelectPrimaryKeyFields;
var
  I: Integer;
  Index: Integer;
  PKeys: TZSQLMetadata;
begin
  if KeyFieldList.Items.Count < 1 then Exit;
  with Dataset do
  begin
    for I := 0 to KeyFieldList.Items.Count - 1  do
      KeyFieldList.Selected[I] := False;
    PKeys := TZSQLMetadata.Create(nil);
    try
      PKeys.Connection := Connection;
      PKeys.TableName := UpdateTableName.Text;
      PKeys.MetadataType := mdPrimaryKeys;
      PKeys.Open;
      PKeys.First;
      while not PKeys.Eof do
      begin
        Index := KeyFieldList.Items.IndexOf(PKeys.FieldByName('COLUMN_NAME').AsString);
        if Index > -1 then KeyFieldList.Selected[Index] := True;
        PKeys.Next;
      end;
    finally
      PKeys.Free;
    end;
  end;
end;

procedure TZUpdateSQLEditForm.SetDefaultSelections;
var
  DSFields: TStringList;
begin
  if FDatasetDefaults or not Assigned(DataSet) then
  begin
    SelectAll(UpdateFieldList);
    SelectAll(KeyFieldList);
  end
  else if (DataSet.FieldDefs.Count > 0) then
  begin
    DSFields := TStringList.Create;
    try
      GetDataFieldNames(DataSet, '', DSFields);
      SetSelectedItems(KeyFieldList, DSFields);
      SetSelectedItems(UpdateFieldList, DSFields);
    finally
      DSFields.Free;
    end;
  end;
end;

procedure TZUpdateSQLEditForm.ShowWait(WaitMethod: TWaitMethod);
begin
  Screen.Cursor := crHourGlass;
  try
    WaitMethod;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{ Event Handlers }

procedure TZUpdateSQLEditForm.FormCreate(Sender: TObject);
begin
//  HelpContext := hcDUpdateSQL;
end;

procedure TZUpdateSQLEditForm.FormResize(Sender: TObject);
Var i: Integer;
begin
  i := PageControl.Height - 92;
  If i < 0 Then i := 0;
  SQLMemo.Height := i;
end;

procedure TZUpdateSQLEditForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TZUpdateSQLEditForm.StatementTypeClick(Sender: TObject);
begin
  if SQLMemo.Modified then
    SQLText[TUpdateKind(StmtIndex)].Assign(SQLMemo.Lines);
  StmtIndex := StatementType.ItemIndex;
  SQLMemo.Lines.Assign(SQLText[TUpdateKind(StmtIndex)]);
end;

procedure TZUpdateSQLEditForm.OkButtonClick(Sender: TObject);
begin
  if SQLMemo.Modified then
    SQLText[TUpdateKind(StmtIndex)].Assign(SQLMemo.Lines);
end;

procedure TZUpdateSQLEditForm.DefaultButtonClick(Sender: TObject);
begin
  with UpdateTableName do
    if Items.Count > 0 then ItemIndex := 0;
  ShowWait(GetDataSetFieldNames);
  FDatasetDefaults := True;
  SetDefaultSelections;
  KeyfieldList.SetFocus;
  SetButtonStates;
end;

procedure TZUpdateSQLEditForm.GenerateButtonClick(Sender: TObject);
begin
  GenerateSQL;
  FSettingsChanged := False;
end;

procedure TZUpdateSQLEditForm.PrimaryKeyButtonClick(Sender: TObject);
begin
  ShowWait(SelectPrimaryKeyFields);
  SettingsChanged(Sender);
end;

procedure TZUpdateSQLEditForm.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (PageControl.ActivePage = PageControl.Pages[0]) and
    not SQLPage.Enabled then
    AllowChange := False;
end;

procedure TZUpdateSQLEditForm.FormDestroy(Sender: TObject);
begin
  if ConnectionOpened then
    DataSet.Connection.Disconnect;
end;

procedure TZUpdateSQLEditForm.GetTableFieldsButtonClick(Sender: TObject);
begin
  ShowWait(GetTableFieldNames);
  SetDefaultSelections;
  SettingsChanged(Sender);
end;

procedure TZUpdateSQLEditForm.SettingsChanged(Sender: TObject);
begin
  FSettingsChanged := True;
  FDatasetDefaults := False;
  SetButtonStates;
end;

procedure TZUpdateSQLEditForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = mrOK) and FSettingsChanged then
    CanClose := MessageDlg(SSQLNotGenerated, mtConfirmation,
      mbYesNoCancel, 0) = mrYes;
end;

procedure TZUpdateSQLEditForm.UpdateTableNameChange(Sender: TObject);
begin
  SettingsChanged(Sender);
end;

procedure TZUpdateSQLEditForm.UpdateTableNameClick(Sender: TObject);
begin
  if not Visible then Exit;
  GetTableFieldsButtonClick(Sender);
end;

procedure TZUpdateSQLEditForm.SelectAllClick(Sender: TObject);
begin
  SelectAll(FieldListPopup.PopupComponent as TListBox);
end;

procedure TZUpdateSQLEditForm.ClearAllClick(Sender: TObject);
var
  I: Integer;
begin
  with FieldListPopup.PopupComponent as TListBox do
  begin
    Items.BeginUpdate;
    try
      for I := 0 to Items.Count - 1 do
        Selected[I] := False;
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TZUpdateSQLEditForm.SQLMemoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #27 then Close;
end;

{$IFDEF FPC}
initialization
{$i ZUpdateSqlEditor.lrs}
{$ENDIF}

end.
