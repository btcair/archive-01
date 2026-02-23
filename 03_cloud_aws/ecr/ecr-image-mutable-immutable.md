# ECR Image Tags: Mutable vs Immutable

## 1. 개요
ECR에 컨테이너 이미지를 Push할 때 사용하는 **이미지 태그(Tag, 예: `v1.0`, `latest`)를 덮어쓸 수 있게 할 것인지(Mutable) 방지할 것인지(Immutable)** 결정하는 설정입니다.

## 2. 설명
* **Mutable (변경 가능 - 기본값):**
  * 동일한 태그 이름으로 새 이미지를 Push하면, 이전 이미지는 태그를 잃고 `<untagged>` 상태가 되며 새 이미지가 해당 태그를 가져갑니다.
  * 개발 환경에서 `latest` 태그를 반복적으로 덮어쓸 때 유용합니다.
* **Immutable (변경 불가 - 운영 권장):**
  * 한 번 특정 태그(`v1.0.1`)로 푸시된 이미지는 **절대 동일한 태그로 덮어쓸 수 없습니다.** * 프로덕션 환경에서 누군가 악의적이거나 실수로 검증되지 않은 코드를 동일한 버전 태그로 배포하는 것을 원천 차단하여 시스템의 예측 가능성을 높입니다.



## 3. 참조 및 관련된 파일
* [[ecr-private-repository-create]]
* [[eks-version-upgrade-scenario]] (버전 관리와 연관)

## 4. 트러블 슈팅
* **이미지 Push 시 `ImageTagAlreadyExistsException` 에러:**
  * 리포지토리가 `Immutable`(변경 불가)로 설정되어 있는데, 이미 존재하는 태그(예: `v2.0`)로 다시 `docker push`를 시도했을 때 발생합니다. CI/CD 파이프라인의 버전 넘버링 로직(예: Git Commit Hash 활용)이 정상적으로 새 버전을 생성하고 있는지 확인하세요.
* **Untagged 이미지에 의한 스토리지 비용 증가:**
  * Mutable 환경에서 `latest` 태그를 계속 덮어쓰면 태그를 잃은 고아(Untagged) 이미지들이 리포지토리에 계속 쌓여 요금이 부과됩니다. ECR **수명 주기 정책(Lifecycle Policy)**을 설정하여 "Untagged 이미지는 14일 후 삭제"하도록 자동화해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - ECR 이미지 태그 변경 가능성](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html)

- [참고]
https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/image-tag-mutability.html


