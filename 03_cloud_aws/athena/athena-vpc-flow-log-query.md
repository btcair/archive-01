
# Athena VPC Flow Log Query

## 1. 개요
**Amazon Athena**를 사용하여 S3 버킷에 저장된 **VPC Flow Logs(네트워크 트래픽 로그)**를 SQL 문법으로 간편하고 빠르게 검색 및 분석하는 방법에 대한 문서입니다.

## 2. 설명
* **작동 원리:** VPC Flow Log가 S3에 저장되면, Athena에서 해당 S3 경로를 가리키는 외부 테이블(External Table)을 생성(DDL)하여 데이터를 조회할 수 있습니다. 별도의 데이터베이스 서버 프로비저닝 없이 쿼리한 데이터만큼만 비용(Serverless)을 지불합니다.
* **파티셔닝(Partitioning):** S3에 쌓이는 로그는 날짜나 시간별로 나뉘어 있습니다. Athena 테이블 생성 시 파티션을 설정하면, 쿼리 스캔 범위를 줄여 **비용을 절감하고 쿼리 속도를 향상**시킬 수 있습니다.

## 3. 참조 및 관련된 파일
* [[vpc-flog-log]] (VPC 플로우 로그 설정 방법)
* [[s3-lifecycle-security]] (S3 데이터 보존 주기)

## 4. 트러블 슈팅
* **쿼리 결과가 0건으로 나오는 경우:**
  * S3에는 데이터가 있지만 Athena가 파티션을 인식하지 못했을 수 있습니다. `MSCK REPAIR TABLE 테이블명;` 명령어를 실행하여 파티션 메타데이터를 최신화해야 합니다.
* **쿼리 권한 오류 (Access Denied):**
  * Athena 쿼리 실행 결과가 저장되는 '쿼리 결과 S3 버킷(Query result location)'에 대한 쓰기 권한이 사용자(IAM)에게 있는지 확인합니다.
  * 원본 VPC Flow Logs가 저장된 S3 버킷에 대한 읽기 권한이 있는지 확인합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Athena를 사용하여 VPC 흐름 로그 쿼리](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-athena.html)
* https://techblog.samsung.com/blog/article/74


