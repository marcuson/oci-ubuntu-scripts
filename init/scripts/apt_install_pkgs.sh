#!/usr/bin/env bash

installAptPackages() {
    declare -a config_pkgs_arr
    echo -e "\n\nInstalling new packages"

    if isVarEmpty "$OUI_APT_PACKAGES"; then
        echo "OUI_APT_PACKAGES unset or empty"
        echo -e "\nPlease input one or more space separated pacman packages to install, then press enter to confirm"
        read -r -a config_pkgs_arr
        echo
    else
        readarray -td, config_pkgs_arr <<<"$OUI_APT_PACKAGES,"
        unset 'config_pkgs_arr[-1]'
    fi

    echo "New packages to install: ${config_pkgs_arr[*]}"
    apt -y install "${config_pkgs_arr[@]}"
    return 0
}
