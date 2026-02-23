
# Objects: K8s ResourceQuota & LimitRange

## 1. 개요 및 비유
**ResourceQuota(리소스 쿼터)**와 **LimitRange(리밋 레인지)**는 다수의 팀이 하나의 쿠버네티스 클러스터를 공유(Multi-tenancy)할 때, 특정 팀이 자원(CPU, 메모리)을 독점하지 못하도록 네임스페이스 단위로 제한을 거는 거버넌스 오브젝트입니다.

💡 **비유하자면 '팀별 법인카드 한도(ResourceQuota)'와 '1회 결제 한도(LimitRange)'와 같습니다.**
* **ResourceQuota:** "개발팀(Namespace)은 한 달에 총 1,000만 원(CPU 10코어, RAM 20GB)까지만 쓸 수 있다"고 정해둔 **팀 전체 예산**입니다.
* **LimitRange:** "팀원 한 명(파드 1개)이 한 끼 식사에 10만 원(CPU 1코어) 이상 결제할 수 없으며, 카드 결제 시 금액을 말하지 않으면 기본 1만 원(Default Request)으로 자동 처리한다"는 **개별 사용 가이드라인**입니다.

## 2. 핵심 설명
* **ResourceQuota (네임스페이스 전체 제한):**
  * 네임스페이스 내에서 생성되는 모든 파드들의 CPU/Memory Requests(요청량)와 Limits(제한량)의 총합을 제한합니다.
  * 하드웨어 자원뿐만 아니라 "이 네임스페이스에는 ConfigMap을 최대 10개, LoadBalancer 서비스를 최대 2개까지만 만들 수 있다"는 식의 **오브젝트 개수 제한**도 가능합니다.
* **LimitRange (파드/컨테이너 개별 제한):**
  * 주니어 개발자가 파드를 배포할 때 `resources` (CPU/Memory) 스펙을 적는 것을 깜빡하더라도, LimitRange가 **기본값(Default)**을 자동으로 찔러 넣어주어 클러스터의 안정성을 보호합니다.
  * 파드 하나가 무식하게 큰 자원을 요구하는 것을 차단(Max Limit)합니다.

## 3. YAML 적용 예시 (팀 예산 및 기본값 설정)
특정 네임스페이스에 전체 자원 한도를 걸고, 파드를 띄울 때 기본 메모리를 주입하는 세트 예시입니다.

```yaml
# 1. 네임스페이스 전체 예산 (ResourceQuota)
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a
spec:
  hard:
    requests.cpu: "4" # 팀 전체 CPU 보장량 총합은 4코어까지만
    requests.memory: 8Gi
    limits.cpu: "8"   # 팀 전체 CPU 최대 허용량 총합은 8코어까지만
    limits.memory: 16Gi
    pods: "10"        # 파드는 최대 10개까지만 생성 가능

---
# 2. 개별 파드의 기본값/최대값 제한 (LimitRange)
apiVersion: v1
kind: LimitRange
metadata:
  name: team-a-limits
  namespace: team-a
spec:
  limits:
  - type: Container
    default:
      cpu: "500m" # 개발자가 limit을 안 적으면 0.5 코어로 자동 설정
      memory: "512Mi"
    defaultRequest:
      cpu: "250m" # 개발자가 request를 안 적으면 0.25 코어로 자동 설정
      memory: "256Mi"
    max:
      cpu: "2"    # 컨테이너 하나가 절대 2코어 이상을 가질 수 없음
```

## 4. 트러블 슈팅
* **파드 배포 시 `Forbidden: exceeded quota` 에러:**
  * 배포하려는 파드의 리소스를 합치면 네임스페이스의 ResourceQuota 한도를 초과할 때 발생합니다. `kubectl describe quota -n <네임스페이스>` 명령어로 현재 `Used(사용량)`와 `Hard(제한량)`를 비교하여 어떤 자원이 부족한지 확인하세요.
* **`Forbidden: must specify limits.cpu` 에러:**
  * 네임스페이스에 ResourceQuota가 설정되어 있는데, 개발자가 파드 YAML에 `resources` 스펙을 아예 빼먹은 경우입니다. 쿠버네티스는 이 파드가 자원을 얼마나 쓸지 계산할 수 없으므로 배포를 거부합니다. LimitRange를 세팅하여 기본값을 자동으로 넣어주거나, 파드 스펙에 리소스 요구량을 명시하도록 가이드해야 합니다.