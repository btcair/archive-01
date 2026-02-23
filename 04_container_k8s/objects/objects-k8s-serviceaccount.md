
# Objects: K8s ServiceAccount

## 1. 개요 및 비유
**ServiceAccount(서비스어카운트)**는 파드(애플리케이션)가 쿠버네티스 API 서버나 외부 클라우드 서비스(AWS 등)에 접근할 때 자신을 증명하는 '신분증'입니다.

💡 **비유하자면 '사원증(ID 카드)'과 같습니다.**
회사(클러스터)에서 일하는 직원(사용자/관리자)은 지문이나 비밀번호로 로그인하지만, 프린터기나 무인 로봇(파드)은 로그인 창에 아이디를 칠 수 없습니다. 그래서 봇 전용 목걸이(ServiceAccount)를 걸어주고, "이 목걸이를 찬 로봇은 AWS S3 창고의 문을 열 수 있다(RoleBinding/IRSA)"라고 권한을 부여하는 것입니다.



## 2. 핵심 설명
* **파드 기본 할당:** 파드를 생성할 때 `serviceAccountName`을 명시하지 않으면, 해당 네임스페이스의 `default` 서비스어카운트가 자동으로 연결됩니다.
* **RBAC 연동:** 쿠버네티스 내부 자원(예: 다른 파드 목록 읽기)에 접근하려면 `Role` 또는 `ClusterRole`을 만든 뒤 `RoleBinding`을 통해 서비스어카운트에 연결해야 합니다.
* **AWS EKS의 꽃, IRSA:** AWS IAM 역할을 파드에 부여하는 **IAM Roles for Service Accounts (IRSA)** 기술의 핵심입니다. 서비스어카운트에 `eks.amazonaws.com/role-arn` 어노테이션을 달아주면, 해당 파드는 AWS S3나 DynamoDB를 제어할 수 있는 임시 자격 증명(토큰)을 발급받습니다.

## 3. YAML 적용 예시 (EKS IRSA 적용)
AWS S3 접근 권한(IAM Role)을 갖는 서비스어카운트를 만들고, 파드에 이 신분증을 걸어주는 예시입니다.

```yaml
# 1. 신분증(ServiceAccount) 발급 및 AWS IAM Role 연결
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-reader-sa
  namespace: default
  annotations:
    # 사전에 생성해둔 AWS IAM Role의 ARN을 매핑
    [eks.amazonaws.com/role-arn](https://eks.amazonaws.com/role-arn): arn:aws:iam::123456789012:role/my-s3-reader-role

---
# 2. 파드에 신분증 걸어주기
apiVersion: v1
kind: Pod
metadata:
  name: s3-app-pod
spec:
  serviceAccountName: s3-reader-sa # 위에서 만든 신분증 지정
  containers:
  - name: my-app
    image: my-app:latest
    # 이 컨테이너 안에서 AWS SDK(boto3 등)를 쓰면 자동으로 S3 권한을 얻음
```

## 4. 트러블 슈팅
* **파드에서 AWS 자원에 접근 시 `AccessDenied` 에러 발생:**
  * 가장 빈번한 EKS 트러블슈팅입니다. 다음 3가지를 순서대로 확인해야 합니다.
    1. 파드 스펙에 `serviceAccountName`이 정확히 오타 없이 들어갔는지?
    2. ServiceAccount 어노테이션에 적힌 AWS IAM Role ARN이 정확한지?
    3. AWS IAM Role의 **'신뢰 관계(Trust Policy)'**에 해당 EKS 클러스터의 OIDC 자격 증명 제공자가 정확히 등록되어 있고, 대상(Subject)이 이 서비스어카운트를 가리키고 있는지?