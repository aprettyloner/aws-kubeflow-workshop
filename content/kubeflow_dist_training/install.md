---
title: "Install Kubeflow"
date: 2019-10-28T15:42:44-07:00
weight: 10
---

#### Download the `kfctl` CLI tool
```bash
curl --location https://github.com/kubeflow/kfctl/releases/download/v1.0-rc.1/kfctl_v1.0-rc.1-0-g963c787_linux.tar.gz | tar xz

sudo mv kfctl /usr/local/bin

```

#### Get the latest Kubeflow configuration file
```bash
export CONFIG_URI='https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.1.yaml'

echo "export CONFIG_URI=${CONFIG_URI}" | tee -a ~/.bash_profile

```

#### Check environment variables are set

```bash
echo $AWS_CLUSTER_NAME
echo $STACK_NAME
echo $INSTANCE_ROLE_NAME
echo $INSTANCE_PROFILE_ARN
```


#### Set more environment variables 

```bash
export KF_NAME=${AWS_CLUSTER_NAME}

echo "export KF_NAME=${KF_NAME}" | tee -a ~/.bash_profile
```

```bash
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-4-kubeflow

export KF_DIR=$PWD/${KF_NAME}

echo "export KF_DIR=${KF_DIR}" | tee -a ~/.bash_profile

```

#### Customize the configuration files
We'll edit the configuration with the right names for the cluster and node groups before deploying Kubeflow.

```bash
mkdir -p ${KF_DIR}

cd ${KF_DIR}

curl -O ${CONFIG_URI}

export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.1.yaml

echo "export CONFIG_FILE=${CONFIG_FILE}" | tee -a ~/.bash_profile

sed -i.bak -e "s@eksctl-kubeflow-aws-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$INSTANCE_ROLE_NAME@" ${CONFIG_FILE}

sed -i.bak -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}

sed -i.bak -e "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

```

#### Download Kubeflow manifests

```
cd ${KF_DIR}

wget https://github.com/kubeflow/manifests/archive/v0.7-branch.tar.gz

tar xvf v0.7-branch.tar.gz

TODO: Change uri field in .yaml file to point to the downloaded manifest directory. 
`/home/ec2-user/SageMaker/aws-kubeflow-workshop/notebooks/part-4-kubeflow/pipelineai/manifests-0.7-branch` 

```


#### Generate the Kubeflow installation files
```bash
cd ${KF_DIR}

rm -rf kustomize
rm -rf .cache

kfctl build -V -f ${CONFIG_FILE}

```


#### Allow Access from to the Elastic Container Registry (ECR)
This allows our cluster worker nodes to load custom Docker images (ie. models) from ECR.  We will load these custom Docker images in a later section. 

```bash
aws iam attach-role-policy --role-name $INSTANCE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```


#### Deploy Kubeflow
```bash
cd ${KF_DIR}

kfctl apply -V -f ${CONFIG_FILE}

```

#### Wait for resource to become available

Monitor changes by running kubectl get all namespaces command.
```bash
kubectl -n kubeflow get all

```

#### Delete the usage reporting beacon
```bash
kubectl delete all -l app=spartakus --namespace=kubeflow

```

#### Change to `kubeflow` namespace
```bash
kubectl config set-context --current --namespace=kubeflow

```

#### Navigate to the Kubeflow Dashboard - THIS WILL TAKE A FEW MINUTES
Note:  DNS is eventually consistent and will take a few minutes to propagate.  Please be patient if you see a 404 in your browser.  It will take a few minutes!

```bash
echo $(kubectl get ingress -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')

### EXPECTED OUTPUT - THIS WILL TAKE A FEW MINUTES!! ###
<some-long-subdomain-name>.<aws-region>.elb.amazonaws.com 

```

Navigate to the link above ^^.  Please be patient.  DNS takes time to propagate.

![dashboard](/images/kubeflow/dashboard-welcome.png)

Click on `Start Setup`.

Set the `namespace` to `eksworkshop`.

_Note:  If you accidentally use the default `anonymous` namespace, you will be OK.  Please continue._

Click `Finish` to view the dashboard

![dashboard](/images/kubeflow/dashboard-first-look.png)
