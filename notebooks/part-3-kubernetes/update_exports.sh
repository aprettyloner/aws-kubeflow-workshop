echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile

echo "export BUCKET_NAME=${BUCKET_NAME}" | tee -a ~/.bash_profile

STACK_NAME=$(eksctl get nodegroup --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[].StackName')
echo "export STACK_NAME=${STACK_NAME}" | tee -a ~/.bash_profile

INSTANCE_PROFILE_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="InstanceProfileARN") | .OutputValue')
echo "export INSTANCE_PROFILE_ARN=${INSTANCE_PROFILE_ARN}" | tee -a ~/.bash_profile

ROLE_NAME=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="InstanceRoleARN") | .OutputValue' | cut -f2 -d/)
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

export KF_NAME=${AWS_CLUSTER_NAME}
echo "export KF_NAME=${KF_NAME}" | tee -a ~/.bash_profile

export KF_DIR=$PWD/${KF_NAME}
echo "export KF_DIR=${KF_DIR}" | tee -a ~/.bash_profile

export CONFIG_URI=https://raw.githubusercontent.com/kubeflow/manifests/v0.7.0/kfdef/kfctl_aws.0.7.0.yaml
echo "export CONFIG_URI=https://raw.githubusercontent.com/kubeflow/manifests/v0.7.0/kfdef/kfctl_aws.0.7.0.yaml" | tee -a ~/.bash_profile

export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml
echo "export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml" | tee -a ~/.bash_profile
