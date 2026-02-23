
이 문서는 EKS 클러스터 운영에 필요한 주요 오픈소스 및 가용성 높은 컴포넌트들의 공식 퍼블릭 레지스트리 주소를 정리합니다. 프라이빗 ECR로 미러링 시 소스(Source) 주소로 사용합니다.

## 1. Docker Hub (docker.io)
가장 보편적인 레지스트리이지만, 최근 Rate Limit 이슈로 인해 프라이빗 미러링이 필수적인 곳들입니다.

| **컴포넌트**            | **이미지 경로 (Source)**                          | **비고**             |
| ------------------- | -------------------------------------------- | ------------------ |
| **Istio**           | `istio/pilot`, `istio/proxyv2`               | 서비스 메시 컨트롤러 및 사이드카 |
| **Grafana**         | `grafana/grafana`                            | 모니터링 시각화           |
| **Jenkins**         | `jenkins/jenkins`, `jenkins/inbound-agent`   | CI 서버 및 빌드 에이전트    |
| **VictoriaMetrics** | `victoriametrics/victoria-metrics`           | 고성능 시계열 DB         |
| **Kong Gateway**    | `kong`, `kong/kubernetes-ingress-controller` | API 게이트웨이 및 컨트롤러   |
| **Jaeger**          | `jaegertracing/all-in-one`                   | 분산 트레이싱            |
| **Falco**           | `falcosecurity/falco`                        | 런타임 보안 탐지          |
| **Redis / Nginx**   | `library/redis`, `library/nginx`             | 베이스 인프라 이미지        |

## 2. Quay.io (RedHat)
쿠버네티스 생태계의 주요 프로젝트들이 Docker Hub의 대안으로 많이 사용하는 곳입니다.

| **컴포넌트**         | **이미지 경로 (Source)**                                 | **비고**                       |
| ---------------- | --------------------------------------------------- | ---------------------------- |
| **Prometheus**   | `prometheus/prometheus`, `prometheus/node-exporter` | 메트릭 수집 및 노드 엑스포터             |
| **Cert-manager** | `jetstack/cert-manager-controller`                  | 인증서 자동 관리                    |
| **External DNS** | `kubernetes-sigs/external-dns`                      | DNS 레코드 자동 동기화               |
| **Keycloak**     | `keycloak/keycloak`                                 | Identity & Access Management |


## 3. Amazon Public ECR (public.ecr.aws)
EKS와 직접적으로 연관된 AWS 관리형 컴포넌트들이 주로 위치합니다. AWS 환경에서 가장 신뢰할 수 있는 소스입니다.

| 컴포넌트 | 공식 이미지 경로 | 비고 |
| :--- | :--- | :--- |
| **Karpenter** | `public.ecr.aws/karpenter/controller` | 노드 오토스케일러 |
| **Fluent Bit** | `public.ecr.aws/aws-observability/aws-for-fluent-bit` | AWS 최적화 로그 수집기 |
| **CW Agent** | `public.ecr.aws/cloudwatch-agent/cloudwatch-agent` | CloudWatch 메트릭 에이전트 |
| **EFS Driver** | `public.ecr.aws/efs-csi-driver/amazon-efs-csi-driver` | EFS 스토리지 드라이버 |
| **Kubecost** | `public.ecr.aws/kubecost/cost-model` | EKS 비용 분석 도구 |
| **AWS Load Balancer** | `public.ecr.aws/eks/aws-load-balancer-controller` | LBC 컨트롤러 |

## 4. GitHub Container Registry (ghcr.io)
최근 많은 오픈소스 프로젝트들이 GitHub Action과의 연동을 위해 이동하고 있는 곳입니다.

|**컴포넌트**|**이미지 경로 (Source)**|**비고**|
|---|---|---|
|**Argo 프로젝트**|`argoproj/argocd`, `argoproj/rollouts`, `argo`|GitOps 및 워크플로우 도구|
|**KEDA**|`kedacore/keda`|이벤트 기반 오토스케일러|
|**OpenTelemetry**|`open-telemetry/opentelemetry-collector-...`|OTel 컬렉터 (AL2023 대응 필수)|
|**Cilium**|`cilium/cilium`|차세대 CNI 및 보안|
|**Kyverno**|`kyverno/kyverno`|K8s 정책 관리 엔진|
|**Trivy**|`aquasecurity/trivy`|이미지 및 파일 취약점 스캐너|
|**Flux CD**|`fluxcd/source-controller`|GitOps 배포 도구

## 5. Google Container Registry (gcr.io / k8s.gcr.io)
쿠버네티스 핵심 컴포넌트들이 위치한 곳입니다. (최근 `registry.k8s.io`로 이전 중)

| **컴포넌트**     | **이미지 경로 (Source)**                              | **비고**                  |
| ------------ | ------------------------------------------------ | ----------------------- |
| **K8s Core** | `kube-apiserver`, `kube-proxy`, `kube-scheduler` | EKS Managed 노드에서 자동 사용  |
| **Pause**    | `pause`                                          | 모든 Pod의 네트워크 네임스페이스 유지용 |
| **Coredns**  | `coredns/coredns`                                | 클러스터 내부 DNS             |

---
