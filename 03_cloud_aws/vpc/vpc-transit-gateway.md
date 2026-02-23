
# VPC Transit Gateway (TGW)

## 1. 개요
수십, 수백 개의 복잡한 VPC 라우팅과 온프레미스 VPN/Direct Connect 연결을 **허브 앤 스포크(Hub and Spoke) 토폴로지 구조로 단일 중앙 지점에서 관리**하는 네트워크 연결 라우터(허브) 서비스입니다.

## 2. 설명
* **VPC Peering의 한계 극복:**
  * VPC 피어링은 1:1 연결만 지원하여, VPC 개수가 늘어날수록 통신망이 복잡한 그물망(Mesh, $N(N-1)/2$) 형태로 변합니다. TGW는 모든 통신을 허브 하나로 모아 라우팅 관리를 극도로 단순화합니다.
* **라우팅 도메인 분리:**
  * TGW 내부에 여러 개의 라우팅 테이블(Route Table)을 만들어, 개발(Dev) VPC 끼리만 통신하고 운영(Prod) VPC와는 단절되도록 세밀하게 논리적 망 분리를 수행할 수 있습니다.
* **멀티캐스트 지원:** 일반 VPC에서는 불가능한 IP 멀티캐스트(Multicast) 트래픽 라우팅을 클라우드 환경에서 지원합니다.



## 3. 참조 및 관련된 파일
* [[dx-building-resiliency]] (DX Gateway와 TGW 연동)
* [[vpc-design-best-practice]] (TGW 전용 서브넷 설계)
* [[route53-vpc-resolver]]

## 4. 트러블 슈팅
* **TGW를 연결했는데 VPC 간 핑(Ping)이 가지 않음:**
  1. **VPC의 서브넷 라우팅 테이블:** 목적지 IP의 라우팅 타겟이 TGW(예: `tgw-xxxx`)로 설정되어 있는지 확인.
  2. **TGW 라우팅 테이블:** TGW 안에서 목적지 VPC Attachment로 가는 경로가 존재하는지 확인.
  3. **Security Group & NACL:** 방화벽에서 사설 IP 대역 간의 트래픽을 허용했는지 확인.
* **TGW Attachment 설계 오류:**
  * TGW가 VPC와 연결(Attachment)되려면 VPC 각 가용 영역에 1개씩 서브넷과 IP(ENI)가 필요합니다. 만약 애플리케이션 파드나 EC2가 가득 찬 서브넷을 TGW Attachment용으로 혼용하면, 라우팅 제어나 NACL 보안 적용이 꼬이게 됩니다. 항상 **TGW 전용의 작은 서브넷(예: `/28`)**을 별도로 만들어 할당하는 것이 모범 사례입니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - AWS Transit Gateway란 무엇인가요?](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html)