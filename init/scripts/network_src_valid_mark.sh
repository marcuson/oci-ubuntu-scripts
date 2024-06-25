#!/usr/bin/env bash

enableNetSrcValidMark() {
    local systctld_network_conf_f="/etc/sysctl.d/22-network_src_valid_mark.conf"
    echo -e "\n\nAdding network confs to $systctld_network_conf_f"
    echo "net.ipv4.conf.all.src_valid_mark = 1" | tee "$systctld_network_conf_f" >/dev/null
    echo "Network src valid mark enabled"
    return 0
}