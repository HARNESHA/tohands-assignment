output "infra_details" {
  description = "Infra Creations Details"
  value = {
    # Networking
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets

    # # EKS
    # cluster_arn      = module.eks.cluster_arn
    # node_group_arn   = module.eks.node_group_arn
    # node_group_sg_id = module.eks.node_group_security_group_id

    # RDS
    rds_endpoint = module.rds.db_instance_address
    db_user      = module.rds.db_user
    db_name      = module.rds.db_name

    # ECR
    ecr_repositories = {
      for name, repo in module.ecr :
      name => repo.repository_url
    }
  }
}
