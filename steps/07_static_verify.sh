#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"
safe_source "$WORKSPACE_DIR/install/setup.bash"
failed=0
pkgs=(scout_base scout_msgs scout_description ugv_sdk scout_navigation scout_slam scout_web_monitor slam_toolbox nav2_bringup velodyne_driver velodyne_pointcloud pointcloud_to_laserscan rosbridge_server web_video_server)
for p in "${pkgs[@]}"; do ros2 pkg prefix "$p" >/dev/null 2>&1 && log_success "package $p" || { log_error "package $p"; failed=1; }; done
launches=("scout_slam scout_slam_integrated.launch.py" "scout_navigation scout_industrial_safety_integrated.launch.py" "scout_web_monitor web_nav.launch.py" "scout_web_monitor web_slam.launch.py")
for item in "${launches[@]}"; do read -r p f <<< "$item"; prefix=$(ros2 pkg prefix "$p" 2>/dev/null || true); path="$prefix/share/$p/launch/$f"; [[ -f "$path" ]] || { log_error "launch missing $p/$f"; failed=1; continue; }; timeout 20 ros2 launch "$p" "$f" --show-args >/dev/null 2>&1 && log_success "launch $p/$f" || { log_error "launch syntax $p/$f"; failed=1; }; done
find "$WORKSPACE_DIR/src" -name '*.launch.py' -print0 | xargs -0 -r python3 -m py_compile
python3 - <<'PY'
import pathlib, yaml
for p in pathlib.Path().glob('src/**/*.yaml'):
    with p.open(encoding='utf-8') as f: yaml.safe_load(f)
print('[OK] YAML parse')
PY
[[ $failed -eq 0 ]] || exit 1
log_success "Static verification passed."
