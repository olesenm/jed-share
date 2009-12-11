%--------------------------------*-SLang-*--------------------------------
% charset.sl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c)1997-2002 Mark Olesen
%
% Do as you wish with this code under the following conditions:
% 1) leave this notice intact
% 2) don't try to sell it
% 3) don't try to pretend it is your own code
% 4) it's nice when improvements make their way back to the 'net'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!%+
%\function{charset}
%\synopsis{Void charset(Void)}
%\description
% popup a buffer with the character set 0 - 255 (without control chars)
%!%-
define charset()       % <AUTOLOAD>
{
    variable buf = "*character-set*";

    pop2buf(buf);
    erase_buffer();
    insert(buf);

    variable i = 0;
    loop (2) {
        % skip control characters
        vinsert("\n%3d [0x%X]", i, i);
        i += 32;
        loop (3) {
            vinsert("\n%3d [0x%X]\t", i, i);
            loop (32) {
                insert_char(i);
                i++;
            }
        }
    }
    bob();
    set_buffer_modified_flag(0);        % pretend no modifications
}
%%%%%%%%%%%%%%%%%%%%%%%%%%% end-of-file (SLang) %%%%%%%%%%%%%%%%%%%%%%%%%%
% *character-set*
%  32 [0x20]     !"#$%&'()*+,-./0123456789:;<=>?
%  64 [0x40]    @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_
%  96 [0x60]    `abcdefghijklmnopqrstuvwxyz{|}~
% 128 [0x80]
% 160 [0xA0]     ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿
% 192 [0xC0]    ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß
% 224 [0xE0]    àáâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ
% *character-set*
