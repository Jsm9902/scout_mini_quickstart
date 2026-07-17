#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

if [[ -f /opt/ros/humble/setup.bash ]]; then
    log_info "ROS2 Humble already installed."

    sudo apt-get update

    apt_install \
        python3-rosdep2 \
        python3-vcstool \
        python3-colcon-common-extensions

    safe_source /opt/ros/humble/setup.bash
    ros2 --help >/dev/null

    log_success "ROS2 Humble and ROS development tools are ready."
    exit 0
fi

sudo apt-get update

sudo apt-get install -y \
    locales \
    software-properties-common \
    curl \
    gnupg

sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

sudo add-apt-repository universe -y

sudo mkdir -p /usr/share/keyrings

curl -fsSL \
    https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | sudo gpg --dearmor --yes \
        -o /usr/share/keyrings/ros-archive-keyring.gpg

arch="$(dpkg --print-architecture)"
ubuntu_codename="$(
    . /etc/os-release
    echo "$UBUNTU_CODENAME"
)"

echo \
    "deb [arch=${arch} signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu ${ubuntu_codename} main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null

sudo apt-get update

apt_install \
    ros-humble-desktop \
    python3-rosdep2 \
    python3-vcstool \
    python3-colcon-common-extensions

safe_source /opt/ros/humble/setup.bash

ros2 --help >/dev/null

log_success "ROS2 Humble and ROS development tools installed."
