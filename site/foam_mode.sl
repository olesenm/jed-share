%--------------------------------------------------------------------------
% c_set_style ("foam");
% -------------------------------------------------------------------------
provide("cmode");
custom_variable("_C_Indentation_Style", "foam");

define foam_mode()     % <AUTOLOAD> <COMPLETE> <EXTS="C,H">
{
    USE_TABS = 0;
    c_mode();
    run_mode_hooks("c_mode_hook");
}

%---------------------------------------------------------------------------
