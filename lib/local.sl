% local.sl		-*- SLang -*-
% extra local functions, some of which aid in Emacs compliance.
% Autoload upon demand.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997-2002 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!%+
%\function{mark_word}
%\synopsis{Void mark_word (Void)}
%\description
% marks a woard according to the current definitons of a word character
%#v+
% Emacs binding: setkey ("mark_word",  "\e@");
%#v-
%\seealso{skip_word, bskip_word}
%!%-
define mark_word ()	% <AUTOLOAD>
{
    while (skip_non_word_chars(), eolp()) {
	!if (right (1)) break;
    }
    
    skip_word ();
    !if (is_visible_mark ()) {
	push_visible_mark ();
	bskip_word ();
	exchange_point_and_mark ();
    }
}

%!%+
%\function{transpose_word}
%\synopsis{Void transpose_word (Void)}
%\description
% transpose word1 and word2, move point after word2
%#v+
% Emacs binding: setkey ("transpose_words",  "\et");
%#v-
%\seealso{skip_word, bskip_word}
%!%-
define transpose_words ()	% <AUTOLOAD>
{
    push_mark();		% save original position

    % get word2
    skip_non_word_chars();
    skip_word_chars();
    push_mark();
    bskip_word_chars();
    variable word2 = bufsubstr();

    % get word1
    bskip_non_word_chars();
    push_mark();
    bskip_word_chars();
    variable word1 = bufsubstr();

    variable n1 = strlen (word1);
    variable n2 = strlen (word2);
    !if (n1 and n2) {
	pop_mark_1();		% restore original position
	return;
    }

    pop_mark_0();		% forget original position

    deln (n1);
    insert (word2);
    skip_non_word_chars();
    deln (n2);
    insert (word1);
}

%!%+
%\function{string_rect}
%\synopsis{Void string_rect (Void)}
%\description
% prefix each line with a string
%#v+
% Possible Emacs binding:
% local_setkey ("string_rect", "^XRi");
%#v-
%!%-
define string_rect () 	% <AUTOLOAD>
{
    variable col, str, n, nlines;
    variable start;
    check_region (0);

    % find the correct starting column
    col = what_column ();
    nlines = what_line ();
    exchange_point_and_mark ();
    n = what_column ();
    start = what_line ();
    if (n < col) col = n;
    nlines++;
    nlines -= start;
    
    % what string should be inserted?
    str = read_mini ("Rect String Insert:", "", "");
    n = strlen (str);
    !if (n) return;

    loop (nlines) {
	goto_column (col);
	insert (str);
	go_down_1();
    }
    % re-mark the region
    goto_line (start);
    goto_column (col);
}


%!%+
%\function{unindent_line}
%\synopsis{Void unindent_line (Void)}
%\description
% Remove indentation from beginning of line (ie, trim the beg-of-line)
%!%-
define unindent_line ()		% <AUTOLOAD>
{
    push_spot_bol (); trim (); pop_spot ();
}

% service function for 'goto_line_cmd' and 'goto_column_cmd'
static define goto_cmd (prompt, moveto, get_position)
{
    variable target = read_mini(prompt, Null_String, Null_String);
    if (target[0] < '0') @get_position(); else 0;	% offset from
    @moveto (integer (target) + ());
}


%!%+
%\function{goto_column_cmd}
%\synopsis{Void goto_column_cmd (Void)}
%\description
% Goto to the specified column number (improved functionality).
% If the first character of the line number is +/- (ie., <'0'), 
% treat the value as relative to the current column.
%#v+
% Emacs binding:
%    setkey ("goto_line_cmd", "\eg");
% Possible Alternative binding:
%    local_setkey ("goto_line_cmd", "\e#");
%#v-
%!%-
define goto_column_cmd ()	% <AUTOLOAD>
{
    goto_cmd ("Goto column:", &goto_column, &what_column);
}

%!%+
%\function{goto_line_cmd}
%\synopsis{Void goto_line_cmd (Void)}
%\description
% Goto to the specified line number (improved functionality).
% If the first character of the line number is +/- (ie., <'0'), 
% treat the value as relative to the current line.
%#v+
% Emacs binding:
%    setkey ("goto_line_cmd", "\eg");
% Possible Alternative binding:
%    local_setkey ("goto_line_cmd", "\e#");
%#v-
%!%-
define goto_line_cmd ()		% <AUTOLOAD>
{
    goto_cmd ("Goto line:", &goto_line, &what_line);
}

%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%%
