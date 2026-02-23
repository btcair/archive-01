# ECR Private Repository Create

## 1. 개요
사내 개발팀이나 특정 AWS 계정 내부에서만 접근할 수 있는 **프라이빗 컨테이너 이미지 저장소(Private Repository)**를 생성하고 도커(Docker) 클라이언트와 인증(Login)하는 기본 절차입니다.

## 2. 설명
* **생성 시 주요 옵션:**
  * **태그 변경 가능성 (Tag Mutability):** Mutable(덮어쓰기 가능) / Immutable(덮어쓰기 불가) 중 선택합니다. 운영 환경은 Immutable을 권장합니다.
  * **푸시 시 스캔 (Scan on push):** 이미지가 업로드될 때마다 OS 패키지의 취약점(CVE)을 자동으로 스캔하여 보안 위협을 사전에 식별합니다. (기본 스캔 또는 Amazon Inspector를 통한 향상된 스캔 지원)
* **인증(Login) 절차:**
  * 로컬 환경이나 CI/CD 서버의 도커 데몬이 ECR에 이미지를 푸시/풀 하려면 AWS CLI를 통해 임시 인증 토큰(12시간 유효)을 발급받아야 합니다.
  * **기본 로그인 명령어 예시:**
    ```bash
    aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-northeast-2.amazonaws.com
    ```

[Image of AWS ECR private repository creation console showing tag mutability and scan on push options]

## 3. 참조 및 관련된 파일
* [[ecr-image-encryption]]
* [[ecr-image-mutable-immutable]]
* [[ecr-public-registries]]

## 4. 트러블 슈팅
* **`aws ecr get-login-password` 실행 시 권한 에러 발생:**
  * 로컬 환경에 구성된 AWS IAM 자격 증명(Access Key)에 `ecr:GetAuthorizationToken` 권한이 없거나 만료되었을 때 발생합니다. `aws sts get-caller-identity` 명령어로 현재 적용된 인증 정보를 먼저 확인하세요.
* **Docker Push 시 `no basic auth credentials` 오류:**
  * ECR 로그인 토큰이 만료되었거나(발급 후 12시간 초과), 로그인 시도한 ECR 주소와 `docker push` 하려는 이미지의 대상 레지스트리 주소가 일치하지 않을 때 발생합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon ECR 프라이빗 리포지토리 생성](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html)