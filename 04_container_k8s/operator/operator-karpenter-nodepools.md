# Operator: Karpenter NodePools

## 1. 개요 및 비유
**NodePool(노드풀)**은 클러스터에 어떤 종류의 노드(크기, 구매 옵션, 아키텍처 등)를 허용할 것인지, 그리고 유휴 노드를 어떻게 정리(Consolidation)할 것인지 정의하는 **'인사 채용 규정 및 예산 관리 정책'**입니다. (v1beta1의 `Provisioner`가 이름이 변경된 것입니다.)

💡 **비유하자면 'HR 부서의 알바생 채용 가이드라인'과 같습니다.**
"우리 가게는 주문(Pod)이 밀리면 알바생을 즉시 뽑되(Provisioning), 비용 절감을 위해 주로 프리랜서(Spot 인스턴스) 위주로 뽑아. 단, 시급 예산(Limit)은 100만 원을 넘기면 안 돼. 그리고 손님이 줄어서 알바생 2명이 노가리 까고 있으면 1명은 집에 보내(Consolidation)."

[Image of Karpenter NodePool configuration showing instance requirements and consolidation behavior]

## 2. 핵심 설명
* **요구사항 (Requirements):** 이 NodePool이 프로비저닝할 수 있는 인스턴스 패밀리(`c5`, `m5`), 세대, 크기(`large`, `xlarge`), 구매 옵션(`Spot`, `On-Demand`), CPU 아키텍처(`amd64`, `arm64`) 등을 `In`, `NotIn` 연산자로 유연하게 정의합니다.
* **자원 한도 (Limits):** 무한정 스케일 아웃되어 클라우드 요금 폭탄을 맞는 것을 막기 위해, 이 NodePool이 생성할 수 있는 CPU 코어 수나 메모리의 총합 한도를 설정합니다.
* **Disruption (중단 및 최적화):**
  * `Consolidation`: 덜 채워진 노드들을 빈 노드로 합치거나, 더 저렴하고 알맞은 크기의 노드로 교체하여 비용을 최적화하는 강력한 기능입니다.

## 3. YAML 적용 예시 (비용 최적화 NodePool)
스팟(Spot) 인스턴스 위주로 구성하며, 자원 낭비 시 적극적으로 통합(Consolidation)을 수행하는 NodePool 설정입니다.

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot-pool
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default # EC2NodeClass 명세 연결
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"] # 스팟 인스턴스만 사용
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["m5", "m6i", "c5", "c6i"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
  limits:
    cpu: 1000 # 클러스터 전체 CPU 1000코어 제한
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized # 낭비되는 노드 적극적 통합
    consolidateAfter: 1m # 파드가 비워지고 1분 후 노드 삭제
```

## 4. 트러블 슈팅
* **스케줄링 대기 파드(Pending)가 있는데 새 노드가 안 생김:**
  * 파드의 `nodeSelector`나 `tolerations`가 NodePool의 `requirements`와 맞지 않는 경우입니다. 예를 들어 파드는 `arm64` 아키텍처를 원하는데, NodePool은 `amd64`만 허용하고 있다면 교집합이 없어 프로비저닝을 포기(Nominate 실패)합니다.
* **Consolidation(통합)이 끊임없이 일어나 파드가 계속 재시작(Thrashing) 됨:**
  * 애플리케이션의 시작 시간(Ready가 되기까지의 시간)이 오래 걸리거나 트래픽 변동이 너무 심할 때 발생할 수 있습니다. `disruption` 정책을 너무 타이트하게 잡지 말고, 핵심 워크로드 파드에는 `karpenter.sh/do-not-disrupt: "true"` 어노테이션을 달아 쫓겨나지 않게 보호해야 합니다.