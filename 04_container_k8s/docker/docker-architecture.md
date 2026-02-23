# Docker Architecture

## 1. 개요 및 비유
**Docker(도커)**는 애플리케이션과 그 실행 환경을 컨테이너라는 격리된 단위로 패키징하여, 어디서든 동일하게 실행될 수 있도록 해주는 플랫폼입니다.

💡 **비유하자면 '대형 레스토랑의 주방 시스템'과 같습니다.**
* **Docker CLI (홀 직원):** 사용자의 명령(주문)을 받습니다.
* **Docker Daemon (주방장):** CLI의 명령을 받아 실제로 컨테이너(요리)를 만들고 관리합니다.
* **Docker Image (레시피 북):** 요리를 만들기 위한 완벽한 레시피와 재료 모음입니다.
* **Docker Registry (본사 창고):** 레시피 북을 보관하고 공유하는 저장소(Docker Hub, AWS ECR 등)입니다.

## 2. 핵심 설명
* **Client-Server 모델:** 도커는 클라이언트(CLI)와 서버(Daemon/`dockerd`) 구조로 나뉘어 있습니다. 이 둘은 REST API, UNIX 소켓 또는 네트워크 인터페이스를 통해 통신합니다.
* **격리 기술:** 리눅스 커널의 `Namespaces`(프로세스, 네트워크 격리)와 `Cgroups`(CPU, 메모리 자원 할당량 제한) 기술을 뼈대로 삼아 컨테이너를 가볍고 안전하게 격리합니다.
* **가상머신(VM)과의 차이:** VM은 무거운 통째의 Guest OS를 띄워야 하지만, 도커 컨테이너는 호스트 OS의 커널을 공유하므로 부팅 속도가 몇 초 단위로 매우 빠릅니다.

## 3. YAML 적용 예시 (Docker Daemon 설정)
Docker 데몬(`dockerd`)의 작동 방식을 제어하는 `daemon.json` 설정 파일 예시입니다. (JSON 형식은 YAML의 하위 집합으로 YAML 파서에서 완벽히 호환/해석됩니다.)

```yaml
# /etc/docker/daemon.json
# 도커 데몬의 로깅 드라이버를 변경하고, 프라이빗 레지스트리를 허용하는 설정
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "insecure-registries": ["my-private-registry.internal.com:5000"],
  "data-root": "/mnt/docker-data"
}
```

## 4. 트러블 슈팅
* **`Cannot connect to the Docker daemon` 에러:**
  * 도커 클라이언트가 데몬과 통신할 수 없을 때 발생합니다. `sudo systemctl status docker`로 데몬이 켜져 있는지 확인하세요.
  * 사용자가 `docker` 그룹에 속해있지 않아 UNIX 소켓 권한이 없는 경우, `sudo usermod -aG docker $USER` 명령어로 권한을 부여하고 로그아웃 후 다시 로그인해야 합니다.