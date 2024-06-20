#!/usr/bin/env bash

aptAddDockerRepo() {
    echo -e "\n\nAdd Docker repo to APT"

    local docker_gpg_f="/etc/apt/keyrings/docker.asc"
    local docker_list_f="/etc/apt/sources.list.d/docker.list"

    # Add Docker's official GPG key
    if [ ! -f "$docker_gpg_f" ]; then
        apt update
        apt install ca-certificates curl
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "${docker_gpg_f}"
        chmod a+r "${docker_gpg_f}"
    else
        echo "Docker repo GPG key already added"
    fi

    # Add the repository to Apt sources
    if [ ! -f "$docker_list_f" ]; then
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=$docker_gpg_f] \
            https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            tee "${docker_list_f}" > /dev/null
        apt update
    else
        echo "Docker repo already added"
    fi

    echo "Docker APT repo added and configured"
    return 0
}
