module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = var.ApplicationName
  cidr = var.VpcCidrBlock

  azs             = var.azs
  public_subnets  = var.public_subnets_cidrs
  private_subnets = var.private_subnets_cidrs

  create_vpc = true

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = true

  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  public_dedicated_network_acl  = false
  private_dedicated_network_acl = false

  tags = local.Common_Tags
}

module "eks" {
  source           = "s3::https://terrraform-module.s3.ap-south-1.amazonaws.com/eks/v1.0.1.zip"
  application_name = var.ApplicationName
  eks_version      = var.eks_version

  eks_addons = var.eks_addons

  master_subnet_ids     = module.vpc.public_subnets
  node_group_subnet_ids = module.vpc.public_subnets

  node_group_desired_capacity = var.node_group_desired_capacity
  node_group_max_capacity     = var.node_group_max_capacity
  node_group_min_capacity     = var.node_group_min_capacity

  node_instance_type       = var.node_instance_type
  node_group_capacity_type = var.node_group_capacity_type
  tags                     = local.Common_Tags
}

module "ecr" {
  for_each = {
    backend  = "${var.ApplicationName}-backend"
    frontend = "${var.ApplicationName}-frontend"
  }

  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.3"

  repository_name = each.value
  repository_image_tag_mutability = "MUTABLE"
  repository_read_write_access_arns = [
    "*"
  ]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 7 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.Common_Tags
}


module "rds" {
  source                       = "s3::https://terrraform-module.s3.ap-south-1.amazonaws.com/rds/v1.0.1.zip"
  db_instance_identifier       = "${var.ApplicationName}-${var.Environment}-db"
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  db_name                      = "${var.ApplicationName}${var.Environment}db"
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  parameter_group_name         = module.rds.db_parameter_group
  skip_final_snapshot          = var.skip_final_snapshot
  multi_az                     = var.multi_az
  performance_insights_enabled = var.performance_insights_enabled
  publicly_accessible          = var.publicly_accessible
  storage_type                 = var.storage_type
  db_subnet_group              = module.rds.db_subnet_group
  vpc_security_group_ids       = [module.db_security_group.security_group_id]
  backup_retention_period      = var.backup_retention_period
  db_parameter_group_name      = "${var.ApplicationName}-${var.Environment}-db-parameter-group"
  db_parameter_group_family    = var.db_parameter_group_family
  manage_master_user_password  = true
  master_username              = "${var.ApplicationName}_${var.Environment}_db"

  db_subnet_group_name = "${var.ApplicationName}-${var.Environment}-db-subnet-group"
  db_subnet_ids        = module.vpc.public_subnets
  db_subnet_group_tags = local.Common_Tags
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name        = "${var.ApplicationName}-${var.Environment}-db-sg"
  description = "Security group for PostgreSQL open to serve EKS Workload Traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.eks.node_group_security_group_id
    },
  ]
}