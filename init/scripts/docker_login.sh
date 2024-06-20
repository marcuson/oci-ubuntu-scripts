#!/usr/bin/env bash

dockerLogin() {
    echo -e "\n\nDocker login"

    local docker_group="docker"

    if ! checkCommand "docker"; then
        echo >&2 "docker command missing, cannot proceed"
        return 1
    fi

    echo "Please prepare docker hub user and password"
    paktc

    if ! checkSU 2>/dev/null; then
        if ! isMeInGroup "$docker_group"; then
            echo >&2 -e "\nCurrent user isn't in $docker_group group, cannot proceed"
            return 1
        fi
        docker login
        return 0
    fi

    if isVarEmpty "$OUI_USER"; then
        echo -e "\nMissing OUI_USER, please enter the normal user name and press enter\n"
        read -r
        OUI_USER="$REPLY"
    fi

    if ! isNormalUser "$OUI_USER"; then
        echo >&2 -e "\nOUI_USER problem, it must be set, it must be a normal user, it must exists"
        return 1
    fi

    if ! isUserInGroup "$OUI_USER" "$docker_group"; then
        echo >&2 -e "\nOUI_USER found, $OUI_USER isn't in $docker_group group"
        read -p "Do you want to add $OUI_USER to $docker_group group? Y/N: " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            usermod -aG "$docker_group" "$OUI_USER"
        else
            echo >&2 "Cannot proceed"
            return 1
        fi
    fi
    sudo -u "$OUI_USER" docker login
    return 0
}