/*
 * veri funni demo™
 *
 * copyright (c) eason qin, 2025
 *
 * licensed under the bsd 2-clause license
 */
#include <math.h>
#include <signal.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

#define S_DIM          "\033[2m"
#define S_END          "\033[0m"
#define S_BLACK        "\033[30m"
#define S_RED          "\033[31m"
#define S_GREEN        "\033[32m"
#define S_YELLOW       "\033[33m"
#define S_BLUE         "\033[34m"
#define S_MAGENTA      "\033[35m"
#define S_CYAN         "\033[36m"
#define S_WHITE        "\033[37m"
#define S_BG_BLACK     "\033[40m"
#define S_BG_RED       "\033[41m"
#define S_BG_GREEN     "\033[42m"
#define S_BG_YELLOW    "\033[43m"
#define S_BG_BLUE      "\033[44m"
#define S_BG_MAGENTA   "\033[45m"
#define S_BG_CYAN      "\033[46m"
#define S_BG_WHITE     "\033[47m"
#define S_CLEAR_SCREEN "\033[2J\033[H"
#define S_CLEAR_LINE   "\r\033[K"
#define S_ENTER_ALT    "\033[?1049h"
#define S_LEAVE_ALT    "\033[?1049l"
#define S_SHOWCURSOR   "\033[?25h"
#define S_HIDECURSOR   "\033[?25l"

#define TICK_SPEED    35 // usec
#define g             9.8
#define MAX_PARTICLES (int)100

#define MIN_U     15
#define MAX_U     35
#define MIN_ANGLE 30
#define MAX_ANGLE 65

#define MSG_BEGIN 35
#define TXT_BEGIN (MSG_BEGIN + 10)

#define LENGTH(a) (sizeof(a) / sizeof(a[0]))

#define check_alloc(ptr)                                                       \
    do {                                                                       \
        if (!ptr) {                                                            \
            perror("alloc failed: ");                                          \
            exit(EXIT_FAILURE);                                                \
        }                                                                      \
    } while (0);

typedef enum {
    C_BLACK = 30,
    C_RED,
    C_GREEN,
    C_YELLOW,
    C_BLUE,
    C_MAGENTA,
    C_CYAN,
    C_WHITE,
} Color;

typedef struct {
    double angle;
    double u; // initial velocity
    double x;
    double y;
    Color color;
} Confetti;

static unsigned trow, tcol, ticker, curcol;
static bool should_exit, confetti_done, drew_confetti;

static Confetti* l_confetti;
static Confetti* r_confetti;

#define BANNER_TOP_WIDTH    19
#define BANNER_MIDDLE_WIDTH 34
#define BANNER_BOTTOM_WIDTH 11

static const char* BANNER_TOP[] = {
    "█▄█ ▄▀▄ █▀█ █▀█ █ █\n", //
    "█ █ █▀█ █▀▀ █▀▀  █\n"   //
};

static const char* BANNER_MIDDLE[] = {"▀█▀ ▛▀▀ ▄▀▄ █▀▀ █ █ ▛▀▀ █▀▄ █  █▀▀\n", //
                                      " █  ▛▀  █▀█ █   █▀█ ▛▀  █▀▄    ▀▀█\n", //
                                      " ▀  ▀▀▀ ▀ ▀ ▀▀▀ ▀ ▀ ▀▀▀ ▀ ▀    ▀▀▀\n"};

static const char* BANNER_BOTTOM[] = {"█▀▅ ▄▀▄ █ █\n", //
                                      "█ █ █▀█  █\n",  //
                                      "▀▀  ▀ ▀  ▀\n"};

static const char* LINES[5] = {
    "Thank you for being an incredible person,",
    "not just a legendary teacher but a friendly man;",
    "indulgente, amable y honesto.",
    "You provide the best homeless shelter I've ever been to!",
    "(Google Translate shamelessly used)"};

static int line_counters[5] = {0, -1, -2, -3, -4};
static int line_colors[5] = {0};

const int BOX_WIDTH = 38;  // 34 + 2 on each side
const int BOX_HEIGHT = 12; // 8 + 2 betw + 1 on each side
static unsigned bybegin, bxbegin;

void handle_sigint(int dummy);
void init(void);
void deinit(void);
void populate(void);
void draw(void);
void update(void);
double uniform(double a, double b);
int randint(int a, int b);

double uniform(double a, double b) {
    // uniformly distributed random number
    // thanks chatjippety
    return a + (b - a) * ((double)rand() / RAND_MAX);
}

int randint(int a, int b) { return (rand() % (b - a + 1)) + a; }

void handle_sigint(int dummy) {
    (void)dummy;
    should_exit = 1;
}

void init(void) {
    srand(time(NULL));
    atexit(deinit);
    signal(SIGINT, handle_sigint);

    should_exit = 0;
    struct winsize sz;
    ioctl(0, TIOCGWINSZ, &sz);
    trow = sz.ws_row;
    tcol = sz.ws_col;

    bxbegin = tcol / 2 - BOX_WIDTH / 2;
    bybegin = trow / 2 - BOX_HEIGHT / 2;
    ticker = 0;
    curcol = 0;
    confetti_done = false;
    drew_confetti = true;

    l_confetti = calloc(MAX_PARTICLES / 2, sizeof(Confetti));
    r_confetti = calloc(MAX_PARTICLES / 2, sizeof(Confetti));
    check_alloc(l_confetti);
    check_alloc(r_confetti);

    printf(S_ENTER_ALT);
    printf(S_CLEAR_SCREEN);
    printf(S_HIDECURSOR);
}

void deinit(void) {
    printf(S_LEAVE_ALT);
    printf(S_SHOWCURSOR);
}

void populate(void) {
    int lc_end = 0;
    int rc_end = 0;

    Confetti* c;
    for (int i = 0; i < MAX_PARTICLES / 2; i++) {
        c = &l_confetti[i];
        c->u = uniform(MIN_U, MAX_U);
        c->angle =
            uniform(MIN_ANGLE, MAX_ANGLE) * (M_PI / 180); // convert to radian
        c->color = (Color)randint(31, 37);
    }

    for (int i = 0; i < MAX_PARTICLES / 2; i++) {
        c = &r_confetti[i];
        c->u = uniform(MIN_U, MAX_U);
        c->angle =
            uniform(MIN_ANGLE, MAX_ANGLE) * (M_PI / 180); // convert to radian
        c->color = (Color)randint(31, 37);
    }
}

// false: left
// true: right
static void draw_confetti(Confetti* c, bool side) {
    int row = trow - (int)c->y;
    int col;
    if (side)
        col = (int)c->x + 1;
    else
        col = tcol - (int)c->x + 1;

    bool in_range = 1 <= row && row <= trow && 1 <= col && col <= tcol;
    if (in_range) {
        drew_confetti = true;
        printf("\033[%d;%dH", row, col);
        if (ticker % 2 == 0)
            printf("\033[%dm*", c->color);
        else
            printf("\033[1;%dm*", c->color);
    }
}

static void draw_banner(void) {
    // paint the box first
    for (int i = bybegin; i < bybegin + BOX_HEIGHT; i++) {
        // 38 spaces
        printf("\033[%d;%dH", i, bxbegin);
        printf("\033[0;37;40m                                      \033[0m");
    }

    // top
    int topxbegin = BOX_WIDTH / 2 - BANNER_TOP_WIDTH / 2;
    int middlexbegin = BOX_WIDTH / 2 - BANNER_MIDDLE_WIDTH / 2;
    int btmxbegin = BOX_WIDTH / 2 - BANNER_BOTTOM_WIDTH / 2;
    // the top is 2 chars tall
    for (int i = 0; i < LENGTH(BANNER_TOP); i++) {
        printf("\033[%d;%dH", bybegin + i + 1, bxbegin + topxbegin);
        printf("\033[0;37;40m%s\033[0m", BANNER_TOP[i]);
    }

    for (int i = 0; i < LENGTH(BANNER_MIDDLE); i++) {
        printf("\033[%d;%dH", bybegin + i + 4, bxbegin + middlexbegin);
        printf("\033[0;37;40m%s\033[0m", BANNER_MIDDLE[i]);
    }

    for (int i = 0; i < LENGTH(BANNER_MIDDLE); i++) {
        printf("\033[%d;%dH", bybegin + i + 8, bxbegin + btmxbegin);
        printf("\033[0;37;40m%s\033[0m", BANNER_BOTTOM[i]);
    }
}

static void draw_rainbow(void) {
    int left = bxbegin - 1;
    int right = bxbegin + BOX_WIDTH;
    int top = bybegin - 1;
    int btm = bybegin + BOX_HEIGHT;

    int x = 0, y = 0;
    // top
    for (x = left; x <= right; x++) {
        printf("\033[%d;%dH", top, x);
        printf("\033[0;37;%dm \033[0m", curcol + 41);
        curcol = (curcol + 1) % 7;
    }

    // right-down
    for (y = top + 1; y <= btm - 1; y++) {
        printf("\033[%d;%dH", y, right);
        printf("\033[0;37;%dm \033[0m", curcol + 41);
        curcol = (curcol + 1) % 7;
    }

    // bottom
    for (x -= 1; x >= left; x--) {
        printf("\033[%d;%dH", btm, x);
        printf("\033[0;37;%dm \033[0m", curcol + 41);
        curcol = (curcol + 1) % 7;
    }

    // left-up
    for (y -= 1; y >= top + 1; y--) {
        printf("\033[%d;%dH", y, left);
        printf("\033[0;37;%dm \033[0m", curcol + 41);
        curcol = (curcol + 1) % 7;
    }
}

static void draw_text(void) {
    int x = 0, y = 0;
    for (int i = 0; i < LENGTH(LINES); i++) {
        if (line_counters[i] < 0)
            continue;

        if (i % 2 == 0)
            // left side right
            x = line_counters[i];
        else
            // right side left
            x = tcol - line_counters[i] - strlen(LINES[i]);
        y = 2 + i;
        printf("\033[%d;%dH", y, x);
        printf("\033[%dm%s\033[0m", line_colors[i], LINES[i]);
    }
}

void draw(void) {
    if (!confetti_done) {
        Confetti* c;
        for (int i = 0; i < MAX_PARTICLES / 2; i++) {
            c = &l_confetti[i];
            draw_confetti(c, false);
        }

        for (int i = 0; i < MAX_PARTICLES / 2; i++) {
            c = &r_confetti[i];
            draw_confetti(c, true);
        }
    }

    if (ticker >= TXT_BEGIN) {
        draw_text();
    }

    if (ticker >= MSG_BEGIN) {
        draw_rainbow();
        draw_banner();
    }
}

static void update_rainbow(void) {
    if (ticker % 2 == 0)
        curcol = (curcol + 1) % 7;
}

static void update_text(void) {
    int wanted_pos, cur_pos;

    if (ticker % 4 != 0)
        return;

    for (int i = 0; i < LENGTH(line_counters); i++) {
        line_colors[i] = randint(31, 37);

        int curlen = strlen(LINES[i]);
        wanted_pos = tcol / 2 - curlen / 2;

        if (i % 2 == 0) {
            cur_pos = line_counters[i];
        } else {
            cur_pos = tcol - line_counters[i] - curlen;
        }

        if (cur_pos == wanted_pos)
            continue;

        line_counters[i]++;
    }
}

void update(void) {
    if (!drew_confetti)
        confetti_done = true;

    double elt = (double)TICK_SPEED / 1000 * ticker;
    if (!confetti_done) {
        Confetti* c;
        for (int i = 0; i < MAX_PARTICLES / 2; i++) {
            c = &l_confetti[i];
            // S_x = u cos(theta) t
            // S_y = u sin(theta) t - 1/2 g t^2
            c->x = c->u * cos(c->angle) * elt;
            c->y = c->u * sin(c->angle) * elt - 0.5 * g * elt * elt;
        }

        for (int i = 0; i < MAX_PARTICLES / 2; i++) {
            c = &r_confetti[i];
            c->x = c->u * cos(c->angle) * elt;
            c->y = c->u * sin(c->angle) * elt - 0.5 * g * elt * elt;
        }
    }

    if (ticker >= TXT_BEGIN) {
        update_text();
    }

    if (ticker >= MSG_BEGIN) {
        update_rainbow();
    }
}

int main(void) {
    init();
    populate();

    if (tcol < 80 || trow < 24) {
        fprintf(stderr, "must have an 80x24 terminal!");
        exit(EXIT_FAILURE);
    }

    while (!should_exit) {
        drew_confetti = false;

        printf(S_CLEAR_SCREEN);

        draw();
        update();

        usleep(TICK_SPEED * 1000);
        fflush(stdout);
        ticker++;
    }

    deinit();
    exit(EXIT_SUCCESS);
}
