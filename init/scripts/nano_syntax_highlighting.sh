#!/usr/bin/env bash

enableNanoSyntaxHighlighting() {
    echo -e "\n\nEnabling Nano Syntax highlighting"

    if isVarEmpty "$OUI_USER"; then
        echo -e "\nMissing OUI_USER, please enter the normal user name and press enter\n"
        read -r
        OUI_USER="$REPLY"
    fi

    if ! isNormalUser "$OUI_USER"; then
        echo >&2 -e "\nOUI_USER problem, it must be set, it must be a normal user, it must exists"
        return 1
    fi

    if isVarEmpty "$HOME_USER_D"; then
        HOME_USER_D=$(sudo -u "$OUI_USER" sh -c 'echo $HOME')
    fi

    if isVarEmpty "$HOME_ROOT_D"; then
        HOME_ROOT_D=$(sudo -u root sh -c 'echo $HOME')
    fi

    local nano_conf_f=".nanorc"
    local nano_conf_user_f="$HOME_USER_D/$nano_conf_f"
    local nano_conf_root_f="$HOME_ROOT_D/$nano_conf_f"

    if [ ! -f "$nano_conf_root_f" ] || ! grep -q 'include "/usr/share/nano/\*.nanorc' "$nano_conf_root_f"; then
        echo -e 'include "/usr/share/nano/*.nanorc"\nset linenumbers' | tee -a "$nano_conf_root_f" >/dev/null
    else
        echo "$nano_conf_root_f already configured"
    fi

    if [ ! -f "$nano_conf_user_f" ] || ! grep -q 'include "/usr/share/nano/\*.nanorc' "$nano_conf_user_f"; then
        echo -e 'include "/usr/share/nano/*.nanorc"\nset linenumbers' | sudo -u "$OUI_USER" tee -a "$nano_conf_user_f" >/dev/null
    else
        echo "$nano_conf_user_f already configured"
    fi
    echo -e "\nNano Syntax highlighting enabled"
    return 0
}
