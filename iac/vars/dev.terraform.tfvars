AWSProfile = "default"
AWSRegion  = "ap-south-1"

ApplicationName = "assignment"
Environment     = "dev"
Managedby       = "team-devops@com.com"

VpcCidrBlock          = "10.0.0.0/16"
azs                   = ["ap-south-1a", "ap-south-1b"]
public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

eks_version              = "1.33"
eks_addons = {
  coredns    = ["v1.12.4-eksbuild.1"]
  kube-proxy = ["v1.33.5-eksbuild.2"]
  vpc-cni    = ["v1.20.4-eksbuild.1"]
  metrics-server = ["v0.8.0-eksbuild.6"]
}

node_group_desired_capacity = 2
node_group_max_capacity     = 2
node_group_min_capacity     = 1
node_group_capacity_type    = "SPOT"
node_instance_type          = ["t3.small"]

allocated_storage = 20
max_allocated_storage = 20
engine = "postgres"
engine_version = "16"
db_parameter_group_family = "postgres16"
instance_class = "db.t4g.micro"
skip_final_snapshot = true
multi_az = false
performance_insights_enabled = false
publicly_accessible = true
storage_type = "gp3"
backup_retention_period = 1