# Objects: K8s Persistent Volume (PV & PVC)

## 1. 개요 및 비유
**Persistent Volume(PV, 영구 볼륨)**과 **Persistent Volume Claim(PVC, 영구 볼륨 클레임)**은 파드가 종료되더라도 데이터를 영구적으로 보존하기 위해 스토리지 자원을 관리하는 오브젝트입니다.

💡 **비유하자면 '주차장 자리(PV)'와 '주차권(PVC)'과 같습니다.**
관리자는 미리 서버용 하드디스크나 클라우드 스토리지로 100GB짜리 주차장 공간(PV)을 만들어 둡니다. 주니어 개발자가 파드를 띄울 때 "나 10GB짜리 주차 공간이 필요해"라고 주차권(PVC)을 제출하면, 쿠버네티스가 조건에 맞는 빈 주차장(PV)을 찾아 둘을 찰칵 묶어줍니다(Binding). 파드는 이 주차권만 들고 있으면 언제든 자기 데이터에 접근할 수 있습니다.

[Image of Kubernetes Persistent Volume and Persistent Volume Claim binding architecture]

## 2. 핵심 설명
* **라이프사이클 분리:** 스토리지를 제공하는 인프라 관리자(PV 생성)와 스토리지를 소비하는 개발자(PVC 요청)의 역할을 분리하여 유연성을 높입니다.
* **접근 모드 (Access Modes):** * `ReadWriteOnce (RWO)`: 단일 노드에서 읽기/쓰기 가능 (예: AWS EBS).
  * `ReadWriteMany (RWX)`: 여러 노드에서 동시에 읽기/쓰기 가능 (예: AWS EFS, NFS).
* **반환 정책 (Reclaim Policy):** PVC가 삭제되었을 때 실제 데이터(PV)를 어떻게 할지 결정합니다. `Retain`(보존 - 운영 환경 권장), `Delete`(자동 삭제), `Recycle`(재사용 - 현재는 사용 안 함)가 있습니다.

## 3. YAML 적용 예시 (PVC 생성 및 파드 마운트)
개발자가 5GB 용량의 스토리지를 요청(PVC)하고, 이를 Nginx 파드의 웹 루트 디렉터리에 연결하는 예시입니다.

```yaml
# 1. 스토리지 요청 (PVC)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi

---
# 2. 파드에 PVC 마운트
apiVersion: v1
kind: Pod
metadata:
  name: nginx-storage-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: web-storage
      mountPath: /usr/share/nginx/html # 이 경로에 데이터가 영구 저장됨
  volumes:
  - name: web-storage
    persistentVolumeClaim:
      claimName: web-data-pvc # 위에서 만든 PVC 이름 지정
```

## 4. 트러블 슈팅
* **PVC가 계속 `Pending` 상태에서 넘어가지 않음:**
  * 클러스터 내에 요청한 용량(5Gi)과 접근 모드(RWO)를 만족하는 `Available` 상태의 PV가 없거나, 동적 프로비저닝을 담당하는 `StorageClass`가 지정되지 않았기 때문입니다.
  * `kubectl describe pvc web-data-pvc` 명령어로 Events 항목을 확인하여 스토리지가 부족한지, CSI 드라이버 오류인지 원인을 파악해야 합니다.