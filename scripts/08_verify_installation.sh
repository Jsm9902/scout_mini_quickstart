#!/usr/bin/env bash
set -Eeuo pipefail

# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"
# shellcheck disable=SC1090
source "$WORKSPACE_DIR/install/setup.bash"

required_packages=(
  scout_base
  scout_msgs
  scout_description
  ugv_sdk
  scout_navigation
  scout_slam
  scout_web_monitor
  rosbridge_server
  web_video_server
  pointcloud_to_laserscan
  slam_toolbox
  nav2_bringup
)

required_launch_files=(
  "scout_navigation:scout_industrial_safety_integrated.launch.py"
  "scout_slam:scout_slam_integrated.launch.py"
  "scout_web_monitor:web_nav.launch.py"
  "scout_web_monitor:web_slam.launch.py"
)

failed=0
for pkg in "${required_packages[@]}"; do
  if ros2 pkg prefix "$pkg" >/dev/null 2>&1; then
    echo "[OK] Package: $pkg"
  else
    echo "[FAIL] Package not found: $pkg"
    failed=1
  fi
done

for item in "${required_launch_files[@]}"; do
  pkg="${item%%:*}"
  launch_file="${item#*:}"
  prefix="$(ros2 pkg prefix "$pkg" 2>/dev/null || true)"
  path="$prefix/share/$pkg/launch/$launch_file"
  if [[ -n "$prefix" && -f "$path" ]]; then
    echo "[OK] Launch: $pkg/$launch_file"
  else
    echo "[FAIL] Launch file not found: $pkg/$launch_file"
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  echo "[ERROR] Installation verification failed." >&2
  exit 1
fi

echo "[OK] Installation verification passed."
