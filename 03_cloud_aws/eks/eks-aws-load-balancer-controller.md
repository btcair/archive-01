# EKS AWS Load Balancer Controller

## 1. 개요
**AWS Load Balancer Controller (LBC)**는 EKS 클러스터 내부의 쿠버네티스 트래픽 라우팅 리소스(Ingress, Service)를 관리하여, 실제 AWS의 **ALB(Application Load Balancer)** 및 **NLB(Network Load Balancer)**를 자동으로 프로비저닝하는 공식 컨트롤러입니다.

## 2. 설명
* **동작 방식:**
  * K8s `Ingress` 리소스 생성 $\rightarrow$ AWS **ALB** 자동 생성 (L7 라우팅).
  * K8s `Service (Type=LoadBalancer)` 리소스 생성 $\rightarrow$ AWS **NLB** 자동 생성 (L4 라우팅).
* **트래픽 모드:**
  * **Instance Mode:** 트래픽이 로드밸런서 $\rightarrow$ 워커 노드(EC2)의 NodePort $\rightarrow$ Kube-Proxy $\rightarrow$ Pod 순으로 전달됩니다.
  * **IP Mode (권장):** AWS VPC CNI와 결합하여, 로드밸런서가 워커 노드를 거치지 않고 VPC 내의 **Pod IP로 직접 트래픽을 꽂아주는** 방식입니다. (네트워크 홉 감소로 성능 향상)

[Image of AWS Load Balancer Controller routing traffic directly to Pod IPs in EKS]

## 3. 참조 및 관련된 파일
* [[eks-ingress-nginx-controller]]
* [[eks-fargate]] (Fargate는 IP mode만 지원함)

## 4. 트러블 슈팅
* **Ingress를 만들었는데 ALB가 생성되지 않음:**
  * **Subnet 태그 누락:** 로드밸런서가 배치될 VPC 서브넷에 필수 태그가 있는지 확인하세요.
    * 퍼블릭 서브넷: `kubernetes.io/role/elb = 1`
    * 프라이빗 서브넷: `kubernetes.io/role/internal-elb = 1`
  * **IRSA 권한 부족:** LBC 파드에 연결된 ServiceAccount(IAM 역할)에 최신 AWS LoadBalancer Controller IAM 정책이 매핑되어 있는지 확인합니다.
* **대상 그룹(Target Group)이 Unhealthy 상태인 경우:**
  * 보안 그룹(Security Group) 문제로 로드밸런서가 워커 노드나 파드의 포트로 헬스 체크(Health Check)를 통과하지 못하는 경우입니다.

## 5. 참고자료 또는 링크
* [AWS 공식 문서 - AWS Load Balancer Controller 설치 및 구성](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)


ingress-nginx를 사용하지 못한다면 aws load balancer controller 도입을 검토해야함

- [참고] aws load balancer controller 참고자료
https://aws.amazon.com/ko/blogs/containers/exposing-kubernetes-applications-part-2-aws-load-balancer-controller/