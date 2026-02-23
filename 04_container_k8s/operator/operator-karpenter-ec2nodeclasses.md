# Operator: Karpenter EC2NodeClass

## 1. 개요 및 비유
**EC2NodeClass**는 AWS 환경에서 Karpenter가 워커 노드(EC2)를 생성할 때 참조하는 **'AWS 종속적인 하드웨어 및 네트워크 설정 명세서'**입니다. (Karpenter v1beta1 이전의 `AWSNodeTemplate`이 이름이 바뀐 것입니다.)

💡 **비유하자면 '자동차 공장의 주문서(옵션 표)'와 같습니다.**
Karpenter(공장장)가 차(EC2)를 만들 때, "타이어는 무엇으로 할지(AMI), 색상은 무엇으로 칠할지(Tag), 어떤 창고에 주차할지(Subnet), 도난 방지 장치는 무엇을 달지(Security Group)"를 정확히 지정해둔 주문서입니다.

[Image of AWS Karpenter EC2NodeClass defining subnets, security groups, and AMIs for EC2 instance provisioning]

## 2. 핵심 설명
* **클라우드 종속성 분리:** Karpenter는 클라우드 중립적인 스케일러를 지향합니다. 따라서 공통 로직은 `NodePool`에 두고, AWS만의 고유한 설정(서브넷 ID, 보안 그룹, IAM 역할, EBS 볼륨 크기)은 `EC2NodeClass`로 완전히 분리했습니다.
* **동적 리소스 검색 (Discovery):** 서브넷이나 보안 그룹의 ID를 하드코딩하지 않고, `tags` (예: `karpenter.sh/discovery: my-cluster`)를 사용하여 AWS 환경에서 동적으로 검색(Discover)하여 매핑할 수 있습니다.
* **보안 및 스토리지:** 생성될 EC2의 루트 볼륨 사이즈나 타입(gp3), 그리고 컨테이너 런타임에 필요한 UserData(부트스트랩 스크립트)를 세밀하게 조작할 수 있습니다.

## 3. YAML 적용 예시 (AL2023 기반 EC2NodeClass)
특정 태그를 가진 서브넷과 보안 그룹을 찾아 EC2를 생성하고, 디스크 용량을 50GB로 늘리는 설정입니다.

```yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  # 생성될 EC2에 부여할 IAM 역할
  role: "KarpenterNodeRole-my-cluster"
  
  # 동적으로 서브넷과 보안 그룹을 찾기 위한 태그 필터
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "my-cluster"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "my-cluster"
  
  # Amazon Linux 2023 최신 AMI 자동 사용
  amiFamily: AL2023
  
  # 블록 스토리지(EBS) 설정
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
        encrypted: true
```

## 4. 트러블 슈팅
* **Karpenter가 파드를 스케줄링하지 못하고 에러 발생 (No subnets found):**
  * `subnetSelectorTerms`에 지정한 태그(`karpenter.sh/discovery: my-cluster`)가 실제 AWS VPC 서브넷 리소스에 부여되어 있지 않은 경우입니다. AWS 콘솔에서 서브넷 태그를 확인하고 추가해 주어야 합니다.
* **노드는 떴는데 `NotReady` 상태에서 멈춤:**
  * `EC2NodeClass`에 명시된 보안 그룹이 컨트롤 플레인(EKS API Server)이나 Core