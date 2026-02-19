program Birthday;

uses
    sysutils, baseunix, unix, math;

type
    TPos = record
        x: Double;
        y: Double;
        vx: Double;
        vy: Double; 
    end;

    TEntity = record
        p: TPos;
        ch: Char;
        color: Integer;
        active: Boolean;
    end;

    TState = (SMarcosDrop, SMarcosExplode, SFireworks);

const
    FPS = 30;
    BOLD = #27'[1m';
    RESET = #27'[0m';
    GRAVITY = 24;
    MAX_FIREWORK_PARTICLE_V = 18;
    MAX_MARCOS_PARTICLE_V = 30;
    FIREWORK_PARTICLES = 50;
    FIREWORK_COUNTDOWN_BEGIN = 18;
    FIREWORK_BLINK_INTERVAL = 6;
    { 35 across }
    { 87 chars }
    MARCOS_TXT: array[1..6] of AnsiString = (
       '.   .   .   ....   ...   ...   ....',
       '.. ..  . .  .   . .   . .   . .    ',
       '. . . .   . .   . .     .   .  ... ',
       '.   . ..... ....  .     .   .     .',
       '.   . .   . .   . .   . .   .     .',
       '.   . .   . .   .  ...   ...  .... '
    );
    FINAL_MESSAGE: array[1..3] of AnsiString = (
        '(Very late) Happy Birthday!!!',
        'And happy Chinese New Year!',
        '祝您财源广进、平安喜乐、大吉大利、身体健康!'
    );
    FINAL_MESSAGE_LENGTHS: array[1..3] of Integer = (29, 27, 43);
    FIREWORKS_PADDING = 8;
    CREDITS_TXT = 'Made with <3 by Eason Qin, with contributions from Ved Jaggi, 3bd (xqrs)';

var
    Marcos: TPos;
    { allow more entities due to firework particles after marcos explosion }
    Entities: array[1..256] of TEntity; 
    State: TState;
    CurFrame: LongInt;
    TermWidth: Integer;
    TermHeight: Integer;
    Done: Boolean;
    AllParticlesDespawned: Boolean;
    { countdown for when the firework should explode in frames }
    FireworkCountdown: Integer;
    CurMsgColor: Integer;
    

{ utilities }
procedure Clear;
begin
    Write(#27'[2J'#27'[H');
end;

procedure CursorTo(x, y: Double);
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
    Row: Integer;
    Col: Integer;
    CurChar: Char;
begin
    State := SMarcosExplode;  
    AllParticlesDespawned := false;
    PartsLast := 1;

    for Row := Low(MARCOS_TXT) to High(MARCOS_TXT) do
        for Col := 1 to 35 do
        begin
            CurChar := MARCOS_TXT[Row][Col];
            if CurChar = ' ' then
                continue;
           
            with NewPart.p do
            begin
                x := Marcos.x + Col;
                y := Marcos.y + (Row - 1);
                vx := 0;
                vy := 0;
            end;

            if Col < 6 then
                CurChar := 'M'
            else if Col < 12 then
                CurChar := 'A'
            else if Col < 18 then
                CurChar := 'R'
            else if Col < 24 then
                CurChar := 'C'
            else if Col < 30 then
                CurChar := 'O'
            else
                CurChar := 'S';

            NewPart.ch := CurChar;

            case CurChar of
                'M': NewPart.color := 34;
                'A': NewPart.color := 31;
                'R': NewPart.color := 33;
                'C': NewPart.color := 32;
                'O': NewPart.color := 35;
                'S': NewPart.color := 36;
            end;

            { set a random velocity }
            NewPart.p.vx := Random(MAX_MARCOS_PARTICLE_V);
            NewPart.p.vy := -1.0 * (Random(15) + 2 * (MAX_MARCOS_PARTICLE_V div 3));
            NewPart.active := true;

            if Col < 17 then
                NewPart.p.vx := NewPart.p.vx * -1.0;

            Entities[PartsLast] := NewPart;
            PartsLast := PartsLast + 1;
        end;
end;

procedure SpawnFirework;
const
    TEXT_OFFSET = 3 + High(FINAL_MESSAGE);
var
    i: Integer;
begin
    with Entities[1] do
    begin
        p.x := (FIREWORKS_PADDING div 2) + Random(TermWidth - FIREWORKS_PADDING);
        { 5: lines of message + 3 (beginning height) }
        p.y := TEXT_OFFSET + (FIREWORKS_PADDING div 2)
                 + Random(TermHeight - FIREWORKS_PADDING - TEXT_OFFSET);
        p.vx := 0;
        p.vy := 0;
        ch := '*';
        active := true;
    end;

    for i := 2 to ((FIREWORK_PARTICLES + 1) div 2) do
    begin
        with Entities[i] do
        begin
            p.x := Entities[1].p.x;
            p.y := Entities[1].p.y;
            p.vx := Random(MAX_FIREWORK_PARTICLE_V);
            p.vy := -1.0 * (Random(15) + 2 * (MAX_FIREWORK_PARTICLE_V div 3));

            ch := '*';
            active := true;
            color := 31;
        end;

        with Entities[FIREWORK_PARTICLES + 3 - i] do
        begin
            p.x := Entities[1].p.x;
            p.y := Entities[1].p.y;
            p.vx := -1.0 * Entities[i].p.vx;
            p.vy := -1.0 * (Random(15) + 2 * (MAX_FIREWORK_PARTICLE_V div 3));

            ch := '*';
            active := true;
            color := 31;
        end;
    end;


    FireworkCountdown := FIREWORK_COUNTDOWN_BEGIN;
    AllParticlesDespawned := false;
end;

procedure BeginFireworks;
begin
    State := SFireworks;
    CurMsgColor := 0;
    { set up first firework entity }
    SpawnFirework;
end;

{ Draw code }
procedure DrawMarcosDrop;
var
    i, j: LongInt;
begin
    for i := Low(MARCOS_TXT) to High(MARCOS_TXT) do
    begin
        CursorTo(Marcos.x, Marcos.y + (i - 1));
        for j := 1 to 35 do
            if MARCOS_TXT[i][j] = ' ' then
                Write(' ')
            else
                Write('█');
    end;
end;

procedure DrawEntities(L, U: Integer);
var
    i: Integer;
    DrewActive: Boolean;
begin
    if AllParticlesDespawned then
        exit;

    DrewActive := false;

    for i := L to U do
    begin
        if not Entities[i].active then
            continue;

        DrewActive := true;
        with Entities[i] do
        begin
            CursorTo(p.x, p.y);
            Write(#27'[1;', color, 'm', ch, #27'[0m');
        end;
    end;

    if not DrewActive then
        AllParticlesDespawned := true;
end;

procedure DrawMarcosExplode;
begin
    DrawEntities(1, 87);
end;

procedure DrawFireworksText;
var
    i: Integer;
    Msg: AnsiString;
begin
    if CurFrame mod 6 = 0 then
        CurMsgColor := (CurMsgColor + 1) mod 6;

    for i := Low(FINAL_MESSAGE) to High(FINAL_MESSAGE) do
    begin
        Msg := FINAL_MESSAGE[i];
        Write(#27'[', 3 + (i - 1), ';', (TermWidth div 2) - (FINAL_MESSAGE_LENGTHS[i] div 2), 'H');
        Write(#27'[1;30;', CurMsgColor + 41, 'm', Msg , #27'[0m');
    end;

    Write(#27'[', TermHeight, ';0H');
    Write(#27'[2m', CREDITS_TXT, #27'[0m');
end;

procedure DrawFireworks;
begin
    if FireworkCountdown > 0 then
    begin
        CursorTo(Entities[1].p.x, Entities[1].p.y);
        if 
            FireworkCountdown mod FIREWORK_BLINK_INTERVAL <
            (FIREWORK_BLINK_INTERVAL div 2)
        then
            Write('*')
        else
            Write(#27'[1;33m*'#27'[0m');
    
        DrawFireworksText;
        exit;
    end;

    DrawEntities(2, FIREWORK_PARTICLES + 1);
    DrawFireworksText;
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
begin
    if AllParticlesDespawned then
        BeginFireworks;

    for i := 1 to 87 do
        with Entities[i] do 
        begin
            p.vy := p.vy + GRAVITY * (1/FPS);
            p.x := p.x + p.vx * (1/FPS);
            p.y := p.y + p.vy * (1/FPS);

            if p.y > TermHeight then
                active := false;
        end;
end;

procedure UpdateFireworks;
var
    i: Integer;
    Angle: Double;
begin
    if AllParticlesDespawned then
    begin
        SpawnFirework;
        Exit;
    end;
    
    if FireworkCountdown > 0 then
    begin
        FireworkCountdown := FireworkCountdown - 1;
        exit;
    end;

    for i := 2 to FIREWORK_PARTICLES + 1 do
        with Entities[i] do 
        begin
            p.vy := p.vy + GRAVITY * (1/FPS);
            p.x := p.x + p.vx * (1/FPS);
            p.y := p.y + p.vy * (1/FPS);

            if p.y > TermHeight then
                active := false;

            Angle := RadToDeg(arctan2(p.vy, p.vx));
            if Angle < 0 then
                Angle := Angle + 360;

            { - / \ | }
            if ((80 < Angle) and (Angle < 100))
                or ((260 < Angle) and (Angle < 280))
            then
                ch := '|'
            else if ((0 < Angle) and (Angle < 10))
                    or ((170 < Angle) and (Angle < 190))
                    or (350 < Angle)
            then 
                ch := '-'
            else if ((10 <= Angle) and (Angle <= 80))
                    or ((190 <= Angle) and (Angle <= 260))
            then
                ch := '\'
            else
                ch := '/';

        end;
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
    CurFrame := 0;

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
        Clear;
        Draw;
        Update;
        Sleep(Trunc(1000/FPS));
        CurFrame := CurFrame + 1;
    end;
    Deinit;
end.
