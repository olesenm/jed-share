% AUTOMATICALLY GENERATED [2019-02-20 10:36:23] - DO NOT EDIT !!
% CHANGES MADE HERE WILL BE LOST THE NEXT TIME 'slloader.pl' IS RUN !!
%
% _loader.sl: </home/mol/share/jed/lib>
% ---------------------------------------------------------------------------
% this file is called by 'loader.sl' and defines autoloads/completions
% for SLang files in this directory
%
% NOTES:
%   'slloader.pl' searches for 'define' statements that have
%   any '<AUTOLOAD>', '<COMPLETE>', or '<COMPLETION>' tags
%   and adds these function names to this file.
%   The <EXTS="..."> tag (after a mode definition) is also supported.
%
%   eg,
%     public define foo()  % <AUTOLOAD> <COMPLETE>
%     define bar()         % <AUTOLOAD>
%     private define foo() % <AUTOLOAD> <= IGNORED (cannot export a private)
%     static  define foo() % <COMPLETE> <= IGNORED (cannot export a static)
%     define foo_mode()    % <EXTS="bar,baz">
%
%   any 'define' statement with an '<OVERLOAD>' tag indictes that an
%   'evalfile()' should always be used for the file.
%   This is useful for overloading standard library functions.
%
% ---------------------------------------------------------------------------
% list of function/filename pairs for autoload
%
$0 = _stkdepth();       % save stack depth
% <align>
	"align";	"align";
	"align_to";	"align";
	"back_to_indentation";	"align";
	"indent_region";	"align";
	"indent_tab";	"align";
	"move_to_tab";	"align";
	"tab_to_tab_stop1";	"align";
	"trim_backward";	"align";
	"untab_buffer";	"align";
% <charset>
	"charset";	"charset";
% <cmisc1>
	"c_make_comment";	"cmisc1";
% <comment>
	"c_box";	"comment";
	"c_line";	"comment";
	"c_un_comment";	"comment";
% <cwd>
	"cwd";	"cwd";
% <helphelp>
	"help_slang";	"helphelp";
% <hpcalc>
	"hpcalc";	"hpcalc";
% <local>
	"goto_column_cmd";	"local";
	"goto_line_cmd";	"local";
	"indent_rect";	"local";
	"mark_word";	"local";
	"string_rect";	"local";
	"transpose_words";	"local";
	"unindent_line";	"local";
% <mpp_mode>
	"mpp_mode";	"mpp_mode";
(_stkdepth() - $0)/2;   % leave count on stack
_autoload;
% ---------------------------------------------------------------------------
% list of function names for completion
%
$0 = _stkdepth();       % save stack depth
% <hpcalc>
	"hpcalc";
(_stkdepth() - $0);     % leave count on stack
_add_completion;
% ---------------------------------------------------------------------------
	() = evalfile("helphelp");
% extensions for <mpp> mode
	add_mode_for_extension("mpp", "MAC");
	add_mode_for_extension("mpp", "MACRO");
	add_mode_for_extension("mpp", "STARCD");
% --------------------------------------------------------------- end-of-file

