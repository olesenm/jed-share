% apropos.sl		-*- SLang -*-
%
% extra routines for help.sl that provide convenient functions to help
% navigating thru the S-Lang language help.  With minor adjustments, could
% be extended to access general language (C, F77, etc.) help.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997,98 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!%+
%\function{keyword_extract}
%\synopsis{keyword_extract}
%\usage{String keyword_extract (void)}
%\description
% extract an alphanumeric keyword (including underscores)
% from the current buffer
%!%-
define keyword_extract ()
{
   variable chars = "0-9A-Z_a-z";

   !if (markp())
     {
	% skip leading non-word chars, including newline
	do {
	   skip_chars ("^" + chars);
	   !if (eolp ()) break;
	} while (down (1));
	bskip_chars (chars);	% in case we started in the middle of a word
	push_mark (); skip_chars (chars);	% mark the word
     }
   return bufsubstr ();
}

% re-implementation of apropos() function from help.sl, split in two pieces
% apropos() and help_for_apropos()

%!% Void help_for_apropos (String)
%!% find Apropos context for a particular string
define help_for_apropos (s)
{
   variable n, cbuf = whatbuf();

   if (s == NULL) return; !if (strlen (s)) return;	% no funny strings

   n = _apropos(s, 0xF);
   pop2buf("*apropos*");
   erase_buffer();
   loop (n)
     {
	insert(());
	newline();
     }
   buffer_format_in_columns();
   bob();
   set_buffer_modified_flag(0);
   pop2buf(cbuf);
}

%!% Void apropos (void)
%!% prompt for a string and find the Apropos context
define apropos ()
{
   variable s;
   if (MINIBUFFER_ACTIVE) return;

   s = read_mini ("apropos:", "", "");
   help_for_apropos (s);
}

%!% Void slang_help (void)
%!% extract an alphanumeric keyword and display S-Lang function/variable help
define slang_help ()
{
   help_for_function (keyword_extract());
}

%!% Void slang_apropos (void)
%!% extract an alphanumeric keyword and display S-Lang apropos context
define slang_apropos ()
{
   help_for_apropos (keyword_extract());
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
