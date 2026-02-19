
# Ingress (인그레스)

### 개념 요약
**Ingress**는 클러스터 외부에서 내부 서비스로 비치는 HTTP와 HTTPS 경로를 관리하는 API 오브젝트입니다. 트래픽 라우팅, 로드 밸런싱, SSL/TLS 종료 등을 설정할 수 있습니다.

---

### 핵심 메커니즘
* **L7 로드 밸런싱:** 호스트(Domain)나 경로(Path)를 기반으로 트래픽을 서로 다른 서비스로 배분합니다.
* **SSL/TLS 종료:** 각 서비스마다 설정할 필요 없이 Ingress 단에서 보안 인증서를 일괄 관리합니다.
* **Ingress Controller:** Ingress 리소스만으로는 작동하지 않으며, 실제 규칙을 수행할 컨트롤러(Nginx, Kong, Traefik 등)가 필요합니다.

---

### 설정 예시 (YAML)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test-service
            port:
              number: 80
```

### 참고 자료

- [Kubernetes Docs - Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)