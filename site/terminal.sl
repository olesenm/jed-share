% terminal.sl           -*- SLang -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997-2002 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the Net
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file sets up keys and characteristics for various terminals, in what
% attempts to be a uniform fashion so that individual users are unburdened.
%
% It should be loaded by adding the following the line
%       () = evalfile("terminal.sl");
% to the file defaults.sl which is automatically loaded from site.sl
%
% NB:
% using '#if' for distinguishing terminal types is not strictly correct!
% thus we use string_match()

%{{{ general preferences
() = evalfile("wmark");        % MS-Windows Shift-marking + cut/paste

% make ESC Backspace == ESC DEL
if (is_defined("yp_yank_pop")) {
    local_setkey("yp_bkill_word", "\e^H");
}
else {
    local_setkey("bdelete_word", "\e^H");
}
local_setkey("move_to_tab", "\e\t");   % Emacs: ESC TAB
%}}}
#ifdef MSDOS OS2
%{{{ Dos OS/2
% set_color_scheme(Null_String);
IGNORE_BEEP = 4;        % flash status line (djgpp version only)
LINENUMBERS = 2;        % lines/columns
DISPLAY_EIGHT_BIT = 1;
HORIZONTAL_PAN  = -1;   % pan window

# ifdef MSWINDOWS
() = evalfile("iso-latin");
# endif
% conveniences for the various keyboards / languages

if ($1 = getenv("NWLANGUAGE"), $1 != NULL) {
    $1 = strup($1);
    if (string_match($1, "^DE", 1)) {
        local_setkey("dabbrev", "\e-"); % can't reach "\e/"
    }
}
%}}}
#elifdef UNIX
% standard Unix preferences
IGNORE_BEEP = 0;        % Do not beep the terminal in any way (too annoying)
OUTPUT_RATE = 0;        % Should be set automatically by JED.
LINENUMBERS = 1;        % display linenumber only
DISPLAY_EIGHT_BIT = 160;% assume ISO Latin 1

#ifdef XWINDOWS
putenv("TERM=xterm");
#endif
if ($1 = getenv("TERM"), $1 == NULL) $1 = Null_String;

#ifdef XWINDOWS
%{{{ XWINDOWS - remap to xterm (rxvt) escape sequences
% set_color_scheme(Null_String);
% putenv("TERMINFO=/usr/local/lib/terminfo");
%
TERM_BLINK_MODE = 1;
LINENUMBERS = 2;                % display line & column numbers
%
% x_set_keysym(0xFF08, '$',     "^D");          % S-Backspace
% x_set_keysym(0xFF08, '^',     "^D");          % C-Backspace
x_set_keysym(0xFF09, '$',       "\e[Z");        % S-Tab
x_set_keysym(0xFF09, '^',       "^Q^I");        % C-Tab -> quoted tab
%
x_set_keysym(0xFFFF,  0,        "\e[3~");       % Delete
x_set_keysym(0xFFFF, '$',       "\e[3$");       % S-Delete
x_set_keysym(0xFFFF, '^',       "\e[3^");       % C-Delete
%}}}
#else   % XWINDOWS
%{{{ TERM_BLINK_MODE
if ($2 = getenv("COLORTERM"), $2 == NULL) $2 = Null_String;
if (string_match($2, "^rxvt", 1)  or string_match($1, "^rxvt", 1) or
    string_match($2, "^xterm", 1) or string_match($1, "^xterm.color", 1) )
{
    TERM_BLINK_MODE = 1;
    % define simple_menu()
    % {
    %    if (strlen(expand_jedlib_file("jedmenu.sl"))) () = evalfile("jedmenu");
    % }
}
%}}}
#endif  % XWINDOWS
%{{{ xterm* rxvt*
if (string_match($1, "^kvt", 1)  or
    string_match($1, "^rxvt", 1) or
    string_match($1, "^xterm", 1)) {
#ifndef XWINDOWS
    % map_input(127, 4);               % map: ^? -> ^D
    set_term_vtxxx(0);
    % xterm mouse support - only load once
    ifnot (BATCH) ifnot (is_defined("Mouse_Button")) () = evalfile("mousex");

    % we mostly have a poor terminfo for xterm Key_Home / Key_End
    local_setkey("bol",         "\e[1~");
    local_setkey("eol_cmd",     "\e[4~");
#endif
    %    local_setkey("unindent_line",  "\e[Z");        % S-Tab
    %
    % Map keypad to motion keys
    local_setkey("toggle_overwrite",    "\eOp");        % KP_0 (Insert)
    local_setkey("delete_char_cmd",     "\eOn");        % KP_Period (Delete)
    local_setkey("eol_cmd",             "\eOq");        % KP_1 (End)
    local_setkey("next_line_cmd",       "\eOr");        % KP_2 (Down)
    local_setkey("page_down",           "\eOs");        % KP_3 (Next)
    local_setkey("previous_char_cmd",   "\eOt");        % KP_4 (Left)
    local_setkey("next_char_cmd",       "\eOv");        % KP_6 (Right)
    local_setkey(".0 recenter", "\eOu");        % KP_5 (center)
    local_setkey("bol",         "\eOw");        % KP_7 (Home)
    local_setkey("previous_line_cmd",   "\eOx");        % KP_8 (Up)
    local_setkey("page_up",             "\eOy");        % KP_9 (Prior)
    %
    local_setkey("backward_paragraph",  "\eOa");        % C-Up
    local_setkey("forward_paragraph",   "\eOb");        % C-Down
    local_setkey("skip_word",           "\eOc");        % C-Right
    local_setkey("bskip_word",  "\eOd");        % C-Left
}
%}}}
#endif  % UNIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign Function keys (f1 - f10) as per emacs
local_setkey("help_prefix",     Key_F1);
local_setkey("undo",            Key_F2);
local_setkey("find_file",       Key_F3);
local_setkey("pop_mark_0",      Key_Shift_F4);  % S-F4 = pop mark
local_setkey("smart_set_mark_cmd",      Key_F4);
local_setkey("yp_copy_region_as_kill",  Key_F5);
local_setkey("yp_yank",         Key_F6);
local_setkey("save_buffer",     Key_F7);
local_setkey("begin_macro",     Key_F8);
local_setkey("end_macro",       Key_F9);
local_setkey("execute_macro",   Key_F10);
%
local_setkey("help_slang",      Key_Shift_F1);
local_setkey("bol",             Key_Home);
local_setkey("eol_cmd",         Key_End);
local_setkey("toggle_overwrite",Key_Ins);

local_setkey("delete_char_cmd", Key_Del);

local_setkey("goto_top_of_window",      Key_Alt_Up);
local_setkey("goto_bottom_of_window",   Key_Alt_Down);
local_setkey("next_wind_up",            Key_Alt_PgUp);
local_setkey("next_wind_dn",            Key_Alt_PgDn);
local_setkey("backward_paragraph",      Key_Ctrl_Up);
local_setkey("forward_paragraph",       Key_Ctrl_Down);
local_setkey("skip_word",       Key_Ctrl_Right);
local_setkey("bskip_word",      Key_Ctrl_Left);
% local_setkey("\".nil\"flush", Key_Ctrl_Home);
%
if (is_defined("yp_yank_pop")) {
    local_setkey("yp_kill_line",        Key_Ctrl_End);  % C-End
}
else {
   local_setkey("del_eol",      Key_Ctrl_End);
}
%
local_setkey("bob",             Key_Ctrl_PgUp);
local_setkey("eob",             Key_Ctrl_PgDn);
local_setkey("@\033\001",       Key_Alt_Home);  % -> ESC ^A
local_setkey("@\033\005",       Key_Alt_End);   % -> ESC ^E

%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
