# Changelog

## v0.2.0

- 실제 원본 저장소 패키지명에 맞춰 검증 대상을 `scout_base`, `scout_msgs`로 수정
- 존재하지 않는 `scout_ros2` ROS 패키지 검증 제거
- 핵심 launch 파일 설치 여부 검증 추가
- 운용 스크립트의 ROS 배포판 및 workspace 하드코딩 제거
- 설치 시 runtime 환경 파일 생성
- CAN systemd 서비스에서 실제 `ip` 실행 경로 사용
- workspace 재설치 시 기존 `src` 백업 정책 추가
- `--full` 옵션 제거
- `git`, `rsync`, 빌드 도구 및 teleop 의존성 보강
