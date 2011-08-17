/* modifier 0 means no modifier */
static char *useragent      = "Surf/"VERSION" (X11; U; Unix; en-US) AppleWebKit/531.2+ Compatible (Safari)";
static char *progress       = "#FF0000";
static char *progress_trust = "#00FF00";
static char *stylefile      = ".surf/style.css";
static char *scriptfile     = ".surf/script.js";
static char *cookiefile     = ".surf/cookies.txt";
static char *historyfile    = ".surf/history.txt";
static char *bookmarkfile   = ".surf/bookmark.txt";
static char *searchfile     = ".surf/searchhistory.txt";
static time_t sessiontime   = 3600;
#define NOBACKGROUND 0
#define SETPROP(p, q)     { .v = (char *[]){ "/bin/sh", "-c", \
	"prop=\"`xprop -id $2 $0 | cut -d '\"' -f 2 | dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`\" &&" \
	"xprop -id $2 -f $1 8s -set $1 \"$prop\"", \
	p, q, winid, NULL } }

#define URLOPEN(p, q)     { .v = (char *[]){ "/bin/sh", "-c", \
	"prop=\"`cat ~/.surf/history.txt | cut -d '/' -f 3 | dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`\" &&" \
	"xprop -id $2 -f $1 8s -set $1 \"$prop\"", \
	p, q, winid, NULL } }

#define SEARCH(p, q)     { .v = (char *[]){ "/bin/sh", "-c", \
	"prop=\"`cat ~/.surf/searchhistory.txt | cut -d ':' -f 8 | dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`\" &&" \
	"xprop -id $2 -f $1 8s -set $1 \"$prop\"", \
	p, q, winid, NULL } }

#define BOOKMARK(p, q)     { .v = (char *[]){ "/bin/sh", "-c", \
	"prop=\"`cat ~/.surf/bookmark.txt | cut -d ':' -f 8 | dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`\" &&" \
	"xprop -id $2 -f $1 8s -set $1 \"$prop\"", \
	p, q, winid, NULL } }

#define HISTORY     { .v = (char *[]){ "/bin/sh", "-c", "ruby $HOME/surf/history.rb $0 ", \
	winid, NULL } }
/*
#define DOWNLOAD(d) { \
	.v = (char *[]){ "/bin/sh", "-c", \
	"xterm -e \"wget --load-cookies ~/.surf/cookies.txt '$0';\"", \
	d, NULL } }
*/
#define DOWNLOAD(d) { \
	.v = (char *[]){ "/bin/sh", "-c", \
	"xterm -bc -fn \"-nsb-lokaltog-medium-r-normal--10-100-75-75-c-60-iso10646-1\" -bg \"#000000\" -cr \"#00aaff\" -fg \"#00aaff\" -e \"ruby ~/surf/download.rb '$0';\"", \
	d, NULL } }

#define OPEN(w)     { .v = (char *[]){ "/bin/sh", "-c", \
	"xprop -id $0 -f _SURF_GO 8s -set _SURF_GO $1", \
	winid, w, NULL } }

#define MODKEY GDK_CONTROL_MASK
static Key keys[] = {
    /* modifier	             keyval         function      arg             Focus */
    { MODKEY|GDK_SHIFT_MASK, GDK_r,         reload,       { .b = TRUE } },
    { GDK_SHIFT_MASK,        GDK_F5,        reload,       { .b = TRUE } },
    { MODKEY,                GDK_r,         reload,       { .b = FALSE } },
    { 0,                     GDK_F5,        reload,       { .b = FALSE } },
    { MODKEY,                GDK_p,         print,        { 0 } },
    { MODKEY,                GDK_l,         clipboard,    { .b = TRUE } },
    { MODKEY,                GDK_y,         clipboard,    { .b = FALSE } },
    { MODKEY,                GDK_minus,     zoom,         { .i = -1 } },
    { MODKEY,                GDK_plus,      zoom,         { .i = +1 } },
    { MODKEY,                GDK_0,         zoom,         { .i = 0  } },
    { MODKEY,                GDK_Right,     navigate,     { .i = +1 } },
    { MODKEY,                GDK_BackSpace, navigate,     { .i = -1 } },
//    { 0,                     Button1,       navigate,     { .i = -1 } },
    { MODKEY,                GDK_Left,      navigate,     { .i = -1 } },
    { MODKEY,                GDK_Down,      scroll,       { .i = +1 } },
    { MODKEY,                GDK_Up,        scroll,       { .i = -1 } },
    { 0,                     GDK_Escape,    stop,         { 0 } },
    { MODKEY,                GDK_o,         source,       { 0 } },
    { MODKEY,                GDK_d,         spawn,        URLOPEN("_SURF_URI", "_SURF_GO") },
    { MODKEY,                GDK_s,         spawn,        SEARCH("_SURF_SEARCH", "_SURF_SEARCH") },
    { MODKEY,                GDK_f,         spawn,        SETPROP("_SURF_FIND", "_SURF_FIND") },
    { MODKEY,                GDK_b,         spawn,        BOOKMARK("_SURF_BOOKMARK", "_SURF_BOOKMARK") },
    { MODKEY,                GDK_h,         spawn,        HISTORY },
    { MODKEY,                GDK_n,         find,         { .b = TRUE } },
    { MODKEY|GDK_SHIFT_MASK, GDK_n,         find,         { .b = FALSE } },
    { MODKEY,                GDK_1,         spawn,        OPEN("www.github.com") },
    { MODKEY,                GDK_2,         spawn,        OPEN("www.lastfm.de/") },
    { MODKEY,                GDK_3,         spawn,        OPEN("www.kwick.de/login") },
    { MODKEY,                GDK_4,         spawn,        OPEN("www.archlinux.de") },
    { MODKEY,                GDK_5,         spawn,        OPEN("webmailer.1und1.de") },
    { MODKEY,                GDK_6,         spawn,        OPEN("www.google.de") },
    { MODKEY,                GDK_7,         spawn,        OPEN("www.css4you.de") },
};
