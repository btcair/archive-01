# ElastiCache Version Upgrade

## 1. 개요
**Amazon ElastiCache (Redis/Memcached)** 클러스터의 엔진 버전을 최신 기능 사용 및 보안 패치를 위해 업그레이드할 때, 서비스 중단(Downtime)을 최소화하며 안전하게 진행하는 방법입니다.

## 2. 설명
* **온라인 마이그레이션 (Redis):** 최신 버전의 Redis 엔진은 가용성 저하를 최소화하기 위해 '온라인 업그레이드'를 지원합니다.
* **클러스터 모드 비활성화 (Replica Group):**
  * 다중 AZ 구조일 경우, ElastiCache는 먼저 복제본(Replica) 노드의 버전을 업그레이드합니다.
  * 복제본 업그레이드가 완료되면 주(Primary) 노드와 역할을 교체(Failover)한 뒤, 기존 주 노드를 업그레이드하여 읽기/쓰기 중단을 수 초 이내로 최소화합니다.
* **유지 관리 시간대 (Maintenance Window):** 강제 패치가 적용되는 시간을 지정하여 트래픽이 가장 적은 새벽 시간대에 자동으로 업그레이드되도록 설정할 수 있습니다.

## 3. 참조 및 관련된 파일
* [[eks-vm-migration]] (세션 저장소 분리)
* [[service-quotas-request]] (노드 수 제한 확인)

## 4. 트러블 슈팅
* **업그레이드 중 일시적 타임아웃(Timeout) 발생:**
  * 역할 교체(Failover)가 일어나는 약 5~10초 동안 쓰기(Write) 작업이 지연될 수 있습니다. 애플리케이션 측에서 재시도(Retry) 로직과 백오프(Exponential Backoff)가 구현되어 있지 않으면 연결 에러가 대량 발생합니다.
* **명시적 `REPLICAOF` 명령어 제한:**
  * ElastiCache는 완전 관리형 서비스이므로 사용자가 임의로 복제 토폴로지를 변경하는 명령어(`SLAVEOF`, `BGSAVE` 등)가 제한되어 있어, 수동으로 마이그레이션 튜닝을 할 수 없습니다. 기본 Failover 메커니즘을 신뢰해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - ElastiCache for Redis 엔진 버전 업그레이드](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/VersionManagement.html)




1. 내부적으로 "새 노드 클러스터" 그룹을 만듦  
2. "기존 노드 클러스터" 그룹과 데이터를 동기화  
3. "기존 노드 클러스터" 그룹 데이터 동기화 확인   
4. "기존 노드 클러스터"를 "새 노드 클러스터"로 Failover 진행 ( 끊어지는 지점 )  
5. "새 노드 클러스터"로 Endpoint DNS IP 업데이트 ( Client의 DNS cache 가 영향받는 지점 )  
6. "기존 노드 클러스터"를 제거   
7. Events 페이지에 완료 표시

- [참고] 버전 업그레이드
https://docs.aws.amazon.com/ko_kr/AmazonElastiCache/latest/dg/engine-versions.html

- [참고] 버전 업그레이드
https://docs.aws.amazon.com/ko_kr/AmazonElastiCache/latest/dg/VersionManagement.HowTo.html

- [참고] 버전 업그레이드
https://repost.aws/knowledge-center/elasticache-redis-upgrade-engine-version
