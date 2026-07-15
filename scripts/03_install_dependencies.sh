#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
packages=(
 git git-lfs rsync build-essential cmake ninja-build pkg-config
 python3-colcon-common-extensions python3-rosdep python3-vcstool python3-pip python3-setuptools python3-yaml
 can-utils iproute2 net-tools ethtool jq unzip
 "ros-${ROS_DISTRO}-navigation2" "ros-${ROS_DISTRO}-nav2-bringup"
 "ros-${ROS_DISTRO}-slam-toolbox" "ros-${ROS_DISTRO}-rosbridge-suite"
 "ros-${ROS_DISTRO}-web-video-server" "ros-${ROS_DISTRO}-velodyne"
 "ros-${ROS_DISTRO}-pointcloud-to-laserscan" "ros-${ROS_DISTRO}-robot-localization"
 "ros-${ROS_DISTRO}-xacro" "ros-${ROS_DISTRO}-joint-state-publisher"
 "ros-${ROS_DISTRO}-joint-state-publisher-gui" "ros-${ROS_DISTRO}-robot-state-publisher"
 "ros-${ROS_DISTRO}-rviz2" "ros-${ROS_DISTRO}-teleop-twist-keyboard"
 "ros-${ROS_DISTRO}-image-transport" "ros-${ROS_DISTRO}-image-transport-plugins"
 "ros-${ROS_DISTRO}-rmw-fastrtps-cpp"
)
[[ "$INSTALL_REALSENSE" == 1 ]] && packages+=("ros-${ROS_DISTRO}-realsense2-camera" "ros-${ROS_DISTRO}-realsense2-description")
[[ "$INSTALL_V4L2_CAMERA" == 1 ]] && packages+=("ros-${ROS_DISTRO}-v4l2-camera")
sudo apt-get update
sudo apt-get install -y "${packages[@]}"
if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then sudo rosdep init; fi
rosdep update --rosdistro "$ROS_DISTRO"
echo "[OK] Runtime and build dependencies installed."
