
# Objects: K8s StatefulSet

## 1. 개요 및 비유
**StatefulSet(스테이트풀셋)**은 파드의 순서와 고유한 식별자(이름, 네트워크, 스토리지)를 영구적으로 보장해야 하는 상태 유지형(Stateful) 애플리케이션을 위한 컨트롤러입니다.

💡 **비유하자면 '지정석이 있는 VIP 극장(StatefulSet)'과 같습니다.**
일반 영화관(Deployment)은 자율 좌석제라 관객(파드)이 아무 데나 앉고 이름표도 무작위(`nginx-7b4d...`)입니다. 하지만 VIP 극장(StatefulSet)은 관객마다 고정된 이름표(`db-0`, `db-1`)와 전용 지정석(영구 볼륨)이 주어집니다. `db-0` 관객이 잠시 화장실을 다녀와도(파드 재시작) 원래 앉았던 그 자리와 팝콘(데이터)이 그대로 보존됩니다.



## 2. 핵심 설명
* **고정된 네트워크 ID:** 파드 이름 뒤에 무작위 해시가 붙는 대신, `0, 1, 2...` 순서대로 숫자가 붙습니다. 이 이름 자체를 도메인으로 사용할 수 있어 파드 간 통신(예: DB Primary-Replica 동기화)이 매우 직관적입니다.
* **순차적 생성 및 종료:** 생성할 때는 `0`번부터 하나씩 순서대로 켜지며(전 단계가 Ready가 되어야 다음이 켜짐), 삭제할 때는 가장 큰 번호부터 역순으로 꺼집니다.
* **VolumeClaimTemplates:** 파드가 생성될 때마다 각 파드 전용의 PVC(영구 볼륨 클레임)를 자동으로 찍어내어 1:1로 매핑해 줍니다. 파드가 죽었다 살아나도 항상 자기 볼륨에 다시 붙습니다.

## 3. YAML 적용 예시 (순서를 보장하는 DB 클러스터)
각 파드마다 별도의 10GB 스토리지를 가지며 `mysql-0`, `mysql-1` 로 생성되는 설정입니다. (Headless Service와 세트로 다닙니다.)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql-hsvc" # StatefulSet은 Headless Service 이름이 필수
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        volumeMounts:
        - name: data # 아래 템플릿에서 만든 볼륨 마운트
          mountPath: /var/lib/mysql
  volumeClaimTemplates: # 각 파드마다 개별 PVC 자동 생성
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

## 4. 트러블 슈팅
* **StatefulSet을 지워도 PVC(데이터)가 지워지지 않음:**
  * 이것은 에러가 아니라 **데이터 보호를 위한 의도된 동작**입니다! 쿠버네티스는 실수로 컨트롤러를 날리더라도 DB 데이터가 날아가는 것을 막기 위해 PVC를 자동으로 삭제하지 않습니다. 완전히 지우려면 PVC를 수동으로 하나씩 삭제해야 합니다.
* **파드가 `Terminating` 상태에서 영원히 멈춤:**
  * 파드가 띄워진 워커 노드가 갑자기 물리적으로 죽어버리면, StatefulSet은 "동일한 ID를 가진 파드는 클러스터에 절대 2개가 뜰 수 없다"는 원칙(At-most-one) 때문에 기존 파드가 완벽히 죽은 것을 확인하지 못하면 새 노드에 파드를 띄우지 못합니다. 이 땐 관리자가 강제 삭제(`--force --grace-period=0`)를 해줘야 합니다.