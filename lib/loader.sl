% loader.sl:
%
% * Find and evaluate all '_loader.sl' files in the Jed library path.
%
% * Find all '_jedfuns.txt' files in the Jed library path and append their
%   names to 'Jed_Doc_Files'
%
% ---------------------------------------------------------------------------
%
% The '_loader.sl' files define autoloads/completions for SLang files
% on a per directory basis and are most easily generated via an 
% external script (eg, slloader.pl)
%
% Adding the following line to 'site.sl' or 'defaults.sl' will
% activate the loader:
%
%   if (strlen(expand_jedlib_file("loader.sl"))) () = evalfile("loader.sl");
%
% NB: If you use set_jed_library_path() within your startup, be sure that
%     it precedes the evaluation of 'loader.sl', otherwise no all files
%     will be found.
% ---------------------------------------------------------------------------
static define loader ()
{
    variable depth = _stkdepth();
    variable file;

    ERROR_BLOCK { _clear_error(); }

    foreach (strtok (get_jed_library_path(), ",")) {	
	variable dir = ();
	% append existing '_jedfuns.txt'
	file = dircat(dir, "_jedfuns.txt");
	if (1 == file_status(file))
	  Jed_Doc_Files = strcat(Jed_Doc_Files, ",", file);

	% look for '_loader.sl'
	file = dircat(dir, "_loader.sl");
        if (1 == file_status(file))
	  () = evalfile(file);
    }
    
    depth = _stkdepth() - depth;
    if (depth)
      _pop_n(depth);	% clean-up possible junk left on the stack
}
loader();	% could/should unload itself as well
% ---------------------------------------------------------------------------
