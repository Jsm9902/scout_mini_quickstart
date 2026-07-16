#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
if [[ -f /opt/ros/humble/setup.bash ]]; then log_info "ROS2 Humble already installed."; exit 0; fi
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo add-apt-repository universe -y
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg
arch=$(dpkg --print-architecture)
echo "deb [arch=$arch signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null
sudo apt-get update
apt_install ros-humble-desktop
safe_source /opt/ros/humble/setup.bash
ros2 --help >/dev/null
log_success "ROS2 Humble installed."
