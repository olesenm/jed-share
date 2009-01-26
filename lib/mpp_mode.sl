% simple mode for mpp (Mark's macro pre-processor) macro files
% It does not defined any indentation style.
% Rather, it simply implements a highlighting scheme.

$1 = "mpp";

% create/initialize the syntax tables
create_syntax_table($1);
define_syntax( "//", Null_String, '%', $1 );    % EOL comments
define_syntax( "##", Null_String, '%', $1 );    % EOL comments
define_syntax( "<comment", "</comment>", '%', $1 ); % long comments
define_syntax( '#',           '#',   $1 );      % preprocess
define_syntax( '\'',          '"',   $1 );      % string
define_syntax( '"',           '"',   $1 );      % string
define_syntax( "([{",         ")]}", '(', $1 ); % brackets

define_syntax( '\\',           '\\',  $1 );      % quote character
define_syntax( "-0-9a-zA-Z_", 'w',   $1 );      % words
define_syntax( "-+0-9.eE",    '0',   $1 );      % Numbers
define_syntax( "$,.:;?",      ',',   $1 );      % delimiter
define_syntax( "-+/&|",       '+',   $1 );      % operators
set_syntax_flags( $1, 0x01 | 0x10 | 0x20 );


() = define_keywords($1,
                     "centcsetcsysedgegetcgetvheadloadoperoverplty" +
                     "poptputcpsyssetrsetwtermvsetwindzoom",
                     4);
() = define_keywords($1, "cdispclosecplotcsdelofilepldispllabpllocsnorm", 5);
() = define_keywords($1, "clocalcscalereplotspointsystem", 6);

() = define_keywords_n($1, "eqgegtleltneon", 2, 1);
() = define_keywords_n($1, "addalloff", 3, 1);
() = define_keywords_n($1, "cartexecnewsnonesubs", 4, 1);
() = define_keywords_n($1, "clearfluidlocal", 5, 1);
() = define_keywords_n($1, "deleteinvert", 6, 1);

% static define mpp_indent_preprocess_line ()
% {
%    variable col;
% 
%    push_spot_bol ();
%    
%    trim ();
%    !if (up_1 ())
%      {
%       pop_spot ();
%       return;
%      }
%    
%    !if (bol_bsearch_char ('#'))
%      {
%       pop_spot ();
%       return;
%      }
%    go_right_1 ();
%    skip_white ();
%    col = what_column ();
%    if (looking_at ("if"))
%      col += C_Preprocess_Indent;
%    else if (looking_at ("el"))
%      col += C_Preprocess_Indent;
%    
%    pop_spot ();
%    go_right_1 ();
%    skip_white ();
%    
%    !if (looking_at ("error"))
%      {
%       if (looking_at_char ('e'))
%         col -= C_Preprocess_Indent;
%      }
% 
%    if (what_column () == col)
%      return;
%    bskip_white ();
%    trim ();
%    whitespace (col - 2);
% }
 
define mpp_mode ()      % <AUTO> <EXTS="MAC,MACRO">
{
   variable mode = "mpp";
   set_mode(mode, 0);
   use_syntax_table(mode);
   mode_set_mode_info(mode, "fold_info", "//{{{\r//}}}\r\r");
   run_mode_hooks("mpp_mode_hook");
}
