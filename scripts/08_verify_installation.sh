#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"
[[ -f "$WORKSPACE_DIR/install/setup.bash" ]] || { echo "[ERROR] Workspace is not built."; exit 1; }
# shellcheck disable=SC1090
source "$WORKSPACE_DIR/install/setup.bash"
failed=0
packages=(scout_base scout_msgs scout_description ugv_sdk scout_navigation scout_slam scout_web_monitor rosbridge_server web_video_server pointcloud_to_laserscan slam_toolbox nav2_bringup velodyne_driver velodyne_pointcloud)
for p in "${packages[@]}"; do ros2 pkg prefix "$p" >/dev/null 2>&1 && echo "[OK] package $p" || { echo "[FAIL] package $p"; failed=1; }; done
launches=(
 'scout_navigation scout_industrial_safety_integrated.launch.py'
 'scout_slam scout_slam_integrated.launch.py'
 'scout_web_monitor web_nav.launch.py'
 'scout_web_monitor web_slam.launch.py'
)
for item in "${launches[@]}"; do
  read -r pkg file <<<"$item"; prefix="$(ros2 pkg prefix "$pkg" 2>/dev/null || true)"; path="$prefix/share/$pkg/launch/$file"
  [[ -f "$path" ]] && echo "[OK] launch $pkg/$file" || { echo "[FAIL] launch $pkg/$file"; failed=1; }
  if [[ -f "$path" ]]; then timeout 15 ros2 launch "$pkg" "$file" --show-args >/dev/null 2>&1 && echo "[OK] launch syntax $pkg/$file" || { echo "[FAIL] launch syntax $pkg/$file"; failed=1; }; fi
done
python3 - <<'PY' || failed=1
import importlib
for m in ('rclpy','yaml'):
    importlib.import_module(m)
print('[OK] Python ROS modules')
PY
[[ -x "$HOME/.local/bin/scout-manager" ]] || { echo "[FAIL] scout-manager missing"; failed=1; }
if [[ "$ENABLE_CAN_SERVICE" == 1 ]]; then systemctl is-enabled scout-can.service >/dev/null 2>&1 && echo "[OK] CAN service enabled" || { echo "[FAIL] CAN service disabled"; failed=1; }; fi
((failed==0)) || { echo "[ERROR] Verification failed."; exit 1; }
echo "[OK] Static installation verification passed. Hardware topics are checked after launch with check_robot."
