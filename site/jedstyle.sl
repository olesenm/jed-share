%--------------------------------------------------------------------------
% c_set_style ("foam");
% -------------------------------------------------------------------------
require ("cmode");

define jed()
{

    USE_TABS = 0;
    c_mode();
    c_set_style("jed");
}


%     (
%         C_INDENT, C_BRACE, C_BRA_NEWLINE, C_CONTINUED_OFFSET,
%         C_Colon_Offset, C_Class_Offset, C_Namespace_Offset
%     ) = (4,0,0,4,0,4,0);
% 
%     ( C_Colon_Offset, C_Switch_Offset, C_Param_Offset_Max ) = (0,4,-1);
% }
% 
% define foam_mode ()
% {
%    foam();
%    run_mode_hooks("c_mode_hook");
% }
% 
%---------------------------------------------------------------------------
