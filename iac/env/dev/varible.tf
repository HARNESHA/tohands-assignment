variable "AWSProfile" {
  description = "The AWS CLI profile to use."
  type        = string
  default     = ""
}
variable "AWSRegion" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}
variable "ApplicationName" {
  description = "The name of the application."
  type        = string
  default     = "MyApp"
}
variable "Environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"
}
variable "Managedby" {
  description = "The entity managing the infrastructure."
  type        = string
  default     = "team-devops@gmail.com"
}
variable "VpcCidrBlock" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}
variable "azs" {
  description = "List of availability zones."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "private_subnets_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}
variable "eks_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.27"
}
variable "node_group_desired_capacity" {
  description = "Desired number of worker nodes in the EKS node group."
  type        = number
  default     = 2
}
variable "node_group_max_capacity" {
  description = "Maximum number of worker nodes in the EKS node group."
  type        = number
  default     = 3
}
variable "node_group_min_capacity" {
  description = "Minimum number of worker nodes in the EKS node group."
  type        = number
  default     = 1
}
variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}
variable "node_group_capacity_type" {
  description = "The capacity type for the EKS node group (e.g., ON_DEMAND, SPOT)."
  type        = string
  default     = "SPOT"
}
variable "eks_addons" {
  description = "EKS addons with versions as a set"
  type        = map(set(string))
}
variable "allocated_storage" {
  type        = number
  default     = 0
  description = "allocates dtorage for rds instance"
}
variable "max_allocated_storage" {
  type        = number
  default     = 0
  description = "allocates dtorage for rds instance"
}
variable "engine" {
  type        = string
  default     = ""
  description = "describe engine name for database"
}
variable "engine_version" {
  type        = number
  default     = 0
  description = "describe db engine version"
}
variable "instance_class" {
  type        = string
  default     = ""
  description = "describe db instance class"
}
variable "skip_final_snapshot" {
  type        = bool
  description = "set final snapshot details"
}
variable "multi_az" {
  type        = bool
  default     = false
  description = "set multiaz setup for db instance"
}
variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "set performance_insights for db instance"
}
variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "set publicly_accessible for db instance"
}
variable "storage_type" {
  type        = string
  default     = ""
  description = "set storage type for db instance"
}
variable "backup_retention_period" {
  type        = number
  default     = 0
  description = "backup retentation period for db instance in days"
}
variable "db_parameter_group_family" {
  type        = string
  description = "db parameter group for instance"
}