#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
red='\033[0;31m'; green='\033[0;32m'; yellow='\033[1;33m'; reset='\033[0m'
check_topic(){ local t="$1"; if timeout 4 ros2 topic echo "$t" --once >/dev/null 2>&1; then echo -e "${green}[OK]${reset} $t"; else echo -e "${yellow}[WAIT]${reset} $t"; fi; }
echo "=== CAN ==="; ip -details link show "$CAN_INTERFACE" || true
echo "=== Nodes ==="; ros2 node list || true
echo "=== Topic data ==="
for t in /tf /tf_static /odom /scan; do check_topic "$t"; done
ros2 topic list | grep -E '^/(map|amcl_pose|cmd_vel|cmd_vel_nav|cmd_vel_web|cmd_vel_selected|battery)' || true
echo "Web access: http://$(hostname -I | awk '{print $1}'):$WEB_SERVER_PORT"
