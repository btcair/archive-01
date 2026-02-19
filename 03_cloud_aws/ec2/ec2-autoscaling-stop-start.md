
**오토스케일링으로 구성된 EC2의 중지 및 시작 작업시에 주의해야하는 점**
-> ASG그룹에 할당되어있는 인스턴스는 곧바로 재기동 또는 중지 및 시작 작업을 진행할때 바로 인스턴스 중지를 진행하면 안 된다.  아래의 체크 사항을 참고하여 진행하면 좋음.
1. 인스턴스 축소보호: 콘솔>EC2>Auto Scaling>Auto Scaling 그룹>[ASG 선택]>인스턴스 관리>인스턴스 모두 선택> 인스턴스 축소보호 설정 선택
2. Min 수정: 콘솔>EC2>Auto Scaling>Auto Scaling 그룹>[ASG 선택]>용량개요>편집>원하는 최소용량:[개수 선택]>업데이트
3. 대기상테: 콘솔>EC2>Auto Scaling>Auto Scaling 그룹>[ASG 선택]>인스턴스 관리>[인스턴스 선택]>작업>대기로 설정>인스턴스 교체 해제 체크>상태확인:Entering Standby->Standby (복구시에는 InService)

- **[참고]인스턴스를 대기(Standby) 상태로 설정**
https://docs.aws.amazon.com/ko_kr/autoscaling/ec2/userguide/as-enter-exit-standby.html

- **[참고]인스턴스 축소 보호**
https://docs.aws.amazon.com/ko_kr/autoscaling/ec2/userguide/ec2-auto-scaling-instance-protection.html

- **[참고]ASG 상태 확인 및 교체 메커니즘**
https://docs.aws.amazon.com/ko_kr/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html

---

