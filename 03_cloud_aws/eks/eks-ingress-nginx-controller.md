# EKS Ingress NGINX Controller

## 1. 개요
EKS 환경에서 AWS ALB 대신 오픈소스 기반의 **NGINX Ingress Controller**를 배포하여 클러스터로 들어오는 외부 HTTP/HTTPS 트래픽의 L7 라우팅, SSL 종료, Rewrite 등의 기능을 수행하는 구성입니다.

## 2. 설명
* **아키텍처 구조:** 주로 클러스터 앞단에 **AWS NLB(L4)**를 두고, 이 NLB가 모든 트래픽을 클러스터 내부의 NGINX Controller 파드(데몬셋 또는 디플로이먼트)로 전달합니다. NGINX가 헤더(URL 경로, 도메인)를 분석해 적절한 애플리케이션 파드로 다시 트래픽을 뿌려줍니다.
* **장점:** AWS ALB는 규칙이 많아질수록 비용이 증가하고 기능적 제약(정규식 제어 등)이 있지만, NGINX는 쿠버네티스 표준에 가까우며 풍부한 어노테이션(Annotation) 설정과 서드파티 플러그인(ModSecurity 등)을 제공합니다.



## 3. 참조 및 관련된 파일
* [[eks-aws-load-balancer-controller]]
* [[eks-ingress-nginx-retirement]]
* [[vpc-nat-gateway]]

## 4. 트러블 슈팅
* **클라이언트의 실제 IP(Real IP)를 애플리케이션 파드에서 알 수 없음:**
  * 트래픽이 NLB와 NGINX를 거치면서 출발지 IP가 NGINX의 IP나 워커 노드의 IP로 변환(SNAT)되는 현상입니다.
  * **해결책 1:** NGINX 서비스의 `externalTrafficPolicy`를 `Local`로 설정합니다.
  * **해결책 2 (권장):** AWS NLB의 타겟 그룹 속성에서 **Proxy Protocol v2**를 활성화하고, NGINX ConfigMap에도 `use-proxy-protocol: "true"`를 추가하여 실제 클라이언트 IP를 전달받도록 구성합니다.
* **대용량 파일 업로드 시 413 Request Entity Too Large 에러:**
  * NGINX Ingress의 기본 Body Size 제한(1MB)에 걸린 것입니다. Ingress 어노테이션에 `nginx.ingress.kubernetes.io/proxy-body-size: 50m` 과 같이 용량을 늘려주어야 합니다.

## 5. 참고자료 또는 링크
* [Kubernetes 공식 문서 - Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/)


- [참고] aws ingress nginx 참고자료
https://aws.amazon.com/ko/blogs/containers/exposing-kubernetes-applications-part-3-nginx-ingress-controller/