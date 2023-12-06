################################################################################
# ECR Repository
################################################################################

module "neuron_trn1_ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name         = local.name
  repository_force_delete = true # For example only

  tags = module.tags.tags
}
