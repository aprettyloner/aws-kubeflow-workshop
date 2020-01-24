---
title: "Setup an Amazon EKS cluster"
date: 2019-10-28T15:14:12-07:00
weight: 3
---

Navigate to ***aws-kubeflow-workshop > notebooks > part-3-kubernetes***

Setup the `AWS_REGION`, `AWS_CLUSTER_NAME` environment variables
```bash
export AWS_REGION=us-west-2
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile

export AWS_CLUSTER_NAME=pipelineai
echo "export AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME}" | tee -a ~/.bash_profile

```

Run the following:
```bash
eksctl create cluster \
    --name ${AWS_CLUSTER_NAME} \
    --version 1.14 \
    --region ${AWS_REGION} \
    --nodegroup-name cpu-nodes \
    --node-type c5.xlarge \
    --nodes 5 \
    --node-volume-size 100 \
    --node-zones us-west-2a \
    --timeout=40m \
    --zones=us-west-2a,us-west-2b,us-west-2c \
    --alb-ingress-access \
    --auto-kubeconfig

```

You should an output that something similar to this.

![eks output](/images/eks/eksctl_launch.png)

Creating a cluster may take about 15 mins. 

Navigate to the [**AWS Console**](https://console.aws.amazon.com) to monitor the progress:
```
https://console.aws.amazon.com/cloudformation
```

### Associated IAM and OIDC
To use IAM roles for service accounts in your cluster, you must create an OIDC identity provider in the IAM console.  See https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html for more info.
```
eksctl utils associate-iam-oidc-provider --cluster ${AWS_CLUSTER_NAME} --approve

aws eks describe-cluster --name ${AWS_CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.identity.oidc.issuer" --output text

```

### Add Access to Elastic Container Registry (ECR)
```
aws iam attach-role-policy --role-name $INSTANCE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```
