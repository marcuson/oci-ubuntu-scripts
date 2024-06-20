#!/usr/bin/env bash

limitJournal() {
    # Defaults
    local config_journal_system_max_default="1024M"
    local config_journal_file_max_default="100M"
    # Dirs
    local journal_conf_d="/etc/systemd/journald.conf.d"
    local journal_conf_f="${journal_conf_d}/size.conf"

    # Apply default if conf is not found
    local system_max="${OUI_JOURNAL_SYSTEM_MAX:=$config_journal_system_max_default}"
    local file_max="${OUI_JOURNAL_FILE_MAX:=$config_journal_file_max_default}"

    echo -e "\n\nLimit journal size"
    mkdir -p "$journal_conf_d"
    echo "Using SystemMaxUse=$system_max | SystemMaxFileSize=$file_max"
    echo -e "[Journal]\nSystemMaxUse=$system_max\nSystemMaxFileSize=$file_max" | tee "$journal_conf_f" >/dev/null
    echo "New conf file is located at $journal_conf_f"
    echo "Journal size limited"
    return 0
}