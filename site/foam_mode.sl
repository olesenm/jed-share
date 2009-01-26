%--------------------------------------------------------------------------
% c_set_style ("foam");
% -------------------------------------------------------------------------
provide ("cmode");
custom_variable ("_C_Indentation_Style", "foam");

% define foam()
% {
%     (
%         C_INDENT, C_BRACE, C_BRA_NEWLINE, C_CONTINUED_OFFSET,
%         C_Colon_Offset, C_Class_Offset, C_Namespace_Offset
%     ) = (4,0,0,4,0,4,0);
% 
%     USE_TABS = 0;
% 
%     ( C_Colon_Offset, C_Switch_Offset, C_Param_Offset_Max ) = (0,4,-1);
% }

define foam_mode ()     % <AUTOLOAD> <COMPLETE> <EXTS="C,H">
{
    USE_TABS = 0;
    c_mode();
    run_mode_hooks("c_mode_hook");
}

%---------------------------------------------------------------------------
