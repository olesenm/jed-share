% cmisc1.sl -*- SLang *-*
% alternative implementations for $JED_ROOT/lib/cmisc.sl
variable C_Comment_Column = 33; % on a TAB

%!%+
%\function{c_make_comment}
%\synopsis{Void c_make_comment (Void)}
%\description
% produce a comment for C, when possible align on a TAB stop
%#v+
% Possible key binding:
%    local_setkey ("c_make_comment", "\e;");
%#v-
%\seealso{c_un_comment}
%!%-
define c_make_comment ()        % <AUTOLOAD>
{
    variable cbeg, cend, name, spaces, incr;
    
    % try and handle a few different modes, but no promises
    (name,) = what_mode ();
    switch (name)
      { case "C":       "/*"; "*/"; }
      { case "SLang" or is_substr (name, "TeX") :       % "TeX/LaTeX"
          "%"; Null_String; }
      { return; }       % no other modes handled
    cend = ();
    cbeg = ();

    if (TAB and (TAB < 8))
      incr = TAB;       % likely the Linux 'TAB = 4' people
    else
      incr = TAB/2;     % assume standard 'TAB = 8' people
    
    USER_BLOCK0 {
        spaces = C_Comment_Column - what_column ();
        while (spaces < 0)
          spaces += incr;
        whitespace (spaces);
    }
    
    % search for a comment on the line
    eol ();
    if (bfind (cbeg)) {
        ifnot (bolp()) {
            go_left_1 ();
            trim ();
            () = ffind (cbeg);
        }
        X_USER_BLOCK0 ();
        if (strlen (cend)) {
            ifnot (ffind (cend)) {
                eol ();
                insert_spaces (2);
                insert (cend);
            }
        }
        () = bfind (cbeg);
        go_right (strlen(cbeg) + 1);
    }
    else {                                     % not found
        X_USER_BLOCK0 ();
        insert (cbeg);
        insert ("  ");
        if (strlen (cend)) {
            insert (cend);
            go_left (3);
        }
    }
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
