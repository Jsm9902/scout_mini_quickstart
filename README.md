# Scout Mini Quickstart

ROS 2 Humble 기반 Scout Mini 실전 운용 환경을 자동으로 구축하는 Quick Guide 저장소입니다.

기존 [`scout_mini`](https://github.com/Jsm9902/scout_mini) 저장소는 개발 과정과 전체 소스를 보존하고, 이 저장소는 **Ubuntu 22.04 신규 PC 설치와 현장 운용 자동화**에 집중합니다.

## 지원 범위

- ROS 2 Humble Desktop
- AgileX Scout Mini 소스 패키지
- Velodyne VLP-16
- PointCloud to LaserScan
- SLAM Toolbox
- AMCL / Navigation2
- Safety Stop / Industrial Safety
- ROSBridge / Web Video Server
- Web Navigation / Web SLAM
- CAN 인터페이스 systemd 자동 설정
- 설치 후 빌드 및 패키지 검증

## 요구 환경

- Ubuntu 22.04 LTS x86_64
- 인터넷 연결
- sudo 권한
- Scout Mini CAN 어댑터
- Velodyne VLP-16

> 이 설치 스크립트는 Ubuntu 22.04 전용입니다. 다른 Ubuntu 버전에서는 실행을 중단합니다.

## 빠른 설치

```bash
git clone https://github.com/Jsm9902/scout_mini_quickstart.git
cd scout_mini_quickstart
cp config/quickstart.env.example config/quickstart.env
nano config/quickstart.env
chmod +x quickstart.sh scripts/*.sh tools/*.sh
./quickstart.sh
```

전체 기능 소스를 설치하려면:

```bash
./quickstart.sh --full
```

설치 로그는 `logs/install-YYYYMMDD-HHMMSS.log`에 저장됩니다.

## 설정 파일

`config/quickstart.env`에서 다음 값을 변경할 수 있습니다.

```bash
WORKSPACE_DIR=$HOME/scout_ws
SOURCE_REPO=https://github.com/Jsm9902/scout_mini.git
SOURCE_BRANCH=main
CAN_INTERFACE=can0
CAN_BITRATE=500000
WEB_SERVER_PORT=8000
ROSBRIDGE_PORT=9090
VIDEO_SERVER_PORT=8080
```

## 설치 후 명령

```bash
start_slam
start_navigation
start_web_slam
start_web_navigation
check_robot
stop_robot
```

기본 Navigation 명령은 안전 제어가 포함된 다음 런처를 실행합니다.

```bash
ros2 launch scout_navigation scout_industrial_safety_integrated.launch.py
```

## 자동 설치 단계

1. Ubuntu 22.04, sudo, 네트워크 및 Conda 상태 확인
2. ROS 2 Humble 설치
3. Nav2, SLAM Toolbox, ROSBridge, Velodyne 등 의존성 설치
4. 기존 `scout_mini` 저장소에서 소스 패키지 복사
5. CAN systemd 서비스 설치
6. rosdep 및 colcon 빌드
7. 운용 명령 설치
8. 핵심 ROS 패키지 검증

## 보안 주의

ROSBridge는 브라우저에서 ROS 토픽과 서비스에 접근할 수 있게 합니다. 포트 `9090`을 인터넷에 직접 노출하지 말고, 신뢰할 수 있는 로컬 네트워크나 VPN 내부에서만 사용하십시오.

## 문서

- [하드웨어 연결](docs/hardware-setup.md)
- [문제 해결](docs/troubleshooting.md)

## 저장소 역할

| 저장소 | 목적 |
|---|---|
| `scout_mini` | 개발 과정, 전체 코드, 주행백서 기반 기초 데이터 |
| `scout_mini_quickstart` | 신규 PC 자동 설치, 검증, 실전 운용 |
