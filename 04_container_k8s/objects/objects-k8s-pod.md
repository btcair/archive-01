# Objects: K8s Pod

## 1. 개요 및 비유
**Pod(파드)**는 쿠버네티스에서 생성하고 관리할 수 있는 가장 작고 기본적인 배포 단위입니다. 하나의 파드 안에는 한 개 이상의 컨테이너(Docker 등)가 들어갈 수 있습니다.

💡 **비유하자면 '우주선 캡슐(Pod)'과 '우주 비행사(Container)'와 같습니다.**
하나의 우주선 캡슐 안에는 한 명 혹은 여러 명의 우주 비행사가 탈 수 있습니다. 이 비행사들은 캡슐 내의 산소통(스토리지 볼륨)과 무전기(네트워크/IP)를 공유하며, 우주로 발사될 때도 항상 같이 출발하고 귀환할 때도 똑같은 장소(동일한 워커 노드)에 함께 착륙합니다. 

## 2. 핵심 설명
* **자원 공유:** 파드 내의 컨테이너들은 **동일한 IP 주소와 포트 공간**을 공유합니다. 따라서 파드 내부의 컨테이너끼리는 `localhost:포트번호`를 통해 초고속으로 통신할 수 있습니다.
* **비영구적(Ephemeral) 특성:** 파드는 일시적인 존재입니다. 파드에 오류가 생겨 죽으면, 쿠버네티스는 그 파드를 살려내지 않고 완전히 똑같은 복제본 파드를 새로 만들어 버립니다. (따라서 파드 내부 디스크에 중요한 데이터를 저장하면 안 됩니다.)
* **사이드카 패턴 (Sidecar Pattern):** 하나의 파드에 메인 앱 컨테이너와, 로깅이나 프록시 역할을 돕는 보조(Sidecar) 컨테이너를 함께 띄우는 것이 실무의 핵심 아키텍처입니다.

## 3. YAML 적용 예시 (기본 파드 생성)
Nginx 웹 서버를 실행하는 가장 기본적인 파드 매니페스트입니다. (실무에서는 파드를 직접 만들지 않고 Deployment를 통해 만듭니다.)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-first-pod
  labels:
    app: web
    env: dev
spec:
  containers:
  - name: nginx-container
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
```

## 4. 트러블 슈팅
* **파드 상태가 `ImagePullBackOff` 또는 `ErrImagePull`인 경우:**
  * 오타 등으로 인해 도커 이미지의 이름이나 태그(버전)가 존재하지 않거나, Private ECR/Registry에 접근할 수 있는 인증 정보(`imagePullSecrets`)가 없어서 이미지를 다운로드하지 못한 상태입니다.
* **파드 상태가 `CrashLoopBackOff`인 경우:**
  * 이미지는 잘 다운로드했지만, 컨테이너 내부의 애플리케이션이 시작되자마자 에러를 뱉고 죽는 현상이 반복되는 것입니다. 
  * 해결책: `kubectl logs my-first-pod` 명령어로 애플리케이션의 에러 로그(예: DB 연결 실패, 환경변수 누락)를 확인해야 합니다.