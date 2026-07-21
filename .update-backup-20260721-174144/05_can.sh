#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
[[ "$ENABLE_CAN_SERVICE" == "1" ]] || { log_info "CAN service disabled."; exit 0; }
sudo mkdir -p /usr/local/lib/scout-mini
cat > /tmp/scout-can-setup <<EOF_CAN
#!/usr/bin/env bash
set -e
IFACE="${CAN_INTERFACE}"
BITRATE="${CAN_BITRATE}"
RESTART_MS="${CAN_RESTART_MS}"
TXQLEN="${CAN_TXQUEUELEN}"
IP_BIN="\$(command -v ip)"
action="\${1:-up}"
if [[ "\$action" == "down" ]]; then
  "\$IP_BIN" link set "\$IFACE" down 2>/dev/null || true
  exit 0
fi
for _ in \$(seq 1 20); do [[ -e "/sys/class/net/\$IFACE" ]] && break; sleep 1; done
[[ -e "/sys/class/net/\$IFACE" ]] || exit 0
"\$IP_BIN" link set "\$IFACE" down 2>/dev/null || true
"\$IP_BIN" link set "\$IFACE" type can bitrate "\$BITRATE" restart-ms "\$RESTART_MS"
"\$IP_BIN" link set "\$IFACE" txqueuelen "\$TXQLEN"
"\$IP_BIN" link set "\$IFACE" up
EOF_CAN
sudo install -m 0755 /tmp/scout-can-setup /usr/local/lib/scout-mini/scout-can-setup
sudo install -m 0644 "$ROOT_DIR/systemd/scout-can.service.in" /etc/systemd/system/scout-can.service
sudo systemctl daemon-reload
sudo systemctl enable scout-can.service
if [[ -e "/sys/class/net/$CAN_INTERFACE" ]]; then sudo systemctl restart scout-can.service; else log_warn "$CAN_INTERFACE not connected; service installed for next boot."; fi
log_success "CAN service configured."
