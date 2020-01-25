---
title: "Monitoring training progress"
date: 2019-10-28T13:54:27-07:00
weights: 4
---

### Monitoring training progress using tensorboard

The ***cifar10-sagemaker-distributed.ipynb*** notebook will automatically start a tensorboard server for you when your run the following cell. 

Tensorboard is running locally on your SageMaker Notebook instance, but reading the events from the Amazon S3 bucket we used to save the events.

From your terminal, run the following command to start Tensorboard
```bash
S3_REGION=us-west-2 tensorboard --logdir s3://${S3_BUCKET}/tensorboard_logs/ # <== MAKE SURE YOU INCLUDE THE TRAILING `/`
```

Navigate to **`https://workshop.notebook.us-west-2.sagemaker.aws/proxy/6006/`**

Notes:  
* Make sure you copy the trailing `/` in the link above.
* If you see no data, you are likely not using the correct `globally-unique-bucket-name` above.

![tensorboard](/images/sagemaker/tensorboard.png)

From your terminal, hit `ctrl-c` to break out of the running Tensorboard process and return to your terminal prompt.

**DO NOT CONTINUE UNTIL YOU HAVE HIT `ctrl-c` in your terminal**

### Monitoring training job status on the AWS SageMaker console

Navigate to ***AWS management console > SageMaker console*** to see a full list of training jobs and their status.

![tensorboard](/images/sagemaker/aws_console.png)

To view cloudwatch logs from the training instances, click on the ***training job name > Monitor > View logs***
