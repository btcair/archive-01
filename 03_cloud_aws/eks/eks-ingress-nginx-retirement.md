# EKS Ingress NGINX Retirement

## 1. 개요
EKS 클러스터 내에서 운영 중인 구버전 **NGINX Ingress Controller의 지원 종료(Retirement/EOL) 및 쿠버네티스 API 버전 마이그레이션**에 대비하기 위한 업그레이드 가이드입니다.

## 2. 설명
* **API 버전 변경 (v1beta1 $\rightarrow$ v1):** 쿠버네티스 1.22 버전부터 기존의 `networking.k8s.io/v1beta1` Ingress API가 완전히 제거되었습니다. 따라서 EKS 클러스터를 업그레이드하기 전에 반드시 Ingress 리소스 매니페스트를 `v1` 스펙에 맞게 수정해야 합니다. (예: `serviceName` $\rightarrow$ `service.name`)
* **Controller 호환성:** 쿠버네티스 버전에 따라 지원되는 NGINX Controller의 버전이 정해져 있습니다. (예: K8s 1.25+ 환경에서는 NGINX Controller v1.4.0 이상이 필수입니다.)
* **보안 취약점 (CVE) 대응:** NGINX Controller 내부에 포함된 Lua 스크립트 엔진 등에서 정기적으로 취약점이 보고되므로 주기적인 Helm 차트 업그레이드가 필수적입니다.

## 3. 참조 및 관련된 파일
* [[eks-ingress-nginx-controller]]
* [[eks-version-upgrade-scenario]] (클러스터 업그레이드 전 사전 점검 요소)

## 4. 트러블 슈팅
* **업그레이드 후 설정(ConfigMap) 포맷 변경으로 인한 장애:**
  * 메이저 버전 업그레이드 시 NGINX의 기본 로직이나 ConfigMap 문법이 변경되어, 기존에 잘 작동하던 어노테이션(Rewrite, SSL 등)이 무시되거나 에러를 뱉을 수 있습니다. 반드시 스테이징 환경에서 Helm Upgrade 테스트를 거쳐야 합니다.
* **파드 재생성 과정에서의 다운타임 (Downtime):**
  * NGINX Controller 파드가 롤링 업데이트될 때, 기존에 맺혀있던 클라이언트 세션이 강제로 끊어질 수 있습니다. Deployment 스펙에 `lifecycle: preStop` 훅을 설정하여 파드가 종료되기 전 트래픽을 우아하게 차단(Graceful shutdown)하도록 대기 시간(`sleep`)을 주어야 합니다.

## 5. 참고자료 또는 링크
* [NGINX Ingress Controller 버전 지원 매트릭스](https://github.com/kubernetes/ingress-nginx#supported-versions-table)


ingress-nginx 는 더 이상 지원하지 않기 때문에 
ingress nginx -> aws load balancer controller로 전환을 검토해야함

- [참고] ingress-nginx 서비스 종료
https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/