# Configure the AWS provider block. This tells Terraform which cloud provider to use and 
# how to authenticate (access key, secret key, and region) when provisioning resources.
# Note: Hardcoding credentials is not recommended for production use. Instead, use environment variables
# or IAM roles to manage credentials securely.
provider "aws" {
  access_key = var.access_key       # Replace with your AWS access key ID (leave empty if using IAM roles or env vars)
  secret_key = var.secret_key       # Replace with your AWS secret access key (leave empty if using IAM roles or env vars)
  region     = var.region           # Specify the AWS region where resources will be created (e.g., us-east-1, us-west-2)
}

module "VPC" {
  source = "./VPC"
}

module "EC2"{
  source = "./EC2"
  vpc_id = module.VPC.vpc_id
  private_subnet_id = module.VPC.private_subnet_id
  public_subnet_id = module.VPC.public_subnet_id
 
}

