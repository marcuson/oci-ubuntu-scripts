#!/usr/bin/env bash

restoreBackup() {
    echo -e "\n\nRestoring backup"

    checkConfig "OUI_BACKUP_FILE_PATH" || return 1

    if [ ! -f "$OUI_BACKUP_FILE_PATH" ]; then
        echo -e "\nCannot find $OUI_BACKUP_FILE_PATH, please check"
        return 1
    else
        tar --same-owner -xf "$OUI_BACKUP_FILE_PATH" -C /
    fi

    echo "Backup restored"
    return 0
}
