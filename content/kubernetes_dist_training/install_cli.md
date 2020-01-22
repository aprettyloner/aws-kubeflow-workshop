---
title: "Install CLI tools"
date: 2019-10-28T15:02:28-07:00
weight: 2
---

From the terminal, navigate to the following directory for part 3 of the workshop
```
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes/
```


#### Install `eksctl`

To get started we'll first install the `awscli` and `eksctl` CLI tools. [eksctl](https://eksctl.io) simplifies the process of creating EKS clusters.

```bash
pip install awscli --upgrade --user

curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

```

#### Enable `eksctl` bash_completion
```
eksctl completion bash >> ~/.bash_completion

. /etc/profile.d/bash_completion.sh

. ~/.bash_completion

```

#### Install `kubectl`
`kubectl` is a command line interface for running commands against Kubernetes clusters. 

Run the following to install Kubectl

```bash
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin

kubectl version --short --client

```

#### Enable `kubectl` bash_completion
```
kubectl completion bash >>  ~/.bash_completion

. /etc/profile.d/bash_completion.sh

. ~/.bash_completion
```

#### Install `aws-iam-authenticator`

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator

chmod +x ./aws-iam-authenticator

sudo mv aws-iam-authenticator /usr/local/bin

aws-iam-authenticator version

```

#### Install jq, envsubst (from GNU gettext utilities) and bash-completion
```
sudo yum -y install jq gettext bash-completion

```

#### Verify the binaries are in the path and executable
```
for command in kubectl jq envsubst
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done

```
