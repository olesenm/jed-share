% This is a simple mode for editing AVL-FIRE Tim files
% It does not defined any form of indentation style.  
% Rather, it simply implements a highlighting scheme.

$1 = "TIM";

create_syntax_table ($1);
define_syntax ("*", "", '%', $1);
define_syntax ("([{", ")]}", '(', $1);

define_syntax ('\'', '"', $1);
define_syntax ('"', '"', $1);

define_syntax ('\\', '\\', $1);
define_syntax ("-0-9a-zA-Z_", 'w', $1);        % words
define_syntax ("-+0-9eE.xX", '0', $1);   % Numbers
define_syntax (",;:", ',', $1);
define_syntax ("%-+/&*=<>|!~^", '+', $1);

#ifdef HAS_DFA_SYNTAX
enable_highlight_cache ("shmode.dfa", $1);
define_highlight_rule ("\\\\.", "normal", $1);
define_highlight_rule ("\\*.*$", "comment", $1);
define_highlight_rule ("\"([^\\\\\"]|\\\\.)*\"", "string", $1);
define_highlight_rule ("\"([^\\\\\"]|\\\\.)*$", "string", $1);
define_highlight_rule ("'[^']*'", "string", $1);
define_highlight_rule ("'[^']*$", "string", $1);
define_highlight_rule("[0-9]+(\\.[0-9]*)?([Ee][\\+\\-]?[0-9]*)?",
                      "number", $1);
define_highlight_rule ("[\\|&;\\(\\)<>]", "Qdelimiter", $1);
define_highlight_rule ("[\\[\\]\\*\\?]", "Qoperator", $1);
define_highlight_rule ("[^ \t\"'\\\\\\|&;\\(\\)<>\\[\\]\\*\\?]+",
                       "Knormal", $1);
define_highlight_rule (".", "normal", $1);
build_highlight_table ($1);
#endif

() = define_keywords ($1, "LINES", 5);

define tim_mode ()
{
   set_mode("TIM", 0);
   use_syntax_table ("TIM");
%   mode_set_mode_info ("TIM", "fold_info", "#{{{\r#}}}\r\r");
   runhooks("tim_mode_hook");
}

