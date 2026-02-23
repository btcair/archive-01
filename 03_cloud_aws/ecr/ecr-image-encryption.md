# ECR Image Encryption

## 1. 개요
**Amazon ECR(Elastic Container Registry)**에 저장되는 도커(Docker) 컨테이너 이미지의 데이터를 보호하기 위해 저장 시점(At Rest)에 **서버 측 암호화(SSE)**를 적용하는 보안 설정입니다.

## 2. 설명
* **기본 암호화 (SSE-S3):** ECR은 생성 시 기본적으로 Amazon S3 관리형 암호화 키를 사용하여 모든 이미지를 자동으로 암호화합니다. (추가 비용 없음)
* **AWS KMS 암호화 (SSE-KMS):** 더 강력한 보안 요구사항(컴플라이언스)이 필요할 때 사용합니다. AWS KMS(Key Management Service) 고객 관리형 키(CMK)를 사용하여 이미지를 암호화합니다.
  * 장점: 누가 언제 암호화 키를 사용했는지 CloudTrail을 통해 상세히 감사(Audit)할 수 있으며, 키 접근 권한을 세밀하게 제어할 수 있습니다.

## 3. 참조 및 관련된 파일
* [[ecr-private-repository-create]]
* [[s3-lifecycle-security]]
* [[cloudtrail]]

## 4. 트러블 슈팅
* **EKS / EC2에서 ECR 이미지 Pull(다운로드) 실패:**
  * `ErrImagePull` 에러가 발생하며 이미지를 가져오지 못할 때, ECR 권한뿐만 아니라 **KMS 키에 대한 복호화 권한**이 누락된 경우가 많습니다.
  * 워커 노드의 IAM 역할(Role) 정책에 `kms:Decrypt`, `kms:DescribeKey` 권한이 부여되어 있는지 확인해야 합니다.
* **리포지토리 생성 후 암호화 설정 변경 불가:**
  * 이미 생성된 ECR 리포지토리의 암호화 설정(SSE-S3 $\leftrightarrow$ SSE-KMS)은 사후에 변경할 수 없습니다. 설정을 바꾸려면 리포지토리를 새로 만들고 이미지를 다시 Push해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon ECR 저장 데이터 암호화](https://docs.aws.amazon.com/AmazonECR/latest/userguide/encryption-at-rest.html)

- [참고]
https://docs.aws.amazon.com/AmazonECR/latest/userguide/encryption-at-rest.html