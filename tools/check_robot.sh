#!/usr/bin/env bash
set -Eeuo pipefail
source /opt/ros/humble/setup.bash
source "$HOME/scout_ws/install/setup.bash"
echo "=== CAN ==="
ip -details link show can0 || true
echo "=== ROS nodes ==="
ros2 node list || true
echo "=== Essential topics ==="
ros2 topic list | grep -E '^/(scan|map|odom|tf|cmd_vel|amcl_pose|battery)' || true
