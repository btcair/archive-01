
# Pod

### 개념 요약
**Pod**는 쿠버네티스에서 생성하고 관리할 수 있는 가장 작은 배포 단위입니다. 하나 이상의 컨테이너를 포함하며, 이들은 저장소와 네트워크 자원을 공유하는 논리적인 단위입니다.

---

### 핵심 메커니즘
* **공유 자원:** Pod 내의 컨테이너들은 동일한 IP 주소와 포트 공간을 공유하며, `localhost`를 통해 서로 통신합니다.
* **원자성:** Pod 내의 모든 컨테이너는 항상 동일한 노드에 함께 스케줄링되며 실행됩니다.
* **비영구적 생명주기:** Pod는 일시적(Ephemeral)입니다. 스스로 치유되지 않으며, 장애 발생 시 컨트롤러에 의해 새 Pod로 대체됩니다.

[Image of Kubernetes Pod architecture showing multiple containers and shared volumes]

---

### 설정 예시 (YAML)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web
spec:
  containers:
  - name: nginx-container
    image: nginx:1.21
    ports:
    - containerPort: 80
```

### 참고 자료

- [Kubernetes Docs - Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)