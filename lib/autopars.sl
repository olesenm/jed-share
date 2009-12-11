#!/usr/bin/jed -script autopars.sl
%--------------------------------*-SLang-*--------------------------------
% autopars.sl: find all 'manifest.sl' files & do pre-parsing
%-------------------------------------------------------------------------
%      jed -script autopars.sl

%!% Void autoparse(Void)
%!% search through jed library path & get the 'manifest.sl' files, which
%!% list the names of files which should be pre-parsed
define autoparse()
{
   variable dir, file, n = 0;
   forever
     {
        dir = extract_element(get_jed_library_path(), n, ',');
        if (dir == NULL)
          break;

        file = dircat(dir, "manifest.sl");
        if (file_status(file) == 1)
          {
             if (evalfile(file))
               {
                  % byte-compile / pre-process
                  while (file = (), file != NULL)
                    {
                       variable f;
                       f = dircat(dir, file);
                       if (file_status(f) == 1)
                         {
                            flush("Processing " + file);
                            byte_compile_file(f, 1);
                         }
                       else
                         {
                            flush(file + " not found");
                         }
                    }
               }
          }
        n++;
     }
   if (BATCH) exit_jed();
}
if (BATCH) autoparse();
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
