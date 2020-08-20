provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

data "aws_eks_cluster" "frontend" {
  name = module.frontend.cluster_id
}

data "aws_eks_cluster_auth" "frontend" {
  name = module.frontend.cluster_id
}

provider "kubernetes" {
  alias                  = "frontend"
  host                   = data.aws_eks_cluster.frontend.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.frontend.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.frontend.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "frontend" {
  source = "terraform-aws-modules/eks/aws"
  providers = {
    kubernetes = kubernetes.frontend
  }
  cluster_name                         = "frontend"
  cluster_version                      = "1.16"
  subnets                              = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
  vpc_id                               = data.terraform_remote_state.vpc.outputs.vpc
  worker_additional_security_group_ids = [aws_security_group.frontend-eks-consul.id]

  manage_aws_auth  = true
  write_kubeconfig = true

  worker_groups = [
    {
      instance_type        = "t3.large"
      asg_max_size         = 3
      asg_desired_capacity = 1
    }
  ]
}

resource "aws_security_group" "frontend-eks-consul" {
  name        = "consul-frontend-eks-gossip"
  description = "consul-eks-gossip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc

  ingress {
    from_port   = 20000
    to_port     = 20000
    protocol    = "tcp"
    cidr_blocks = ["10.2.0.0/16", "10.3.0.0/16"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  
  
  ingress {
    from_port   = 8303
    to_port     = 8303
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 8303
    to_port     = 8303
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

