# Service Mesh: Istio Istiod (Control Plane)

## 1. 개요 및 비유
**Istiod (이스티오디)**는 Istio 서비스 메시 아키텍처의 두뇌이자 **'컨트롤 플레인(Control Plane)'**입니다. 클러스터 내의 모든 라우팅 규칙과 보안 정책을 관리하고, 이를 각 파드에 붙어있는 프록시(Envoy)들에게 쏴주는 역할을 합니다.

💡 **비유하자면 '공항의 관제탑'과 같습니다.**
관제탑(Istiod)은 직접 비행기를 조종하지 않지만, 모든 비행기(Envoy 프록시)에게 "A 활주로로 가라(라우팅 규칙)", "현재 난기류가 있으니 우회해라(서킷 브레이커)", "보안 통신 주파수를 맞춰라(mTLS 인증서)"라고 지시를 내립니다. 관제탑이 있어야 수백 대의 비행기가 충돌 없이 안전하게 날아다닐 수 있습니다.

[Image of Istio architecture showing Istiod control plane managing Envoy proxies in the data plane]

## 2. 핵심 설명
* **기능 통합:** 과거 Istio(v1.4 이전)는 Pilot(라우팅), Citadel(보안/인증서), Galley(설정 검증), Mixer(원격 측정) 등 여러 컴포넌트로 나뉘어 복잡했지만, 현재는 이 모든 기능이 **`istiod`라는 단일 바이너리(파드)로 통합**되어 운영이 매우 쉬워졌습니다.
* **xDS API 통신:** Istiod는 쿠버네티스의 상태(Service, Endpoint 등)와 사용자 정의 규칙(VirtualService 등)을 감지한 뒤, 이를 Envoy가 이해할 수 있는 동적 설정(xDS)으로 번역하여 gRPC 스트림을 통해 실시간으로 프록시들에게 푸시(Push)합니다.
* **인증 기관 (CA):** 파드 간에 안전한 상호 TLS(mTLS) 통신을 할 수 있도록, 각 Envoy 프록시에게 암호화 키와 인증서를 발급하고 주기적으로 갱신(Rotate)해 줍니다.

## 3. YAML 적용 예시 (PeerAuthentication을 통한 mTLS 강제)
Istiod의 보안 제어 기능을 활용하여, 특정 네임스페이스(`default`) 안의 모든 파드 간 통신을 강제로 암호화(Strict mTLS)하도록 지시하는 설정입니다.

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default-mtls-strict
  namespace: default
spec:
  mtls:
    mode: STRICT # PERMISSIVE(평문 혼용)가 아닌 무조건 암호화 통신만 허용
```

## 4. 트러블 슈팅
* **라우팅 규칙을 바꿨는데(VirtualService 수정) 앱에 반영되지 않음:**
  * Istiod 파드 자체가 과부하(CPU/Mem 부족) 상태이거나 죽어서, 각 파드의 Envoy 프록시로 새로운 설정을 밀어내지(Push) 못하고 있는 'Out of Sync' 상태일 확률이 높습니다. `istioctl proxy-status` 명령어를 쳐서 `SYNCED` 상태가 아닌 프록시가 있는지 확인해야 합니다.
* **새로운 파드가 생겼는데 통신이 안 됨:**
  * Istiod의 CA(인증 기관) 기능에 문제가 생겨 새 파드의 Envoy 프록시에게 TLS 인증서를 발급해주지 못한 경우입니다. Istiod의 로그를 확인하여 시크릿 접근 권한이나 시간 동기화 문제를 점검하세요.