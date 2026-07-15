#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/_lib.sh"
export DEBIAN_FRONTEND=noninteractive
retry 3 sudo apt-get update
retry 3 sudo apt-get -y full-upgrade
sudo apt-get install -y locales software-properties-common curl gnupg ca-certificates lsb-release
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
sudo add-apt-repository universe -y

# Current ROS-recommended repository setup with a fallback for Jammy.
arch="$(dpkg --print-architecture)"
version="$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F 'tag_name' | awk -F\" '{print $4}')"
if [[ -n "$version" ]] && curl -fL -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${version}/ros2-apt-source_${version}.$(. /etc/os-release && echo "$UBUNTU_CODENAME")_all.deb"; then
  sudo dpkg -i /tmp/ros2-apt-source.deb
else
  echo "[WARN] ros2-apt-source package unavailable; using signed keyring fallback."
  sudo mkdir -p /usr/share/keyrings
  curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo gpg --dearmor --yes -o /usr/share/keyrings/ros-archive-keyring.gpg
  echo "deb [arch=$arch signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null
fi
retry 3 sudo apt-get update
sudo apt-get install -y "ros-${ROS_DISTRO}-desktop" ros-dev-tools
[[ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]] || { echo "[ERROR] ROS setup missing after installation."; exit 1; }
echo "[OK] ROS 2 $ROS_DISTRO installed."
