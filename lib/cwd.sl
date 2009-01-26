%!%+
%\function{cwd}
%\synopsis{Void cwd(void)}
%\description
% fix current working directory of "*scratch*" to match that
% of the current buffer
%\seealso{getbuf_info, setbuf_info}
%!%-
define cwd ()	% <AUTOLOAD>
{
    variable dir, file, buf, flags, obuf;
   
    (,dir,obuf,) = getbuf_info ();
    
    setbuf ("*scratch*");
    (file,, buf, flags) = getbuf_info ();
    setbuf_info (file, dir, buf, flags);
    setbuf (obuf);
}
