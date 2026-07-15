#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"

packages=(
  python3-colcon-common-extensions
  python3-rosdep
  python3-vcstool
  python3-pip
  can-utils
  net-tools
  ros-humble-navigation2
  ros-humble-nav2-bringup
  ros-humble-slam-toolbox
  ros-humble-rosbridge-suite
  ros-humble-web-video-server
  ros-humble-velodyne
  ros-humble-pointcloud-to-laserscan
  ros-humble-robot-localization
  ros-humble-xacro
  ros-humble-joint-state-publisher
  ros-humble-robot-state-publisher
  ros-humble-rviz2
  ros-humble-twist-mux
)

sudo apt-get update
sudo apt-get install -y "${packages[@]}"

if [[ "${INSTALL_FULL_FEATURES:-0}" == "1" ]]; then
  echo "[INFO] Full feature mode selected. Project-specific nodes are installed from source."
fi

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init
fi
rosdep update

echo "[OK] ROS dependencies installed."
