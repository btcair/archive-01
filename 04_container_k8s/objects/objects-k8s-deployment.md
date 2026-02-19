
# Deployment (디플로이먼트)

### 개념 요약
**Deployment**는 Pod와 ReplicaSet에 대한 선언적 업데이트를 제공합니다. 사용자가 원하는 상태(Desired State)를 정의하면, 배포 컨트롤러가 실제 상태를 원하는 상태로 변경합니다.

---

### 핵심 메커니즘
* **상태 관리:** 지정된 수의 Pod 복제본(Replicas)이 항상 실행되도록 보장합니다.
* **배포 전략:** * **RollingUpdate:** 서비스 중단 없이 순차적으로 Pod를 교체합니다.
    * **Recreate:** 기존 Pod를 모두 삭제 후 새로운 Pod를 생성합니다.
* **롤백(Rollback):** 업데이트 중 문제가 발생할 경우 이전 버전(Revision)으로 즉시 되돌릴 수 있습니다.



---

### 설정 예시 (YAML)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app-container
        image: my-app:v1.0.0
        ports:
        - containerPort: 8080
````

---

### 참고 자료

- [Kubernetes Docs - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)