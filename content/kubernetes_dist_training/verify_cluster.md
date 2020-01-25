---
title: "Verify installation and test cluster"
date: 2019-10-28T15:33:52-07:00
weight: 4
---

Once the cluster is up and running, you should see a message that your cluster is now ready.
![verify eks](/images/eks/verify_eks.png)

Update kubeconfig file to point to our new cluster.

```bash
aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME} 
```

Run the following to confirm that you can access the EKS cluster:

You should see a list of kubernetes namespaces:
```
kubectl get ns

```
```
### EXPECTED OUTPUT ###
# NAME              STATUS   AGE
# default           Active   12m
# kube-node-lease   Active   13m
# kube-public       Active   13m
# kube-system       Active   13m
```

You should see total number of nodes in your cluster:
```
kubectl get nodes

```
```
### EXPECTED OUTPUT ###
# NAME                                            STATUS   ROLES    AGE    VERSION
# ip-XXX-XXX-XXX-XXX.us-west-2.compute.internal   Ready    <none>   7m3s   v1.14.7-eks-1861c5
# ip-XXX-XXX-XXX-XXX.us-west-2.compute.internal   Ready    <none>   7m4s   v1.14.7-eks-1861c5
```
