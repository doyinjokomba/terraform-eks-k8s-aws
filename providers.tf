#
# Create EKS Cluster - Providers Collection
#

provider "aws" {
  region  = var.aws_region
  profile = var.profile
}
