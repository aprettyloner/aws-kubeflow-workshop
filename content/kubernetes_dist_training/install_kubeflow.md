---
title: "Install Kubeflow"
date: 2019-10-28T15:42:44-07:00
weight: 5
---

#### Download the kfctl CLI tool

```
curl --location https://github.com/kubeflow/kubeflow/releases/download/v0.7.0/kfctl_v0.7.0_linux.tar.gz | tar xz

sudo mv kfctl /usr/local/bin
```

#### Get the latest Kubeflow configuration file
```
export CONFIG_URI='https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.0.yaml'
echo "export CONFIG_URI=${CONFIG_URI}" | tee -a ~/.bash_profile
```

#### Create environment and local variables
{{% notice warning %}}
Make sure that environment variables are set before proceeding.

Confirm by running the following commands
```
echo $AWS_CLUSTER_NAME
```
```
echo $BUCKET_NAME
```
and make sure these are not empty.
{{% /notice %}}
```
# AWS_CLUSTER_NAME=$(eksctl get cluster --output=json | jq '.[0].name' --raw-output)

export STACK_NAME=$(eksctl get nodegroup --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[].StackName')
echo "export STACK_NAME=${STACK_NAME}" | tee -a ~/.bash_profile

export INSTANCE_PROFILE_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="InstanceProfileARN") | .OutputValue')
echo "export INSTANCE_PROFILE_ARN=${INSTANCE_PROFILE_ARN}" | tee -a ~/.bash_profile

export ROLE_NAME=$(eksctl get iamidentitymapping --cluster ${AWS_CLUSTER_NAME} --output=json | jq '.[0].rolearn' --raw-output | sed -e 's/.*\///')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

export KF_NAME=${AWS_CLUSTER_NAME}
echo "export KF_NAME=${KF_NAME}" | tee -a ~/.bash_profile

export KF_DIR=$PWD/${KF_NAME}
echo "export KF_DIR=${KF_DIR}" | tee -a ~/.bash_profile

export CONFIG_URI=https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.0.yaml
echo "export CONFIG_URI=${CONFIG_URI}" | tee -a ~/.bash_profile
```

#### Customize the configuration files
We'll edit the configuration with the right names for the cluster and node groups before deploying Kubeflow.

```
mkdir -p ${KF_DIR}
cd ${KF_DIR}
curl -O ${CONFIG_URI}

export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml

sed -i .bak "s@eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG_FILE}
sed -i .bak -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i .bak "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

kfctl build -V -f ${CONFIG_FILE}
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
