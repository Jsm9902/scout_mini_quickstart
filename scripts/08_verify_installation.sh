#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"
# shellcheck disable=SC1090
source "$WORKSPACE_DIR/install/setup.bash"

required_packages=(
  scout_navigation
  scout_slam
  scout_web_monitor
  scout_ros2
  scout_description
  rosbridge_server
  slam_toolbox
  nav2_bringup
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

if [[ "$failed" -ne 0 ]]; then
  echo "[ERROR] Installation verification failed." >&2
  exit 1
fi

echo "[OK] Installation verification passed."
