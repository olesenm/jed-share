%--------------------------------*-SLang-*--------------------------------
% align.sl
% misc. routines for indenting, aligning, etc.
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
%\function{indent_region}
%\synopsis{Void indent_region(Void)}
%\description
% indent each non-blank line in the region
%#v+
% Emacs key binding:
%   local_setkey ("indent_region", "\e^\\");    % Emacs: C-M-\
%#v-
%#v+
% Possible Alternative key bindings (better for European keyboards):
%   local_setkey ("indent_region", "^XR\t");
%#v-
%!%-
define indent_region () % <AUTOLOAD>
{
    variable n;

    USER_BLOCK0 { !if (eolp()) indent_line(); } % only non-blank lines
    !if (markp ()) {
        X_USER_BLOCK0;
        return;
    }

    check_region (0);           % canonical region
    n = what_line (); n++;      % final line, inclusive
    pop_mark_1 ();              % return to first line
    n -= what_line ();
    loop (n) {                  % indent line by line (ie slowly)
        X_USER_BLOCK0;
        go_down_1 ();
    }
}
% local_setkey ("indent_region", "\e^\\");      % Emacs: C-M-\
% local_setkey ("indent_region", "^XR\t");      % better for European keyboards

%!%+
%\function{back_to_indentation}
%\synopsis{Void back_to_indentation(Void)}
%\description
% move point to the first non-whitespace character on this line
%#v+
% Emacs key binding:
%   local_setkey ("back_to_indentation", "\em");        % Emacs: M-m
%#v-
%!%-
define back_to_indentation ()   % <AUTOLOAD>
{
    bol_skip_white ();
}
% local_setkey ("back_to_indentation", "\em");  % Emacs: M-m

%!%+
%\function{trim_backward}
%\synopsis{Void trim_backward(Void)}
%\description
% like trim, but also trim if the previous char is whitespace
%!%-
define trim_backward () % <AUTOLOAD>
{
    bskip_white (); trim ();
}


%!%+
%\function{align_to}
%\synopsis{Void align_to(Void)}
%\description
% align first non-blank character to a particular column
%!%-
define align_to ()      % <AUTOLOAD>
{
    variable c = what_column ();
    trim_backward ();
    whitespace (c - what_column ());
}

%!%+
%\function{align}
%\synopsis{Void align(Void)}
%\description
% handle two different type of text alignment
%!%-
define align () % <AUTOLOAD>
{
    if (markp ()) indent_region (); else align_to ();
}
% local_setkey ("align", "\e^\\");      % C-M-\
% local_setkey ("align", "^XR\t");      % better for European keyboards

%!%+
%\function{tab_to_tab_stop1}
%\synopsis{Void tab_to_tab_stop1(Void)}
%\description
% insert spaces or tabs to the next defined tab-stop column
% - respects the local value of TAB
%#v+
% Emacs key binding:
%   local_setkey ("tab_to_tab_stop", "\ei");    % Emacs: M-i
%#v-
%\seealso{TAB}
%!%-
define tab_to_tab_stop1 ()      % <AUTOLOAD>
{
    if (TAB) {
        variable c = what_column () + TAB;
        trim_backward ();
        c - ((c-1) mod TAB) - what_column();            % leave on stack
        whitespace (());
    }
}

%!%+
%\function{move_to_tab}
%\synopsis{Void move_to_tab(Void)}
%\description
%  move to the next defined tab stop
%#v+
% Emacs key binding:
%   local_setkey ("move_to_tab", "\e\t");       % Emacs: ESC TAB
%#v-
%!%-
define move_to_tab ()   % <AUTOLOAD>
{
    if (TAB) {
        variable c = what_column () + TAB;
        c - ((c-1) mod TAB);                            % leave on stack
        goto_column (());
    }
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
