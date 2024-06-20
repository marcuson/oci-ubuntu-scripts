#!/usr/bin/env bash

prepareSSH() {
    echo -e "\n\nAdding .ssh folders and basic files"

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

    local ssh_user_d="$HOME_USER_D/.ssh"
    export SSH_AUTH_KEYS_USER_F="$ssh_user_d/authorized_keys"
    export SSH_KNOWN_HOSTS_USER_F="$ssh_user_d/known_hosts"

    sudo -u "$OUI_USER" mkdir -p "$ssh_user_d"
    sudo -u "$OUI_USER" touch "$SSH_AUTH_KEYS_USER_F" "$SSH_KNOWN_HOSTS_USER_F"
    chmod 700 "$ssh_user_d"
    chmod 600 "$SSH_AUTH_KEYS_USER_F" "$SSH_KNOWN_HOSTS_USER_F"
    echo ".ssh folders and basic files added"
    return 0
}
