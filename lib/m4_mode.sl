% simple mode for m4 macro files
% It does not defined any indentation style.
% Rather, it simply implements a highlighting scheme.

$1 = "m4";

% Create/initialize the syntax tables
create_syntax_table($1);
define_syntax("#", "", '%', $1);    % EOL comments
define_syntax('"',   '"',   $1);    % quoting
define_syntax("([{", ")]}", '(', $1); % brackets

define_syntax('\\',          '\\',  $1);      % quote character
define_syntax("-0-9a-zA-Z_", 'w',   $1);      % words
define_syntax("-+0-9.eE",    '0',   $1);      % Numbers
define_syntax(",;:", ',',  $1);
define_syntax("-+/&|",     '+',     $1);      % operators

() = define_keywords($1, "defneval", 4);
() = define_keywords($1, "ifdef", 5);
() = define_keywords($1, "definedivertformatifelse", 6);
() = define_keywords($1, "builtin", 7);
() = define_keywords($1, "undefineundivert", 8);
() = define_keywords($1, "changecom", 9);
() = define_keywords($1, "changeword", 10);
() = define_keywords($1, "changequote", 11);

() = define_keywords_n($1, "dnl", 3, 2);
() = define_keywords_n($1, "popdef", 6, 2);
() = define_keywords_n($1, "includepushdef", 7, 2);

define m4_mode()      % <AUTO> <EXTS="m4">
{
   variable mode = "m4";
   set_mode(mode, 0);
   use_syntax_table(mode);
   run_mode_hooks("m4_mode_hook");
}

%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
