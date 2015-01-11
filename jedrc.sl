% User Initialization file for the JED editor  -*- mode: SLang; mode: Fold -*-
% NB: backspace <-> delete using map_input() in terminal.sl

%{{{ common variables
enable_top_status_line (0);
HORIZONTAL_PAN  = -1;           % pan whole window
%}}}
%{{{ MSDOS OS2
#ifdef MSDOS OS2
#ifdef MSWINDOWS
() = evalfile("wmenu.sl"); simple_menu();
#endif
set_color_scheme ("White-on-Black");
%}}}
#elifdef UNIX
%{{{ XWINDOWS
#ifdef XWINDOWS
set_color_scheme ("White-on-Black");
x_set_window_name (strcat ("XJed - ", getenv ("USER")));
%}}}
%{{{ non-XWINDOWS, colors & mouse
#else   % XWINDOWS
#if$TERM xterm?color linux
set_color_scheme ("White-on-Black");
#elif$COLORTERM rxvt conex xterm*
set_color_scheme ("White-on-Black");
#elif$COLORTERM hft aixterm vt100-am
set_color_scheme ("Gray-on-Black");
#elif$JED_COLORS
set_color_scheme (getenv ("JED_COLORS"));
#endif
#endif  % XWINDOWS
%}}}
%{{{ mail settings
#ifn$USER olesen
variable Mail_Reply_To = "<olesen@me.QueensU.CA>";
#endif

$0 = _stkdepth ();
$1 = "me.queensu.ca,olesen";
variable Rmail_Dont_Reply_To =
strncat ("olesen@conn.", $1, "@weber.", $1, _stkdepth () - $0);

define mail_hook ()             % define a convenient mail hook
{
   local_setkey ("mail_send", "^C^C");  % send and exit buffer
   local_setkey ("mailalias_expand", "^C^E");
   % set_buffer_modified_flag (0);
}

%define rmail_hook ()   {}
%define rmail_folder_hook ()    {}
setkey ("rmail",        "^X^M");

%}}}
%{{{ man page
.(unix_man)man          % quick and easy way to get man-pages
.()clean_manpage        % forward reference

%!% retrieve a man page entry and use clean_manpage to clean it up
define conn_man ()
{
   variable subj, buf = "*manual-entry*", msg = "Getting man page...";

   ifnot (is_defined ("unix_man")) () = evalfile ("man.sl");

   subj = read_mini ("conn_man", Null_String, Null_String);
   ifnot (strlen (subj)) return;

   pop2buf (buf);
   set_readonly (0);
   erase_buffer ();
   flush (msg);
   () = run_shell_cmd (Sprintf ("rsh 130.15.72.40 man %s 2> /dev/null", subj, 1));
   clean_manpage ();
   bob ();
   set_buffer_modified_flag (0);
   most_mode ();
   set_readonly (1);
}
add_completion ("conn_man");
%}}}
#endif  % MSDOS/UNIX

%{{{ local_setup()
% if the file "jed.sl" exists in the current directory, evaluate it
% this provides an easy way to load custom definitions
define local_setup ()
{
   variable f = "jed.sl";
   if (file_status (f) == 1)
     () = evalfile (f);
}
%}}}

define makefile_mode ()
{
   text_mode ();
}

%{{{ Hooks:  read jed/doc/hooks.sl for more information
%
#ifdef UNIX
%{{{ ashell
#iffalse
variable Shell_Default_Shell = "/bin/csh";
define ashell_mode_hook ()
{
   putenv ("TERM=jed");
   putenv (strcat ("SHELL=", Shell_Default_Shell));
}
#else
variable Shell_Default_Shell = "/bin/ksh";
define ashell_mode_hook ()
{
   putenv ("TERM=jed");
   putenv ("HISTFILE=/dev/null");
   putenv (strcat ("ENV=", expand_filename ("~/.kshrc")));
   putenv (strcat ("SHELL=", Shell_Default_Shell));
}
#endif
%}}}

% I always use a Bourne-type Shell
% define sh_mode_hook ()
% {
%    bsh_mode ();
% }

% define ksh_mode ()
% {
%    bsh_mode ();
% }
#endif
define dired_hook ()
{
   % local_unsetkey ("^K");
   % local_setkey ("dired_kill_line", "^K");
   local_setkey(". 1 dired_point", "\t");
   local_setkey("dired_find", "\r");
}
%define dired_mode_hook ()      {}
%define text_mode_hook ()       {}
%define fortran_hook ()         {}
%define tex_mode_hook ()        {}

define c_mode_hook ()
{
%%   CASE_SEARCH = 1;
%    % local_setkey ("c_comment_region", "^X;");
   local_setkey ("compile", "^C^C");
   local_setkey ("c_mark_function", "\eH");     % instead of ESC Ctrl-H

   local_setkey ("insert_fold_beg",     "\e{");
   local_setkey ("insert_fold_end",     "\e}");

   % some more keywords
#iffalse
   () = add_keywords ("C", "fflushprintfsize_tstderrstdout", 6, 1);

   () = add_keywords ("C", "FILE", 4, 1);
   () = add_keywords ("C", "fopen", 5, 1);
   () = add_keywords ("C", "fclosestrcpy", 6, 1);
   () = add_keywords ("C", "fprintf", 7, 1);
#endif
   local_setup ();
}

define slang_mode_hook ()
{
   local_setkey ("evalbuffer",          "^C^C");
   local_setkey ("insert_fold_beg",     "\e{");
   local_setkey ("insert_fold_end",     "\e}");

   % some more keywords
   () = add_keywords ("SLANG", "BATCH", 5, 1);
   () = add_keywords ("SLANG", "setkey", 6, 1);
   () = add_keywords ("SLANG", "autoload", 8, 1);
   () = add_keywords ("SLANG", "_autoload", 9, 1);
}
%}}}
%-------------------------------------------------------------------------
% additional functions
%{{{ folding
autoload ("fold_get_marks",     "folding");
define insert_fold_beg ()
{
   variable s1, s2;
   (s1,,s2,) = fold_get_marks ();
   insert (strcat (s1, s2));
}

define insert_fold_end ()
{
   variable e1, e2;
   (,e1,,e2) = fold_get_marks ();
   insert (strcat (e1, e2));
}
%}}}

% completions
add_completion ("replace_across_buffer_files");
% cpp preprocessed files
add_mode_for_extension ("c", "i");

%{{{ toggle_case()
%!% toggle case searching on/off
define toggle_case ()
{
   CASE_SEARCH = not (CASE_SEARCH);
   "case ";
   if (CASE_SEARCH) "respected"; else "ignored";
   message (strcat());
}
add_completion ("toggle_case");
%}}}
%{{{ toggle_backup()
define toggle_backup ()
{
   setbuf_info (getbuf_info() xor 0x100);
   (,,,$1) = getbuf_info ();
   if ($1 & 0x100) "No file backup"; else "File backup";
   message (());
}
add_completion ("toggle_backup");
%}}}
define libref ()        %{{{
{
   variable file = "/usr/local/info/", buf = "libref.doc";
#ifdef MSDOS OS2
   file = strcat ("c:", file);
#endif
   file = strcat (file, buf);

   if (bufferp (buf))
     {
        pop2buf (buf);
     }
   else if (find_file (file))
     {
        getbuf_info ();         % mark unchanged, no backup, no undo, etc.
        () | 0x108;
        () & ~(0x23);
        setbuf_info (());
     }
   else
     {
        delbuf (whatbuf ());    % not found
     }
}
add_completion ("libref");
%}}}
%{{{ vi_percent()
#iffalse
%!% Go to the matching parenthesis if on parenthesis otherwise insert %
define vi_percent ()
{
   if (looking_at_char ('(') or looking_at_char (')'))
     call ("goto_match");
   else
     insert_char ('%');
}
setkey ("vi_percent", "%");
#endif
%}}}
%-------------------------------------------------------------------------
%{{{ more autoload/setkey

autoload ("fopen",      "fopen");

setkey ("enlarge_window",       "^^");
setkey ("backward_paragraph",   "\e^P");
setkey ("forward_paragraph",    "\e^N");
setkey ("query_replace_match",  "^X%"); % vaguely like the "\e%" binding

_autoload ("c_box", "cbox",
           "c_un_comment", "cbox",
           "c_eof", "cbox",
           3);
setkey(". '-'c_box",    "^C-");
setkey("c_un_comment", "\e:");

_autoload ("indent_region",     "align",
           "back_to_indentation","align",
           "move_to_tab",       "align",
           "tab_to_tab_stop1",  "align",
           "just_one_space",    "align",
           5);

setkey ("indent_region",        "\e^\\");       % C-M-\
setkey ("back_to_indentation",  "\em");         % M-m
setkey ("move_to_tab",          "\e\t");        % M-TAB
setkey ("tab_to_tab_stop1",     "\ei");         % M-i
setkey ("just_one_space",       "\e\040");      % M-SPACE

% autoload ("compile_previous_error",   "compile");
% setkey ("compile_previous_error",     "^X`");

autoload ("keycode",  "keycode");

autoload ("bufed", "bufed");
setkey ("bufed", "^X^B");
%}}}
%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%%

#if$OSTYPE AIX
%{{{ toggle_compiler
%!% compiler name in the database "compile.dat"
ifnot (is_defined ("compile_parse_error_function"))
variable compile_parse_error_function = Null_String;

%!% regular expression to extract compile errors
ifnot (is_defined ("compile_parse_regexp"))
variable compile_parse_regexp = Null_String;

define toggle_compiler ()
{
   if (strcmp (compile_parse_error_function, "gcc")) "gcc"; else "xlc";
   compile_parse_error_function = ();
   compile_parse_regexp = Null_String;
   () = evalfile ("compile.sl");
   flush (compile_parse_error_function);
}
add_completion ("toggle_compiler");
%}}}
#endif  % AIX

%{{{ search_across_buffer_files ()
%
%  This function executes a query-replace across all buffers attached to
%  a file.
%

ifnot (is_defined ("search_across_lines")) () = evalfile ("search");
% This evalfile also brings in replace_do_replace.

define search_across_buffer_files ()
{
   variable cbuf = whatbuf ();
   variable n = buffer_list ();
   variable str, buf, file, flags;

   str = read_mini ("Search files:", LAST_SEARCH, Null_String);
   ifnot (strlen (str)) return;
   save_search_string (str);

   push_spot ();                % save our location
   ERROR_BLOCK
     {
        sw2buf (cbuf);
        pop_spot ();
        loop (n) pop ();        % remove buffers from stack
     }

   while (n)
     {
        buf = ();  n--;

        % skip special buffers
        if ((buf[0] == '*') or (buf[0] == ' ')) continue;

        sw2buf (buf);

        (file,,,flags) = getbuf_info ();

        % skip if no file associated with buffer, or is read only
        ifnot (strlen (file) or (flags & 8)) continue;

        % ok, this buffer is what we want.

        push_spot ();
        ERROR_BLOCK
          {
             pop_spot ();
          }

        bob ();

        () = search_maybe_again (&search_across_lines, str, 1);
        pop_spot ();
     }

   EXECUTE_ERROR_BLOCK;
   message ("Done.");
}
add_completion ("search_across_buffer_files");
%}}}

define duplicate_line()         %{{{
{
   push_spot ();
   line_as_string ();           % on stack
   newline ();
   insert (());
   pop_spot ();
}
setkey ("duplicate_line", "\E+");   % looks like ESC +
setkey ("duplicate_line", "\E=");   % looks like ESC +
%}}}

%{{{ unused stuff
#iffalse
variable  Jed_State_File = dircat (getenv ("HOME"), ".jedstate");

define exit_hook ()
{
   variable f = buffer_filename ();

   if (strlen(f))
     {
        () = delete_file (Jed_State_File);
# ifdef MSDOS OS2               % fix backslash char used for pathname
        f = str_quote_string (f, "\\", '\\');
# endif
        f = Sprintf ("()=find_file(\"%s\");goto_line(%d);goto_column(%d)"
                     f, what_line (), what_column (), 3);
        () = write_string_to_file (f, Jed_State_File);
     }
   exit_jed();
}

define startup_hook ()
{
   if (MAIN_ARGC == 1)
     {
        if (1 == file_status(Jed_State_File))
          {
             () = evalfile (Jed_State_File);
             () = delete_file (Jed_State_File);
          }
     }
}
#endif
%}}}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
