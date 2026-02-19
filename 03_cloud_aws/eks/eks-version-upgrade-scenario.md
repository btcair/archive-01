
# EKS 클러스터 업그레이드 시나리오 (v1.32 -> v1.34)

## 1. 개요

본 문서는 EKS 1.32 버전을 1.34로 업그레이드하기 위한 단계별 절차와 모니터링 방안을 정의합니다. 특히 Karpenter와 Istio의 호환성 유지 및 데이터 평면의 무중단 전환에 초점을 맞춥니다.

## 2. 업그레이드 전제 조건 및 순서

EKS 마이너 버전 업그레이드는 순차적(1.32 -> 1.33 -> 1.34)으로 진행되어야 하며, 제어 평면 업데이트 전 관리 도구의 선행 업데이트가 필수적입니다.

### 작업 순서 요약

1. **사전 검증:** Deprecated API 사용 여부 및 할당량 점검.
    
2. **Karpenter 업그레이드:** v1.0.2에서 v1.1.x 이상으로 업데이트 및 CRD 동기화.
    
3. **Istio 업그레이드:** v1.26.2에서 v1.28까지 순차적 Canary 업그레이드.
    
4. **EKS Add-ons 업데이트:** VPC CNI, CoreDNS, Kube-proxy 버전 상향.
    
5. **EKS 제어 평면 업데이트:** 1.33 및 1.34 순차 진행.
    
6. **노드 마이그레이션:** Amazon Linux 2023(AL2023) 기반 노드 교체.
    

---

## 3. 단계별 실행 세부 사항

### Phase 1: Karpenter (v1.0.2 -> v1.1.x)

Karpenter는 1.34의 AL2023 및 향상된 Node API 지원을 위해 업데이트가 필요합니다.

- **CRD 업데이트:** Helm 업그레이드 전 수동으로 최신 CRD를 적용합니다.
    
- **EC2NodeClass 수정:** AL2 지원 중단에 대비하여 `amiFamily: AL2023` 설정을 준비합니다.
    
- **Drift 활성화:** 제어 평면 업그레이드 후 구버전 AMI 노드를 자동 교체하기 위해 `spec.disruption.consolidationPolicy: WhenUnderutilized` 및 Drift 감지 기능을 유지합니다.
    

### Phase 2: Istio (v1.26.2 -> v1.28)

Istio 1.26은 K8s 1.34를 지원하지 않으므로 1.28까지 두 단계를 올려야 합니다.

- **Revision 기반 업그레이드:** `istio.io/rev=1-28` 레이블을 사용하여 구버전(1.26)과 신버전(1.28) 사이드카를 병행 운영합니다.
    
- **Gateway API 검증:** Kubernetes 1.34에서 안정화된 Gateway API와의 호환성을 위해 `istioctl analyze` 명령어로 설정을 검토합니다.
    

### Phase 3: EKS 제어 평면 및 노드

- **순차 업데이트:** 1.32 -> 1.33 진행 후, 안정성을 확인하고 1.34로 진행합니다.
    
- **AL2023 전환:** EKS 1.34는 Amazon Linux 2를 공식 지원하지 않을 가능성이 높으므로, `NodePool` 설정을 통해 순차적으로 AL2023 노드로 워크로드를 이동(Eviction)시킵니다.
    

---

## 4. 모니터링 전략 (Prometheus & Grafana)

업그레이드 중 가시성 확보를 위해 다음 대시보드와 지표를 실시간으로 관측합니다.

### 4.1 Karpenter & Node 가용성

- **Node Claim 실패율:**
    
    코드 스니펫
    
    ```
    sum(rate(karpenter_node_claims_terminated_total{reason="launch_failed"}[5m]))
    ```
    
- **노드 준비 시간 (Join Latency):** 신규 AL2023 노드가 `Ready` 상태가 되는 시간을 측정하여 UserData 스크립트 오류를 감지합니다.
    

### 4.2 Istio & Traffic 안정성

- **XDS 동기화 상태:** 컨트롤 플레인 업그레이드 후 사이드카 설정 푸시 성공 여부.
    
    코드 스니펫
    
    ```
    sum(pilot_xds_push_errors)
    ```
    
- **서비스 에러율 (HTTP 5xx):**
    
    코드 스니펫
    
    ```
    sum(rate(istio_requests_total{response_code=~"5.*"}[5m])) by (destination_service)
    ```
    

### 4.3 K8s API 서버 부하

- **API 서버 지연 시간:** 1.34 업그레이드 중 컨트롤러들의 API 요청 처리 속도.
    
    코드 스니펫
    
    ```
    histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket[5m])) by (le, verb))
    ```
    

---

## 5. 트러블슈팅 및 롤백 포인트

- **Karpenter 롤백:** 노드 생성 실패 시 `amiFamily`를 이전 버전으로 복구하고 Helm 버전을 v1.0.2로 롤백합니다.
    
- **Istio 롤백:** Canary 방식이므로 네임스페이스 레이블을 구버전 Revision으로 원복하고 Pod을 재시작합니다.
    
- **EKS 제어 평면:** AWS 측면의 업데이트이므로 실패 시 AWS Support를 통한 개입이 필요할 수 있습니다. (업데이트 전 스냅샷 및 etcd 백업 권장)
    

---

## 6. 공식 참조 문서 (AWS Docs & Resources)

1. **AWS EKS 업데이트 가이드:**
    
    - [Updating an Amazon EKS cluster Kubernetes version](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
        
2. **Karpenter v1.0 마이그레이션:**
    
    - [Karpenter Graduation to v1](https://www.google.com/search?q=https://karpenter.sh/docs/upgrade-guide/)
        
3. **Amazon Linux 2023 on EKS:**
    
    - [Amazon Linux 2023 EKS optimized AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html)
        
4. **Istio 버전 호환성 매트릭스:**
    
    - [Istio Supported Releases](https://istio.io/latest/docs/releases/supported-releases/)
        
5. **EKS Best Practices Guide (Security/Upgrade):**
    
    - [EKS Best Practices - Upgrade](https://aws.github.io/aws-eks-best-practices/upgrades/)