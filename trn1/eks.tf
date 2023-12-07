locals {
  ami_id = "ami-02d1a0883ae6aca8d"
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.20"

  cluster_name                   = local.name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ingress traffic. Required for EFA"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_self_all = {
      description = "Node to node all egress traffic. Required for EFA"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      # Not required, but used in the example to access the nodes to inspect drivers and devices
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = ["m7i.2xlarge"]

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type = "gp3"
            volume_size = 64
          }
        }
      }

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }

    (local.name) = {
      create = true

      ami_id                     = local.ami_id
      enable_bootstrap_user_data = true

      instance_types = ["trn1.32xlarge"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type = "gp3"
            volume_size = 512
          }
        }
      }

      # Use the availability zone that supports the instance
      # aws ec2 describe-instance-type-offerings --location-type availability-zone  \
      # --filters Name=instance-type,Values=trn1.32xlarge \
      # --region us-east-1 --output table
      subnet_ids = [element(module.vpc.private_subnets, 1)]

      # trn1.32xlarge has 8 network cards
      network_interfaces = [
        for i in range(8) : {
          associate_public_ip_address = false
          delete_on_termination       = true
          device_index                = i == 0 ? 0 : 1
          network_card_index          = i
          interface_type              = "efa"
        }
      ]

      placement = {
        group_name = aws_placement_group.this.name
      }

      taints = {
        gpu = {
          key    = "aws.amazon.com/neuron"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = module.tags.tags
}

################################################################################
# Placement group
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start.html#efa-start-instances
################################################################################

resource "aws_placement_group" "this" {
  name     = local.name
  strategy = "cluster"
}
