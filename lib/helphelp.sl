% this -*- SLang -*- file supplements 'help.sl' by providing simple navigation
% through the '*function-help*' buffer (S-Lang language help).
% ---------------------------------------------------------------------------
% Simply move near the word in question and use:
%   ?     - apropos on this word
%   ^M    - help on this word
%   ^C?   - help on this word
% If a region is marked, it will be used for the query
%
% you can also add the following to your ~/.jedrc file
#iffalse 
autoload("help_slang", "helphelp.sl");
define slang_mode_hook ()
{
    local_setkey ("help_slang", "^C?");
}
#endif
% to enable this functionality from within 'slang_mode'.
% With minor adjustments, and a bit of ambition, it could be extended
% to access help information for other languages (eg, C, F77, etc.).
%
% --------------------------------------------------------------------------
% (c)1997-2002 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

() = evalfile ("help.sl");	% we need stuff from there
% hijack the 'apropos', 'describe_function', 'describe_variable'
% entry points from help_prefix() and add in the keymap information

% '*help-slang*' would be a nicer name for the buffer!
private variable
  help_buf = "*function-help*",  % no separate 'apropos' buffer anymore
  help_keymap = "*help-slang*";

% we seem to need this an awful lot, since we currently
% have no help mode and the user may have deleted the buffer in
% the meantime ... with a bit better integration in the main JED
% distribution, we could reduce this overhead
static define attach_keymap ()
{
    !if (keymap_p(help_keymap)) {
	make_keymap(help_keymap);
	definekey("help_apropos", "?",   help_keymap);
	definekey("help_slang",   "\r",  help_keymap);
	definekey("help_slang",   "^C?", help_keymap);		% for consistency
    }

    variable cbuf = whatbuf();
    if (bufferp(help_buf)) {
	setbuf(help_buf);
	use_keymap(help_keymap);		% attach keymap here
	setbuf(cbuf);
    }
}

%% %!%+
%% %\function{extract_word}
%% %\synopsis{extract_word}
%% %\usage{String extract_word (String Word_Chars)}
%% %\description
%% % extract a word defined by \var{Word_Chars} from the current buffer
%% %!%-
static define extract_word (chars)
{
    !if (markp()) {
	% skip leading non-word chars, including newline
	do {
	    skip_chars ("^" + chars);
	    !if (eolp()) break;
	} while (down (1));
	bskip_chars (chars);	% in case we started in the middle of a word
	push_mark(); skip_chars (chars);	% mark the word
    }
    return bufsubstr();
}


% re-implementation of apropos() function from help.sl, split in two pieces
% apropos() and help_for_apropos()

%!%+
%\function{help_for_apropos}
%\synopsis{Void help_for_apropos (String)}
%\description
% find Apropos context for a particular string
%\seealso{apropos, help_apropos}
%!%-
define help_for_apropos (s)
{
    if (s == NULL) return; 
    !if (strlen (s)) return;	% no funny strings

    variable a = _apropos("Global", s, 0xF);
    variable n = length (a);
    variable cbuf = whatbuf();

    vmessage ("Found %d matches.", n);

    pop2buf(help_buf);
    attach_keymap();
    erase_buffer();
    
    a = a[array_sort (a)];
    foreach (__tmp(a))
      {
	  insert(());
	  newline();
      }
    buffer_format_in_columns();   
    bob();
    set_buffer_modified_flag(0);
    pop2buf(cbuf);
}

%!%+
%\function{apropos}
%\synopsis{Void apropos (Void)}
%\description
% prompt for a string and find the Apropos context
%\seealso{help_apropos, help_for_apropos}
%!%-
define apropos ()	% <OVERLOAD>
{
   variable s;
   if (MINIBUFFER_ACTIVE) return;

   s = read_mini("apropos:", Null_String, Null_String);
   help_for_apropos(s);
}

% copied from help.sl - added keymap
define describe_function ()
{
    help_do_help_for_object ("Describe Function:", 0x3);
    attach_keymap();
}

define describe_variable ()
{
    help_do_help_for_object ("Describe Variable:", 0xC);
    attach_keymap();
}

static variable wordchars = "0-9A-Z_a-z";	% no localized 'define_word'

%!%+
%\function{help_apropos}
%\synopsis{Void help_apropos (Void)}
%\description
% use either the marked region or else extract an alphanumeric keyword,
% and then display S-Lang apropos context for this entry
%\seealso{apropos, help_slang, help_for_apropos}
%!%-
define help_apropos ()
{
    variable what = extract_word(wordchars);
    help_for_apropos(what);
    attach_keymap();
}

%!%+
%\function{help_slang}
%\synopsis{Void help_slang (Void)}
%\description
% use either the marked region or else extract an alphanumeric keyword,
% and then display S-Lang function/variable help
%\seealso{apropos, help_apropos, help_for_function}
%!%-
define help_slang ()	% <AUTOLOAD>
{
    variable what = extract_word(wordchars);
    help_for_function(what);
    attach_keymap();
}

%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
