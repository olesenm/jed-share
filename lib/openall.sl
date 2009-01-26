% openall.sl            -*- SLang -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997,98 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%!% openall():
%!% Opens file(s) named on each line of a special buffer.
%!% A 'special' buffer means one with a name that starts with a `*'
%!%
%!% useful for opening a list of files output by another program
%!% eg.,
%!% grep [-l] "foo" *.[ch] | jed --openall
%!% ls [-F] *.[ch] | jed -f openall
define openall ()
{
   variable file, buf = whatbuf ();

   if (buf[0] != '*') error ("Must start from a '*' buffer");
   bol ();
   if (markp ())
     {
        narrow ();
        bob ();
        EXIT_BLOCK { widen (); }
     }
   do
     {
        skip_white ();
        if (what_char () > 45)          % skip lines starting with
          {                             % these chars: !"#$%&'()*+,-
             push_mark ();              % beginning of filename
#ifdef MSDOS OS2
             go_right (2);              % in case of "c:/filename"
#endif
             skip_chars ("^\t *:@");    % ':' (grep -l) or '*', '@' (ls -F)
             file = bufsubstr ();
             if (file_status (file) == 1) % file exists and is not a directory
               {
                  () = read_file (file);
                  setbuf (buf);
               }
          }
     }
   while (down_1 ());
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
