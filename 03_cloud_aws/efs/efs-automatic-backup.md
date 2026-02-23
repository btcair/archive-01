# EFS Automatic Backup

## 1. 개요
**Amazon EFS(Elastic File System)** 볼륨에 저장된 데이터를 보호하기 위해 **AWS Backup** 서비스와 연동하여 자동으로 일일 백업을 수행하고 보존 주기를 관리하는 설정입니다.

## 2. 설명
* **자동 백업 활성화:** EFS 파일 시스템을 생성할 때 기본적으로 '자동 백업(Automatic backups)'이 활성화되어 있습니다. 이는 AWS Backup의 기본 백업 플랜(Default Backup Plan)을 사용하여 매일 스냅샷을 캡처합니다.
* **보존 기간 (Retention):** 기본 설정된 자동 백업은 35일 동안 보관된 후 삭제됩니다.
* **증분 백업:** 최초 백업 이후에는 변경된 데이터(증분)만 백업하므로 스토리지 비용을 효율적으로 관리할 수 있습니다.
* **복구 옵션:** 전체 파일 시스템을 새 EFS로 복구하거나, **항목 수준 복구(Item-level recovery)**를 통해 특정 파일/폴더만 기존 EFS에 복구할 수도 있습니다.

## 3. 참조 및 관련된 파일
* [[backup-plan-delete]]
* [[ec2-ebs-backup]]

## 4. 트러블 슈팅
* **백업 요금이 과도하게 청구되는 경우:**
  * EFS 볼륨에 매일 대량의 데이터가 생성/수정/삭제되는 워크로드라면 증분 백업이라도 백업 용량이 크게 늘어납니다. 불필요한 캐시 폴더나 로그 파일이 EFS에 저장되고 있지 않은지 확인하고, 필요하다면 백업 플랜의 보존 기간(Retention)을 35일에서 7일 등으로 단축해야 합니다.
* **자동 백업 비활성화 실패:**
  * EFS 콘솔에서 자동 백업을 해제하려 할 때, AWS Backup 서비스 쪽에 이미 생성된 Backup Vault나 Lock이 걸려있으면 해제가 제한될 수 있습니다. AWS Backup 콘솔에서 해당 플랜 설정을 먼저 확인하세요.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EFS 파일 시스템 자동 백업](https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html)



efs 신규 생성시에는 자동으로 Backup Plan과 Vault가 생성됨, 별도 삭제가 불가능 함
네이밍은 다음과 같다
- Backup Plan: aws/efs/automatic-backup-plan
- Backup Vault: aws/efs/automatic-backup-vault

- [참고]
https://docs.aws.amazon.com/efs/latest/ug/automatic-backups.html

- [참고] 
https://repost.aws/knowledge-center/efs-disable-automatic-backups

---
