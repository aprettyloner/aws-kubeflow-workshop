---
title: "Install Kubeflow"
date: 2019-10-28T15:42:44-07:00
weight: 8 
---

#### Check environment variables are set with valid values

```bash
echo $AWS_CLUSTER_NAME
echo $STACK_NAME
echo $INSTANCE_ROLE_NAME
echo $INSTANCE_PROFILE_ARN
```

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

#### Set Kubeflow environment variables 

```bash
export KF_NAME=${AWS_CLUSTER_NAME}

echo "export KF_NAME=${KF_NAME}" | tee -a ~/.bash_profile
```

```bash
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes

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

# TODO: Change uri field in .yaml file to point to the downloaded manifest directory. 
#       /home/ec2-user/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes/pipelineai/manifests-0.7-branch` 

```


#### Generate the Kubeflow installation files
```bash
cd ${KF_DIR}

rm -rf kustomize
rm -rf .cache

kfctl build -V -f ${CONFIG_FILE}

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

#### Setup AWS credentials in EKS cluster

AWS credentials are required to save model on S3 bucket. These credentials are stored in EKS cluster as Kubernetes secrets.

Create an IAM user 's3user', attach S3 access policy and retrieve temporary credentials
```
aws iam create-user --user-name s3user
aws iam attach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess
aws iam create-access-key --user-name s3user > /tmp/create_output.json
```

Next, save the new user's credentials into environment variables:
```
export AWS_ACCESS_KEY_ID_VALUE=$(jq -j .AccessKey.AccessKeyId /tmp/create_output.json | base64)

echo "export AWS_ACCESS_KEY_ID_VALUE=${AWS_ACCESS_KEY_ID_VALUE}" | tee -a ~/.bash_profile

export AWS_SECRET_ACCESS_KEY_VALUE=$(jq -j .AccessKey.SecretAccessKey /tmp/create_output.json | base64)

echo "export AWS_SECRET_ACCESS_KEY_VALUE=${AWS_SECRET_ACCESS_KEY_VALUE}" | tee -a ~/.bash_profile

```

Apply to EKS cluster.

_Note:  If you used `anonymous` for the namespace, please substitute `--namespace anonymous` below._

```
cat <<EOF | kubectl apply --namespace eksworkshop -f -
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
type: Opaque
data:
  AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID_VALUE
  AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY_VALUE
EOF
```

More credentials used by Kubeflow to access SageMaker
```
TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"Service\": \"sagemaker.amazonaws.com\" }, \"Action\": \"sts:AssumeRole\" } ] }"
aws iam create-role --role-name eksworkshop-sagemaker-kfp-role --assume-role-policy-document "$TRUST"
aws iam attach-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-arn arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess
```

```
export SAGEMAKER_ROLE_ARN=$(aws iam get-role --role-name eksworkshop-sagemaker-kfp-role --output text --query 'Role.Arn')

echo "export SAGEMAKER_ROLE_ARN=${SAGEMAKER_ROLE_ARN}" | tee -a ~/.bash_profile

```

```
cat <<EoF > sagemaker-invoke.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": "*"
        }
    ]
}
EoF

aws iam put-role-policy --role-name eksworkshop-sagemaker-kfp-role --policy-name sagemaker-invoke-for-worker --policy-document file://sagemaker-invoke.json

aws iam put-role-policy --role-name ${INSTANCE_ROLE_NAME} --policy-name sagemaker-invoke-for-worker --policy-document file://sagemaker-invoke.json

```
