
# EKS Version Upgrade

## 1. 개요
EKS 클러스터를 In-Place 방식으로 업그레이드할 때 실제로 따라야 하는 **표준 작업 절차(SOP, Step-by-Step) 및 주의사항**입니다. EKS 업그레이드는 순서가 매우 중요합니다.

## 2. 설명
* **버전 도약 불가:** EKS는 한 번에 하나의 마이너 버전만 올릴 수 있습니다 (예: 1.28 $\rightarrow$ 1.30으로 건너뛰기 불가, 1.28 $\rightarrow$ 1.29 $\rightarrow$ 1.30 순서로 진행해야 함).
* **표준 업그레이드 3단계:**
  1. **Control Plane 업그레이드:** AWS 콘솔이나 CLI에서 클러스터 버전을 업데이트합니다. (약 10~20분 소요, 이 동안 API 서버 호출은 불안정할 수 있으나 파드 구동에는 영향 없음).
  2. **Add-ons 업그레이드:** K8s 버전에 맞는 핵심 애드온(`VPC CNI`, `CoreDNS`, `kube-proxy`)을 호환 버전으로 업데이트합니다.
  3. **Data Plane(워커 노드) 업그레이드:** 관리형 노드 그룹(MNG)의 AMI 릴리스 버전을 업데이트하여, 구형 노드를 죽이고 신형 노드로 교체(Rolling Update)합니다.

## 3. 참조 및 관련된 파일
* [[eks-version-upgrade-scenario]] (사전 계획 수립)
* [[eks-karpenter-upgrade]] (노드 오토스케일러 버전 호환성)
* [[eks-node-termination]] (노드 롤링 시 Cordon/Drain 과정)

## 4. 트러블 슈팅
* **VPC CNI 충돌 및 네트워크 장애:**
  * 커스텀 설정(예: `WARM_IP_TARGET`)이 적용된 VPC CNI를 덮어쓰기 방식으로 업그레이드하면 기존 설정이 날아가 파드가 IP를 할당받지 못할 수 있습니다. 설정 보존 옵션(Preserve)을 잘 확인해야 합니다.
* **워커 노드 업그레이드 멈춤 (Subnet IP 고갈):**
  * MNG 롤링 업데이트는 **새로운 버전을 가진 노드를 먼저 하나 띄우고, 기존 노드를 하나 죽이는 방식(Surge)**으로 진행됩니다. 만약 서브넷에 남은 가용 IP가 없거나 EC2 Quota(제한)에 도달했다면 새 노드가 뜨지 못해 업그레이드가 무한 대기 상태에 빠집니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EKS 클러스터 업데이트](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
## 5. 참고자료 또는 링크
* [AWS 블로그 - EKS 블루/그린 배포 파이프라인 구축](https://aws.amazon.com/ko/blogs/containers/blue-green-or-canary-amazon-eks-clusters-migration-for-stateless-argocd-workloads/)




- [참고] 기본 클러스터를 새 버전으로 업그레이드 참고 문서
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/update-cluster.html

- [참고] Best Practice for cluster upgrades
https://docs.aws.amazon.com/eks/latest/best-practices/cluster-upgrades.html

- [참고] EKS 버전 수명주기 참고 문서
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/kubernetes-versions.html

- [참고]  Amazon Linux 2 FAQs 참고
https://aws.amazon.com/ko/amazon-linux-2/faqs/

- [참고] al2와 al2023의 비교
https://docs.aws.amazon.com/ko_kr/linux/al2023/ug/compare-with-al2.html

- [참고] EKS 업그레이드 사례(marcincuber님)
https://github.com/marcincuber/eks