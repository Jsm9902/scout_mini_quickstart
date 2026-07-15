#!/usr/bin/env bash
set -Eeuo pipefail

IP_BIN="$(command -v ip)"
service_file="/etc/systemd/system/scout-can.service"

sudo tee "$service_file" >/dev/null <<SERVICE
[Unit]
Description=Configure Scout Mini CAN interface
After=network-pre.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${IP_BIN} link set ${CAN_INTERFACE} down
ExecStart=${IP_BIN} link set ${CAN_INTERFACE} type can bitrate ${CAN_BITRATE}
ExecStart=${IP_BIN} link set ${CAN_INTERFACE} up
ExecStop=${IP_BIN} link set ${CAN_INTERFACE} down

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable scout-can.service

if ip link show "$CAN_INTERFACE" >/dev/null 2>&1; then
  sudo systemctl restart scout-can.service
  echo "[OK] CAN interface configured: $CAN_INTERFACE @ $CAN_BITRATE bit/s"
else
  echo "[WARN] CAN interface '$CAN_INTERFACE' is not currently present."
  echo "       The systemd service was installed, but it can only start after the CAN adapter is detected."
fi
