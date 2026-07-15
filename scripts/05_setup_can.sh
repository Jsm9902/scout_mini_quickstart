#!/usr/bin/env bash
set -Eeuo pipefail

service_file="/etc/systemd/system/scout-can.service"
sudo tee "$service_file" >/dev/null <<SERVICE
[Unit]
Description=Configure Scout Mini CAN interface
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '/sbin/ip link set ${CAN_INTERFACE} down || true; /sbin/ip link set ${CAN_INTERFACE} type can bitrate ${CAN_BITRATE}; /sbin/ip link set ${CAN_INTERFACE} up'
ExecStop=/sbin/ip link set ${CAN_INTERFACE} down

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable scout-can.service

if ip link show "$CAN_INTERFACE" >/dev/null 2>&1; then
  sudo systemctl restart scout-can.service || true
  echo "[OK] CAN interface configured: $CAN_INTERFACE @ $CAN_BITRATE"
else
  echo "[WARN] CAN interface '$CAN_INTERFACE' is not currently present."
  echo "       The systemd service has been installed and will configure it when available."
fi
