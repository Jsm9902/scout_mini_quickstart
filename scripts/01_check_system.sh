#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ! -f /etc/os-release ]]; then
  echo "[ERROR] /etc/os-release not found. Ubuntu 22.04 is required." >&2
  exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "22.04" ]]; then
  echo "[ERROR] Ubuntu 22.04 is required. Detected: $PRETTY_NAME" >&2
  exit 1
fi
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "[WARN] This guide is tested primarily on x86_64 Intel NUC systems."
fi
if [[ -n "${CONDA_PREFIX:-}" ]]; then
  echo "[ERROR] Conda is active: $CONDA_PREFIX"
  echo "        Run 'conda deactivate' and execute quickstart.sh again." >&2
  exit 1
fi
if ! command -v sudo >/dev/null 2>&1; then
  echo "[ERROR] sudo is required." >&2
  exit 1
fi
sudo -v
if ! getent hosts packages.ros.org >/dev/null 2>&1; then
  echo "[ERROR] Internet/DNS connection to packages.ros.org failed." >&2
  exit 1
fi
echo "[OK] System check passed: $PRETTY_NAME"
