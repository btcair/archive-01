# EKS Launch Template

## 1. 개요
**시작 템플릿(Launch Template)**은 EKS 워커 노드(EC2)가 오토스케일링 그룹(ASG)이나 관리형 노드 그룹(Managed Node Group)을 통해 생성될 때 참조하는 설정 파일입니다. AMI ID, 인스턴스 타입, 보안 그룹, 사용자 데이터(User Data) 등을 정의합니다.

## 2. 설명
* **EKS 관리형 노드 그룹(MNG)과의 연동:**
  * MNG 생성 시 시작 템플릿을 지정할 수 있습니다. 
  * 단, MNG가 자체적으로 제어하는 일부 항목(예: 인스턴스 타입, 서브넷 등)은 템플릿에 지정하면 충돌이 발생하므로 비워두어야 합니다.
* **사용자 데이터 (User Data):**
  * 노드가 부팅될 때 쿠버네티스 클러스터에 조인(Join)하기 위해 실행되는 부트스트랩 스크립트가 들어갑니다. (예: `/etc/eks/bootstrap.sh 클러스터이름`)
  * 사내 보안 에이전트 설치, OS 커널 파라미터(sysctl) 튜닝 등을 이곳에 작성합니다.
* **버전 관리:** 시작 템플릿은 버전을 가집니다. 설정을 변경하면 새 버전을 생성한 뒤, 노드 그룹이 참조하는 버전을 최신으로 업데이트하여 롤링 교체를 유도합니다.

## 3. 참조 및 관련된 파일
* [[ec2-ami]]
* [[eks-nodeadm]] (AL2023의 새로운 User Data 포맷)
* [[eks-self-managed-and-node-group]]

## 4. 트러블 슈팅
* **새로운 노드가 클러스터에 `NotReady`로 뜨거나 아예 조인하지 못함:**
  * **보안 그룹 누락:** 워커 노드가 EKS 컨트롤 플레인(API 서버) 및 다른 노드들과 통신하기 위한 보안 그룹(클러스터 보안 그룹 등)이 시작 템플릿에 명시되지 않았을 확률이 높습니다.
  * **User Data 오타:** 부트스트랩 스크립트의 Base64 인코딩이나 MIME 형식 래핑(Wrapping)이 잘못되어 스크립트가 실행되지 않은 경우입니다. EC2에 직접 접속하여 `/var/log/cloud-init-output.log`를 확인하세요.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EKS 시작 템플릿 사용](https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html)


- [참고]시작 템플릿을 사용한 관리형 노드 사용자 지정
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/launch-templates.html