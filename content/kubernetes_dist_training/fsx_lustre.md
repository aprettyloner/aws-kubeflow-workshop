---
title: "Enable Amazon FSx for Lustre access"
date: 2019-10-28T16:20:52-07:00
weight: 6
---

Amazon FSx for Lustre provides a high-performance file system optimized for fast processing of workloads such as in deep learning. FSx for Lustre file system transparently presents S3 objects as files and allows you to write results back to S3.

#### Install the FSx CSI Driver
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/deploy/kubernetes/manifest.yaml
```
```
export VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=eksctl-${AWS_CLUSTER_NAME}-cluster/VPC" --query "Vpcs[0].VpcId" --output text)
echo "export VPC_ID=${VPC_ID}" | tee -a ~/.bash_profile
```

#### Get subnet ID from the EC2 console
Navigate to [AWS EC2 console](https://console.aws.amazon.com/ec2/v2/home) and click on **Instances**.
Select one of the running instances which starts with the name of the EKS cluster. This instance is a node on the EKS cluster.
Copy the subnet ID as show in the image below. Click on the copy-to-clipboard icon show next to the arrow.

![subnet](/images/eks/subnet_image.png)
paste the subnet ID below
```
export SUBNET_ID=<subnet_id>
echo "export SUBNET_ID=${SUBNET_ID}" | tee -a ~/.bash_profile
```

#### Create your security group for the FSx file system
```
export SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name eks-fsx-security-group --vpc-id ${VPC_ID} --description "FSx for Lustre Security Group" --query "GroupId" --output text)
echo "export SECURITY_GROUP_ID=${SECURITY_GROUP_ID}" | tee -a ~/.bash_profile
```

{{% notice warning %}}
**Stop:** Make sure that the security group was created before proceeding.
Confirm by running the following:
```
echo $SECURITY_GROUP_ID
````
and don't proceed if this is empty.
{{% /notice %}}

#### Add an ingress rule that opens up port 988 from the 192.168.0.0/16 CIDR range
```
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 988 --cidr 192.168.0.0/16
```

#### Update the environment variables in the storage class spec file
Running envsubst will populate SUBNET_ID, SECURITY_GROUP_ID, BUCKET_NAME
```
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes/

sed "s@SUBNET_ID@$SUBNET_ID@" specs/fsx-s3-sc.yaml.template > fsx-s3-sc.yaml
sed -i .bak "s@SECURITY_GROUP_ID@$SECURITY_GROUP_ID@" specs/fsx-s3-sc.yaml 
sed -i .bak "s@BUCKET_NAME@$BUCKET_NAME@" specs/fsx-s3-sc.yaml

#envsubst < specs/storage-class-fsx-s3-template.yaml > specs/storage-class-fsx-s3.yaml
```

#### Setup IAM Policies to allow Worker Nodes to Access FSx and S3
```
export POLICY_ARN=$(aws iam create-policy --policy-name fsx-csi --policy-document file://./specs/fsx_lustre_policy.json --query "Policy.Arn" --output text)
echo "export POLICY_ARN=${POLICY_ARN}" | tee -a ~/.bash_profile
aws iam attach-role-policy --policy-arn ${POLICY_ARN} --role-name ${INSTANCE_ROLE_NAME}
```

#### Deploy the StorageClass and PersistentVolumeClaim
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-fsx-csi-driver/master/deploy/kubernetes/manifest.yaml

kubectl apply -f specs/fsx-s3-sc.yaml
kubectl apply -f specs/fsx-s3-pvc.yaml
```

You can check the status by running the following command. Hit `Ctrl+C` if you don't want the terminal to be blocked. To manually check, run the command without `-w`

*This will take several minutes, so please be patient!*

```
kubectl get pvc fsx-claim 
```
