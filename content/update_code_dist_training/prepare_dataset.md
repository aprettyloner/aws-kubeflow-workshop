---
title: "Prepare training dataset"
date: 2019-10-28T01:48:16-07:00
weight: 2
---
### Download the CIFAR10 dataset and upload it to Amazon S3

On a terminal window in Jupyter client, navigate to the notebook directory

```
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/

```

Activate the TensorFlow conda environment
```
source activate tensorflow_p36

```

Download CIFAR10 dataset and convert it to TFRecords format
```
python generate_cifar10_tfrecords.py --data-dir dataset

```
Confirm that the dataset was downloaded successfully. Run:
```
sudo yum install tree -y

tree dataset

```
You should see the following output
```
dataset
├── eval
│   └── eval.tfrecords
├── train
│   └── train.tfrecords
└── validation
    └── validation.tfrecords
```

```
export S3_BUCKET=<your-globally-unique-bucket-name>

```
{{% notice warning %}}
**Note:** Bucket names should be unique globally. If a bucket with the same name already exists, add another unique identifier such as today's date or your last name.
{{% /notice %}}

```
echo "export S3_BUCKET=${S3_BUCKET}" | tee -a ~/.bash_profile

```
Create a new S3 bucket and upload the dataset to it. Be sure to add a unique identifier, such as your name.
```
aws s3 mb s3://${S3_BUCKET}

```

**Proceed only after successful bucket creation above.**

```
aws s3 sync dataset/ s3://${S3_BUCKET}/cifar10-dataset/

```
