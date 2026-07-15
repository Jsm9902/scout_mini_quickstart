#!/usr/bin/env bash
set -Eeuo pipefail
source /opt/ros/humble/setup.bash
source "$HOME/scout_ws/install/setup.bash"
exec ros2 launch scout_web_monitor web_slam.launch.py "$@"
