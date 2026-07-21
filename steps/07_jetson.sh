#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

is_jetson() {
  [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] &&
  { [[ -f /etc/nv_tegra_release ]] || dpkg-query -W nvidia-l4t-core >/dev/null 2>&1; }
}

if ! is_jetson; then
  log_info "Non-Jetson system detected. Jetson-specific setup skipped."
  exit 0
fi

log_info "Jetson environment detected."

sudo mkdir -p /etc/systemd/network
sudo install -m 0644 \
  "$ROOT_DIR/config/systemd-network/10-mttcan.link" \
  /etc/systemd/network/10-mttcan.link
sudo install -m 0644 \
  "$ROOT_DIR/config/systemd-network/11-gs-usb.link" \
  /etc/systemd/network/11-gs-usb.link

sudo udevadm control --reload-rules
sudo systemctl restart systemd-udevd.service

if modinfo gs_usb >/dev/null 2>&1; then
  module_path="$(modinfo -F filename gs_usb 2>/dev/null || true)"
  log_success "gs_usb module available: ${module_path:-installed}"
else
  log_warn "gs_usb module is not available for kernel $(uname -r)."
  log_warn "candleLight/CANable compatible USB-CAN will not work until gs_usb is installed."
fi

can0_driver=""
if [[ -e /sys/class/net/can0/device/driver ]]; then
  can0_driver="$(basename "$(readlink -f /sys/class/net/can0/device/driver)")"
fi

if [[ "$can0_driver" == "gs_usb" ]]; then
  log_success "can0 is already using gs_usb."
elif [[ -n "$can0_driver" ]]; then
  log_warn "Current can0 driver: $can0_driver"
  log_warn "A reboot is required to apply persistent CAN interface names."
else
  log_info "can0 is not currently present. Connect the USB-CAN adapter and reboot if needed."
fi

log_success "Jetson CAN naming rules installed."
log_info "USB CAN(gs_usb): can0"
log_info "Jetson internal CAN(mttcan): can_internal"
