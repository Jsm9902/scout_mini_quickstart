#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
exec ros2 launch scout_navigation scout_industrial_safety_integrated.launch.py "$@"
