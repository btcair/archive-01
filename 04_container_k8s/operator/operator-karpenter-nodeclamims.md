# Operator: Karpenter NodeClaims

## 1. 개요 및 비유
**NodeClaim(노드클레임)**은 쿠버네티스의 파드가 스케줄링되기 위해 인프라(노드)를 요구할 때, Karpenter가 생성하는 **'인스턴스 발주서(티켓)'**입니다. 

💡 **비유하자면 '식당의 주문 전표(NodeClaim)'와 같습니다.**
손님(Pod)이 들어와서 자리가 부족하면, 매니저(Karpenter)가 주방에 "4인용 테이블(인스턴스) 하나 놔주세요"라고 주문 전표를 찍어냅니다. 이 전표는 실제 물리적인 테이블(EC2)이 세팅될 때까지의 진행 상태를 추적하고, 테이블이 치워질 때 전표도 함께 폐기됩니다.

## 2. 핵심 설명
* **라이프사이클 매핑:** NodeClaim은 쿠버네티스의 `Node` 객체와 클라우드 공급자(AWS EC2)의 실제 가상 머신 사이의 생명주기를 이어주는 다리 역할을 합니다.
* **상태 전이 (State Transition):** `Pending`(발주 대기) $\rightarrow$ `Launched`(EC2 프로비저닝 됨) $\rightarrow$ `Ready`(Kubelet 조인 완료) $\rightarrow$ `Empty`(파드가 없어 비워짐) 순으로 상태가 변합니다.
* **디버깅의 핵심 리소스:** Karpenter가 노드를 왜 안 띄우는지, 혹은 어떤 인스턴스 타입(`m5.large`, `c6g.xlarge` 등)을 선택했는지는 이 `NodeClaim` 리소스의 상태(Status)를 조회해야 가장 정확히 알 수 있습니다.

## 3. YAML 적용 예시 (NodeClaim 조회 및 이해)
NodeClaim은 관리자가 직접 작성(Apply)하는 리소스가 아니라 Karpenter가 **자동으로 생성**하는 리소스입니다. 아래는 생성된 NodeClaim의 구조를 확인(describe)하는 예시입니다.

```yaml
# kubectl get nodeclaim -o yaml
apiVersion: karpenter.sh/v1
kind: NodeClaim
metadata:
  name: default-x8f9a
spec:
  nodeClassRef:
    name: default          # 참조한 EC2NodeClass
  requirements:
    - key: node.kubernetes.io/instance-type
      operator: In
      values: [t3.medium, t3.large] # 선택 가능한 인스턴스 타입들
status:
  providerID: aws:///ap-northeast-2a/i-0abcd1234567890ef # 실제 생성된 EC2의 ID
  capacity:
    cpu: "2"
    memory: "4Gi"
  conditions:
    - type: Ready
      status: "True"       # 노드가 클러스터에 정상 조인됨
```

## 4. 트러블 슈팅
* **NodeClaim 상태가 `Pending`에 영원히 머무름 (ICE 에러):**
  * Karpenter가 AWS에 특정 인스턴스 타입(`p4d.24xlarge` 등)을 요청했으나, 해당 가용 영역(AZ)에 **물리적인 서버 재고가 부족(Insufficient Capacity Exception, ICE)**한 상황입니다. `NodePool`에서 허용하는 인스턴스 타입(Requirements)을 더 넓게 열어주어 대체 인스턴스를 찾게 해야 합니다.
* **파드는 지워졌는데 EC2(NodeClaim)가 안 지워짐:**
  * 노드에 기본 데몬셋(DaemonSet)이 아닌 파드(예: `coredns`의 마지막 레플리카, PDB에 의해 보호받는 파드, `karpenter.sh/do-not-disrupt: "true"` 어노테이션이 붙은 파드)가 남아있으면 노드를 강제로 죽일 수 없습니다.