# Objects: K8s Ingress

## 1. 개요 및 비유
**Ingress(인그레스)**는 클러스터 외부에서 내부의 서비스(Service)로 들어오는 HTTP 및 HTTPS 경로(라우팅 규칙)를 정의하는 리소스입니다. L7(애플리케이션 계층) 로드밸런싱, URL 라우팅, SSL/TLS 암호화 종료 등의 역할을 수행합니다.

💡 **비유하자면 '대형 호텔의 프론트 데스크(안내 데스크)'와 같습니다.**
외부에서 손님(클라이언트 트래픽)이 호텔 입구로 들어오면, 프론트 직원(Ingress)이 손님의 목적지(URL 경로)를 물어봅니다. "식당(`/api`)으로 가실 건가요, 아니면 객실(`/web`)로 가실 건가요?" 확인 후, 호텔 내부의 정확한 엘리베이터(Service)로 트래픽을 안내해 주는 문지기 역할을 합니다.

## 2. 핵심 설명
* **Ingress Controller 필수:** Ingress 자체는 규칙(Rule)을 적어둔 문서일 뿐입니다. 이 문서를 읽고 실제로 트래픽을 분배해 줄 **Ingress Controller(예: Nginx, AWS ALB Controller 등)**가 클러스터에 띄워져 있어야만 동작합니다.
* **단일 IP 호스팅:** 여러 개의 애플리케이션 서비스를 외부로 노출할 때, 서비스마다 로드밸런서(Type: LoadBalancer)를 생성하면 클라우드 비용이 크게 발생합니다. Ingress를 사용하면 단 하나의 로드밸런서 IP로 여러 도메인과 경로를 분기 처리하여 비용을 절감할 수 있습니다.
* **SSL/TLS 종료:** 개별 파드마다 인증서를 세팅할 필요 없이, Ingress 단에 인증서를 적용(TLS Secret)하여 트래픽 암호화를 한 번에 처리합니다.

## 3. YAML 적용 예시 (경로 기반 라우팅)
하나의 도메인(`example.com`)으로 들어오는 트래픽을 경로에 따라 서로 다른 서비스로 분배하는 Ingress 예시입니다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-ingress
  annotations:
    # Nginx 인그레스 컨트롤러 사용 명시
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: example.com
    http:
      paths:
      # /api 로 시작하는 요청은 backend-service로 전달
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
      # 그 외의 모든 요청(/)은 frontend-service로 전달
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

## 4. 트러블 슈팅
* **외부에서 도메인 접속 시 `502 Bad Gateway`가 발생함:**
  * Ingress가 트래픽을 뒷단 서비스(Service)로 넘기려 했으나, 연결된 파드가 없거나 파드가 포트를 닫고 있을 때 발생합니다. 
  * `kubectl get endpoints <서비스명>`을 쳐서 IP 주소가 잘 연결되어 있는지 확인하고, 파드가 정의된 포트(`targetPort`)로 정상 구동 중인지 로그를 점검하세요.