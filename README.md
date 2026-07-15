# Scout Mini Quickstart

ROS 2 Humble 기반 Scout Mini 실전 운용 환경을 자동으로 구축하는 설치·운용 저장소입니다.

기존 [`scout_mini`](https://github.com/Jsm9902/scout_mini) 저장소는 개발 과정과 전체 소스를 보존하고, 이 저장소는 **Ubuntu 22.04 신규 PC 설치와 현장 운용 자동화**에 집중합니다.

## 지원 범위

- ROS 2 Humble Desktop
- AgileX Scout Mini 드라이버 (`scout_base`, `scout_msgs`, `ugv_sdk`)
- Velodyne VLP-16 및 PointCloud → LaserScan
- SLAM Toolbox
- AMCL / Navigation2
- Safety Stop / Industrial Safety
- ROSBridge / Web Video Server
- Web Navigation / Web SLAM
- CAN 인터페이스 systemd 자동 설정
- 빌드 후 패키지·런처 검증

## 요구 환경

- Ubuntu 22.04 LTS
- 인터넷 연결
- sudo 권한
- Scout Mini CAN 어댑터
- Velodyne VLP-16

> 설치 스크립트는 Ubuntu 22.04 전용입니다. 다른 Ubuntu 버전에서는 실행을 중단합니다.

## 빠른 설치

```bash
git clone https://github.com/Jsm9902/scout_mini_quickstart.git
cd scout_mini_quickstart

cp config/quickstart.env.example config/quickstart.env
nano config/quickstart.env

chmod +x quickstart.sh scripts/*.sh tools/*.sh
./quickstart.sh
```

설치 로그는 다음 경로에 저장됩니다.

```text
logs/install-YYYYMMDD-HHMMSS.log
```

## 설정 파일

`config/quickstart.env`에서 다음 값을 변경할 수 있습니다.

```bash
ROS_DISTRO=humble
WORKSPACE_DIR=$HOME/scout_ws
SOURCE_REPO=https://github.com/Jsm9902/scout_mini.git
SOURCE_BRANCH=main

CAN_INTERFACE=can0
CAN_BITRATE=500000

WEB_SERVER_PORT=8000
ROSBRIDGE_PORT=9090
VIDEO_SERVER_PORT=8080

BACKUP_EXISTING_SRC=1
```

`BACKUP_EXISTING_SRC=1`이면 기존 `workspace/src`를 날짜가 포함된 폴더로 백업한 뒤 새 소스를 설치합니다.

## 자동 설치 단계

1. Ubuntu 버전, sudo, DNS, Conda 상태 확인
2. ROS 2 Humble 설치
3. Nav2, SLAM Toolbox, ROSBridge, Velodyne 등 의존성 설치
4. 기존 `scout_mini` 저장소에서 검증된 소스 복사
5. CAN systemd 서비스 설치
6. `rosdep` 의존성 해결 및 `colcon` 빌드
7. 실전 운용 명령 설치
8. 실제 패키지와 핵심 런처 검증

## 설치 후 명령

새 터미널을 열거나 다음 명령을 실행합니다.

```bash
source ~/.bashrc
```

### SLAM

```bash
start_slam
```

실행 런처:

```bash
ros2 launch scout_slam scout_slam_integrated.launch.py
```

### 안전 자율주행

```bash
start_navigation
```

실행 런처:

```bash
ros2 launch scout_navigation scout_industrial_safety_integrated.launch.py
```

### Web SLAM

```bash
start_web_slam
```

### Web Navigation

```bash
start_web_navigation
```

### 상태 점검

```bash
check_robot
```

### 종료

```bash
stop_robot
```

## 설치 검증 대상

Quickstart는 빌드 후 다음 실제 ROS 패키지를 확인합니다.

```text
scout_base
scout_msgs
scout_description
ugv_sdk
scout_navigation
scout_slam
scout_web_monitor
rosbridge_server
web_video_server
pointcloud_to_laserscan
slam_toolbox
nav2_bringup
```

또한 다음 핵심 런처가 설치 공간에 존재하는지 확인합니다.

```text
scout_navigation/scout_industrial_safety_integrated.launch.py
scout_slam/scout_slam_integrated.launch.py
scout_web_monitor/web_nav.launch.py
scout_web_monitor/web_slam.launch.py
```

## CAN 확인

```bash
ip -details link show can0
candump can0
```

CAN 장치명이 다르면 `config/quickstart.env`의 `CAN_INTERFACE`를 수정합니다.

## 권장 최초 운용 순서

1. CAN 및 센서 연결 확인
2. `start_slam`으로 지도 생성
3. 지도 저장 및 Navigation 설정의 지도 경로 확인
4. `start_navigation`으로 RViz 자율주행 검증
5. `start_web_navigation`으로 Web 관제 검증

## 보안 주의

ROSBridge 포트 `9090`은 브라우저에서 ROS 토픽과 서비스에 접근할 수 있게 합니다. 인터넷에 직접 노출하지 말고 신뢰할 수 있는 로컬 네트워크 또는 VPN 내부에서만 사용하십시오.

## 문서

- [하드웨어 연결](docs/hardware-setup.md)
- [문제 해결](docs/troubleshooting.md)

## 저장소 역할

| 저장소 | 목적 |
|---|---|
| `scout_mini` | 개발 과정, 전체 코드, 주행백서 기반 기초 데이터 |
| `scout_mini_quickstart` | 신규 PC 자동 설치, 빌드 검증, 실전 운용 |
