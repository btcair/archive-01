# VPC Flow Logs

## 1. 개요
VPC의 네트워크 인터페이스(ENI)에서 송수신되는 **IP 트래픽 정보를 캡처하여 로그 형태로 수집**하는 기능입니다. 보안 모니터링, 비정상 트래픽 감지, 네트워크 장애 원인 분석에 필수적입니다.

## 2. 설명
* **수집 대상 범위:** VPC 전체, 특정 서브넷, 또는 개별 ENI 단위로 플로우 로그를 활성화할 수 있습니다.
* **저장소 위치:**
  * **CloudWatch Logs:** 실시간에 가까운 모니터링과 알람(Metric Filter) 설정에 유리합니다. (비용이 상대적으로 높음).
  * **Amazon S3:** 대용량 로그 장기 보관 및 Athena를 이용한 빅데이터 SQL 쿼리에 적합합니다. (비용 효율적).
* **데이터 필드:** 패킷 자체가 아닌 **메타데이터**를 수집합니다. (출발지/목적지 IP 및 포트, 프로토콜, 허용(ACCEPT)/거부(REJECT) 여부, 패킷 수 등).

## 3. 참조 및 관련된 파일
* [[athena-vpc-flow-log-query]] (S3에 쌓인 로그를 쿼리하는 방법)
* [[vpc-nacl]] (REJECT 로그 분석 시 방화벽 규칙 확인용)

## 4. 트러블 슈팅
* **트래픽 로그가 실시간으로 보이지 않음:**
  * VPC 플로우 로그는 패킷 스니퍼처럼 즉각적으로 기록되지 않습니다. 데이터를 수집하고 처리한 뒤 전송하기까지 **최대 약 1~10분의 집계(Aggregation) 지연**이 발생합니다. 실시간 트래픽 분석이 필요하다면 VPC Traffic Mirroring을 사용해야 합니다.
* **보안 그룹(SG)과 NACL에 의한 차단 구분:**
  * 로그에 `REJECT`가 기록되어 있다면, Security Group 인바운드에서 막혔거나, NACL 인바운드/아웃바운드에서 막힌 것입니다.
  * (팁) Security Group은 Stateful 하므로 요청이 ACCEPT 되면 응답 트래픽도 자동 ACCEPT 되지만, NACL은 Stateless 하므로 양방향을 모두 뚫어주지 않으면 응답 패킷이 돌아갈 때 REJECT 로그가 남습니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - VPC 흐름 로그 사용](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)