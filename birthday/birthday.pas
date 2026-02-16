program Birthday;

uses
    sysutils, baseunix, unix;

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
        active: Boolean;
    end;
    PEntity = ^TEntity;

    TState = (SMarcosDrop, SMarcosExplode, SFireworks);

const
    FPS = 24;
    BOLD = #27'[1m';
    RESET = #27'[0m';
    GRAVITY = 24;
    MAX_PARTICLE_V = 30;
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
    CurFrame: LongInt;
    TermWidth: Integer;
    TermHeight: Integer;
    ParticlesDone: Boolean;
    Done: Boolean;

{ utilities }
procedure Clear;
begin
    Write(#27'[2J'#27'[H');
end;

procedure CursorTo(x, y: Real);
var
    ix: Word;
    iy: Word;
begin
    {given that positive x goes right and positive y goes down, display it on the terminal}
    if y <= 1 then
        iy := 1
    else
        iy := Trunc(y) + 1;

    if x <= 1 then
        ix := 1
    else
        ix := Trunc(x) + 1;

    Write(#27'[', iy, ';', ix, 'H');
end;

{ state transition code }
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

            { set a random velocity }
            NewPart.p.vx := Random(MAX_PARTICLE_V);
            NewPart.p.vy := -1.0 * (Random(15) + 2 * (MAX_PARTICLE_V div 3));

            NewPart.active := true;

            if col < 17 then
                NewPart.p.vx := NewPart.p.vx * -1.0;

            MarcosParts[PartsLast] := NewPart;
            PartsLast := PartsLast + 1;
        end;
end;

procedure BeginFireworks;
begin
    CursorTo(0.0, 0.0);
    State := SFireworks;
    { TODO: implement }
end;

{ Draw code }
procedure DrawMarcosDrop;
var
    i, j: LongInt;
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
    DrewActive: Boolean;
begin
    DrewActive := false;

    for i := 0 to 84 do
    begin
        if not MarcosParts[i].active then
            continue;

        DrewActive := true;
        with MarcosParts[i] do
        begin
            CursorTo(p.x, p.y);
            Write(#27'[1;', color, 'm', ch, #27'[0m');
        end;
    end;

    if not DrewActive then
        ParticlesDone := true;
end;

procedure DrawFireworks;
begin
    Write('fireworks placeholder');
end;

{ Update code }
procedure UpdateMarcosDrop;
var
    FloorHeight: LongInt;
begin
    FloorHeight := Trunc(2*(TermHeight/3));

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

        if (((y + 6.0) = FloorHeight) and (abs(vy) < 16.0)) then
        begin
            vy := 0.0;
            BeginMarcosExplode;
        end;
    end;
end;

procedure UpdateMarcosExplode;
var
    i: LongInt;
    Itm: PEntity;
begin
    if ParticlesDone then
        BeginFireworks;

    for i := 0 to 86 do
    begin
        Itm := @MarcosParts[i]; 
        Itm^.p.vy := Itm^.p.vy + GRAVITY * (1/FPS);
        Itm^.p.x := Itm^.p.x + Itm^.p.vx * (1/FPS);
        Itm^.p.y := Itm^.p.y + Itm^.p.vy * (1/FPS);

        if Itm^.p.y > TermHeight then
            Itm^.active := false;
    end;
end;

procedure UpdateFireworks;
begin

end;

procedure Draw;
begin
    case State of
    SMarcosDrop:
        DrawMarcosDrop;
    SMarcosExplode:
        DrawMarcosExplode;
    SFireworks:
        DrawFireworks;
    end;
end;

procedure Update;
begin
    case State of
    SMarcosDrop:
        UpdateMarcosDrop;
    SMarcosExplode:
        UpdateMarcosExplode; 
    SFireworks:
        UpdateFireworks;
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
    WriteLn(#27'[?25h');
end;

procedure HandleSignal(Signal: CInt); cdecl;
begin
    Deinit;
    Halt(1);
end;

begin
    Init;
    FpSignal(SIGINT, @HandleSignal);
    FpSignal(SIGTERM, @HandleSignal);
    while not Done do
    begin
        Frame;
    end;
    Deinit;
end.
