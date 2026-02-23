# EKS Karpenter Upgrade

## 1. 개요
**Karpenter**는 AWS에서 개발한 쿠버네티스용 고성능 오픈소스 노드 오토스케일러입니다. 기존 Cluster Autoscaler(CA)를 대체하며, 파드의 요구사항에 맞춰 최적의 EC2 인스턴스를 JIT(Just-In-Time) 방식으로 밀리초 단위로 프로비저닝합니다. 본 문서는 Karpenter의 메이저/마이너 버전 업그레이드 시 고려사항을 다룹니다.

## 2. 설명
* **주요 변경 사항 (v1beta1 $\rightarrow$ v1):** * API 리소스 이름이 변경되었습니다. 기존 `Provisioner`와 `AWSNodeTemplate`이 각각 **`NodePool`**과 **`EC2NodeClass`**로 완전히 대체되었습니다. 업그레이드 시 매니페스트(YAML) 마이그레이션이 필수적입니다.
* **업그레이드 절차:**
  1. 기존 버전에 배포된 파드의 리소스 요구량 백업 (NodePool 맵핑 확인).
  2. 신규 버전의 CRD(Custom Resource Definition) 업데이트.
  3. Helm 차트를 사용하여 Karpenter 컨트롤러 버전 업그레이드.
  4. 새로운 `NodePool` 및 `EC2NodeClass` 배포 후 기존 리소스 삭제.
* **통합(Consolidation):** 워크로드가 줄어들면 빈 노드를 삭제할 뿐만 아니라, 흩어진 파드들을 재배치하여 더 작고 저렴한 노드로 교체하는 최적화 기능을 제공합니다.



## 3. 참조 및 관련된 파일
* [[eks-node-termination]] (Karpenter는 자체적으로 노드 종료 및 Interruption 처리를 지원함)
* [[eks-launch-template]]
* [[ec2-finding-instance-types]]

## 4. 트러블 슈팅
* **업그레이드 후 파드가 `Pending` 상태에 머무는 경우:**
  * 가장 흔한 원인은 새로운 CRD(`NodePool`)가 파드의 `nodeSelector`나 `toleration` 조건과 맞지 않아 프로비저닝을 포기한 경우입니다. Karpenter 컨트롤러 로그에서 `nominate` 실패 사유를 확인하세요.
* **IAM 권한(IRSA) 에러:**
  * 메이저 버전이 올라가면서 Karpenter가 EC2, Fleet, 혹은 가격 조회(Pricing API)를 위해 요구하는 IAM 권한이 추가되었을 수 있습니다. 릴리스 노트를 확인하여 컨트롤러의 IAM Role 정책을 업데이트해야 합니다.

## 5. 참고자료 또는 링크
* [Karpenter 공식 문서 - Upgrade Guide](https://karpenter.sh/docs/upgrading/)


- [참고] karpenter drift를 이용한 업그레이드 참고자료
https://aws.amazon.com/ko/blogs/tech/how-to-upgrade-amazon-eks-worker-nodes-with-karpenter-drift/