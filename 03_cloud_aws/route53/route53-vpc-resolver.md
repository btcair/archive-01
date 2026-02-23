# Route 53 VPC Resolver

## 1. 개요
온프레미스(사내망)와 AWS VPC 간에 **하이브리드 DNS 아키텍처**를 구축하여, 서로의 도메인 주소(예: `corp.local` $\leftrightarrow$ `vpc.internal`)를 양방향으로 쿼리(해석)할 수 있게 해주는 **Route 53 Resolver** 설정입니다.

## 2. 설명
* **Inbound Endpoint (온프레미스 $\rightarrow$ AWS):**
  * 온프레미스 DNS 서버가 AWS 내부의 Private Hosted Zone 도메인을 질의할 수 있도록, VPC 내부에 DNS 수신용 IP(엔드포인트)를 생성합니다. 온프레미스 DNS에 이 IP로 '조건부 전달자(Conditional Forwarder)'를 설정합니다.
* **Outbound Endpoint (AWS $\rightarrow$ 온프레미스):**
  * VPC 내부의 리소스(EC2, EKS 등)가 온프레미스 도메인을 질의할 때 트래픽을 외부로 내보내는 엔드포인트입니다. Route 53에 'Resolver Rule'을 생성하여 타겟 DNS 서버의 IP를 지정합니다.

[Image of AWS Route 53 Resolver architecture showing Inbound and Outbound Endpoints connecting VPC and On-Premises network]

## 3. 참조 및 관련된 파일
* [[dx-building-resiliency]] (하이브리드 네트워크 연동 필수 전제)
* [[vpc-design-best-practice]]
* [[eks-version-upgrade-scenario]] (DNS 가중치 기반 트래픽 전환)

## 4. 트러블 슈팅
* **서로 도메인 해석이 불가능한 경우 (Time out):**
  * **보안 그룹 (Security Group):** Inbound/Outbound 엔드포인트에 할당된 보안 그룹이 양방향 **UDP 53, TCP 53 포트** 트래픽을 온프레미스 IP 대역에 대해 허용하고 있는지 반드시 확인해야 합니다.
  * **NACL:** 마찬가지로 VPC 서브넷의 네트워크 ACL에서 임시 포트(Ephemeral Ports) 대역의 트래픽이 막혀있지 않은지 검토합니다.
* **엔드포인트 생성 위치 오류:**
  * 엔드포인트는 고가용성을 위해 최소 2개의 가용 영역(AZ)에 속한 서브넷에 생성해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Route 53 Resolver를 사용하여 VPC와 네트워크 간의 DNS 쿼리 확인](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html)