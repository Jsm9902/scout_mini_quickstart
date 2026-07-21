#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
if [[ -e "/sys/class/net/$CAN_INTERFACE" ]]; then
  state=$(cat "/sys/class/net/$CAN_INTERFACE/operstate" 2>/dev/null || echo unknown)
  log_info "CAN $CAN_INTERFACE state: $state"
else
  log_warn "CAN interface not connected: $CAN_INTERFACE"
fi
if [[ -f "$WORKSPACE_DIR/install/setup.bash" ]]; then
  safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"; safe_source "$WORKSPACE_DIR/install/setup.bash"
  log_info "Software installation is ready. Live topics require powered hardware and launched drivers."
else
  log_error "Workspace not built"
  exit 1
fi
log_success "Hardware readiness check completed."
