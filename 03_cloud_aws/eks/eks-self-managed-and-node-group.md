# EKS Managed Node Group vs Self-Managed

## 1. 개요
EKS 클러스터의 데이터 플레인(워커 노드)을 구성하는 두 가지 주요 방식인 **관리형 노드 그룹(Managed Node Group, MNG)**과 **자체 관리형 노드(Self-Managed Node)**의 차이점 및 선택 기준입니다.

## 2. 설명
* **관리형 노드 그룹 (MNG - 권장):**
  * AWS가 Auto Scaling Group(ASG)의 생명주기, 패치, 버전 업그레이드를 자동화하여 관리해 줍니다.
  * 한 번의 클릭이나 API 호출로 노드의 **롤링 업데이트(Cordon & Drain 자동 수행)**가 가능하여 운영 부담이 크게 줄어듭니다.
* **자체 관리형 노드 (Self-Managed Node):**
  * 사용자가 직접 EC2 인스턴스와 ASG를 생성하고, EKS 클러스터에 조인(Join)시키는 스크립트(User Data)를 완전히 제어하는 방식입니다.
  * AWS에서 기본 제공하지 않는 특수한 커스텀 OS나 하드웨어 아키텍처(Windows 노드 고도화, 특수 커널 패치 등)가 반드시 필요할 때만 사용합니다.

## 3. 참조 및 관련된 파일
* [[eks-launch-template]] (MNG에 커스텀 설정을 입힐 때 사용)
* [[eks-fargate]] (노드 관리 자체를 없애는 서버리스 대안)
* [[eks-nodeadm]]

## 4. 트러블 슈팅
* **자체 관리형 노드가 클러스터에 표시되지 않음 (Not Joined):**
  * 자체 관리형 노드는 EC2가 생성되었다고 끝나는 것이 아니라, 클러스터의 **`aws-auth` ConfigMap**에 해당 EC2의 IAM 역할(Role)을 수동으로 등록(Mapping)해 주어야만 Kubelet이 API 서버와 통신할 수 있습니다.
* **MNG 업그레이드 실패 (Failed 상태):**
  * PDB(Pod Disruption Budget) 설정이 너무 타이트하거나, 파드가 Drain 상태에서 영원히 멈춰 있으면(예: 종료되지 않는 프로세스) MNG 업그레이드 로직이 타임아웃되어 실패 상태로 남습니다. 문제가 되는 파드를 수동으로 강제 삭제해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EKS 관리형 노드 그룹](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)