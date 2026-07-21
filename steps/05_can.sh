#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

[[ "$ENABLE_CAN_SERVICE" == "1" ]] || {
  log_info "CAN service disabled."
  exit 0
}

is_jetson() {
  [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]] &&
  { [[ -f /etc/nv_tegra_release ]] || dpkg-query -W nvidia-l4t-core >/dev/null 2>&1; }
}

net_driver() {
  local iface="$1"
  [[ -e "/sys/class/net/$iface/device/driver" ]] || return 1
  basename "$(readlink -f "/sys/class/net/$iface/device/driver")"
}

# 05_can 단계가 07_jetson보다 먼저 실행되는 설치 구조도 안전하게 지원합니다.
if is_jetson; then
  sudo mkdir -p /etc/systemd/network
  sudo install -m 0644 \
    "$ROOT_DIR/config/systemd-network/10-mttcan.link" \
    /etc/systemd/network/10-mttcan.link
  sudo install -m 0644 \
    "$ROOT_DIR/config/systemd-network/11-gs-usb.link" \
    /etc/systemd/network/11-gs-usb.link
  sudo udevadm control --reload-rules

  if modinfo gs_usb >/dev/null 2>&1; then
    log_success "Jetson gs_usb module detected."
  else
    log_warn "Jetson gs_usb module not found for kernel $(uname -r)."
  fi
fi

sudo mkdir -p /usr/local/lib/scout-mini

cat > /tmp/scout-can-setup <<EOF_CAN
#!/usr/bin/env bash
set -Eeuo pipefail

IFACE="${CAN_INTERFACE}"
BITRATE="${CAN_BITRATE}"
RESTART_MS="${CAN_RESTART_MS}"
TXQLEN="${CAN_TXQUEUELEN}"
IP_BIN="\$(command -v ip)"
ACTION="\${1:-up}"

if [[ "\$ACTION" == "down" ]]; then
  "\$IP_BIN" link set "\$IFACE" down 2>/dev/null || true
  exit 0
fi

for _ in \$(seq 1 40); do
  [[ -e "/sys/class/net/\$IFACE" ]] && break
  sleep 0.5
done

if [[ ! -e "/sys/class/net/\$IFACE" ]]; then
  echo "[WARN] CAN interface not found: \$IFACE"
  exit 0
fi

DRIVER=""
if [[ -e "/sys/class/net/\$IFACE/device/driver" ]]; then
  DRIVER="\$(basename "\$(readlink -f "/sys/class/net/\$IFACE/device/driver")")"
fi

if [[ -f /etc/nv_tegra_release ]] && [[ "\$IFACE" == "can0" ]] && [[ "\$DRIVER" != "gs_usb" ]]; then
  echo "[WARN] Jetson can0 driver is '\${DRIVER:-unknown}', expected 'gs_usb'."
  echo "[WARN] Reboot once to apply /etc/systemd/network/*.link rules."
  exit 0
fi

"\$IP_BIN" link set "\$IFACE" down 2>/dev/null || true
"\$IP_BIN" link set "\$IFACE" type can \
  bitrate "\$BITRATE" \
  restart-ms "\$RESTART_MS"
"\$IP_BIN" link set "\$IFACE" txqueuelen "\$TXQLEN"
"\$IP_BIN" link set "\$IFACE" up

echo "[INFO] Scout CAN configured: \$IFACE, bitrate=\$BITRATE, driver=\${DRIVER:-unknown}"
EOF_CAN

sudo install -m 0755 \
  /tmp/scout-can-setup \
  /usr/local/lib/scout-mini/scout-can-setup
rm -f /tmp/scout-can-setup

sudo install -m 0644 \
  "$ROOT_DIR/systemd/scout-can.service.in" \
  /etc/systemd/system/scout-can.service

sudo systemctl daemon-reload
sudo systemctl enable scout-can.service

if [[ -e "/sys/class/net/$CAN_INTERFACE" ]]; then
  current_driver="$(net_driver "$CAN_INTERFACE" 2>/dev/null || true)"

  if is_jetson && [[ "$CAN_INTERFACE" == "can0" ]] && [[ "$current_driver" != "gs_usb" ]]; then
    log_warn "$CAN_INTERFACE driver is '${current_driver:-unknown}', expected gs_usb."
    log_warn "CAN service was installed, but a reboot is required before it can start safely."
  else
    sudo systemctl restart scout-can.service
  fi
else
  log_warn "$CAN_INTERFACE not connected; service installed for next boot."
fi

log_success "CAN service configured."
