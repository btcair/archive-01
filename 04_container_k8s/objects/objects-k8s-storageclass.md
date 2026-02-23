# Objects: K8s StorageClass

## 1. 개요 및 비유
**StorageClass(스토리지클래스)**는 관리자가 일일이 영구 볼륨(PV)을 만들어두지 않아도, 사용자가 요청(PVC)할 때마다 클라우드 공급자의 디스크를 **동적으로 자동 생성(Dynamic Provisioning)**해 주는 템플릿입니다.

💡 **비유하자면 '자판기(StorageClass)'와 같습니다.**
과거에는 관리자가 미리 100GB짜리 USB(PV)를 10개씩 만들어 창고에 쌓아둬야 했습니다(정적 프로비저닝). 하지만 StorageClass라는 자판기를 설치해 두면, 개발자가 "가장 빠른 SSD 타입으로 50GB 주세요(PVC)"라고 동전을 넣는 순간, 자판기(AWS EBS CSI 드라이버)가 즉시 공장에 주문을 넣어 50GB짜리 디스크를 찍어내어 가져다줍니다.

## 2. 핵심 설명
* **Provisioner (프로비저너):** 실제로 스토리지를 만들어주는 주체입니다. EKS 환경에서는 `ebs.csi.aws.com` (AWS EBS용)이나 `efs.csi.aws.com` (AWS EFS용) 플러그인이 이 역할을 담당합니다.
* **Parameters (파라미터):** 디스크의 세부 스펙을 정의합니다. (예: 볼륨 타입 `gp3`, IOPS 속도, 암호화 여부 등)
* **효율성 극대화:** StorageClass를 사용하면 인프라 관리자가 스토리지 재고를 관리할 필요가 없어 클라우드 자원의 낭비를 막고 운영 리소스를 크게 절감할 수 있습니다.

## 3. YAML 적용 예시 (AWS EBS gp3 스토리지클래스)
AWS 환경에서 비용 효율적이고 성능이 좋은 `gp3` 타입의 EBS 볼륨을 자동으로 찍어내는 StorageClass 정의입니다.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true" # 기본 스토리지클래스로 지정
provisioner: ebs.csi.aws.com # AWS EBS CSI 드라이버가 작동
volumeBindingMode: WaitForFirstConsumer # 파드가 노드에 배치될 때까지 볼륨 생성을 지연(가용 영역 일치를 위해)
allowVolumeExpansion: true # 볼륨 크기 확장 허용 여부
parameters:
  type: gp3
  encrypted: "true" # 생성되는 볼륨 자동 암호화
```

## 4. 트러블 슈팅
* **PVC를 만들었는데 `waiting for first consumer` 메시지만 뜨고 볼륨이 안 생김:**
  * 에러가 아닙니다! `WaitForFirstConsumer` 옵션이 켜져 있으면, PVC만 만들었다고 해서 바로 디스크가 생기지 않습니다. **이 PVC를 사용하는 파드(Pod)가 실제로 특정 워커 노드에 스케줄링되어야만**, 그 노드가 위치한 가용 영역(AZ)에 맞춰서 EBS 볼륨을 생성하기 시작합니다.
* **EBS 볼륨 생성 자체가 실패하는 경우:**
  * EKS 클러스터에 AWS EBS CSI Driver 애드온이 설치되어 있지 않거나, 드라이버를 실행하는 파드(ServiceAccount)에 AWS EBS 생성/삭제를 위한 IAM 권한(Policy)이 부여되지 않은 경우입니다.