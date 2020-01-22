---
title: "Workflow"
date: 2019-10-28T14:18:11-07:00
weight: 1
---

Navigate to
***aws-kubeflow-workshop > notebooks > part-3-kubernetes***
You should see the following files:

```bash
part-3-kubernetes/
├── Dockerfile
├── cpu_eks_cluster.sh
├── gpu_eks_cluster.sh
├── code
│   ├── cifar10-multi-gpu-horovod-k8s.py
│   └── model_def.py
└── specs
    ├── claim-fsx-s3.yaml
    ├── eks_tf_training_job.yaml
    ├── fsx_lustre_policy.json
    └── storage-class-fsx-s3-template.yaml
```

|Files/directories|Description|
|-----|-----|
|Dockerfile | Use this build a custom container image for training on Amazon EKS|
|cpu_eks_cluster.sh, gpu_eks_cluster.sh |shell scripts using `eksctl` CLI tool to launch an Amazon EKS cluster|
|code|Contains the training script and other training script dependencies|
|specs|List of spec files required to configure Kubeflow|

![workflow](/images/eks/workflow.png)

In the next section, we will setup Amazon EKS, Amazon FSx for Lustre file  system and install Kubeflow. This involves multiple steps and we'll leverage various CLI tools to to help install, configure and interact with EKS. At a high level, we'll perform the following steps:

1. Install `eksctl` CLI and use it to launch an Amazon EKS cluster
1. Install `kubectl` CLI to interact with the Amazon EKS cluster
1. Install `kfctl` CLI and use it to configure and install Kubeflow
1. Allow Amazon EKS to access a distributed file system backed by our Amazon S3 bucket
1. Finally, launch a distributed training job
