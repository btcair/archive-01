# Objects: K8s PDB (Pod Disruption Budget)

## 1. 개요 및 비유
**PDB(Pod Disruption Budget, 파드 중단 예산)**는 워커 노드의 유지보수(업그레이드, 스케일인 등)와 같은 자발적 중단(Voluntary Disruption) 상황이 발생할 때, 동시에 다운될 수 있는 파드의 최대 개수나 유지해야 하는 최소 개수를 보장하는 안전장치입니다.

💡 **비유하자면 '응급실의 최소 당직 의사 유지 규칙'과 같습니다.**
병원 전체에서 에어컨 수리(노드 유지보수)를 하더라도, 응급실에는 무조건 **"최소 2명의 의사(minAvailable: 2)"**가 자리를 지켜야 한다는 규칙(PDB)을 세워두는 겁니다. 만약 수리 기사가 2번째 의사마저 잠시 자리를 비우라고 요구(Drain)하면, PDB 규칙이 이를 튕겨내고 의사가 3명이 될 때까지 수리 작업을 강제로 대기시킵니다.

## 2. 핵심 설명
* **보호 대상 제한:** 노드 커널 패닉, 정전, 네트워크 단절 같은 '비자발적 장애(Involuntary Disruptions)'는 PDB로 막을 수 없습니다. 오직 관리자나 시스템(Karpenter, CA 등)이 API를 통해 시도하는 `Eviction(추방)` 요청만 제어합니다.
* **설정 방식 두 가지:**
  * `minAvailable`: 항상 가동되어야 하는 최소 파드 개수 또는 비율(%). (예: 최소 2개는 무조건 살아있어야 함)
  * `maxUnavailable`: 동시에 중단되어도 괜찮은 최대 파드 개수 또는 비율(%). (예: 한 번에 1개까지만 죽이는 걸 허락함)
* **무중단 운영의 핵심:** EKS 클러스터나 노드 그룹을 버전 업그레이드할 때 서비스 다운타임을 막기 위해 Deployment 배포 시 반드시 함께 세팅해야 하는 베스트 프랙티스입니다.

## 3. YAML 적용 예시 (최소 가용성 보장)
웹 서버 파드가 아무리 노드 롤링 업데이트가 일어나더라도 최소 2개는 무조건 서빙 상태를 유지하도록 강제하는 PDB 설정입니다.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-app-pdb
  namespace: default
spec:
  minAvailable: 2 # 항상 최소 2개의 파드는 Ready 상태를 유지해야 함
  selector:
    matchLabels:
      app: web-app # 보호할 파드의 라벨
```

## 4. 트러블 슈팅
* **노드를 비우려고(Drain) 하는데 노드가 무한 대기 상태에 빠짐:**
  * 잦은 주니어 실수 중 하나입니다. Deployment의 전체 Replicas가 2개인데, PDB에 `minAvailable: 2`라고 설정해버리면 쿠버네티스는 파드를 단 하나도 죽일 수 없습니다(죽이면 1개가 되어 규칙 위반이니까요).
  * 이런 상황에서 노드를 Drain 하면 PDB 규칙에 막혀 영원히 `Evicting` 상태에서 멈춥니다. 전체 파드 수보다 `minAvailable`을 작게 설정하거나 `maxUnavailable`을 사용해 여유 공간(Budget)을 만들어 주어야 합니다.