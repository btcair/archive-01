# Lambda Sample Code & Best Practices

## 1. 개요
서버리스 컴퓨팅인 **AWS Lambda**를 작성할 때 성능을 최적화하고 비용을 절감하기 위해 필수적으로 적용해야 하는 코드 작성 모범 사례와 구조입니다.

## 2. 설명
* **핸들러 (Handler):** Lambda가 호출될 때 실행되는 진입점(Entry point) 함수입니다. 클라이언트가 넘겨준 `event` 객체와 실행 환경 정보인 `context` 객체를 인자로 받습니다.
* **콜드 스타트 (Cold Start) 최적화:**
  * Lambda는 오랫동안 호출되지 않으면 실행 환경을 삭제합니다. 새 환경이 뜰 때 발생하는 지연 시간을 콜드 스타트라고 합니다.
  * **해결책:** DB 연결(Connection) 객체나 AWS SDK 클라이언트 초기화 코드를 **핸들러 함수 '바깥(Global scope)'에 배치**하여, 웜 스타트(Warm Start) 시 재사용하도록 설계해야 합니다.
* **환경 변수:** 하드코딩을 피하고 개발/운영 환경 분리를 위해 환경 변수(Environment Variables)를 적극 활용합니다.

## 3. 참조 및 관련된 파일
* [[ec2-savings-plan]] (Lambda 사용량도 Savings Plan에 포함됨)
* [[vpc-nat-gateway]] (프라이빗 서브넷 Lambda의 인터넷 접속용)

## 4. 트러블 슈팅
* **VPC 내부 리소스 접속 시 타임아웃 발생:**
  * Lambda를 VPC 내부에 배치하여 RDS 등에 접근하려 할 때, 해당 서브넷의 ENI(Elastic Network Interface)를 생성할 IP 공간이 부족하거나 보안 그룹(SG) 아웃바운드가 막혀 있으면 타임아웃이 발생합니다.
* **메모리 부족(OOM) 에러:**
  * 코드가 효율적이라도 Lambda 메모리를 너무 작게(예: 128MB) 설정하면 실행이 실패할 수 있습니다. 메모리를 늘리면 비례해서 CPU 파워도 증가하므로, 적절한 크기로 프로비저닝해야 실행 시간이 짧아져 전체 비용이 오히려 감소할 수 있습니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - Lambda 함수를 사용하는 모범 사례](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)