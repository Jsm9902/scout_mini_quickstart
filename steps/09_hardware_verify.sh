#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

is_jetson() {
  [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] &&
  { [[ -f /etc/nv_tegra_release ]] || dpkg-query -W nvidia-l4t-core >/dev/null 2>&1; }
}

net_driver() {
  local iface="$1"
  [[ -e "/sys/class/net/$iface/device/driver" ]] || return 1
  basename "$(readlink -f "/sys/class/net/$iface/device/driver")"
}

check_ros_package() {
  local pkg="$1"
  if ros2 pkg prefix "$pkg" >/dev/null 2>&1; then
    log_success "ROS package ready: $pkg"
  else
    log_warn "ROS package missing: $pkg"
  fi
}

if [[ -e "/sys/class/net/$CAN_INTERFACE" ]]; then
  state="$(cat "/sys/class/net/$CAN_INTERFACE/operstate" 2>/dev/null || echo unknown)"
  driver="$(net_driver "$CAN_INTERFACE" 2>/dev/null || true)"
  details="$(ip -details link show "$CAN_INTERFACE" 2>/dev/null || true)"

  log_info "CAN $CAN_INTERFACE state: $state"
  log_info "CAN $CAN_INTERFACE driver: ${driver:-unknown}"

  if grep -q "bitrate $CAN_BITRATE" <<<"$details"; then
    log_success "CAN bitrate verified: $CAN_BITRATE"
  else
    log_warn "CAN bitrate $CAN_BITRATE was not verified."
  fi

  if is_jetson && [[ "$CAN_INTERFACE" == "can0" ]]; then
    if [[ "$driver" == "gs_usb" ]]; then
      log_success "Jetson USB-CAN naming verified: can0 -> gs_usb"
    else
      log_warn "Jetson can0 is not using gs_usb. Current driver: ${driver:-unknown}"
      log_warn "Reboot after installing the systemd-network .link files."
    fi

    if [[ -e /sys/class/net/can_internal ]]; then
      internal_driver="$(net_driver can_internal 2>/dev/null || true)"
      log_success "Jetson internal CAN found: can_internal (${internal_driver:-unknown})"
    else
      log_warn "Jetson internal CAN interface can_internal was not found."
    fi
  fi
else
  log_warn "CAN interface not connected: $CAN_INTERFACE"
fi

if systemctl is-enabled scout-can.service >/dev/null 2>&1; then
  log_success "scout-can.service enabled"
else
  log_warn "scout-can.service is not enabled"
fi

if systemctl is-active scout-can.service >/dev/null 2>&1; then
  log_success "scout-can.service active"
else
  log_warn "scout-can.service is not active"
fi

if [[ -f "$WORKSPACE_DIR/install/setup.bash" ]]; then
  safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"
  safe_source "$WORKSPACE_DIR/install/setup.bash"

  log_success "Workspace setup found."

  check_ros_package scout_base
  check_ros_package scout_navigation
  check_ros_package scout_slam
  check_ros_package scout_web_monitor
  check_ros_package velodyne
  check_ros_package velodyne_pointcloud
  check_ros_package velodyne_laserscan
  check_ros_package rosbridge_server
  check_ros_package web_video_server

  for executable in \
    "$HOME/.local/bin/scout-start-base" \
    "$HOME/.local/bin/scout-start-slam" \
    "$HOME/.local/bin/scout-start-navigation" \
    "$HOME/.local/bin/scout-start-web-slam" \
    "$HOME/.local/bin/scout-start-web-navigation" \
    "$HOME/.local/bin/scout-check" \
    "$HOME/.local/bin/scout-can-check"
  do
    if [[ -x "$executable" ]]; then
      log_success "Command installed: $(basename "$executable")"
    else
      log_warn "Command missing: $(basename "$executable")"
    fi
  done

  log_info "Live topics and nodes require powered hardware and launched drivers."
else
  log_error "Workspace not built"
  exit 1
fi

log_success "Hardware readiness check completed."
