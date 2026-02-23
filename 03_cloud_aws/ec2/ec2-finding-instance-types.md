# EC2 Finding Instance Types

## 1. 개요
애플리케이션의 워크로드(CPU, 메모리, 네트워크, 스토리지) 특성에 가장 적합하고 비용 효율적인 **EC2 인스턴스 타입 및 크기를 식별하고 선정**하는 가이드입니다.

## 2. 설명
* **명명 규칙 (Naming Convention):** 예) `m5.xlarge`
  * `m`: 인스턴스 패밀리 (목적)
  * `5`: 세대 (Generation, 높을수록 최신)
  * `xlarge`: 크기 (vCPU, RAM 용량)
* **주요 패밀리 분류:**
  * **T 시리즈 (Burstable):** 평소엔 CPU를 적게 쓰다가 간헐적으로 치솟는 웹 서버나 테스트 환경. (CPU 크레딧 개념 존재)
  * **M 시리즈 (General):** CPU와 메모리 비율이 균형(1:4) 잡힌 일반적인 서버.
  * **C 시리즈 (Compute):** 고성능 프로세서가 필요한 배치 처리, 동영상 인코딩.
  * **R 시리즈 (Memory):** 메모리 비율이 높은(1:8) 관계형 DB(RDS), 인메모리 캐시.
* **AWS Compute Optimizer:** 기계 학습을 통해 기존 인스턴스의 과거 14일 치 CloudWatch 지표를 분석하여 "이 인스턴스는 오버프로비저닝 되었으니 `c5.large`로 줄이세요" 등의 최적화 권장 사항을 제공합니다.

## 3. 참조 및 관련된 파일
* [[ec2-savings-plan]] (타입 확정 후 약정 할인)
* [[eks-launch-template]] (워커 노드 타입 선정)
* [[cloudwatch-custom-metric]] (정확한 메모리 지표 수집 후 타입 결정)

## 4. 트러블 슈팅
* **T 시리즈 인스턴스 성능 급락 현상:**
  * CPU 사용률이 갑자기 떨어지면서 서비스가 느려졌다면 **CPU 크레딧 고갈**을 의심해야 합니다. CloudWatch에서 `CPUCreditBalance` 지표가 0인지 확인하세요.
  * 무제한(Unlimited) 모드를 켜거나, M 시리즈로 인스턴스 타입을 변경해야 합니다.
* **인스턴스 생성 시 `InsufficientInstanceCapacity` 오류:**
  * 선택한 AZ(가용 영역)에 사용자가 요청한 특정 인스턴스 타입(예: 최신 GPU 인스턴스)의 물리적 재고가 부족할 때 발생합니다.
  * 다른 AZ를 선택하거나, 이전 세대(예: `g5` 대신 `g4dn`) 또는 다른 크기로 변경하여 시도해야 합니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Amazon EC2 인스턴스 유형](https://aws.amazon.com/ko/ec2/instance-types/)


- [참고]
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/instance-discovery.html

