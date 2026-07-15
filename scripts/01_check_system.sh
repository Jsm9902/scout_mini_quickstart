#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/_lib.sh"
source /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 22.04 ]] || { echo "[ERROR] Ubuntu 22.04 required. Detected: $PRETTY_NAME"; exit 1; }
[[ "$(uname -m)" == x86_64 ]] || echo "[WARN] Primary target is x86_64 Intel NUC. Detected: $(uname -m)"
[[ -z "${CONDA_PREFIX:-}" ]] || { echo "[ERROR] Conda is active. Run 'conda deactivate' first."; exit 1; }
command -v sudo >/dev/null
sudo -v
retry 5 getent hosts packages.ros.org >/dev/null
retry 5 getent hosts github.com >/dev/null
free_gb=$(df -Pk "$HOME" | awk 'NR==2 {printf "%d", $4/1024/1024}')
(( free_gb >= 12 )) || { echo "[ERROR] At least 12 GB free space is required; available ${free_gb} GB."; exit 1; }
if [[ "$WORKSPACE_DIR" != "$HOME"/* ]]; then echo "[WARN] WORKSPACE_DIR is outside HOME: $WORKSPACE_DIR"; fi
for p in WEB_SERVER_PORT ROSBRIDGE_PORT VIDEO_SERVER_PORT; do
  v="${!p}"; [[ "$v" =~ ^[0-9]+$ ]] && ((v>0 && v<65536)) || { echo "[ERROR] Invalid $p=$v"; exit 1; }
done
echo "[OK] System: $PRETTY_NAME, free ${free_gb} GB"
