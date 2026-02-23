# Docker Container Runtime

## 1. 개요 및 비유
**컨테이너 런타임(Container Runtime)**은 컨테이너를 실제로 실행하고 생명 주기를 관리하는 핵심 소프트웨어입니다. 최근 쿠버네티스 생태계에서는 무거운 Docker Engine 대신, 그 안의 알맹이인 **containerd(고수준)**나 **runc(저수준)** 같은 런타임을 직접 사용합니다.

💡 **비유하자면 '자동차의 엔진 시스템'과 같습니다.**
* **고수준 런타임 (containerd 등):** 자동차의 '운전대와 페달'입니다. 사용자의 명령을 받아 이미지를 다운로드하고 엔진에 지시를 내립니다.
* **저수준 런타임 (runc 등):** 자동차의 실제 '엔진 블록'입니다. 리눅스 커널과 직접 맞닿아 폭발을 일으키며(격리 생성) 바퀴를 굴립니다(컨테이너 실행).

## 2. 핵심 설명
* **CRI (Container Runtime Interface):** 쿠버네티스의 Kubelet이 다양한 런타임(containerd, CRI-O 등)과 통신하기 위해 만든 표준 API입니다. 이 표준 덕분에 쿠버네티스에서 Docker 런타임을 덜어낼 수 있었습니다.
* **runc (저수준):** OCI(Open Container Initiative) 표준을 준수하는 가장 대표적인 저수준 런타임으로, Cgroups와 Namespaces를 세팅하여 순수하게 프로세스를 격리하는 역할만 수행합니다.
* **containerd (고수준):** 도커에서 분리되어 나온 런타임으로, 이미지 풀링(Pull), 네트워크 연결, `runc` 호출 등 컨테이너 관리에 필요한 전반적인 기능을 가볍게 제공합니다.

## 3. YAML 적용 예시 (Kubernetes RuntimeClass)
클러스터에 여러 런타임(예: 기본 `runc`와 보안이 강화된 격리 런타임 `gVisor` 또는 `Kata Containers`)이 있을 때, 파드별로 런타임을 지정하는 예시입니다.

```yaml
# 1. 특정 런타임을 정의하는 RuntimeClass 리소스
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc # 컨테이너 런타임(containerd)에 설정된 핸들러 이름

---
# 2. 해당 런타임을 사용하여 파드 배포
apiVersion: v1
kind: Pod
metadata:
  name: secure-nginx
spec:
  runtimeClassName: gvisor # 위에서 정의한 런타임 클래스 사용
  containers:
  - name: nginx
    image: nginx:alpine
```

## 4. 트러블 슈팅
* **쿠버네티스 업그레이드 후 `containerd` 관련 에러 (Docker Deprecation):**
  * 쿠버네티스 1.24 버전부터 Dockershim(도커 지원 모듈)이 제거되어, 워커 노드의 런타임이 `containerd`로 기본 전환되었습니다.
  * 기존에 로컬에서 `docker ps`나 `docker images` 명령어를 사용하던 운영 습관을 버리고, containerd 전용 디버깅 툴인 **`crictl`**이나 **`nerdctl`** 명령어를 사용하도록 적응해야 합니다.