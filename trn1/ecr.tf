################################################################################
# ECR Repository
################################################################################

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name         = local.name
  repository_force_delete = true # For example only
  create_lifecycle_policy = false

  tags = module.tags.tags
}

################################################################################
# Image Build & Push Script
################################################################################

data "aws_caller_identity" "current" {}

resource "local_file" "build" {
  content  = <<-EOT
  #!/usr/bin/env bash

  aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com

  TAG=$(date +%Y%m%d_%H%M%S)

  pushd image
    docker build -t ${module.ecr.repository_url}:$${TAG} .
    docker push ${module.ecr.repository_url}:$${TAG}
  popd

  # Update the MPI Operator bandwidth test manifest with the new image tag
  sed -i "s|image:.*|image: ${module.ecr.repository_url}:$${TAG}|g" mpi-bandwidth-test.yaml
  EOT

  filename = "${path.module}/build.sh"
}
