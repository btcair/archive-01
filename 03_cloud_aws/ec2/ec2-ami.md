# EC2 AMI (Amazon Machine Image)

## 1. 개요
**AMI(Amazon Machine Image)**는 EC2 인스턴스를 시작하는 데 필요한 운영 체제, 애플리케이션 서버, 애플리케이션 등 소프트웨어 구성을 담고 있는 마스터 템플릿입니다.

## 2. 설명
* **구성 요소:** 1개 이상의 EBS 스냅샷(또는 인스턴스 스토어 볼륨), 시작 권한(Launch Permission), 블록 디바이스 매핑(Block Device Mapping)으로 구성됩니다.
* **유형:**
  * **AWS 관리형 AMI:** Amazon Linux, Ubuntu, Windows 등 기본 제공 이미지.
  * **사용자 지정 AMI:** 사용자가 직접 서버를 세팅한 후 구워낸(Bake) 프라이빗 이미지. (골든 이미지라고도 부름)
  * **AWS Marketplace AMI:** 서드파티 소프트웨어(방화벽, DB 등)가 사전 설치된 유료/무료 이미지.
* **수명 주기:** AMI 생성 $\rightarrow$ 등록(Register) $\rightarrow$ 사용 $\rightarrow$ 등록 취소(Deregister). 리전(Region)에 종속적이므로 다른 리전에서 사용하려면 AMI를 복사(Copy)해야 합니다.

[Image of AWS AMI lifecycle from creation to registration and instance launch]

## 3. 참조 및 관련된 파일
* [[ec2-al2-al2023]] (OS 버전 변경 관리)
* [[ec2-ebs-backup]] (AMI를 구성하는 스냅샷)
* [[eks-nodeadm]] (EKS 커스텀 AMI 구성)

## 4. 트러블 슈팅
* **AMI 삭제 후에도 과금이 계속되는 현상:**
  * AMI를 단순히 '등록 취소(Deregister)' 한다고 해서 **연결된 EBS 스냅샷이 자동으로 삭제되지 않습니다.** 반드시 스냅샷 메뉴로 이동하여 연관된 스냅샷을 수동으로 지워야 스토리지 비용 발생을 막을 수 있습니다.
* **다른 리전으로 복사 후 자동화 스크립트 실패:**
  * AMI를 다른 리전으로 복사하면 내용물은 같더라도 **AMI ID(`ami-xxxxxx`)가 완전히 새롭게 발급**됩니다. IaC(Terraform)나 스크립트에서 하드코딩된 AMI ID를 사용 중이라면 리전별 변수로 분리해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon Machine Image(AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)