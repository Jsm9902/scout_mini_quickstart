#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

echo "=== CAN: $CAN_INTERFACE ==="
ip -details link show "$CAN_INTERFACE" || true

echo
echo "=== ROS nodes ==="
ros2 node list || true

echo
echo "=== Essential topics ==="
ros2 topic list | grep -E '^/(scan|map|odom|tf|tf_static|cmd_vel|cmd_vel_nav|cmd_vel_web|cmd_vel_selected|amcl_pose|battery)' || true
