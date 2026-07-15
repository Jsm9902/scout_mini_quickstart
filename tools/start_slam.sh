#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
exec ros2 launch scout_slam scout_slam_integrated.launch.py "$@"
