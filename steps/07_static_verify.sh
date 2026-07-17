#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"
safe_source "$WORKSPACE_DIR/install/setup.bash"

failed=0

########################################
# ROS Package Verification
########################################

pkgs=(
    scout_base
    scout_msgs
    scout_description
    scout_navigation
    scout_slam
    scout_web_monitor
    slam_toolbox
    nav2_bringup
    velodyne_driver
    velodyne_pointcloud
    pointcloud_to_laserscan
    rosbridge_server
    web_video_server
)

for p in "${pkgs[@]}"; do
    if ros2 pkg prefix "$p" >/dev/null 2>&1; then
        log_success "package $p"
    else
        log_error "package $p"
        failed=1
    fi
done

########################################
# Launch File Verification
########################################

launches=(
    "scout_slam scout_slam_integrated.launch.py"
    "scout_navigation scout_industrial_safety_integrated.launch.py"
    "scout_web_monitor web_nav.launch.py"
    "scout_web_monitor web_slam.launch.py"
)

for item in "${launches[@]}"; do
    read -r pkg launch <<< "$item"

    prefix=$(ros2 pkg prefix "$pkg" 2>/dev/null || true)
    launch_file="$prefix/share/$pkg/launch/$launch"

    if [[ ! -f "$launch_file" ]]; then
        log_error "launch missing $pkg/$launch"
        failed=1
        continue
    fi

    if timeout 20 ros2 launch "$pkg" "$launch" --show-args >/dev/null 2>&1; then
        log_success "launch $pkg/$launch"
    else
        log_error "launch syntax $pkg/$launch"
        failed=1
    fi
done

########################################
# Python Syntax Verification
########################################

find "$WORKSPACE_DIR/src" \
    -name "*.launch.py" \
    -print0 \
    | xargs -0 -r python3 -m py_compile

########################################
# YAML Verification
########################################

python3 <<EOF
import pathlib
import yaml

for path in pathlib.Path("src").rglob("*.yaml"):
    with open(path, encoding="utf-8") as f:
        yaml.safe_load(f)

print("[OK] YAML parse")
EOF

########################################
# Result
########################################

if [[ $failed -ne 0 ]]; then
    exit 1
fi

log_success "Static verification passed."
