# Exercise: Expose your application

Now that the application is running and resilient to failure of a single pod, it is time to make it available to other users inside and outside of the cluster.

## Step 0: prerequisites
Once again make sure,  everything is up and running. Use `kubectl` and check your deployment + the respective pods.

## Step 1: create a service
Kubernetes provides a convenient way to expose applications. Simply run `kubectl expose deployment nginx --type=LoadBalancer --port=80 --target-port=80`.
With `--type=LoadBalancer` you request our training infrastructure (GCP) to provision a public IP address. It will also automatically assign a cluster-IP and a nodePort in the current setup of the cluster. To create a service that gets only a cluster IP and a NodePort, use `--type=NodePort`.

## Step 2: connect to your service
Checkout the newly created `service` object in your namespace. Try to get detailed information with `get -o=yaml` or `describe`. Note down the different ports exposed and try to access the application via the external IP.
Next try to access the service via the NodePort. Since the NodePort is opened on any cluster node, all you need, is the IP of a cluster node + the NodePort.
Run `kubectl get nodes -o wide` to get the IP addresses of all cluster nodes. You can take any of them and combine it with your NodePort.

## Step 3: optional - create a service from a yaml file.
Download the  [servic.yaml](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/service.yaml) to your machine.
Check, that the label selector matches the lables of your deployment/pods and (re-)create the service (`kubectl create -f <your-file>.yaml`).
