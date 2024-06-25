#!/usr/bin/env bash

enableRouting() {
    local systctld_network_conf_f="/etc/sysctl.d/21-network_routing.conf"
    echo -e "\n\nAdding network confs to $systctld_network_conf_f"
    echo "net.ipv4.ip_forward = 1" | tee "$systctld_network_conf_f" >/dev/null
    echo "Routing enabled"
    return 0
}