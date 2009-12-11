% hpcalc.sl             -*- SLang -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1995-2006 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the community
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HP-style RPN calculator (v0.98)
%    by Mark Olesen <firstname dot lastname at gmx dot net>
% for the Jed editor by John E. Davis
%
% minimum requirements are likely
%    jed (0.99.18)
%
% to use this mode:
% place it somewhere in the JED_LIBRARY path and add
%
%       autoload("hpcalc", "hpcalc");
%
% to ~/.jedrc.sl or $JED_ROOT/lib/defaults.sl
%
% you may also want to preparse it
% ------------------------------------------------------------------------
%{{{ Notes:
%
% The displayed calculator looks like this:
%
%       [ deg base 10: ... ]            <-- status line
%       [N]   0.000000                  \
%       ...   0.000000                   |
%       [2]   0.000000                   |- stack
%       [1]   0.000000                   |
%       [0]   0.000000                  /
%       ->    ________                  <-- input region
%
%  Numbers or commands may be entered in the input region after the '->'
%  prompt.  Input is terminated by [ENTER]
%
%  There's no support for memory storage/recall, but the editor offers plenty
%  of other possibilities anyhow.
%
%  Features not found in most calculators:
%     - character values        eg, 'J'
%     - octal numbers           eg, 0112
%     - hex numbers             eg, 0x4A
%
%     - "stack" multiple values/operations separated by whitespace or ';'
%       eg.
%          -> 3 15 * sin sq 9 5 * cos sq +
%          which represents -> sin^2 (3*15) + cos^2 (9*5) = ...<-
% ------------------------------------------------------------------------
%
% supported commands:
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   + - * /                     basic arithmetic
%   abs         `M-|'           abs(x)
%   chs         `M--'           -x
%   inv         `M-/'           1/x
%   int                         integer part of x
%   frac                        fractional part of x
%
% circular functions
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   pi          `M-P'           3.141592654...
%   sin         `M-s'
%   cos         `M-c'
%   tan         `M-t'
%   asin        `M-as'  `M-S'
%   acos        `M-ac'  `M-C'
%   atan        `M-at'  `M-T'
%
% conversions functions
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   todeg                       convert x from radians to degrees
%   torad                       convert x from degrees to radians
%
% higher math
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   e                           2.7182818285...
%   ^                           y^x
%   sq          `C-Q'           x^2
%   exp         `M-e'           exp(x)
%   ln          `M-n'           log(x)
%   log         `M-l'           log10(x)
%   alog        `M-L'           10^x
%   sqrt        `M-q'           sqrt(x)
%
% Stack
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   help                        insert help text
%   clear                       clear stack and buffer
%   last        `M-Enter'       retrieve last `x'
%   x                           exchange (x,y)
%   roll        `C-V'           roll-down stack
%               `Enter'         push `x' onto stack
%   deg         `M-^D'          define 'degrees' as the units for angles
%   rad         `M-^R'          define 'radians' as the units for angles
%   fix         `M-^F'          fixed notation
%   sci         `M-^S'          scientific notation
%   prec        `M-#'           adjust decimal point (base 10)
%   char oct dec hex            sets the base for display
%
% integer/bitwise operations
%   COMMAND     BINDING         MEANING
% -------------------------------------
%   &                           y and x   (bitwise)
%   |                           y or x    (bitwise)
%   %                           y mod x
%   !                           not (x)
%   xor                         y xor x   (bitwise)
%   <<                          y shl x = y * 2^x
%   >>                          y shr x = y / 2^x
% ------------------------------------------------------------------------
%}}}
%{{{ Revisions:
% 2008-02-26    - increased stack size to 8 entries
%
% 2006-09-27    - adjust for changes in array semantics in S-Lang 2
%
% 2002-08-20    - some better documentation
%               - fixed code to account for changes in S-Lang
%
% 2001-01-12    - error message for international users ;)
%               - migrated meta functions to keybindings
%               - nicer status line
%
% 1999-06-16    implemented static variables,
%               first problems with internationalization
%
% 1999-11-31    updated to Jed 0.98.7, with all of its new SLang changes
%
% 1996-09-17    combined help file with SLang code
%               updated to reflect some new JED shortcuts
%
% 1996-01-10    moved ^L key-binding "last" to M-Enter
%
% 1995-09-11    the preprocessor define `FLOAT_TYPE', which is new in
%               SLang 0.99-20, makes it possible to use this file with a
%               non-floating-point JED binary for integer only calculations.
%               Added ability to handle negative char/octal/hex numbers
%
% 1995-06-23    Can no longer directly edit the stack -- nice idea but
%               subject to parse errors.
%               Simplified several routines and implemented USER_BLOCKS
%               for a net size savings of about 15 per cent for the
%               preparsed code.
%               HPexit() kills the buffer and removes definitions to
%               save memory.
% ------------------------------------------------------------------------
%}}}
%{{{ variables:
%%% forget implements ("HPcalc") ... just use static variables!
static variable
    Stack_size = 8,      % stack size; 4 <= sz <= 10
    bufferName = "*hpcalc*",  % the buffer name
    last_value,       % last value entered
    displayBase,      % base (0,8,10,16)
    displayFormat,    % display format
    displayPrecison,  % number of decimal points
    angleConversion;  % degrees -> radians conversion

#ifdef SLANG_DOUBLE_TYPE
static variable Stack = Double_Type [Stack_size];
% deal with comma / decimal problem
static variable has_comma_problem = is_substr( sprintf( "%f", 0.1 ), "," );
if (has_comma_problem)  % oops!
    error("export 'LANG=C' before starting Jed - it cannot handle commas!");
#else
static variable Stack = Integer_Type [Stack_size];
#endif
%}}}

% initial (default) values
static define reset()
{
    % clear the stack
    last_value = 0;
    Stack[*] = 0;

    displayBase = 10;
    displayPrecison = 6;
#ifdef SLANG_DOUBLE_TYPE
    last_value = 0.0;
    displayFormat = "%.*f";
    angleConversion = PI / 180;
#else
    last_value = 0;
    displayFormat = "%d";
    angleConversion = 0;
#endif
}

reset();

static define refresh();        % forward declaration

%!%+
%\function{HPrecenter}
%\synopsis{Void HPrecenter(void)}
%\description
% recenter the buffer
%\seealso{hpcalc}
%!%-
define HPrecenter() { eob(); recenter( Stack_size+2 ); }

% insert the mini-help
static define get_help()        %{{{
{
    variable i, x;

    sw2buf(bufferName);
    erase_buffer();

    i = insert_file_region( expand_jedlib_file("hpcalc.sl"),
                             "[", "#</" );

    if (i > 0) {
        go_up(i / 2);
        bol();
        recenter(0);
    }
    else {
        insert("[\n  no help found in JED_LIBRARY path for\n\t'hpcalc.sl'\n\n]");
    }
    set_buffer_modified_flag(0);        % pretend no modifications
    update(0);

    flush("Strike any key");
    () = getkey();
    flush(Null_String);
    eob();
}
%}}}

% here are some helper functions for manipulating the calculator modes

% interactively change the decimal precision (0 <= prec <= 16)
static define change_precision()        %{{{
{
    displayPrecison = 6;  % fallback value
    variable i = integer(read_mini("Precision:", string(displayPrecison), Null_String));
    if (i >= 16) displayPrecison = 16; else if (i >= 0) displayPrecison = i;
}
%}}}

static define get_cmdline()     %{{{
{
    variable str = Null_String();
    bol();
    if (bol_fsearch("->")) {
        go_right(2); skip_white();              % skip prompt
        push_mark_eol();
        str = bufsubstr();
    }
    return str;
}

% change the base and format
static define new_format(base, fmt)
{
    displayBase = base;
    displayFormat = fmt;
    refresh();  % update the status line & buffer
}

% binary operations:
% pop two values and push one - thus also roll-down the stack
static define Binary_Op(val)
{
    Stack[1] = val;
    Stack = [ Stack[[1:]], 0 ];
}

% unary operations:
% pop one value and push one - thus simply replace the last value on the stack
static define Unary_Op(val)
{
    Stack[0] = val;
}

% push a new value on to the stack, truncating the top value
static define Push_Op(val)
{
#ifdef SLANG_DOUBLE_TYPE
    val = double(val);
#else
    val = int(val);
#endif
    % Stack = [ val, Stack[[0:-2]] ];
    Stack = [ val, Stack[[0:Stack_size-2]] ];
}

static variable Command = Assoc_Type[];
Command["?"]     = &get_help();
Command["help"]  = &get_help();
Command["reset"] = &reset();
Command["prec"]  = &change_precision();

%!% command dispatch routine - internal usage
static define dispatch(cmd)    %{{{
{
    variable x = Stack[0], y = Stack[1];
    variable ix = int(x), iy = int(y);  % integer form of the same

    cmd = strlow(cmd);

    if (assoc_key_exists(Command, cmd)) {
        @Command[cmd];
        return;
    }

    switch (cmd)
    { case "*":  Binary_Op( y * x ); }  % y * x
    { case "+":  Binary_Op( y + x ); }  % y + x
    { case "-":  Binary_Op( y - x ); }  % y - x
    { case "/":  Binary_Op( y / x ); }  % y / x
    { case "^":  Binary_Op( y^x );   }  % y^x
    { case "roll": Stack = [ Stack[[1:]], x ]; }  % rotating stack (down)
    % integer/bitwise operations
    { case "<<":  Binary_Op( iy shl ix ); }  % (y << x)
    { case ">>":  Binary_Op( iy shr ix ); }  % (y >> x)
    { case "%":  Binary_Op( iy mod ix ); }
    { case "&":  Binary_Op( iy & ix ); }
    { case "|":  Binary_Op( iy | ix ); }
    { case "xor":  Binary_Op( iy xor ix ); }
    { case "x":  Stack[1] = x; Stack[0] = y; }  % exch (x,y)
    { case "last": Push_Op( last_value ); }
    { case "\r":  Push_Op( Stack[0] ); }        % re-enter x
    { case "sq" or case "^2":  Unary_Op( x^2 ); }  % x^2
#ifdef SLANG_DOUBLE_TYPE
    { case "e":    Push_Op( E ); }              % natural base
    { case "pi":   Push_Op( PI ); }             % PI
    { case "alog": Unary_Op( 10^x ); }          % 10^x
    { case "sin":  Unary_Op( sin(x * angleConversion) ); }
    { case "cos":  Unary_Op( cos(x * angleConversion) ); }
    { case "tan":  Unary_Op( tan(x * angleConversion) ); }
    { case "asin": Unary_Op( asin(x) / angleConversion ); }
    { case "acos": Unary_Op( acos(x) / angleConversion ); }
    { case "atan": Unary_Op( atan(x) / angleConversion ); }
    { case "exp":  Unary_Op( exp(x) ); }
    { case "ln":   Unary_Op( log(x) ); }
    { case "log":  Unary_Op( log10(x) ); }
    { case "sqrt": Unary_Op( sqrt(x) ); }
    { case "inv":  Unary_Op( 1.0 / x ); }       % 1/x
    { case "torad": Unary_Op( x * PI/180 ); }
    { case "todeg": Unary_Op( x * 180/PI); }
    { case "frac":  Unary_Op( x-ix); }  % frac (x)
    { case "int":   Unary_Op( ix); }    % int (x)
#endif
    { case "char" : new_format( 0, "'%c'" );  }
    { case "oct"  : new_format( 8, "%#o" );   }
    { case "hex"  : new_format( 16, "0x%X" ); }
#ifdef SLANG_DOUBLE_TYPE
    { case "dec" or case "fix": new_format( 10, "%.*f" ); }
    { case "sci":  new_format( 10, "%.*e" ); }
    { case "deg":  angleConversion = PI / 180; }        % degrees for angles
    { case "rad":  angleConversion = 1; }       % radians for angles
#else
    { case "dec" or case "fix" or case "sci": new_format(10, "%d"); }
    { case "deg" or case "rad": ; }     % no op
#endif
    { case "clear":  last_value = 0; Stack[*] = 0; }    % clear the stack
    { case "abs":  if (x < 0) Unary_Op( -x ); } % abs (x)
    { case "chs":  Unary_Op( -x ); }            % -x
    { case "!": Unary_Op( not(ix) ); }
    { case "~":  Unary_Op( ~ix ); }
    { verror("no calc function `%s'", cmd); }
}
%}}}

%!%+
%\function{HPenter}
%\synopsis{Void HPenter(Void)}
%\description
% parse the input string & send to dispatch routine
%\seealso{hpcalc}
%!%-
define HPenter()        %{{{
{
    variable str = get_cmdline();

    ifnot (strlen(str)) {         % blank command-line
        Push_Op( Stack[0] );
        refresh();
    }

    variable args = strtok( str, "\t ;" );
    % dispatch command line args/values
    foreach (args) {
        variable tok = ();
        if (has_comma_problem) tok = str_replace_all(tok, ",", "." );
        switch (_slang_guess_type(tok))
          { case Double_Type:
              % BUG: - atof() doesn't like decimals ?
              if (has_comma_problem) tok = str_replace_all(tok, ".", ",");
              last_value = atof(tok);
              Push_Op( last_value );
          }
          { case Integer_Type:
              last_value = integer(tok);
              Push_Op( last_value );
          }
          { case String_Type:
              if (tok[0] == '\'') {     % character values
                  last_value = int(extract_element(tok, 1, '\''));
                  Push_Op( last_value );
              }
              else {
                  dispatch(tok);        % single character or string: a command
              }
          }
    }
    refresh();
}
%}}}

%!%+
%\function{HPcmd}
%\synopsis{Void HPcmd(String tok)}
%\description
% direct command dispatch routine (immediate operation)
%\seealso{hpcalc}
%!%-
define HPcmd(tok)       %{{{
{
    variable str = get_cmdline();
    dispatch(tok);
    refresh();
    insert(str);
}
%}}}

%!%+
%\function{HPins}
%\synopsis{Void HPins(String str)}
%\description
% insert string (with leading/trailing space) at the end of the buffer
%\seealso{hpcalc}
%!%-
define HPins(str)
{
    insert( strcat(" ", str, " ") );
}

% define/update the status line format
% print the calculator stack

static define refresh() %{{{
{
#ifdef SLANG_DOUBLE_TYPE
    if (angleConversion == 1) "rad"; else "deg";
#else
    "int";                      % integer only
#endif
    variable status_line = () + " base " + string(displayBase);

    sw2buf(bufferName);
    erase_buffer();

    variable val;
    % the stack - write out in reverse order
    variable i = 0;
    foreach (Stack) {
        val = ();
        bob();
        vinsert("[%d]\t", i);
        i++;

        switch (displayBase)
#ifdef SLANG_DOUBLE_TYPE
        { case 10: sprintf(displayFormat, displayPrecison, val); }
#endif
        { case 0 and (int(val) == 10) : "'^J'"; }       % linefeed
        { sprintf(displayFormat, int(val)); }
        insert(());
        newline();
    }

    % add the status line(s)
    bob();
    vinsert("[ %s: RPN calculator (v0.98) ]\n", status_line);
    set_status_line("[" + status_line + "]  <%b>   Help: '?'  %o %t", 0);

    % add the prompt
    eob();
    insert("->\t");
    HPrecenter();
    set_buffer_modified_flag(0);        % pretend no modifications
}
%}}}

%!%+
%\function{hpcalc}
%\usage{Void hpcalc(void)}
%\description
% a mode with the basic functionality of the trusty old RPN calculator from HP
%
% Bindings:
%#v+
%  HPexit                     Ctrl-X k
%  HPenter                    Ctrl-M
%  'recenter'                 Ctrl-
%  'popup help'               ?
%#v-
%\seealso{HPcmd, HPins, HPrecenter}
%!%-
define hpcalc() % <AUTOLOAD> <COMPLETE> this function %{{{
{
    variable i = bufferp(bufferName), mode = "hpcalc";
    pop2buf(bufferName);
    ifnot (i) {
        use_keymap(mode);
        use_syntax_table(mode);
        set_buffer_no_autosave();
        set_buffer_undo(1);

        % clear the stack
        last_value = 0; Stack[*] = 0;
    }

    % resize window (migrate to site.sl?)
    if (nwindows() == 2) {
        i = Stack_size + 2 - window_info('r');
        if (i >= 0) {
            loop (i) enlargewin();
        }
        else {
            otherwindow();
            loop (-i) enlargewin();
            otherwindow();
        }
    }

    refresh();  % update everything
}
%}}}

%!%+
%\function{HPexit}
%\synopsis{Void HPexit(void)}
%\description
% kill the buffer - redefine hpcalc to reload this file later
%\seealso{hpcalc}
%!%-
define HPexit() %{{{
{
    if (bufferName == whatbuf()) {
        set_buffer_modified_flag(0);
        delbuf(bufferName);
        eval(".(\"hpcalc.sl\"expand_jedlib_file evalfile pop)hpcalc");
        % try to pop down the old calculator window
        if (2 == nwindows()) {
            call("other_window");
            onewindow();
        }
    }
}
%}}}

%{{{ Keymap, Syntax highlighting
$1 = "hpcalc";
ifnot (keymap_p($1)) make_keymap($1);
definekey("HPenter",           "\r",   $1);
definekey("HPrecenter",        "\f",   $1);
definekey(".\"?\"HPcmd",       "?",    $1);
#ifdef SLANG_DOUBLE_TYPE
definekey(".\"PI\"HPins",      "\eP",  $1);
definekey(".\"cos\"HPins",     "\ec",  $1);
definekey(".\"sin\"HPins",     "\es",  $1);
definekey(".\"tan\"HPins",     "\et",  $1);
definekey(".\"acos\"HPins",    "\eC",  $1);
definekey(".\"asin\"HPins",    "\eS",  $1);
definekey(".\"atan\"HPins",    "\eT",  $1);
definekey(".\"acos\"HPins",    "\eAc", $1);
definekey(".\"asin\"HPins",    "\eAs", $1);
definekey(".\"atan\"HPins",    "\eAt", $1);
definekey(".\"exp\"HPins",     "\ee",  $1);
definekey(".\"log\"HPins",     "\el",  $1);
definekey(".\"alog\"HPins",    "\eL",  $1);
definekey(".\"alog\"HPins",    "\eAl", $1);
definekey(".\"ln\"HPins",      "\en",  $1);
definekey(".\"sqrt\"HPins",    "\eq",  $1);
definekey(".\"inv\"HPins",     "\e/",  $1);
#endif
definekey(".\"abs\"HPins",     "\e|",  $1);
definekey(".\"chs\"HPins",     "\e-",  $1);

definekey(".\"last\"HPins",    "\e\r", $1);
definekey(".\"sq\"HPins",      "^Q",   $1);
definekey(".\"roll\"HPcmd",    "^V",   $1);
definekey(".\"prec\"HPcmd",    "\e#",  $1);
definekey(".\"deg\"HPcmd",     "\e^D", $1);
definekey(".\"rad\"HPcmd",     "\e^R", $1);
definekey(".\"fix\"HPcmd",     "\e^F", $1);
definekey(".\"sci\"HPcmd",     "\e^S", $1);
definekey("HPexit",            "^XK",  $1);

$1 = "hpcalc";
% Now create and initialize the syntax tables.
create_syntax_table($1);
define_syntax("[", "]", '%', $1);
define_syntax('\'', '\'',      $1);
define_syntax("a-zA-Z", 'w',   $1);            % words
define_syntax("-+.0-9a-fA-FxX", '0',   $1);    % Numbers
define_syntax(",;.",           ',',    $1);
define_syntax("%-+/&*<>|!~^",  '+',    $1);
set_syntax_flags($1, 1);

() = define_keywords_n($1, "Ex", 1, 0);
() = define_keywords_n($1, "lnPIsq", 2, 0);
() = define_keywords_n($1, "abschscosdegexpfixhexintinvlogoctradscisintanxor", 3, 0);
() = define_keywords_n($1, "acosasinatancharfrachelplastprecrollsqrt", 4, 0);
() = define_keywords_n($1, "clearresettodegtorad", 5, 0); % log10
%}}}

% main entry point
hpcalc();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{{{ help text - do not delete
#<helpText>
[ HP-style RPN calculator (v0.98) (deg rad fix sci char oct dec hex)

              M-/: inv   M-e: exp   M-q: sqrt          M-s: sin   M-as: asin
  M-L: last   M-|: abs   M-n: ln    C-Q: sq   (x^2)    M-c: cos   M-ac: acos
  C-V: roll   M--: chs   M-l: log   M-L: alog (10^x)   M-t: tan   M-at: atan
  M-Enter: last                             ^ (y^x)    M-p: pi
  M-# (prec)
  clear reset
  + - * / ! & | xor % << >> int frac todeg torad   x = exch (x,y)
]
#</helpText>
%}}}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
