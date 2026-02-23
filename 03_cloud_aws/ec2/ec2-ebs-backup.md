
# EC2 EBS Backup

## 1. 개요
EC2 인스턴스에 연결된 **EBS(Elastic Block Store) 볼륨의 데이터를 스냅샷(Snapshot) 형태**로 S3에 안전하게 백업하고, Data Lifecycle Manager(DLM)나 AWS Backup을 통해 이를 자동화하는 방법입니다.

## 2. 설명
* **증분 백업 (Incremental Backup):** EBS 스냅샷은 최초 1회만 전체 복사(Full Copy)를 수행하고, 이후부터는 **이전 스냅샷 이후 변경된 블록(Delta)만 저장**하므로 스토리지 비용과 시간을 크게 절약합니다.
* **정합성 보장 (Consistency):**
  * **Crash-Consistent:** 볼륨 IO를 멈추지 않고 찍는 기본 스냅샷. 전원 플러그를 뽑은 직후의 디스크 상태와 같습니다.
  * **Application-Consistent:** VSS(Windows) 등을 연동하여 메모리/DB 캐시에 있는 데이터까지 디스크에 완전히 쓴(Flush) 후 찍는 무결성 스냅샷입니다.
* **자동화:** Amazon DLM을 사용하여 "매일 자정에 스냅샷 생성, 7일 후 삭제"와 같은 태그 기반의 백업 정책을 자동화할 수 있습니다.



## 3. 참조 및 관련된 파일
* [[backup-plan-delete]]
* [[ec2-ami]]
* [[s3-lifecycle-security]] (스냅샷 보관 스토리지)

## 4. 트러블 슈팅
* **스냅샷 복원 후 EC2 성능 저하 (Latency 증가):**
  * 스냅샷으로 새 EBS 볼륨을 만들면 데이터가 백그라운드에서 S3로부터 지연 로드(Lazy Loading)됩니다. 처음 읽는 데이터 블록은 S3에서 가져와야 하므로 IOPS가 크게 떨어집니다.
  * **해결책:** `dd` 명령어 등으로 볼륨의 모든 블록을 한 번씩 읽어 미리 로드(Pre-warming)하거나, 비용을 내고 **FSR(Fast Snapshot Restore)** 기능을 활성화하여 즉시 최고 성능을 내도록 해야 합니다.
* **스냅샷 삭제 시 용량/비용이 줄지 않는 현상:**
  * 증분 백업 특성상, 삭제하려는 스냅샷의 블록을 최신 스냅샷이 참조하고 있다면 실제 S3 스토리지에서 해당 블록 데이터는 삭제되지 않습니다. 오로지 참조가 완전히 끝난 고유 블록만 삭제되어 비용이 절감됩니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EBS 스냅샷](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html)