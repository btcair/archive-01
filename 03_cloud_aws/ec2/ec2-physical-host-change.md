AWS의 hardware fault 발생시 EC2의 instance를 중지 및 재시작 작업을 수행해줘야하는데, 중지 및 재시작을 해도 안바뀌는 경우가 있다. 

**TIP.**
그런 경우에는 AWS TAM이나 Support에 case open을 해서 특정시간 작업을 예약해두고 진행하면 된다.

- **Reboot:** 동일한 물리적 호스트 내에서 인스턴스 소프트웨어만 재시작합니다.
- **Stop & Start:** 인스턴스가 중지되면 물리적 호스트와의 연결이 끊깁니다. 다시 `Start`를 누르면 AWS 스케줄러가 해당 가용 영역(AZ) 내에서 가장 건강한 **새로운 물리 서버(Host)**를 찾아 인스턴스를 배치합니다.

- **[참고]EC2 인스턴스 중지 및 시작 (호스트 이관 관련)**
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/Stop_Start.html

- **[참고]인스턴스 스토어 데이터 유지 관련 주의사항**
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/instance-store-lifetime.html

- **[참고]용량 부족 오류(InsufficientInstanceCapacity) 해결** 
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/troubleshooting-launch.html

- **[참고]전용 호스트의 인스턴스 선호도 설정**
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/dedicated-hosts-overview.html

---
