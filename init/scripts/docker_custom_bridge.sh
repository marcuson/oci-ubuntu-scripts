#!/usr/bin/env bash

createCustomDockerBridgeNetwork() {
    echo -e "\n\nCreating Docker custom bridge network"

    local docker_group="docker"

    if ! checkCommand "docker"; then
        echo >&2 "docker command missing, cannot proceed"
        return 1
    fi

    checkConfig "OUI_DOCKER_NETWORK_CUSTOM_BRIDGE_NAME" || return 1

    if ! checkSU 2>/dev/null && ! isMeInGroup "$docker_group"; then
        echo >&2 -e "\nCurrent user isn't in $docker_group group, cannot proceed"
        echo >&2 -e "\nAdd current user to $docker_group group or run this script as root"
        return 1
    fi

    docker network create "$OUI_DOCKER_NETWORK_CUSTOM_BRIDGE_NAME"
    echo "Docker custom bridge network '$OUI_DOCKER_NETWORK_CUSTOM_BRIDGE_NAME' created"
    return 0
}
