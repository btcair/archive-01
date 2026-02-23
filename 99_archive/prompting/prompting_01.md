## 🏆 최적화된 프롬프트를 위한 5대 요소 (CRISPE 프레임워크)

프롬프트를 작성하실 때 다음 5가지 요소를 블록 조립하듯 포함해 주시면 답변의 품질이 극적으로 상승합니다.

- **1. 역할 및 배경 (Context & Role):** AI에게 구체적인 페르소나와 현재 상황을 부여하세요. (예: "너는 15년 차 AWS 클라우드 아키텍트야. 현재 우리는 레거시 VM 환경에서 EKS로 마이그레이션을 준비 중이야.")
    
- **2. 명확한 목표 (Task):** 두리뭉실한 질문 대신 정확한 행동을 요구하세요. (예: "EKS 마이그레이션 전략을 알려줘" $\rightarrow$ "EKS 마이그레이션 시나리오 3가지를 비교 분석해 줘.")
    
- **3. 출력 형식 (Format):** 결과물의 형태를 구체적으로 지정하세요. 표, 마크다운, 코드 블록, 블릿 포인트 등을 명시하면 가독성이 훨씬 좋아집니다.
    
- **4. 제약 조건 (Constraints):** 분량, 어조, 혹은 '절대 하면 안 되는 것'을 정해주세요. (예: "개념 설명은 3줄 이내로 제한하고, 실무적인 트러블슈팅 사례를 위주로 작성해 줘. 전문 용어는 한글과 영어를 병기해 줘.")
    
- **5. 예시 제공 (Examples / Few-Shot):** 원하시는 결과물의 예시나 템플릿을 함께 주시면 AI가 사용자의 의도를 100% 파악합니다.

---

## 🚀 고도화를 위한 심화 프롬프팅 기법

단순한 지시를 넘어, AI의 논리력과 추론 능력을 극대화하는 방법입니다.

- **단계별 추론 요구 (Chain of Thought):** 복잡한 문제나 아키텍처를 설계할 때 **"결론을 바로 내지 말고, 논리적으로 단계별로 생각해서 과정을 설명해 줘"**라고 덧붙이세요. AI가 스스로 논리를 검증하며 답변의 오류가 크게 줄어듭니다.
    
- **역질문 요구 (Reverse Prompting):** 최적의 답변을 내기 위해 AI가 정보가 부족할 때가 있습니다. 프롬프트 마지막에 **"내 요구사항 중 명확하지 않거나 더 필요한 정보가 있다면, 네가 먼저 나에게 질문해 줘"**라고 적어보세요.
    
- **자기 반성 및 개선 요구 (Self-Correction):** 답변을 받은 후 **"방금 네가 작성한 답변에서 보안상 취약한 부분이나 논리적 비약이 있는지 스스로 비판하고 수정해 줘"**라고 요청하면 결과물이 한층 더 단단해집니다.

---

## 실전 마스터 템플릿 (복붙 사용)

[역할 부여]
당신은 글로벌 IT 기업의 시니어 DevOps Engineer 이자 테크니컬 라이터 입니다.

[상황 및 배경]
현재 우리 팀은 DevOps Engineer들을 위해 'AWS 지식 공유 및 기술 아카이빙 '에 대한 가이드 문서를 작성하려고 합니다.

[수행할 작업]
아래의 md 파일들을 작성해주세요


[참고 tree 구조]
C:.
├─addon
│      addon-coredns.md
│
├─docker
│      docker-architecture.md
│      docker-compose.md
│      docker-container-runtime.md
│      docker-dockerfile-best-practice.md
│
├─helm
├─objects
│      objects-k8s-configmap.md
│      objects-k8s-deployment.md
│      objects-k8s-hpa.md
│      objects-k8s-ingress.md
│      objects-k8s-pdb.md
│      objects-k8s-persistance-volume.md
│      objects-k8s-pod.md
│      objects-k8s-secret.md
│      objects-k8s-service.md
│      objects-k8s-storageclass.md
│
├─operator
│  │  operator-karpenter-ec2nodeclasses.md
│  │  operator-karpenter-nodeclamims.md
│  │  operator-karpenter-nodepools.md
│  │
│  └─service_mesh
│          service-mesh-istio-destination-rule.md
│          service-mesh-istio-envoy.md
│          service-mesh-istio-istio-ingressgateway.md
│          service-mesh-istio-istioctl.md
│          service-mesh-istio-istiod.md
│          service-mesh-istio-upgrade.md
│          service-mesh-istio-virtual-service.md
│
└─plugin
        plugin-cni-amazon-vpc-cni.md
        plugin-cni-calico.md
        plugin-cni-cilium.md


[제약 조건]
- 대상 독자는 주니어 DevOps Engineer 이므로 쉽게 이해할 수 있는 비유를 하나씩 포함해 줘.
- 각 주제마다 실제로 적용 가능한 YAML 예시 코드를 반드시 1개 이상 포함해 줘.
- 서론과 결론은 생략하고 바로 본론부터 시작해 줘.

[출력 형식]
- 마크다운(Markdown) 형식으로 작성해 줘.
- H1, H2 태그를 사용하여 목차 구조를 명확히 해 줘.