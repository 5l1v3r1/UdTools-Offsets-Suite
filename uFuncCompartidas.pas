unit uFuncCompartidas;

interface

uses
  System.SysUtils, Winapi.Windows, System.Classes;

Function FileToStr(mFile: String): String;
Function StrToFile(Str, Ruta: String): Boolean;
Procedure ListarFicheros;
Procedure ErrorLog(Errores: TStringList; mFile: String);

implementation

uses
  uUOS;

//Guarda Log en caso de errores
procedure ErrorLog(Errores: TStringList; mFile: String);
begin
  Errores.SaveToFile(mFile);
end;

// Funci�n para almacenar los bytes del fichero en una cadena
Function FileToStr(mFile: String): String;
var
  hFile: THandle;
  dwRet: DWORD;
  iSize: DWORD;
  Buff: AnsiString;
begin
  hFile := CreateFile(PChar(mFile), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then
    Exit;
  iSize := GetFileSize(hFile, nil);
  SetFilePointer(hFile, 0, nil, FILE_BEGIN);
  SetLength(Buff, iSize);
  ReadFile(hFile, Buff[1], iSize, dwRet, nil);
  CloseHandle(hFile);
  Result := WiDeString(Buff);
end;

// Funci�n para crear ficheros a partir de una cadena
Function StrToFile(Str, Ruta: String): Boolean;
var
  hFile: THandle;
  iSize: DWORD;
  dwRet: DWORD;
  Buff: AnsiString;
begin
  Result := False;
  Buff := AnsiString(Str);
  iSize := Length(Buff);
  hFile := CreateFile(PChar(Ruta), GENERIC_WRITE, FILE_SHARE_READ, nil,
    OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if (WriteFile(hFile, Buff[1], iSize, dwRet, nil) = True) then
    Result := True;
  CloseHandle(hFile);
end;

// Procedimiento para listar ficheros del Directorio de trabajo
Procedure ListarFicheros;
var
  SearchResult: TSearchRec;
  Extension: String;
begin
  Form1.ListView2.Clear;
  if Form1.RadioButton1.Checked then
    begin
      if (NOT System.SysUtils.DirectoryExists(Form1.EdDir.Text)) or (NOT System.SysUtils.FileExists(Form1.EdFichero.Text)) then
        Exit;
      Extension:= ExtractFileExt(Form1.EdFichero.Text);
    end;
  if Form1.RadioButton2.Checked then
    begin
      if (NOT System.SysUtils.DirectoryExists(Form1.EdDir.Text)) then
        Exit;
      Extension:= Form1.Edit4.Text;
    end;
  SetCurrentDir(Form1.EdDir.Text);
  if FindFirst('*' + Extension, faArchive, SearchResult) = 0 then
  begin
    repeat
      if (SearchResult.Attr and faArchive = faArchive) and (SearchResult.Attr and faDirectory <> faDirectory) then
        with Form1.ListView2.Items.Add do
          begin
            Caption:= Form1.EdDir.Text + '\' + SearchResult.Name;
            SubItems.Add('');
          end;
    until FindNext(SearchResult) <> 0;
    System.SysUtils.FindClose(SearchResult);
  end;
end;

end.
