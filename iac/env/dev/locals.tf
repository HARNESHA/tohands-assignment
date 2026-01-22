locals {

  Common_Tags = {
    Application = var.ApplicationName
    Environment = var.Environment
    CreatedWith = "Terraform"
    Managedby   = var.Managedby
  }
}
