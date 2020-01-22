---
title: "Update notebook IAM role"
date: 2019-10-27T23:41:36-07:00
weight: 5
---

### Give your notebook instances admin privileges
{{% notice warning %}}
**Note:** We're providing admin privileges to the SageMaker notebook instance only because we'll be using the same instance to launch an Amazon EKS cluster in the later part of the workshop. If you're only going to be using SageMaker managed cluster for training, please use appropriate, least-priviledge access policies.
{{% /notice %}}

* Click on `sworkshop` and you'll see additional details about the instance. Click on the IAM role link, this should take you to the IAM Management Console. Once there, click the `Attach Policy` button.
![go_to_IAM](/images/setup/go_to_IAM.png)
![attach_policy](/images/setup/attach_policy.png)
* Select `AdministratorAccess` and click on `Attach Policy`
![admin attach](/images/setup/admin_attach.png)
* Close the the IAM Management Console window and head back to the SageMaker console. 
