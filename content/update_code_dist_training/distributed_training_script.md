---
title: "Using horovod API for distributed training"
date: 2019-10-28T02:47:30-07:00
weight: 4
---

## Exercise 1: Convert training script to use horovod

<br>In this section you'll update the  training script with horovod API for run distributed training.

Open `cifar10-distributed.ipynb` and run through the cells. The following notebook is located at: <br>
***aws-kubeflow-workshop > notebooks > part-1-horovod***

![singe_instance](/images/convert_script/distributed_script.png)

{{% notice warning %}}
**Stop:** Do this section in a Jupyter Notebook. <br><br>
Open `cifar10-distributed.ipynb` and run these cells. <br><br>
Look for cells that say **Change X** and fill in those cells with the modifications - where **X** is the change number. There are a total of 8 changes.
Click on **> Solution** to see the answers
{{% /notice %}}

You'll need to make the following modifications to your training script to use horovod for distributed training.

1. Run `hvd.init()`
2. Pin a server GPU to be used by this process using `config.gpu_options.visible_device_list`.
3. Scale the learning rate by the number of workers.
4. Wrap the optimizer in `hvd.DistributedOptimizer`.
5. Add `hvd.callbacks.BroadcastGlobalVariablesCallback(0)` to broadcast initial variable states from rank 0 to all other processes.
6. Modify your code to save checkpoints only on worker 0 to prevent other workers from corrupting them.
