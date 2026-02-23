# Service Quotas Request

## 1. 개요
AWS 계정에 적용된 **서비스 한도(Quota/Limit)를 확인하고, 인프라 확장 전에 미리 한도 상향을 요청(Request)**하여 프로비저닝 장애를 예방하는 관리 절차입니다.

## 2. 설명
* **Soft Limit vs Hard Limit:**
  * **Soft Limit:** 고객이 지원 센터나 콘솔을 통해 상향을 요청하면 올려주는 유연한 한도입니다. (예: 리전당 On-Demand EC2 vCPU 개수 기본 한도).
  * **Hard Limit:** 아키텍처나 물리적 한계로 인해 절대 올릴 수 없는 고정 한도입니다. (예: VPC 당 최대 서브넷 수).
* **CloudWatch 연동:**
  * Service Quotas 콘솔에서 특정 자원 사용량이 할당량의 80%에 도달하면 CloudWatch 경보(Alarm)를 발생시키도록 설정하여 선제적으로 대응할 수 있습니다.

## 3. 참조 및 관련된 파일
* [[ec2-finding-instance-types]] (G, P 등 특수 인스턴스 타입은 기본 쿼타가 0인 경우가 많음)
* [[vpc-nat-gateway]] (VPC 당 NAT Gateway 개수 제한)

## 4. 트러블 슈팅
* **새로운 EC2 또는 EKS 워커 노드 프로비저닝 실패 (`VcpuLimitExceeded`):**
  * 기존 인스턴스 개수 제한 방식에서 **vCPU 기반 한도** 방식으로 정책이 변경되었습니다. 예를 들어, 기본 vCPU 한도가 32일 때 `m5.4xlarge`(vCPU 16개)는 2대까지만 생성할 수 있습니다. Auto Scaling Group이 확장되지 않는다면 Quota를 가장 먼저 확인하세요.
* **상향 요청 처리 지연:**
  * 지원 센터에 상향 요청 티켓(Support Case)을 열어도, 특히 고가의 GPU 인스턴스(`p4`, `p5` 등)는 AWS 내부 재고 승인 과정을 거치느라 며칠이 소요될 수 있습니다. 프로젝트 일정에 맞춰 **최소 2주 전에 미리 상향 요청**을 해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Service Quotas란 무엇인가요?](https://docs.aws.amazon.com/servicequotas/latest/userguide/intro.html)


- [참고]
https://aws.amazon.com/ko/blogs/korea/introducing-service-quotas-view-and-manage-your-quotas-for-aws-services-from-one-central-location/