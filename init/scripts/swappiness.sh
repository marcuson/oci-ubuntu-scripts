#!/usr/bin/env bash

setSwappiness() {
    # Defaults
    local swappiness_default=60
    # Dirs
    local swappiness_conf_f="/etc/sysctl.d/swappiness.conf"
    # Apply default if conf is not found
    local swappiness="${OUI_RAM_SWAPPINESS_VALUE:=$swappiness_default}"

    echo -e "\n\nSetting custom swappiness"
    echo "New swappiness value: $swappiness"
    echo "vm.swappiness=$swappiness" | tee "$swappiness_conf_f" >/dev/null
    echo "Custom swappiness set, it will be applied from the next reboot"
    return 0
}
