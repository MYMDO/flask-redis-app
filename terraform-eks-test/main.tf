terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Or try a specific version like "5.89.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" # Keep your desired region
  # Remove hardcoded credentials if you added them earlier, rely on AWS CLI config
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "eks-test-vpc"
  }
}

resource "aws_eks_cluster" "eks_cluster_test" {
  name     = "eks-cluster-test"
  role_arn = aws_iam_role.eks_cluster_test_role.arn
  version  = "1.27" # Or your desired Kubernetes version

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet_test_a.id, aws_subnet.public_subnet_test_b.id] # Define these below
  }
}

resource "aws_subnet" "public_subnet_test_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "public_subnet_test_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
}


resource "aws_iam_role" "eks_cluster_test_role" {
  name = "eks-cluster-test-role"  # Added name argument

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "eks_cluster_test_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_cluster_test_role.name]
   name = "eks-cluster-test-policy-attachment" # Added name argument - try adding names to policy attachments
}
