#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
mapfile -t ros_pkgs < <(grep -Ev '^\s*(#|$)' "$ROOT_DIR/config/package-manifest.txt")
sudo apt-get update
apt_install "${ros_pkgs[@]}"
if [[ "$ENABLE_REALSENSE" == "1" ]]; then
  if apt-cache show ros-humble-realsense2-camera >/dev/null 2>&1; then
    apt_install ros-humble-realsense2-camera ros-humble-realsense2-description
  else
    log_warn "ros-humble-realsense2-camera not available in apt. RealSense will be checked during rosdep/build."
  fi
fi
log_success "ROS dependencies installed."
