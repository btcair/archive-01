
# Objects: K8s RBAC (Role, ClusterRole, Bindings)

## 1. 개요 및 비유
**RBAC(Role-Based Access Control, 역할 기반 접근 제어)**는 쿠버네티스 클러스터 내에서 "누가(Subject), 어떤 자원(Resource)에, 무슨 행동(Verb)을 할 수 있는지"를 통제하는 보안의 핵심 시스템입니다. 이를 구성하는 리소스가 바로 **Role, ClusterRole, RoleBinding, ClusterRoleBinding**입니다.

💡 **비유하자면 '회사 사옥의 출입 통제 시스템'과 같습니다.**
* **Role (역할):** "3층(특정 Namespace)의 회의실 문을 열 수 있다"는 **권한 규칙**입니다.
* **ClusterRole (클러스터 역할):** "사옥 전체(모든 Namespace)의 모든 회의실과 기계실(Node 등 글로벌 자원) 문을 열 수 있다"는 **마스터 권한 규칙**입니다.
* **Binding (부여/결합):** 아무리 권한 규칙을 문서로 만들어 놔도, 누군가의 사원증에 그 규칙을 입력해 주지 않으면 소용이 없습니다. "이 권한 규칙(Role)을 신입사원 김철수(ServiceAccount)의 사원증에 입력해 준다"는 행위가 바로 **Binding**입니다.



## 2. 핵심 설명
* **네임스페이스 종속성:** * `Role`과 `RoleBinding`은 특정 네임스페이스(예: `dev`, `prod`) 안에서만 유효합니다.
  * `ClusterRole`과 `ClusterRoleBinding`은 네임스페이스를 따지지 않고 클러스터 전체 자원(예: Worker Node, PersistentVolume)이나 모든 네임스페이스에 걸쳐 권한을 줍니다.
* **주체 (Subject):** 권한을 받는 대상은 3가지입니다. 사용자(User), 그룹(Group), 그리고 파드가 사용하는 **서비스어카운트(ServiceAccount)**입니다.
* **허용(Allow) 원칙:** 쿠버네티스 RBAC는 기본적으로 '모두 거부(Deny All)' 상태이며, 명시적으로 허용한 규칙만 추가되는 방식입니다. '거부(Deny)' 규칙을 따로 만들 수는 없습니다.

## 3. YAML 적용 예시 (ClusterRole & RoleBinding 조합)
Prometheus 파드가 클러스터 전체의 파드 목록을 읽을(Read-only) 수 있도록 `ClusterRole`을 만들고, 이를 모니터링 네임스페이스의 서비스어카운트에 연결(`ClusterRoleBinding`)하는 예시입니다.

```yaml
# 1. 클러스터 전체 권한 규칙 (ClusterRole)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader-global
rules:
- apiGroups: [""] # 핵심 API 그룹
  resources: ["pods", "nodes"] # 파드와 노드 자원에 대해
  verbs: ["get", "watch", "list"] # 읽기 관련 행동만 허용

---
# 2. 권한 부여 (ClusterRoleBinding)
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-global-binding
subjects:
- kind: ServiceAccount
  name: prometheus-sa # 권한을 받을 서비스어카운트
  namespace: monitoring # 서비스어카운트가 위치한 네임스페이스
roleRef:
  kind: ClusterRole
  name: pod-reader-global # 위에서 만든 ClusterRole을 참조
  apiGroup: rbac.authorization.k8s.io
```

## 4. 트러블 슈팅
* **`User system:serviceaccount:default:my-app cannot list resource "pods"` 에러:**
  * 애플리케이션 파드가 쿠버네티스 API를 호출하려 했으나 권한이 거부된 상황입니다.
  * `my-app` 파드가 사용 중인 ServiceAccount에 적절한 RoleBinding이 연결되어 있는지, 그리고 참조하는 Role의 `verbs`에 `list` 권한이 명시되어 있는지 점검해야 합니다.
* **실수로 권한을 과도하게 부여 (Privilege Escalation):**
  * 주니어 엔지니어들이 권한 에러를 해결하기 귀찮아서 `ClusterRole`의 권한을 `resources: ["*"]`, `verbs: ["*"]` (모든 권한)로 열어버리는 치명적인 실수를 종종 합니다. 이는 파드가 해킹당했을 때 클러스터 전체가 장악되는 지름길이므로, 반드시 **최소 권한의 원칙(Least Privilege)**을 지켜야 합니다.