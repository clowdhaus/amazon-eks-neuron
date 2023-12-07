# Amazon EKS w/ Trn1 for distributed training

Utilizes Amazon EFA (Elastic Fabric Adapter) for high performance networking

## Deploy Cluster

1. Create an AMI using the associated project: [amazon-eks-neuron-ami](https://github.com/clowdhaus/amazon-eks-neuron-ami)
2. Copy the AMI ID generated into the `ami_id = "ami-xxx"` local variable at the top of the `eks.tf` file.
3. Run `terraform init`
4. Run `terraform apply` and enter `yes` when prompted

## Deploy Training Job

1. Update your local `kubeconfig` to access the cluster with:

    ```bash
    aws eks --region us-west-2 update-kubeconfig --name neuron-trn1 --region us-east-1
    ```

2. To deploy the single-node bandwidth test, execute:

    ```bash
    kubectl apply -f bandwidth-test-single.yaml
    ```

3. To deploy the multi-node bandwidth test, execute:

    ```bash
    kubectl apply -f bandwidth-test-multi.yaml
    ```

## Note

The custom AMI used by this example is not publicly available. It has been generated using this configuration [amazon-eks-neuron-ami](https://github.com/clowdhaus/amazon-eks-neuron-ami)
