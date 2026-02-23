# Objects: K8s Deployment

## 1. 개요 및 비유
**Deployment(디플로이먼트)**는 쿠버네티스에서 상태가 없는(Stateless) 애플리케이션을 배포하고 관리하는 가장 기본적이고 강력한 컨트롤러(Controller)입니다. 

💡 **비유하자면 '프랜차이즈 매장의 깐깐한 점장님'과 같습니다.**
점장님(Deployment)에게 "항상 요리사(Pod) 3명이 주방에 있어야 해"라고 지시해 두면, 요리사 한 명이 아파서 조퇴(Pod 장애)하더라도 점장님이 즉시 새로운 요리사를 고용하여 어떻게든 3명이라는 '원하는 상태(Desired State)'를 유지해 줍니다. 또한 새로운 레시피(버전 업데이트)가 나오면 요리사들을 한 명씩 순차적으로 교육(Rolling Update)하여 매장 영업을 멈추지 않게 합니다.

[Image of Kubernetes Deployment rolling update process managing ReplicaSets and Pods]

## 2. 핵심 설명
* **선언적 업데이트:** 관리자가 바라는 상태(Replicas 개수, 사용할 이미지 버전 등)를 YAML로 선언하면, 내부적으로 **ReplicaSet**을 생성하여 현재 상태를 바라는 상태로 일치시킵니다.
* **자가 치유 (Self-Healing):** 파드가 실행 중인 워커 노드가 다운되거나 파드 자체에 크래시가 발생하면, 다른 정상적인 노드에 파드를 새로 띄워 가용성을 보장합니다.
* **롤아웃 및 롤백:** 배포 전략(RollingUpdate)을 통해 무중단 배포를 지원하며, 새 버전에 치명적인 버그가 있다면 즉시 이전 버전으로 되돌릴 수 있는 롤백(`kubectl rollout undo`) 기능을 제공합니다.

## 3. YAML 적용 예시 (롤링 업데이트 설정 포함)
Nginx 웹 서버 파드 3개를 유지하며, 업데이트 시 한 번에 최대 1개씩만 교체하도록 세밀하게 설정한 Deployment 예시입니다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector: # 이 라벨을 가진 파드들을 관리 대상으로 삼음
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1 # 업데이트 중 동시에 사용할 수 없는 파드의 최대 개수
      maxSurge: 1       # 업데이트 중 추가로 띄울 수 있는 파드의 최대 개수
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.4
        ports:
        - containerPort: 80
```

## 4. 트러블 슈팅
* **새로 배포한 파드가 계속 `CrashLoopBackOff` 상태에 빠지고 이전 파드도 사라짐:**
  * 애플리케이션 구동 실패(포트 충돌, 설정 오류 등)로 인해 새 파드가 뜨지 못하는 상태입니다. `kubectl describe pod`와 `kubectl logs`로 원인을 파악하세요.
  * 롤링 업데이트 중이라면 실패한 파드 때문에 배포가 일시 정지(Pause)되어 서비스 전체 중단은 막을 수 있습니다. 원인을 찾기 어렵다면 즉시 `rollout undo`로 롤백해야 합니다.