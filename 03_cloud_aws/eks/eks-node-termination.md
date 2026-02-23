# EKS Node Termination

## 1. 개요
EKS 클러스터 내의 워커 노드가 스케일 인(Scale-in), 스팟 인스턴스 중단, 혹은 물리적 장애로 인해 종료(Termination)될 때, **노드 위에서 돌고 있는 애플리케이션 파드들을 안전하게 다른 노드로 대피시키는(Graceful Shutdown)** 메커니즘입니다.

## 2. 설명
* **Cordon & Drain:**
  * **Cordon:** 해당 노드에 더 이상 새로운 파드가 스케줄링되지 않도록 차단(Unschedulable)합니다.
  * **Drain:** 해당 노드에서 실행 중인 파드들에게 종료 신호(SIGTERM)를 보내 안전하게 종료시키고, 다른 노드에 다시 생성되도록 유도합니다.
* **AWS Node Termination Handler (NTH):**
  * EC2 스팟 인스턴스는 회수되기 2분 전에 중단 경고(Interruption Notice)를 보냅니다.
  * NTH는 이 경고 이벤트를 EventBridge나 IMDS를 통해 감지하여, 노드가 강제 종료되기 전에 자동으로 API를 호출해 Cordon & Drain 프로세스를 실행합니다. (Karpenter를 사용 중이라면 NTH 기능이 내장되어 있어 별도 설치가 필요 없습니다.)



## 3. 참조 및 관련된 파일
* [[eks-karpenter-upgrade]]
* [[ec2-autoscaling-stop-start]]
* [[eks-self-managed-and-node-group]]

## 4. 트러블 슈팅
* **Drain 지연으로 인해 노드가 강제 종료되면서 502 에러 발생:**
  * 파드 내 애플리케이션이 `SIGTERM`을 받았을 때 진행 중인 작업을 마무리하는 로직(Graceful Shutdown)이 없거나 너무 길 경우 발생합니다. K8s 매니페스트의 `terminationGracePeriodSeconds`를 적절히 조절해야 합니다.
* **PDB (Pod Disruption Budget) 설정 충돌:**
  * "최소 2개의 파드는 항상 살려둬라(minAvailable: 2)"라는 PDB 정책이 걸려있는데 클러스터에 여유 자원이 없다면, Drain이 파드를 쫓아내지 못하고 계속 대기(Blocked)하게 됩니다. 결국 EC2 강제 종료 시점이 도래하여 다운타임이 발생합니다.

## 5. 참고자료 또는 링크
* [AWS Github - AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler)


- [참고]
https://github.com/aws/aws-node-termination-handler

- [참고]
https://docs.aws.amazon.com/ko_kr/autoscaling/ec2/userguide/lifecycle-hooks.html

- [참고]
https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/auto-get-logs.html