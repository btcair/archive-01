# Addon: CoreDNS

## 1. 개요 및 비유
**CoreDNS**는 쿠버네티스 클러스터 내부의 서비스와 파드들이 서로 통신할 수 있도록 이름을 IP 주소로 변환해 주는 '기본 네임서버'입니다. 

💡 **비유하자면 '사내 연락처(전화번호부)'와 같습니다.**
주니어 엔지니어인 여러분이 동료의 자리 내선 번호(IP 주소)를 전부 외울 수 없으니, "개발팀 김철수(서비스 이름)"라고 사내 전화번호부(CoreDNS)에 검색하면 자동으로 내선 번호(IP)를 연결해 주는 원리입니다.

## 2. 핵심 설명
* **Service Discovery:** 쿠버네티스에서 `Service` 객체를 생성하면, CoreDNS는 자동으로 `<서비스명>.<네임스페이스>.svc.cluster.local` 이라는 도메인 이름을 부여하고 내부 IP와 매핑합니다.
* **유연한 플러그인 구조:** `Corefile`이라는 설정 파일을 통해 캐싱(Cache), 에러 로깅(Errors), 외부 DNS 포워딩(Forward) 등의 기능을 플러그인 형태로 손쉽게 조립할 수 있습니다.
* **EKS 환경:** EKS 클러스터를 생성하면 기본 Addon으로 설치되며, 파드 개수를 넉넉히 유지해 DNS 병목을 방지하는 것이 중요합니다.

## 3. YAML 적용 예시 (CoreDNS ConfigMap 커스텀)
특정 외부 도메인(예: 사내 온프레미스 DB)에 대한 DNS 질의를 별도의 커스텀 네임서버로 보내도록 `Corefile`을 수정하는 예시입니다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    # 사내 온프레미스 도메인 질의는 특정 사내 DNS 서버(10.100.1.5)로 포워딩
    corp.internal:53 {
        errors
        cache 30
        forward . 10.100.1.5
    }
```

## 4. 트러블 슈팅
* **파드에서 `Unknown Host` 에러가 발생할 때:**
  * 가장 먼저 CoreDNS 파드가 정상적으로 실행 중(`Running`)인지 확인합니다.
  * 파드에 접속하여 `nslookup kubernetes.default.svc.cluster.local` 명령어를 실행해 DNS 해석이 제대로 되는지 점검합니다. 
  * Node의 `iptables` 규칙이 꼬여서 UDP 53 포트 통신이 막힌 경우가 잦으니 노드 네트워크 상태를 확인하세요.