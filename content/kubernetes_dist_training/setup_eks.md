---
title: "Setup an Amazon EKS cluster"
date: 2019-10-28T15:14:12-07:00
weight: 3
---

Navigate to ***aws-kubeflow-workshop > notebooks > part-3-sagemaker***

Setup `AWS_REGION`, `AWS_CLUSTER_NAME`
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
    --region us-west-2 \
    --nodegroup-name cpu-nodes \
    --node-type c5.xlarge \
    --nodes 2 \
    --node-volume-size 100 \
    --node-zones us-west-2a \
    --timeout=40m \
    --zones=us-west-2a,us-west-2b,us-west-2c \
    --auto-kubeconfig
```

You should an output that something similar to this.

![eks output](/images/eks/eksctl_launch.png)

Creating a cluster may take about 15 mins. You could head over to [AWS cloud formation console](https://console.aws.amazon.com/cloudformation) to monitor the progress.

### Associated IAM and OIDC
To use IAM roles for service accounts in your cluster, you must create an OIDC identity provider in the IAM console.  See https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html for more info.
```
aws eks describe-cluster --name ${AWS_CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text

eksctl utils associate-iam-oidc-provider --cluster ${AWS_CLUSTER_NAME} --approve
```
