# Service Mesh: Istio Envoy (Data Plane)

## 1. 개요 및 비유
**Envoy(엔보이)**는 C++로 작성된 초고성능 L7 프록시 서버입니다. Istio 서비스 메시에서 **'데이터 플레인(Data Plane)'**을 담당하며, 애플리케이션 파드 안에 '사이드카(Sidecar)' 형태로 주입되어 모든 인바운드/아웃바운드 네트워크 트래픽을 가로채고 통제합니다.

💡 **비유하자면 'VIP 전담 통역사이자 경호원'과 같습니다.**
VIP(애플리케이션 컨테이너)는 외국어(네트워크 프로토콜, 암호화, 재시도 로직)를 신경 쓸 필요 없이 한국어로만 편하게 말하면 됩니다. 옆에 찰싹 붙어있는 경호원(Envoy 사이드카)이 모든 대화를 가로채서 암호화(mTLS)도 해주고, 상대방이 안 받으면 대신 다시 전화도 걸어주며(Retry), 대화 내용(Telemetry)을 모조리 수첩에 기록해 둡니다.

## 2. 핵심 설명
* **투명한 트래픽 가로채기 (Traffic Interception):** 쿠버네티스의 `iptables` 규칙을 조작하여, 애플리케이션 컨테이너가 밖으로 보내거나 밖에서 들어오는 모든 트래픽이 강제로 Envoy를 거치게 만듭니다. (앱 코드는 1줄도 수정할 필요가 없습니다!)
* **네트워크 탄력성 (Resiliency):** 단순한 로드 밸런싱을 넘어, 재시도(Retries), 타임아웃(Timeouts), 트래픽 차단(Circuit Breaking), 결함 주입(Fault Injection) 등 고도화된 마이크로서비스 안정성 기능을 수행합니다.
* **관측성 (Observability):** 지나가는 모든 트래픽의 메트릭(요청량, 에러율, 지연 시간)과 분산 추적(Trace ID) 데이터를 생성하여 Prometheus나 Jaeger로 보냅니다.

## 3. YAML 적용 예시 (Envoy Sidecar 자동 주입)
Envoy 프록시는 직접 파드 스펙에 작성할 수도 있지만, 보통은 네임스페이스에 **라벨(Label)을 달아서 Mutating Webhook이 자동으로 주입**하게 만드는 것이 베스트 프랙티스입니다.

```yaml
# 네임스페이스에 라벨을 달아 해당 네임스페이스에 생성되는 
# 모든 파드에 Envoy 사이드카를 자동 주입(Inject)하도록 지시
apiVersion: v1
kind: Namespace
metadata:
  name: my-app-namespace
  labels:
    istio-injection: enabled # Istio Webhook이 이 라벨을 감지하여 Envoy 컨테이너를 끼워 넣음

---
# 이 네임스페이스에 일반적인 Deployment를 배포하면,
# K8s API 서버가 파드를 생성하기 직전에 Envoy 컨테이너를 몰래 추가해 줍니다.
```

## 4. 트러블 슈팅
* **앱 파드는 `Running`인데 상태가 `1/2` 에서 넘어가지 않음:**
  * 파드 안에 컨테이너가 2개(App + Envoy) 있어야 하는데, Envoy 컨테이너가 Istiod 컨트롤 플레인과 연결하지 못해(인증서 문제, 네트워크 단절 등) 시작에 실패한 상황입니다. `kubectl logs <파드명> -c istio-proxy` 로 프록시 로그를 봐야 합니다.
* **앱 구동 시 찰나의 순간에 외부 DB 접속 에러 발생:**
  * 파드가 시작될 때 앱 컨테이너와 Envoy 컨테이너가 동시에 켜집니다. 하지만 Envoy가 초기화되고 라우팅 규칙을 받아오기 전(약 1~2초)에 앱이 외부 네트워크로 먼저 요청을 쏴버리면 트래픽이 드롭(Drop)됩니다. 앱 코드에 재시도 로직을 넣거나, 어노테이션(`proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'`)을 추가하여 프록시가 켜질 때까지 앱을 홀딩시켜야 합니다.