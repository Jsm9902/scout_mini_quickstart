#!/usr/bin/env bash
set -Eeuo pipefail
source /opt/ros/humble/setup.bash
source "$HOME/scout_ws/install/setup.bash"
exec ros2 launch scout_navigation scout_industrial_safety_integrated.launch.py "$@"
