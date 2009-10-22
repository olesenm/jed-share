%--------------------------------*-SLang-*--------------------------------
% url.sl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997-2002 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A simple function to find tags marked "http://" or "ftp://" and pass
% them to an already running version of your favourite web browser.
% It's similar to a feature in SLRN that's quite handy.
%
% add
%       autoload ("openURL", "url");
% to  ~/.jedrc or $JED_ROOT/lib/defaults.sl to make it available.
%
% It makes a nice adjunct when authoring HTML with the Jed editor, but
% it's also handy in LaTeX text that will either be converted with
% LaTeX2HTML or hyperTeX.
%
% At the moment this only works for Netscape on Unix, but it beats using
% the mouse to copy the same info.  If cross-platform incompatibility
% bothers you, do what the big boys do: require a `netscape plug-in' ;)
%
% by mj olesen
% 26 March 1997

%!%+
%\function{openURL}
%\synopsis{Void openURL(Void)}
%\description
% find an \var{http://} or \var{ftp://} address and pass it to a web
% browser 
%
% Note: not available on all systems
%\seealso{getbuf_info, setbuf_info}
%!%-
define openURL ()
{
    variable url = "http://";
    push_spot ();

    % find "http://" first, "ftp://" second
    if (orelse
        { fsearch (url) }
          { fsearch ("ftp://") }
        ) {
        push_mark ();
        skip_chars ("^\t \")>]}");      % common delimiters
        url = bufsubstr ();
    }
    pop_spot ();
    url = read_mini ("Open URL:", Null_String, url);
    
    ifnot (strlen (url)) return;
    
#ifdef UNIX
    % assume we're running netscape under X
    () = run_shell_cmd(
                       sprintf 
                       ("netscape -remote 'openURL(%s) || eval \"exec netscape '%s' &\"",
                        url, url));
#else
    flush ("Get the Netscape plug-ins called Unix & X11");
#endif
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
