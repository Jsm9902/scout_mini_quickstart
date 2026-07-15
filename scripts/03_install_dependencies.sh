#!/usr/bin/env bash
set -Eeuo pipefail

# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"

packages=(
  git
  rsync
  build-essential
  cmake
  python3-colcon-common-extensions
  python3-rosdep
  python3-vcstool
  python3-pip
  can-utils
  iproute2
  net-tools
  ros-${ROS_DISTRO}-navigation2
  ros-${ROS_DISTRO}-nav2-bringup
  ros-${ROS_DISTRO}-slam-toolbox
  ros-${ROS_DISTRO}-rosbridge-suite
  ros-${ROS_DISTRO}-web-video-server
  ros-${ROS_DISTRO}-velodyne
  ros-${ROS_DISTRO}-pointcloud-to-laserscan
  ros-${ROS_DISTRO}-robot-localization
  ros-${ROS_DISTRO}-xacro
  ros-${ROS_DISTRO}-joint-state-publisher
  ros-${ROS_DISTRO}-robot-state-publisher
  ros-${ROS_DISTRO}-rviz2
  ros-${ROS_DISTRO}-teleop-twist-keyboard
)

sudo apt-get update
sudo apt-get install -y "${packages[@]}"

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init
fi
rosdep update

echo "[OK] ROS and Scout Mini build dependencies installed."
