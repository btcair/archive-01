# EKS VM Migration

## 1. 개요
기존 온프레미스(On-Premises)나 EC2 인스턴스(VM) 환경에서 구동되던 레거시 애플리케이션을 **컨테이너화하여 K8s(EKS) 환경으로 이관(Migration/Re-platforming)**하는 전략과 가이드입니다.

## 2. 설명
* **Lift and Shift (컨테이너화 1단계):**
  * 애플리케이션의 소스 코드 수정 없이 OS 환경과 앱을 **Docker Image**로 묶어(Packaging) ECR에 푸시한 뒤, EKS의 Deployment로 띄우는 방식입니다.
  * 빠른 이관이 가능하지만, 클라우드 네이티브의 장점(빠른 스케일 아웃 등)을 100% 살리기는 어렵습니다.
* **Stateless 분리 (클라우드 네이티브화 2단계):**
  * K8s의 파드는 언제든지 죽고 살아날 수 있으므로, 기존 VM 로컬 디스크나 메모리에 저장하던 데이터를 반드시 분리해야 합니다.
  * **세션/캐시:** 로컬 메모리 $\rightarrow$ **Amazon ElastiCache (Redis)**
  * **공유 파일:** 로컬 디스크 $\rightarrow$ **Amazon EFS** 또는 **Amazon S3**
  * **로그:** 로컬 파일 $\rightarrow$ **Fluent Bit + CloudWatch/OpenSearch**

## 3. 참조 및 관련된 파일
* [[ecr-private-repository-create]] (도커 이미지 저장)
* [[efs-automatic-backup]] (공유 스토리지 마이그레이션)
* [[elasticache-version-upgrade]] (세션 저장소 연동)

## 4. 트러블 슈팅
* **파드(컨테이너) 구동 속도가 VM보다 현저히 느림:**
  * 기존 VM 환경의 수많은 불필요한 라이브러리까지 모두 도커 이미지로 구워내어(Image size > 2GB) 이미지 풀(Pull) 타임아웃이 발생한 경우입니다. **멀티 스테이지 빌드(Multi-stage build)**를 사용하여 런타임에 필요한 파일만 남겨 이미지 크기를 100MB 단위로 줄여야 합니다.
* **Java(JVM) 애플리케이션의 잦은 OOMKilled 에러:**
  * 오래된 Java 8 이하 버전은 컨테이너에 할당된 메모리 제한(Limits)을 인식하지 못하고, 호스트 EC2 노드의 전체 메모리를 기준으로 Heap을 잡아먹으려다가 K8s에 의해 OOM(Out of Memory) 강제 종료를 당합니다. `+UseContainerSupport` 옵션을 주거나 최신 JVM으로 업그레이드해야 합니다.

## 5. 참고자료 또는 링크
* [AWS Prescriptive Guidance - 컨테이너로 애플리케이션 리플랫포밍](https://aws.amazon.com/ko/prescriptive-guidance/)
* [AWS App2Container (A2C)](https://aws.amazon.com/ko/app2container/) (VM 자동 컨테이너화 도구)