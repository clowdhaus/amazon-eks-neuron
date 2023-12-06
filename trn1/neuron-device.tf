################################################################################
# Neuron Device Plugin
################################################################################

locals {
  neuron_device_plugin_version = "v2.15.2"
}

# Device Plugin Daemonset
data "http" "neuron_device_plugin" {
  url = "https://raw.githubusercontent.com/aws-neuron/aws-neuron-sdk/${local.neuron_device_plugin_version}/src/k8/k8s-neuron-device-plugin.yml"
}

data "kubectl_file_documents" "neuron_device_plugin" {
  content = data.http.neuron_device_plugin.response_body
}

resource "kubectl_manifest" "neuron_device_plugin" {
  for_each = data.kubectl_file_documents.neuron_device_plugin.manifests

  yaml_body = each.value
}

# Cluster Role
data "http" "neuron_device_clusterrole" {
  url = "https://raw.githubusercontent.com/aws-neuron/aws-neuron-sdk/${local.neuron_device_plugin_version}/src/k8/k8s-neuron-device-plugin-rbac.yml"
}

data "kubectl_file_documents" "neuron_device_clusterrole" {
  content = data.http.neuron_device_clusterrole.response_body
}

resource "kubectl_manifest" "neuron_device_clusterrole" {
  for_each = data.kubectl_file_documents.neuron_device_clusterrole.manifests

  yaml_body = each.value
}
