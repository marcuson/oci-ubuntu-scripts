#!/usr/bin/env bash

startDockerCompose() {

    echo -e "\n\nStarting docker compose"

    if ! checkCommand "docker"; then
        echo >&2 "docker command missing, cannot proceed"
        return 1
    fi

    local docker_group="docker"
    if ! checkSU 2>/dev/null && ! isMeInGroup "$docker_group"; then
        echo >&2 -e "\nCurrent user isn't in $docker_group group, cannot proceed"
        echo >&2 -e "\nAdd current user to $docker_group group or run this script as root"
        return 1
    fi

    checkConfig "OUI_DOCKER_COMPOSE_FILE_PATH" || return 1

    if [ ! -f "$OUI_DOCKER_COMPOSE_FILE_PATH" ]; then
        echo "Cannot find $OUI_DOCKER_COMPOSE_FILE_PATH compose file, please check"
        paktc
        return 1
    fi

    docker compose -f "$OUI_DOCKER_COMPOSE_FILE_PATH" up -d
    echo -e "\nServices in $OUI_DOCKER_COMPOSE_FILE_PATH compose file should be up and running"

    return 0
}
