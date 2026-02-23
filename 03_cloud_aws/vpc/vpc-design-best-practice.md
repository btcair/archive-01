# VPC Design Best Practice

## 1. 개요
안정성, 보안, 확장성을 갖춘 클라우드 네트워크 아키텍처를 구축하기 위한 **AWS VPC (Virtual Private Cloud) 및 서브넷(Subnet) 설계 모범 사례**입니다.

## 2. 설명
* **CIDR 블록 설계:**
  * 온프레미스 망 및 타 VPC와의 향후 통신(Peering, Transit Gateway)을 고려하여 **절대 겹치지 않는 사설 IP 대역(RFC 1918)**을 할당해야 합니다. (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` 활용)
* **다중 가용 영역 (Multi-AZ):**
  * 물리적 데이터센터 장애(화재, 단전 등)에 대비하여 최소 2~3개의 AZ(예: `ap-northeast-2a`, `2c`)에 서브넷을 대칭적으로 분산 배치합니다.
* **서브넷 계층 분리 (Tiering):**
  * **Public Subnet:** 인터넷과 직접 통신이 필요한 자원 (ALB, NAT Gateway, Bastion Host).
  * **Private Subnet:** 외부에서 직접 접근할 수 없는 내부 자원 (EC2 App 서버, EKS 노드).
  * **Data/DB Subnet:** 인터넷 통신이 아예 차단된 최하단 보안 계층 (RDS, ElastiCache).
  * **TGW Subnet:** Transit Gateway 연결 전용의 작은 서브넷(예: `/28`).



## 3. 참조 및 관련된 파일
* [[vpc-transit-gateway]]
* [[vpc-nacl]]
* [[route53-vpc-resolver]]

## 4. 트러블 슈팅
* **IP 주소 고갈 현상:**
  * EKS 파드(Pod)나 Lambda 함수가 VPC 내부에 생성될 때 대량의 IP를 소모합니다. 서브넷을 너무 작게(`/24` 등) 할당하면 노드나 파드 확장이 불가능해집니다. 워크로드 예측에 따라 충분히 큰 대역(`/20`, `/18`)을 확보해야 합니다. (단, AWS는 각 서브넷의 첫 4개와 마지막 1개 IP를 예약하므로 사용 불가합니다.)
* **피어링(Peering) 또는 VPN 연결 실패:**
  * A 회사 VPC(`10.0.0.0/16`)와 B 회사 망(`10.0.0.0/16`)을 연결하려 할 때 대역이 완벽히 겹치면 라우팅이 불가능합니다. 설계 단계부터 조직 전체의 IP 할당 테이블(IPAM)을 중앙 관리해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon VPC 네트워킹 구성 모범 사례](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-security.html)