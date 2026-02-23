.
├── 00_meta
│   ├── index
│   │   └── tree.md
│   └── template
├── 01_development
│   ├── git
│   ├── python
│   │   └── python-sample.md
│   └── shell
│       └── shell-script-sample.md
├── 02_infra
│   ├── gpu
│   ├── network
│   │   ├── network-dns.md
│   │   ├── network-ipv4-ipv6.md
│   │   └── network-routing.md
│   └── os
│       ├── os-crontab.md
│       ├── os-kernel-parameter.md
│       ├── os-package-manager.md
│       ├── os-regular-expression-sample.md
│       └── os-systemd.md
├── 03_cloud_aws
│   ├── athena
│   │   └── athena-vpc-flow-log-query.md
│   ├── backup
│   │   └── backup-plan-delete.md
│   ├── cloudfront
│   ├── cloudtrail
│   ├── cloudwatch
│   │   ├── cloudwatch-custom-metric.md
│   │   └── cloudwatch-eks-fluentbit.md
│   ├── config
│   ├── dx
│   │   ├── dx-building-resiliency.md
│   │   ├── dx-location.md
│   │   ├── dx-monitoring.md
│   │   └── dx-packet-loss.md
│   ├── ec2
│   │   ├── ec2-al2-al2023.md
│   │   ├── ec2-ami.md
│   │   ├── ec2-autoscaling-stop-start.md
│   │   ├── ec2-dedicated-instance.md
│   │   ├── ec2-ebs-backup.md
│   │   ├── ec2-finding-instance-types.md
│   │   ├── ec2-gpu-telemetry-capturing.md
│   │   ├── ec2-os-migration.md
│   │   ├── ec2-physical-host-change.md
│   │   └── ec2-savings-plan.md
│   ├── ecr
│   │   ├── ecr-image-encryption.md
│   │   ├── ecr-image-mutable-immutable.md
│   │   ├── ecr-private-repository-create.md
│   │   └── ecr-public-registries.md
│   ├── efs
│   │   └── efs-automatic-backup.md
│   ├── eks
│   │   ├── eks-aws-load-balancer-controller.md
│   │   ├── eks-fargate.md
│   │   ├── eks-ingress-nginx-controller.md
│   │   ├── eks-ingress-nginx-retirement.md
│   │   ├── eks-karpenter-upgrade.md
│   │   ├── eks-launch-template.md
│   │   ├── eks-node-termination.md
│   │   ├── eks-nodeadm.md
│   │   ├── eks-self-managed-and-node-group.md
│   │   ├── eks-version-upgrade-scenario.md
│   │   ├── eks-version-upgrade.md
│   │   └── eks-vm-migration.md
│   ├── elasticache
│   │   └── elasticache-version-upgrade.md
│   ├── elb
│   ├── eventbridge
│   ├── lambda
│   │   └── lambda-sample-code.md
│   ├── opensearch
│   ├── route53
│   │   └── route53-vpc-resolver.md
│   ├── s3
│   │   └── s3-lifecycle-security.md
│   ├── service_quotas
│   │   └── service-quotas-request.md
│   └── vpc
│       ├── vpc-design-best-practice.md
│       ├── vpc-flog-log.md
│       ├── vpc-nacl.md
│       ├── vpc-nat-gateway.md
│       └── vpc-transit-gateway.md
├── 04_container_k8s
│   ├── addon
│   │   └── addon-coredns.md
│   ├── docker
│   │   ├── docker-architecture.md
│   │   ├── docker-compose.md
│   │   ├── docker-container-runtime.md
│   │   └── docker-dockerfile-best-practice.md
│   ├── helm
│   ├── objects
│   │   ├── objects-k8s-configmap.md
│   │   ├── objects-k8s-deployment.md
│   │   ├── objects-k8s-hpa.md
│   │   ├── objects-k8s-ingress.md
│   │   ├── objects-k8s-pdb.md
│   │   ├── objects-k8s-persistance-volume.md
│   │   ├── objects-k8s-pod.md
│   │   ├── objects-k8s-secret.md
│   │   ├── objects-k8s-service.md
│   │   └── objects-k8s-storageclass.md
│   ├── operator
│   │   ├── operator-karpenter-ec2nodeclasses.md
│   │   ├── operator-karpenter-nodeclamims.md
│   │   ├── operator-karpenter-nodepools.md
│   │   └── service_mesh
│   │       ├── service-mesh-istio-destination-rule.md
│   │       ├── service-mesh-istio-envoy.md
│   │       ├── service-mesh-istio-istio-ingressgateway.md
│   │       ├── service-mesh-istio-istioctl.md
│   │       ├── service-mesh-istio-istiod.md
│   │       ├── service-mesh-istio-upgrade.md
│   │       └── service-mesh-istio-virtual-service.md
│   └── plugin
│       ├── plugin-cni-amazon-vpc-cni.md
│       ├── plugin-cni-calico.md
│       └── plugin-cni-cilium.md
├── 05_iac
│   └── terraform
│       ├── best_practice
│       │   ├── best-practice-backend-s3-dynamodb.md
│       │   └── best-practice-state-isolation.md
│       ├── module
│       │   ├── module-statement-management.md
│       │   └── module-versioning.md
│       └── sample
│           ├── environments
│           │   ├── main.tf.md
│           │   ├── outputs.tf.md
│           │   └── variables.tf.md
│           └── module
│               ├── ec2
│               ├── main.tf.md
│               └── vpc
├── 06_observability
│   ├── grafana
│   │   ├── grafana-dashboard-as-code.md
│   │   └── grafana-panel-promql.md
│   ├── open_telemetry
│   ├── prometheus
│   │   ├── prometheus-alert-manger-design.md
│   │   ├── prometheus-exporter-third-party.md
│   │   └── prometheus-function.md
│   └── victoria_metrics
├── 07_business_domain
│   ├── distribution_e_commerce
│   │   ├── e-commerse-oliveyoung-observility.md
│   │   ├── inventory-consistency.md
│   │   └── payment-gateway-integration.md
│   ├── finance_fintech
│   │   ├── crypto-exchange-bithumb-aws-service-endpoint.md
│   │   ├── regulatory-compliance-guide.md
│   │   └── zero-trust-architecture.md
│   ├── gaming
│   └── it_service
├── 90_reference
│   ├── blogs.md
│   ├── docs.md
│   └── reference.md
└── 99_archive
    └── prompting
        └── prompting_01.md

63 directories, 107 files
