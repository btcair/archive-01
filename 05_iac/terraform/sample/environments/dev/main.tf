module "vpc" {
  source   = "../../modules/vpc"
  env      = var.env
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "iam" {
  source = "../../modules/iam"
  env    = var.env
}

module "eks" {
  source           = "../../modules/eks"
  env              = var.env
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.subnet_ids
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn
  
  instance_type    = "t3.micro"
  desired_size     = 2
}