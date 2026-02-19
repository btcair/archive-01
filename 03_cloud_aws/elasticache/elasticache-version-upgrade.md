
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
