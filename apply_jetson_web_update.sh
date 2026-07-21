#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="${1:-$PWD}"

if [[ ! -d "$ROOT_DIR/steps" || ! -f "$ROOT_DIR/README.md" ]]; then
  echo "[ERROR] Scout Mini Quickstart 저장소 루트에서 실행하세요."
  echo "예: cd ~/scout_mini_quickstart && bash /path/to/apply_jetson_web_update.sh"
  exit 1
fi

backup_dir="$ROOT_DIR/.update-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir/steps" "$backup_dir/config"

for file in \
  "$ROOT_DIR/steps/05_can.sh" \
  "$ROOT_DIR/steps/09_hardware_verify.sh" \
  "$ROOT_DIR/README.md" \
  "$ROOT_DIR/install.sh"
do
  [[ -f "$file" ]] && cp -a "$file" "$backup_dir/$(basename "$file")"
done

mkdir -p "$ROOT_DIR/config/systemd-network"

cat > "$ROOT_DIR/config/systemd-network/10-mttcan.link" <<'EOF'
[Match]
Driver=mttcan

[Link]
NamePolicy=
Name=can_internal
EOF

cat > "$ROOT_DIR/config/systemd-network/11-gs-usb.link" <<'EOF'
[Match]
Driver=gs_usb

[Link]
NamePolicy=
Name=can0
EOF

cat > "$ROOT_DIR/steps/07_jetson.sh" <<'EOF'
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
EOF
chmod +x "$ROOT_DIR/steps/07_jetson.sh"

cat > "$ROOT_DIR/steps/05_can.sh" <<'EOF'
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
EOF
chmod +x "$ROOT_DIR/steps/05_can.sh"

cat > "$ROOT_DIR/steps/09_hardware_verify.sh" <<'EOF'
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
EOF
chmod +x "$ROOT_DIR/steps/09_hardware_verify.sh"

cat > "$ROOT_DIR/README.md" <<'EOF'
# Scout Mini Quickstart v2.1

Ubuntu 22.04에서 ROS2 Humble, Scout Mini 드라이버, Velodyne, SLAM,
Navigation2, 안전 제어 및 Web 관제 환경을 자동으로 구축하는 설치기입니다.

지원 환경:

- Ubuntu 22.04 x86_64 Mini PC
- NVIDIA Jetson Orin Nano / ARM64
- ROS2 Humble
- Scout Mini
- Velodyne VLP-16
- RealSense 선택 지원

## 설치

```bash
git clone https://github.com/Jsm9902/scout_mini_quickstart.git
cd scout_mini_quickstart
cp config/scout.env.example config/scout.env
nano config/scout.env
./install.sh
```

중단 후 재개:

```bash
./install.sh --resume
```

검증만 실행:

```bash
./install.sh --verify-only
```

> `sudo ./install.sh`로 실행하지 마세요.

## Jetson CAN 구성

Jetson은 내장 CAN과 USB-CAN의 이름 충돌을 방지하기 위해 다음 이름을 사용합니다.

```text
USB-CAN (gs_usb)        -> can0
Jetson 내장 CAN(mttcan) -> can_internal
```

Quickstart가 다음 파일을 자동으로 설치합니다.

```text
/etc/systemd/network/10-mttcan.link
/etc/systemd/network/11-gs-usb.link
```

첫 설치 후 `can0`가 `gs_usb`가 아니라면 한 번 재부팅합니다.

```bash
sudo reboot
```

재부팅 후 확인:

```bash
ip -br link | grep -E 'can0|can_internal'
readlink -f /sys/class/net/can0/device/driver
scout-can-check
```

기대 결과:

```text
can0         -> gs_usb
can_internal -> mttcan
can0 bitrate -> 500000
```

## 설치 후 명령

```text
scout-manager
scout-build
scout-start-base
scout-start-slam
scout-start-navigation
scout-start-web-slam
scout-start-web-navigation
scout-check
scout-can-check
scout-stop
```

새 터미널에서 명령어를 찾지 못하면 다음을 실행합니다.

```bash
source ~/.bashrc
```

## 빠른 실행 가이드

### 1. 설치 상태 확인

```bash
scout-check
scout-can-check
```

### 2. 기본 구동

```bash
scout-start-base
```

### 3. SLAM 실행

RViz 기반 SLAM:

```bash
scout-start-slam
```

Web 관제 기반 SLAM:

```bash
scout-start-web-slam
```

### 4. Navigation 실행

RViz 기반 Navigation:

```bash
scout-start-navigation
```

Web 관제 기반 Navigation:

```bash
scout-start-web-navigation
```

### 5. 전체 종료

```bash
scout-stop
```

## Web Monitor

Web Monitor는 SLAM 또는 Navigation 실행 명령에 포함되어 실행됩니다.

SLAM Web 관제:

```bash
scout-start-web-slam
```

Navigation Web 관제:

```bash
scout-start-web-navigation
```

로봇의 IP 주소 확인:

```bash
hostname -I
```

브라우저 접속:

```text
http://<ROBOT_IP>:8000
```

기본 포트:

| 서비스 | 포트 |
|---|---:|
| Web UI | 8000 |
| ROSBridge WebSocket | 9090 |
| Web Video Server | 8080 |

Web Monitor에서 사용할 수 있는 주요 기능:

- 지도 표시
- 로봇 위치 표시
- 목표 지점 지정
- 수동 조작
- SLAM 및 Navigation 모드 실행
- 카메라 영상 확인
- 로봇 상태 확인

## 하드웨어 기본값

- CAN 인터페이스: `can0`
- CAN bitrate: `500000`
- ROSBridge: `9090`
- Video Server: `8080`
- Web Server: `8000`

실제 CAN 어댑터, Velodyne IP 및 카메라 연결은 하드웨어 환경에 맞춰 확인해야 합니다.

## 문제 해결

### Web 화면이 열리지 않음

서비스 포트를 확인합니다.

```bash
ss -lntp | grep -E ':8000|:8080|:9090'
```

로봇과 접속 PC가 같은 네트워크인지 확인합니다.

```bash
hostname -I
```

브라우저에서는 `localhost`가 아니라 로봇의 실제 IP를 사용합니다.

```text
http://<ROBOT_IP>:8000
```

### Web에서 Robot Offline 표시

먼저 CAN을 확인합니다.

```bash
scout-can-check
ip -details link show can0
systemctl status scout-can.service --no-pager
```

Scout Base가 실행 중인지 확인합니다.

```bash
ros2 node list | grep scout
ros2 topic list | grep -E 'cmd_vel|odom|battery'
```

### Jetson에서 can0가 gs_usb가 아님

```bash
readlink -f /sys/class/net/can0/device/driver
```

`mttcan`으로 표시되면 `.link` 규칙 적용을 위해 재부팅합니다.

```bash
sudo reboot
```

### gs_usb 모듈 없음

```bash
modinfo gs_usb
```

모듈을 찾을 수 없다면 현재 Jetson 커널용 `gs_usb` 모듈을 설치해야 합니다.
모듈 설치 후 다음 명령으로 확인합니다.

```bash
sudo modprobe gs_usb
lsmod | grep gs_usb
```

### Velodyne 데이터가 없음

```bash
ros2 topic list | grep velodyne
ros2 topic hz /velodyne_points
```

Velodyne과 Jetson 또는 Mini PC의 IP 대역이 같은지 확인합니다.

### Web 관련 ROS 패키지 확인

```bash
ros2 pkg prefix scout_web_monitor
ros2 pkg prefix rosbridge_server
ros2 pkg prefix web_video_server
```

## 업데이트 검증

```bash
bash -n steps/05_can.sh
bash -n steps/07_jetson.sh
bash -n steps/09_hardware_verify.sh
./install.sh --verify-only
```
EOF

# install.sh가 명시적 배열로 steps를 실행하는 경우 07_jetson을 자동 삽입합니다.
if [[ -f "$ROOT_DIR/install.sh" ]] && ! grep -q '07_jetson\.sh' "$ROOT_DIR/install.sh"; then
  python3 - "$ROOT_DIR/install.sh" <<'PY'
from pathlib import Path
import sys, re

path = Path(sys.argv[1])
text = path.read_text()

patterns = [
    (r'("?\$ROOT_DIR/steps/06_build\.sh"?\s*)', r'\1\n"$ROOT_DIR/steps/07_jetson.sh"\n'),
    (r'("steps/06_build\.sh"\s*)', r'\1\n"steps/07_jetson.sh"\n'),
    (r'(06_build\.sh\s*)', r'\1\n07_jetson.sh\n'),
]

for pattern, replacement in patterns:
    new_text, count = re.subn(pattern, replacement, text, count=1)
    if count:
        path.write_text(new_text)
        break
PY
fi

bash -n "$ROOT_DIR/steps/05_can.sh"
bash -n "$ROOT_DIR/steps/07_jetson.sh"
bash -n "$ROOT_DIR/steps/09_hardware_verify.sh"

echo
echo "[SUCCESS] Scout Mini Quickstart v2.1 update applied."
echo "[INFO] Backup directory: $backup_dir"
echo
echo "다음 명령을 실행하세요:"
echo "  cd \"$ROOT_DIR\""
echo "  git diff"
echo "  ./install.sh --verify-only"
echo
echo "Jetson에서 CAN 이름이 아직 바뀌지 않았다면:"
echo "  sudo reboot"
