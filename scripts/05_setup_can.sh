#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$ENABLE_CAN_SERVICE" != 1 ]]; then echo "[SKIP] CAN service disabled."; exit 0; fi
sudo install -m 0755 "$ROOT_DIR/systemd/scout-can-setup" /usr/local/sbin/scout-can-setup
sudo sed -e "s/@CAN_INTERFACE@/$CAN_INTERFACE/g" -e "s/@CAN_BITRATE@/$CAN_BITRATE/g" "$ROOT_DIR/systemd/scout-can.service.in" | sudo tee /etc/systemd/system/scout-can.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable scout-can.service
if ip link show "$CAN_INTERFACE" >/dev/null 2>&1; then
  sudo systemctl restart scout-can.service
  systemctl --no-pager --full status scout-can.service || true
else
  echo "[WARN] $CAN_INTERFACE not detected now. Service will retry during boot after adapter connection."
fi
echo "[OK] CAN boot service installed."
