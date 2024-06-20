#!/usr/bin/env bash

addUserToGroups() {
    echo -e "\n\nAdding user to groups"

    checkConfig "OUI_USER" || return 1
    checkConfig "OUI_USER_GROUPS_TO_ADD" || return 1

    echo "Adding $OUI_USER to $OUI_USER_GROUPS_TO_ADD groups"
    usermod -aG "$OUI_USER_GROUPS_TO_ADD" "$OUI_USER"
    return 0
}