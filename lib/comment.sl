% -*- SLang -*-
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
%\function{c_un_comment}
%\synopsis{Void c_un_comment(Void)}
%\description
% attempt intelligent comment/uncomment text
%#v+
% Possible key binding:
%    local_setkey("c_un_comment", "\e:");
%#v-
%\seealso{c_make_comment}
%!%-
define c_un_comment()  % <AUTOLOAD>
{
    variable n, pt, str, cbeg, cend, space = " ";

    % try and handle a few different modes, but no promises
    (str,) = what_mode();
    switch (str)
      { case "C":       "/*"; "*/"; }
      { case "html":    "<!--"; "-->"; }
      { return; }

    cend = ();
    cbeg = ();

    USER_BLOCK0 {
        push_spot();
        bol_skip_white();
        push_mark_eol();
        EXIT_BLOCK { pop_spot(); }
    }

    if (dupmark()) {
        n = what_line();
        pt = POINT;
        exchange_point_and_mark();
        if (n - what_line()) {         % region spans lines
            pop_mark_1();
            X_USER_BLOCK0();
        }
        else if (pt == POINT) {         % mark dropped, but no region marked
            pop_mark_1();
            bskip_word_chars();        % mark a word
            push_mark();
            skip_word_chars();
        }
    }
    else {
        X_USER_BLOCK0();
    }

    str = strtrim (bufsubstr_delete());
    if (is_substr(str, cbeg) or is_substr(str, cend)) {
        if (str_replace(str, cbeg, "")) str = ();
        if (str_replace(str, cend, "")) str = ();
        str = strtrim(str);
    }
    else {
        str = sprintf("%s %s %s", cbeg, str, cend);
    }
    insert(str);
}

%!%+
%\function{c_line}
%\synopsis{Void c_line(Void)}
%\description
% make a nice comment dividing line for various languages
%!%-
define c_line()        % <AUTOLOAD>
{
    variable n, name, cbeg, cmid, cend, width = 74;

    (name,) = what_mode();
    switch (name)
      { case "C": "/*"; '-'; "*/"; }
      { case "html": "<!-- "; '-'; " -->"; }
      { case "SLang" or is_substr(name, "TeX"):                % "TeX/LaTeX"
          "%"; '%'; Null_String; }
      { case "Fortran" or case "F90": "C"; '-'; Null_String; }
      { return; }

    cend = ();
    cmid = ();
    cbeg = ();
    width -= (strlen(cbeg) + strlen(cend));

    n = what_line();
    if (n == 1) {
        cmid = '-';
        name = "-*-" + name + "-*-";
        n = strlen(name);
    }
    else {
        % check if we are on the last line
        push_spot();
        eob();
        if (n == what_line()) {
            pop_spot();
            eob();
            ifnot (bolp()) newline();
            switch (name)
              { case "C":
                  (name,,,) = getbuf_info();
                  switch (file_type(name))
                    { case "h": "C header"; }
                    { case "hpp": "C++ header"; }
                    { case "cc" or case "cpp": "C++ source"; }
                    { "C source"; }
                  name = ();
              }
              { case "Fortran": name = "F77"; }

            name = sprintf(" end-of-file (%s) ", name);
            n = strlen(name);
        }
        else {
            pop_spot();
            name = Null_String;
            n = 0;
        }
    }
    n = (width - n);

    USER_BLOCK0 { loop (()) insert_char(cmid); }

    bol();
    insert(cbeg);
    X_USER_BLOCK0(n / 2);

    insert(name);
    X_USER_BLOCK0(n - (n / 2));
    insert(cend);
    newline();
}

%!%+
%\function{c_box}
%\synopsis{Void c_box(Void)}
%\description
% make a "nice" comment box
%#v+
%  /*----------------------------------------------------------------*
%   * make a "nice" comment box
%   *----------------------------------------------------------------*/
%#v-
%#v+
% Possible key binding:
%   local_setkey("c_box", "^C=");
%#v-
%!%-
define c_box() % <AUTOLOAD>
{
    variable n, name, width = 74;
    variable cbeg, cbeg1, cmid, cmid1, cend, cend1;

    (name,) = what_mode();
    switch (name)
      { case "C":
          "/*"; '-'; "*/";
          " *"; " * "; "*";
      }
      { case "html":
          "<!-- "; '-'; " -->";
          Null_String; "- "; "--";
      }
      { case "SLang" or is_substr(name, "TeX"):                % "TeX/LaTeX"
          "%"; '%'; Null_String;
          "%"; "% "; Null_String;
      }
      { case "Fortran" or case "F90":
          "C"; '-'; Null_String;
          "C"; "C "; Null_String;
      }
      { return; }

    cend1 = ();
    cmid1 = ();
    cbeg1 = ();
    cend = ();
    cmid = ();
    cbeg = ();

    if (what_line() == 1) {
        name = "-*-" + name + "-*-";
        n = strlen(name);
    }
    else {
        name = Null_String;
        n = 0;
    }
    width -= (strlen(cbeg) + strlen(cend));
    n = (width - n);

    ifnot (dupmark()) push_mark();
    check_region(1);
    narrow();

    EXIT_BLOCK { widen(); pop_spot(); }
    USER_BLOCK0 { loop (()) insert_char(cmid); }

    bob();
    insert(cbeg);
    X_USER_BLOCK0(n / 2);
    insert(name);
    X_USER_BLOCK0(n - (n / 2));
    insert(cend1); newline();
    do
      insert(cmid1);
    while (down_1());
    eol();
    newline(); insert(cbeg1);
    X_USER_BLOCK0(width);
    insert(cend); newline();
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
