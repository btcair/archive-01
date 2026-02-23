# EKS Nodeadm (AL2023)

## 1. 개요
**`nodeadm`**은 Amazon Linux 2023(AL2023) 기반의 EKS 최적화 AMI에서 컨테이너 런타임 및 Kubelet 환경을 설정하고 워커 노드를 클러스터에 부트스트랩하기 위해 새롭게 도입된 유틸리티입니다. 기존의 `/etc/eks/bootstrap.sh` 쉘 스크립트를 완전히 대체합니다.

## 2. 설명
* **선언적 구성 (Declarative Configuration):**
  * 기존 Bash 스크립트에 파라미터를 넘기던 방식에서, **YAML 형식의 `NodeConfig` 객체**를 사용자 데이터(User Data)로 전달하는 방식으로 변경되었습니다.
* **MIME 멀티파트 포맷:**
  * `nodeadm` YAML 설정과 기존의 쉘 스크립트(추가 패키지 설치용 등)를 동시에 실행하려면, 반드시 Cloud-Init의 MIME 멀티파트(Multipart) 문서 형식으로 경계를 나누어 작성해야 합니다.
* **Containerd 통합:**
  * Docker를 걷어내고 Containerd를 기본 런타임으로 사용함에 따라, Kubelet과 Containerd의 고급 설정 파라미터 조정이 `NodeConfig` 내에 통합되었습니다.

## 3. 참조 및 관련된 파일
* [[ec2-al2-al2023]] (OS 아키텍처 변경)
* [[eks-launch-template]] (User Data에 NodeConfig 적용)

## 4. 트러블 슈팅
* **AL2023 노드가 클러스터에 조인되지 않는 경우:**
  * User Data에 입력한 YAML의 들여쓰기(Indentation)가 잘못되었거나, `apiVersion: node.eks.aws/v1alpha1` 과 같은 필수 스펙 라인이 누락되었는지 확인하세요.
* **기존 커스텀 스크립트가 실행되지 않음:**
  * 쉘 스크립트와 `NodeConfig`를 섞어 쓸 때 MIME 헤더 파트가 잘못 래핑되면 쉘 스크립트 블록이 무시됩니다.
  * AL2023은 기본 패키지 매니저가 `yum`에서 `dnf`로 변경되었으므로, 사용자 데이터에 포함된 레거시 OS 명령어 패키지가 존재하는지 검토해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon Linux 2023 EKS AMI 부트스트랩 (nodeadm)](https://docs.aws.amazon.com/eks/latest/userguide/al2023.html)


- [참고] nodeadm 문서 참고
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/hybrid-nodes-nodeadm.html
- [참고] amazon linux 2023은 nodeadm으로의 변경 참고
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/al2023.html