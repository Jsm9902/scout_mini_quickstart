#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
pkgs=(build-essential cmake git curl wget gnupg lsb-release software-properties-common python3-pip python3-venv python3-rosdep python3-vcstool python3-colcon-common-extensions python3-argcomplete can-utils iproute2 net-tools rsync unzip jq libasio-dev libboost-all-dev libwebsocketpp-dev)
[[ "$INSTALL_OPENSSH" == "1" ]] && pkgs+=(openssh-server)
[[ "$INSTALL_TERMINATOR" == "1" || "$DEVELOPER_TOOLS" == "1" ]] && pkgs+=(terminator)
apt_install "${pkgs[@]}"
log_success "System packages installed."
