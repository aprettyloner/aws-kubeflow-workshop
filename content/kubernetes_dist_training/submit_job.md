---
title: "Submit distributed training job"
date: 2019-10-28T17:14:05-07:00
weight: 10 
---
#### Confirm that you are in the right directory
```
cd ~/SageMaker/aws-kubeflow-workshop/notebooks/part-3-kubernetes/
```


#### Update the MPIJob spec file with your Docker image

```
sed -i.bak -e "s@YOUR_DOCKER_IMAGE@${ECR_REPOSITORY_URI}:latest@" specs/eks_tf_training_job-cpu.yaml
```
{{% notice tip %}}
For GPU jobs use this instead: `eks_tf_training_job-gpu.yaml`
{{% /notice %}}

#### Submit a job run:
```
kubectl create -f specs/eks_tf_training_job-cpu.yaml

### EXPECTED OUTPUT ###
mpijob.kubeflow.org/eks-tf-distributed-training created 
```

Running `kubectl get pods` will should you the number of workers + 1 number of pods.

_Note:  You may see some pods in the `Initializing` state.  This is OK.  Try again in a few seconds._

```bash
kubectl get pods | grep eks-tf-distributed-training

### EXPECTED OUTPUT ###
...
NAME                                         READY   STATUS    RESTARTS   AGE
eks-tf-distributed-training-launcher-6lgzg   1/1     Running   0          63s
eks-tf-distributed-training-worker-0         1/1     Running   0          66s
eks-tf-distributed-training-worker-1         1/1     Running   0          66s
```

To observer training logs, run the following command.  Note:  You can use `tab` completion as shown below - or copy the name of the pod from the output of `kubectl get pods` above.

```
kubectl logs eks-tf-distributed-training-launcher-<POD_NAME_FROM_ABOVE>

### EXPECTED OUTPUT ###
...
Epoch 1/30
Epoch 1/30
 3/78 [>.............................] - ETA: 4:05 - loss: 3.6816 - acc: 0.1172 3/724/78 [========>.....................] - ETA: 1:29 - loss: 2.7493 - acc: 0.161024/778/78 [==============================] - 128s 2s/step - loss: 2.1984 - acc: 0.2268 - val_loss: 2.1794 - val_acc: 0.1699
Epoch 2/30
78/78 [==============================] - 129s 2s/step - loss: 2.2108 - acc: 0.2268 - val_loss: 2.1794 - val_acc: 0.1699
Epoch 2/30
```

*Congratulations!*  

You just trained a distributed TensorFlow model using Horovod on Amazon EKS with the FSx for Lustre distributed file system backed by S3!  

*High-five!!*
