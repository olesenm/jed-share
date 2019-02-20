%--------------------------------*-SLang-*--------------------------------
% foam_comments.sl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)2018 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!%+
%\function{foam_comments}
%\synopsis{Void foam_comments(Void)}
%\description
% popup a buffer with OpenFOAM comment styles
%!%-
define foam_comments()       % <AUTOLOAD> <AUTOLOAD> <COMPLETE>
{
    variable buf = "*comment-styles*";

    pop2buf(buf);
    erase_buffer();
    c_mode();

    variable file = dircat(getenv("HOME"), "share/jed/etc/foamCommentStyles");

    variable n = insert_file(file);

    bob();
    set_buffer_modified_flag(0);        % Pretend no modifications
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
