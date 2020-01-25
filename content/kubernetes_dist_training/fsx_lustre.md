---
title: "Enable Amazon FSx for Lustre access"
date: 2019-10-28T16:20:52-07:00
weight: 6
---

Amazon FSx for Lustre provides a high-performance file system optimized for fast processing of workloads such as in deep learning. FSx for Lustre file system transparently presents S3 objects as files and allows you to write results back to S3.

#### Install the FSx CSI Driver
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/release-0.2.0/deploy/kubernetes/manifest.yaml 

```

```
export VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eksctl-${AWS_CLUSTER_NAME}-cluster/VPC" --query "Vpcs[0].VpcId" --output text)
echo "export VPC_ID=${VPC_ID}" | tee -a ~/.bash_profile

```

#### Get subnet ID from the VPC ID console
```
export SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" --query "Subnets[0].SubnetId" --output text)
echo "export SUBNET_ID=${SUBNET_ID}" | tee -a ~/.bash_profile

```

#### Create your security group for the FSx file system
```
export SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name eks-fsx-security-group --vpc-id ${VPC_ID} --description "FSx for Lustre Security Group" --query "GroupId" --output text)
echo "export SECURITY_GROUP_ID=${SECURITY_GROUP_ID}" | tee -a ~/.bash_profile

```

#### Add an ingress rule that opens up port 988 from the 192.168.0.0/16 CIDR range
```
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 988 --cidr 192.168.0.0/16

```

#### Update the environment variables in the storage class spec file

Populate SUBNET_ID, SECURITY_GROUP_ID, S3_BUCKET
```
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes/

sed "s@SUBNET_ID@$SUBNET_ID@" specs/fsx-s3-sc.yaml.template > specs/fsx-s3-sc.yaml

sed -i.bak -e "s@SECURITY_GROUP_ID@$SECURITY_GROUP_ID@" specs/fsx-s3-sc.yaml 

sed -i.bak -e "s@S3_BUCKET@$S3_BUCKET@" specs/fsx-s3-sc.yaml

```

#### Setup IAM Policies to allow Worker Nodes to Access FSx and S3
```
export POLICY_ARN=$(aws iam create-policy --policy-name fsx-csi --policy-document file://./specs/fsx_lustre_policy.json --query "Policy.Arn" --output text)
echo "export POLICY_ARN=${POLICY_ARN}" | tee -a ~/.bash_profile

aws iam attach-role-policy --policy-arn ${POLICY_ARN} --role-name ${INSTANCE_ROLE_NAME}

```

#### Deploy the StorageClass and PersistentVolumeClaim
```
kubectl create -f specs/fsx-s3-sc.yaml

```
```
kubectl create -f specs/fsx-s3-pvc.yaml

```

You can check the status by running the following command (as many times as you like). 

*Note:  This will take 5-10 minutes, so please be patient!*

```
kubectl get pvc fsx-claim 

```

Please wait for this to complete before continuing.

When the claim is bound, you will see the following:

```
kubectl get pvc fsx-claim

```
```
### EXPECTED OUTPUT ###
# NAME        STATUS   VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
# fsx-claim   Bound    pvc-xxx                                    1200Gi     RWX           fsx-sc         1m
```

You can monitor creation by navigating to the AWS Console, searching `FSx`, and clicking `File systems`.

![](/images/eks/fsx-lustre.png)

_Note:  The minimum size of an FSx Lustre file system is 1.2 Terabytes._
