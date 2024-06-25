#!/usr/bin/env bash

# @scriptman namespace marcuson
# @scriptman name oci-ubuntu-init
# @scriptman asset tpl.getargs.env
# @scriptman asset scripts/**
# @scriptman getargs-tpl tpl.getargs.env

# region sec:getargs
# @scriptman sec:start getargs
echo "Note: configure env file before running this script with Scriptman"
# @scriptman sec:end getargs
# endregion sec:getargs

# region sec:run
# @scriptman sec:start run
# Script related vars
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_D=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
SCRIPT_NAME=$(basename "$(readlink -f "$0")" .sh)
PROGRESS_FILE_NAME="__oci_ubuntu_init_progress"

# External scripts
APT_INSTALL_PKGS_F="$SCRIPT_D/scripts/apt_install_pkgs.sh"
APT_ADD_DOCKER_REPO_F="$SCRIPT_D/scripts/apt_add_docker_repo.sh"
BACKUP_RESTORE_F="$SCRIPT_D/scripts/backup_restore.sh"
DOCKER_COMPOSE_START_F="$SCRIPT_D/scripts/docker_compose_start.sh"
DOCKER_CUSTOM_BRIDGE_F="$SCRIPT_D/scripts/docker_custom_bridge.sh"
DOCKER_LOGIN_F="$SCRIPT_D/scripts/docker_login.sh"
JOURNAL_LIMIT_F="$SCRIPT_D/scripts/journal_limit.sh"
NANO_SYNTAX_HIGHLIGHTING_F="$SCRIPT_D/scripts/nano_syntax_highlighting.sh"
NETWORK_ROUTING_F="$SCRIPT_D/scripts/network_routing.sh"
NETWORK_SRC_VALID_MARK_F="$SCRIPT_D/scripts/network_src_valid_mark.sh"
SSH_PREPARE_F="$SCRIPT_D/scripts/ssh_prepare.sh"
SWAPPINESS_F="$SCRIPT_D/scripts/swappiness.sh"
USER_GROUPS_F="$SCRIPT_D/scripts/user_groups.sh"
USER_PASSWRODLESS_SUDO="$SCRIPT_D/scripts/user_passwordless_sudo.sh"
UTILS_F="$SCRIPT_D/scripts/utils.sh"

# Source utils
# shellcheck source=scripts/utils.sh
. "$UTILS_F"

# Safety checks
checkSU || exit 1

# Check if config from Scriptman
if [ "$OUI_SMAN_IS_SET" == "true" ]; then
    echo "Env var loaded via Scriptman"
else
    echo "Config file not found... proceeding to manual config"
fi

if isVarEmpty "$OUI_USER"; then
    echo -e "\nMissing OUI_USER, please enter the normal user name and press enter\n"
    read -r
    OUI_USER="$REPLY"
fi

if ! isNormalUser "$OUI_USER"; then
    echo -e "\nOUI_USER problem, it must be set, it must be a normal user, it must exists"
    exit 1
fi

# Constants
HOME_USER_D=$(sudo -u "$OUI_USER" sh -c 'echo $HOME')
HELPER_F="$HOME_USER_D/${PROGRESS_FILE_NAME}"

# Create helper file if not found
if [ ! -f "$HELPER_F" ]; then
    echo "0" | sudo -u "$OUI_USER" tee "$HELPER_F" >/dev/null
fi

helper_f_content=$(<"$HELPER_F")

if [[ "$helper_f_content" == "2" ]]; then
    echo "All config already done, exiting."
    exit 3

# First pass
elif [[ "$helper_f_content" == "0" ]]; then

    echo -e "\nFirst init pass"

    # Journal - limit size
    if checkInitConfig "OUI_ENABLE_JOURNAL_LIMIT"; then
        # shellcheck source=scripts/journal_limit.sh
        . "$JOURNAL_LIMIT_F"
        limitJournal || exit 2
    fi

    # RAM - set swappiness
    if checkInitConfig "OUI_ENABLE_RAM_SWAPPINESS_CUSTOMIZE"; then
        # shellcheck source=scripts/swappiness.sh
        . "$SWAPPINESS_F"
        setSwappiness || exit 2
    fi

    # APT - update
    echo -e "\n\nUpdating packages"
    apt -y update
    apt -y upgrade
    echo "Packages updated"

    # APT - add Docker repo
    if checkInitConfig "OUI_ENABLE_ADD_DOCKER_APT_REPO"; then
        # shellcheck source=scripts/apt_add_docker_repo.sh
        . "$APT_ADD_DOCKER_REPO_F"
        aptAddDockerRepo || exit 2
    fi

    # APT - install packages
    if checkInitConfig "OUI_ENABLE_APT_INSTALL_PACKAGES"; then
        # shellcheck source=scripts/apt_install_pkgs.sh
        . "$APT_INSTALL_PKGS_F"
        installAptPackages || exit 2
    fi

    # User - add to groups
    if checkInitConfig "OUI_ENABLE_USER_ADD_TO_GROUPS"; then
        # shellcheck source=scripts/user_groups.sh
        . "$USER_GROUPS_F"
        addUserToGroups || exit 2
    fi

    # User - sudo without password
    if checkInitConfig "OUI_ENABLE_USER_SUDO_WITHOUT_PWD"; then
        # shellcheck source=scripts/user_passwordless_sudo.sh
        . "$USER_PASSWRODLESS_SUDO"
        enablePasswordlessSudo || exit 2
    fi

    # Nano - enable syntax highlighting
    if checkInitConfig "OUI_ENABLE_NANO_ENABLE_SYNTAX_HIGHLIGHTING"; then
        # shellcheck source=scripts/nano_syntax_highlighting.sh
        . "$NANO_SYNTAX_HIGHLIGHTING_F"
        enableNanoSyntaxHighlighting || exit 2
    fi

    # Network - enable routing
    if checkInitConfig "OUI_ENABLE_NETWORK_ROUTING"; then
        # shellcheck source=scripts/network_routing.sh
        . "$NETWORK_ROUTING_F"
        enableRouting
    fi

    # Network - enable src valid mark
    if checkInitConfig "OUI_ENABLE_NETWORK_SRC_VALID_MARK"; then
        # shellcheck source=scripts/network_src_valid_mark.sh
        . "$NETWORK_SRC_VALID_MARK_F"
        enableNetSrcValidMark
    fi

    # SSH - prepare
    # shellcheck source=scripts/ssh_prepare.sh
    . "$SSH_PREPARE_F"
    prepareSSH || exit 2

    # Services - docker
    if checkInitConfig "OUI_ENABLE_SRV_DOCKER_ENABLE"; then
        enableService "docker.service" false || exit 2
        enableService "containerd.service" false || exit 2
    fi

    # Pass 1 done
    echo "1" | tee "$HELPER_F" >/dev/null
    echo -e "\n\nFirst part of the config done"
    echo "Please check sshd config using 'sudo sshd -t' command and fix any problem before rebooting"
    echo "If the command sudo sshd -t has no output the config is ok"
    echo "Reboot and run this script again to finalize the configuration"
    exit 0

# Second pass
elif [[ "$helper_f_content" == "1" ]]; then
    echo "Second init pass"

    # Docker - login
    if checkInitConfig "OUI_ENABLE_DOCKER_LOGIN"; then
        # shellcheck source=scripts/docker_login.sh
        . "$DOCKER_LOGIN_F"
        dockerLogin || exit 2
    fi

    # Docker - custom bridge network
    if checkInitConfig "OUI_ENABLE_DOCKER_NETWORK_ADD_CUSTOM_BRIDGE"; then
        # shellcheck source=scripts/docker_custom_bridge.sh
        . "$DOCKER_CUSTOM_BRIDGE_F"
        createCustomDockerBridgeNetwork || exit 2
    fi

    # Backup - restore
    if checkInitConfig "OUI_ENABLE_BACKUP_RESTORE"; then
        # shellcheck source=scripts/backup_restore.sh
        . "$BACKUP_RESTORE_F"
        restoreBackup || exit 2
    fi

    if checkInitConfig "OUI_ENABLE_DOCKER_COMPOSE_START"; then
        # shellcheck source=scripts/docker_compose_start.sh
        . "$DOCKER_COMPOSE_START_F"
        startDockerCompose || exit 2
    fi

    echo "2" | tee "$HELPER_F" >/dev/null
    echo -e "\n\nSecond part of the config done"
    exit 0
fi

exit 0

# endregion sec:run
# @scriptman sec:end run