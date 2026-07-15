#!/usr/bin/env bash
set -Eeuo pipefail

if [[ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]]; then
  echo "[SKIP] ROS 2 $ROS_DISTRO is already installed."
  exit 0
fi

sudo apt-get update
sudo apt-get install -y locales software-properties-common curl gnupg lsb-release
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo add-apt-repository universe -y

sudo mkdir -p /usr/share/keyrings
curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null

sudo apt-get update
sudo apt-get install -y ros-humble-desktop ros-dev-tools

echo "[OK] ROS 2 Humble installed."
