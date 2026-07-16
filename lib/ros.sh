#!/usr/bin/env bash
set -Eeuo pipefail
source_ros(){ safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"; }
source_workspace(){ safe_source "${WORKSPACE_DIR}/install/setup.bash"; }
