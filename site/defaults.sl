% defaults.sl   -*- mode: SLang; mode: Fold -*-
% defaults.sl is automatically loaded from site.sl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997-2009 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strlen(expand_jedlib_file("loader.sl"))) () = evalfile("loader.sl");

%{{{ default key bindings
ifnot (BATCH) {
    () = evalfile("emacs");
    % don't like incremental search
    setkey("search_backward",  "^R");
    setkey("search_forward",   "^S");
    setkey("trim_buffer",      "^X^O");        % Emacs: delete-blank-lines

    setkey("re_search_backward","\e^R");       % Emacs: C-M-r
    setkey("re_search_forward",        "\e^S");        % Emacs: C-M-s
    % setkey("sys_spawn_cmd",  "^X^Z");        % Emacs: suspend-emacs

    setkey("mark_word",                "\e@");         % Emacs: mark-word
    setkey("transpose_words",  "\et");         % Emacs: M-t
    setkey("goto_line_cmd",    "\e#");         % M-#   % arbitrary
    setkey("string_rect",      "^XRi");        % rectangle related

    % $1 = getenv("LANG");
    % if (string_match($1, "^de", 1)) {        % german keyboard
    setkey("self_insert_cmd",  "`");   % instead of quoted_insert
    setkey("dabbrev",          "\e-"); % instead of ESC-/
    % }

#ifdef MSWINDOWS
    set_status_line("(WJed %v) Emacs: %b    (%m%a%n%o)  %p,%c   %t", 1);
#elifdef XWINDOWS
    set_status_line("(XJed %v) Emacs: %b    (%m%a%n%o)  %p,%c   %t", 1);
#endif
    autoload("bufed", "bufed");
    setkey("bufed", "^X^B");
}
%}}}

%{{{ vi_percent()
%!% Go to the matching parenthesis if on parenthesis otherwise insert %
define vi_percent()    % <AUTOLOAD>
{
    variable ch = what_char();
    variable pairs = "([{}])";

    ifnot (strcmp("html", get_mode_name()))
    {
        pairs = "([{<>}])";
    }

    if (ch and is_substr(pairs, char(ch))) {
        push_mark();
        if (1 == find_matching_delimiter(ch)) {
            pop_mark_0();
        }
        else {
            pop_mark_1();
            error("mismatched");
        }
    }
    else {
        insert_char('%');
    }
}
#iftrue
setkey("vi_percent", "%");
#endif
%}}}

%{{{ Global Variables
WANT_EOB = 1;
KILL_LINE_FEATURE = 1;
ADD_NEWLINE = 1;
C_BRA_NEWLINE = -1;

% C_No_Brace_Offset = 0;        % no EXTRA space following 'if', 'else' ...
% C_CONTINUED_OFFSET = 2;       % indentation for continued lines
% C_Colon_Offset = 1;   % indentation of case statements
%}}}

%{{{ insert_other_window()
%!% Insert contents of other window
define insert_other_window()
{
    if (nwindows() != 2) return;
    otherwindow();
    whatbuf();
    otherwindow();
    insbuf();
}
%}}}

variable C_No_Brace_Offset = 1; % ensure that it is defined
C_Comment_Column = 41;          % column for a C comment (put on tab stop)
% C_CONTINUED_OFFSET = 0;

%}}}
%----------------------------------------------------------------------
%{{{ LaTeX stuff
add_mode_for_extension("latex", "tex");        % overrides tex_mode
add_mode_for_extension("latex", "sty");
add_mode_for_extension("latex", "cls");
%}}}
%----------------------------------------------------------------------

%{{{ terminal characteristics/keys
ifnot (BATCH) { () = evalfile("terminal.sl"); }
%}}}
%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%%
