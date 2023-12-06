################################################################################
# MPI Operator
################################################################################

locals {
  kubeflow_version = "v0.4.0"
}

data "http" "mpi_operator" {
  url = "https://raw.githubusercontent.com/kubeflow/mpi-operator/${local.kubeflow_version}/deploy/v2beta1/mpi-operator.yaml"
}

data "kubectl_file_documents" "mpi_operator" {
  content = data.http.mpi_operator.response_body
}

resource "kubectl_manifest" "mpi_operator" {
  for_each = data.kubectl_file_documents.mpi_operator.manifests

  yaml_body = each.value
}

# Cluster Role
data "http" "mpi_operator_clusterrole" {
  url = "https://raw.githubusercontent.com/kubeflow/mpi-operator/${local.kubeflow_version}/manifests/base/cluster-role.yaml"
}

data "kubectl_file_documents" "mpi_operator_clusterrole" {
  content = data.http.mpi_operator_clusterrole.response_body
}

resource "kubectl_manifest" "mpi_operator_clusterrole" {
  for_each = data.kubectl_file_documents.mpi_operator_clusterrole.manifests

  yaml_body = each.value
}
