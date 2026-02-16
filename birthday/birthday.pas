program Birthday;

{$mode objfpc}{$H+}

uses
    sysutils;

type
    TStringArray = array[0..5] of AnsiString;

    TPos = record
        x: Real;
        y: Real;
        vx: Real;
        vy: Real; 
    end;

    TEntity = record
        p: TPos;
        ch: Char;
        color: Integer;
    end;

    TState = (SMarcosDrop, SMarcosExplode, SBirthdayText, SLantern);

const
    FPS = 24;
    BOLD = #27'[1m';
    RESET = #27'[0m';
    GRAVITY = 17;
    { 35 across }
    { 85 chars }
    MARCOS_TXT: TStringArray = (
       '.   .   .   ....   ...   ...   ....',
       '.. ..  . .  .   . .   . .   . .    ',
       '. . . .   . .   . .     .   .  ... ',
       '.   . ..... ....  .     .   .     .',
       '.   . .   . .   . .   . .   .     .',
       '.   . .   . .   .  ...   ...  .... '
    );

var
    Marcos: TPos;
    { 87 things }
    MarcosParts: array[0..86] of TEntity; 
    State: TState;
    CurFrame: Integer;
    SavedFrame: Integer;
    TermWidth: Integer;
    TermHeight: Integer;
    Done: Boolean;

procedure Clear;
begin
    Write(#27'[2J'#27'[H');
end;

procedure Init;
var
    Width: AnsiString;
    Height: AnsiString;
    ShouldExit: Boolean;
begin
    Width := GetEnvironmentVariable('COLUMNS');
    Height := GetEnvironmentVariable('LINES');

    ShouldExit := false;
    if Width = '' then
    begin
        WriteLn(StdErr, 'Please set $COLUMNS. zsh users should just type `export COLUMNS`');
        ShouldExit := true;
    end;

    if Height = '' then
    begin
        WriteLn(StdErr, 'Please set $LINES. zsh users should just type `export LINES`');
        ShouldExit := true;
    end;

    if ShouldExit then
        Halt(1);

    TermWidth := StrToInt(Width); 
    TermHeight := StrToInt(Height); 

    { setup marcos text }
    with Marcos do
    begin
        x := (TermWidth div 2) - 17; 
        y := -6.0;
        vx := 0;
        vy := 6;
    end;

    State := SMarcosDrop;
    Done := false; 

    { hide cursor }
    Write(#27'[?25l');
    Clear;
end;

procedure Deinit;
begin
    Clear;
    { show cursor }
    WriteLn(#27'[?25h');
end;

procedure CursorTo(x, y: Real);
var
    ix: Word;
    iy: Word;
begin
    {given that positive x goes right and positive y goes down, display it on the terminal}
    if y < 0 then
        iy := 1
    else
        iy := Trunc(y) + 1;

    if x < 0 then
        ix := 1
    else
        ix := Trunc(x) + 1;

    Write(#27'[', iy, ';', ix, 'H');
end;

procedure DrawMarcosDrop;
var
    i, j: Integer;
begin
    for i := 0 to 5 do
    begin
        CursorTo(Marcos.x, Marcos.y + i);
        for j := 1 to 35 do
            if MARCOS_TXT[i][j] = ' ' then
                Write(' ')
            else
                Write('█');
    end;
end;

procedure DrawMarcosExplode;
var
    i: Integer;
begin
    for i := 0 to 84 do
        with MarcosParts[i] do
        begin
            CursorTo(p.x, p.y);
            Write(#27'[1;', color, 'm', ch, #27'[0m');
        end;
end;

procedure Draw;
begin
    case State of
    SMarcosDrop:
        DrawMarcosDrop;
    SMarcosExplode:
        DrawMarcosExplode;
    else
        begin
            WriteLn('Not Implemented');
            Halt(1);
        end;
    end;
end;

procedure BeginMarcosExplode;
var
    NewPart: TEntity;
    PartsLast: Integer;
    row: Integer;
    col: Integer;
    CurChar: Char;
begin
    State := SMarcosExplode;  
    PartsLast := 0;
    SavedFrame := CurFrame;

    for row := 0 to 5 do
        for col := 1 to 35 do
        begin
            CurChar := MARCOS_TXT[row][col];
            if CurChar = ' ' then
                continue;
           
            with NewPart.p do
            begin
                x := Marcos.x + col;
                y := Marcos.y + row;
                vx := 0;
                vy := 0;
            end;

            if col < 6 then
                NewPart.ch := 'M'
            else if col < 12 then
                NewPart.ch := 'A'
            else if col < 18 then
                NewPart.ch := 'R'
            else if col < 24 then
                NewPart.ch := 'C'
            else if col < 30 then
                NewPart.ch := 'O'
            else
                NewPart.ch := 'S';

            case NewPart.ch of
                'M': NewPart.color := 34;
                'A': NewPart.color := 31;
                'R': NewPart.color := 33;
                'C': NewPart.color := 32;
                'O': NewPart.color := 35;
                'S': NewPart.color := 36;
            end;

            MarcosParts[PartsLast] := NewPart;
            PartsLast := PartsLast + 1;
        end;
end;

procedure Update;
var
    FloorHeight: Integer;
begin
    FloorHeight := Trunc(2*(TermHeight/3));

    case State of
    SMarcosDrop:
        with Marcos do
        begin
            vy := vy + GRAVITY * (1/FPS);
            x := x + vx * (1/FPS);
            y := y + vy * (1/FPS);

            if y + 6 >= FloorHeight then
            begin
                vy := -0.7 * vy;
                y := FloorHeight - 6;
            end;

            if (((y + 6.0) = FloorHeight) and (abs(vy) < 12.0)) then
            begin
                vy := 0.0;
                BeginMarcosExplode;
            end;
        end;
    SMarcosExplode:
        begin
        end;
    else
        begin
            WriteLn('Not Implemented');
            Halt(1);
        end;
    end;
end;

procedure Frame;
begin
    Clear;
    Draw;
    Update;
    Sleep(Trunc(1000/FPS));
    CurFrame := CurFrame + 1;
end;

begin
    Init;
    while not Done do
    begin
        Frame;
    end;
    Deinit;
end.
