# AWS Backup Plan Delete

## 1. 개요
**AWS Backup** 서비스에서 생성한 중앙 집중식 백업 계획(Backup Plan)을 중지하거나, 기존에 생성된 복구 지점(Recovery Point) 및 백업 볼트(Vault)를 안전하게 삭제하는 절차와 주의사항입니다.

## 2. 설명
* **보존 규칙 (Retention Rule):** 백업 플랜에 설정된 수명 주기에 따라 오래된 백업은 자동 삭제됩니다. 하지만 비용 절감이나 실수로 잘못 만든 플랜을 즉시 정리해야 할 때 수동 삭제가 필요합니다.
* **삭제 순서:** 리소스를 깔끔하게 삭제하려면 보통 다음 순서를 따릅니다.
  1. **리소스 할당(Resource Assignment) 제거:** 플랜이 새 백업을 만들지 못하게 연결을 끊습니다.
  2. **백업 플랜(Backup Plan) 삭제:** 스케줄 자체를 삭제합니다.
  3. **복구 지점(Recovery Point) 삭제:** Vault에 저장된 실제 백업본 데이터를 삭제합니다.
  4. **백업 볼트(Backup Vault) 삭제:** Vault가 완전히 비워져야만 삭제 가능합니다.

## 3. 참조 및 관련된 파일
* [[ec2-ebs-backup]] (EC2 및 볼륨 백업 정책)
* [[efs-automatic-backup]] (EFS 데이터 보호)

## 4. 트러블 슈팅
* **복구 지점(Recovery Point) 삭제 시 Access Denied 오류:**
  * 백업 볼트에 **액세스 정책(Access Policy)**이 설정되어 있어 삭제(`backup:DeleteRecoveryPoint`)를 명시적으로 `Deny`하고 있는지 확인해야 합니다.
* **백업 볼트 잠금 (Vault Lock) 상태:**
  * 런섬웨어 방지 등을 위해 `Vault Lock` 기능이 컴플라이언스 모드로 활성화되어 있다면, **루트 사용자를 포함한 그 누구도** 보존 기간이 끝나기 전까지 데이터를 수동으로 삭제할 수 없습니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - 백업 및 백업 플랜 삭제](https://docs.aws.amazon.com/aws-backup/latest/devguide/deleting-backups.html)
- [참고]https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html#how-backup-works
- [참고]https://docs.aws.amazon.com/aws-backup/latest/devguide/deleting-a-backup-plan.html
- [참고]https://repost.aws/knowledge-center/support-case-browser-har-file