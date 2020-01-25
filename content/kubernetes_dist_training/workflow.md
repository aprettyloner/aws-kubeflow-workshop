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
├── docker
│   ├── Dockerfile.cpu
│   ├── Dockerfile.gpu
│   └── code
│       ├── cifar10-multi-gpu-horovod-k8s.py
│       └── model_def.py
└── specs
    ├── claim-fsx-s3.yaml
    ├── eks_tf_training_job-cpu.yaml
    ├── eks_tf_training_job-gpu.yaml
    ├── fsx-driver-manifest.yaml
    ├── fsx_lustre_policy.json
    ├── fsx-s3-sc.yaml.template
    └── fsx-s3-pvc.yaml
... 
Lots of Notebooks...
...

```

|Files/directories|Description|
|-----|-----|
|docker/Dockerfile | Use this build a custom container image for training on Amazon EKS|
|docker/code|Contains the training script and other training script dependencies|
|specs|List of spec files required to configure Kubeflow|

![workflow](/images/eks/workflow.png)

In the next couple sections, we will setup Amazon EKS, a distributed file system, and launch a distributed training job. This involves multiple steps and we'll leverage various CLI tools to to help install, configure, and interact with EKS in a secure manner using IAM authentication.
