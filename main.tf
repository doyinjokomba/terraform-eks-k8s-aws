
#  EC2 Security Group to allow networking traffic with EKS cluster


terraform {
  cloud {
    organization = "DoyinJokoInc"
    workspaces {
      name = "Example-Workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

#  Create the IAM role. This ensures that the role has access to EKS service to manage other AWS services
resource "aws_iam_role" "eks-iam-role" {
  name = "doyindevops-eks-iam-role"

  path = "/"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

# Add these three policies
resource "aws_iam_role_policy_attachment" "doyin-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "doyin-cluster-AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-iam-role.name
}

resource "aws_iam_role_policy_attachment" "doyin-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-iam-role.name
}

# Add Security group and rule to allow workstation 
resource "aws_security_group" "doyinsg-cluster" {
  name        = "doyinterraform-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.doyintestprojvpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-doyintestprojvpc"
  }
}

#create the EKS cluster
resource "aws_eks_cluster" "doyindevops-eks" {
  name     = "doyindevops-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.doyinsg-cluster.id]
    subnet_ids         = aws_subnet.doyintestprojsn[*].id
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.doyin-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.doyin-cluster-AmazonEC2ContainerRegistryReadOnly-EKS,
    aws_iam_role_policy_attachment.doyin-cluster-AmazonEKSVPCResourceController,
  ]
}

#IAM role and policies creation for the EKS cluster except this time the policies that you attach will be for the EKS worker node policies
resource "aws_iam_role" "doyinworkernodes" {
  name = "doyineks-node-group2"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.doyinworkernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.doyinworkernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.doyinworkernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.doyinworkernodes.name
}

#just one worker node in the scaling_config configuration. In prod, follow best practices and use at least three worker nodes.
resource "aws_eks_node_group" "doyinworker-node-group2" {
  cluster_name    = aws_eks_cluster.doyindevops-eks.name
  node_group_name = "doyindevops-workernodes"
  node_role_arn   = aws_iam_role.doyinworkernodes.arn
  subnet_ids      = aws_subnet.doyintestprojsn[*].id
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,

  ]
}



