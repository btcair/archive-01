# EC2 OS Migration

## 1. 개요
기존에 운영 중인 EC2 인스턴스의 **운영 체제(OS)를 다른 버전(예: CentOS 7 $\rightarrow$ Amazon Linux 2023, Windows 2012 $\rightarrow$ 2022)으로 업그레이드하거나 마이그레이션**하는 전략과 절차입니다.

## 2. 설명
* **In-place 마이그레이션 (권장하지 않음):**
  * 기존 인스턴스 내부에서 OS 업그레이드 명령을 실행하는 방식.
  * 롤백이 어렵고, 패키지 의존성 충돌로 시스템이 부팅되지 않을 위험이 큽니다.
* **Side-by-side 마이그레이션 (Blue/Green 방식 - AWS 권장):**
  1. 새로운 타겟 OS(예: AL2023)로 **새 EC2 인스턴스를 생성**합니다.
  2. 기존 인스턴스의 데이터가 있는 EBS 볼륨을 떼어 새 인스턴스에 붙이거나(Attach), 애플리케이션 및 데이터를 복사합니다.
  3. 로드 밸런서(ELB)나 Route 53을 통해 트래픽을 새 인스턴스로 전환합니다.
  4. 문제가 발생하면 즉시 구형 인스턴스로 트래픽을 원복(Rollback)할 수 있습니다.

## 3. 참조 및 관련된 파일
* [[ec2-al2-al2023]] (Amazon Linux 간의 차이점)
* [[ec2-ebs-backup]] (마이그레이션 전 필수 백업)
* [[ec2-physical-host-change]]

## 4. 트러블 슈팅
* **데이터 볼륨(EBS) 마운트 실패:**
  * 구형 OS에서 사용하던 볼륨을 신형 OS에 붙였을 때, 파일 시스템 마운트 설정(`/etc/fstab`)이나 디바이스 이름(예: `/dev/xvdf` $\rightarrow$ `/dev/nvme1n1`) 체계가 달라 부팅이 멈출 수 있습니다. NVMe 드라이버 호환성을 확인해야 합니다.
* **Windows Server 라이선스/활성화 문제:**
  * 사용자 지정 이미지를 통해 OS를 업그레이드한 경우, AWS의 KMS(Key Management Service) 정품 인증 서버와 통신하지 못해 Windows 인증이 풀릴 수 있습니다. VPC 내 라우팅이나 SSM 에이전트 상태를 점검하세요.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - EC2 인스턴스 운영 체제 업그레이드 모범 사례](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/os-upgrade.html)