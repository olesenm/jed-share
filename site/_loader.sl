% AUTOMATICALLY GENERATED [2008-10-30 09:08:53] - DO NOT EDIT !!
% CHANGES MADE HERE WILL BE LOST THE NEXT TIME 'slloader.pl' IS RUN !!
%
% _loader.sl: </data/app/share/jed/site>
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
$0 = _stkdepth();	% save stack depth
% <defaults>
	"vi_percent";	"defaults";
% <foam_mode>
	"foam_mode";	"foam_mode";
(_stkdepth() - $0)/2;	% leave count on stack
_autoload;
% ---------------------------------------------------------------------------
% list of function names for completion
%
$0 = _stkdepth();	% save stack depth
% <foam_mode>
	"foam_mode";
(_stkdepth() - $0);	% leave count on stack
_add_completion;
% ---------------------------------------------------------------------------
%	no files for evalfile()
% extensions for <foam> mode
	add_mode_for_extension("foam", "C");
	add_mode_for_extension("foam", "H");
% ----------------------------------------------------------------------- END

