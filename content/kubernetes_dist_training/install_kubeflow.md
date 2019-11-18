---
title: "Install Kubeflow"
date: 2019-10-28T15:42:44-07:00
weight: 5
---

#### Download the kfctl CLI tool

```
curl --silent --location https://github.com/kubeflow/kubeflow/releases/download/v0.7.0/kfctl_v0.7.0_linux.tar.gz | tar xz

sudo mv kfctl /usr/local/bin
```

#### Get the latest Kubeflow configuration file

```
export CONFIG_URI='https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.0.yaml'
```

#### Create environment and local variables

```
AWS_CLUSTER_NAME=$(eksctl get cluster --output=json | jq '.[0].name' --raw-output)

ROLE_NAME=$(eksctl get iamidentitymapping --cluster ${AWS_CLUSTER_NAME} --output=json | jq '.[0].rolearn' --raw-output | sed -e 's/.*\///')
```

{{% notice warning %}}
Make sure that both environment variables are set before proceeding.
Confirm by running `echo $AWS_CLUSTER_NAME` and `echo $ROLE_NAME`.
Make sure that these are not empty.
{{% /notice %}}

Add your AWS_REGION below:
```
export AWS_REGION=us-west-2
```

Add your S3 bucket name below:
```
export BUCKET_NAME=<your_bucket>
```

{{% notice warning %}}
**Stop:** Verify that you have the correct bucket name before proceeding.
{{% /notice %}}

```
export KF_NAME=${AWS_CLUSTER_NAME}
export KF_DIR=$PWD/${KF_NAME}
```

#### Build your configuration files
We'll edit the configuration with the right names for the cluster and node groups before deploying Kubeflow.

```
mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl build -V -f ${CONFIG_URI}
export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml
```

#### Edit the configuration file to include the correct instance role name and cluster name
```
sed -i .bak "s@cpu-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG_FILE}

sed -i .bak -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}

sed -i .bak "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}
```

#### Apply the changes and deploy Kubeflow
```
cd ${KF_DIR}
rm -rf kustomize/
kfctl apply -V -f ${CONFIG_FILE}
```

#### Wait for resource to become available

Monitor changes by running kubectl get all namespaces command.
```
kubectl -n kubeflow get all
```
