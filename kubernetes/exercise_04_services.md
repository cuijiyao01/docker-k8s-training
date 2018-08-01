# Exercise: Expose your application

Now that the application is running and resilient to failure of a single pod, it is time to make it available to other users inside and outside of the cluster.

## Step 0: prerequisites
Once again make sure,  everything is up and running. Use `kubectl` and check your deployment and the respective pods.

## Step 1: create a service
Kubernetes provides a convenient way to expose applications. Simply run `kubectl expose deployment <deployment-name> --type=LoadBalancer --port=80 --target-port=80`.
With `--type=LoadBalancer` you request our training infrastructure (GCP) to provision a public IP address. It will also automatically assign a cluster-IP and a nodePort in the current setup of the cluster. To create a service that gets only a cluster IP and a NodePort, use `--type=NodePort`.

## Step 2: connect to your service
Checkout the newly created `service` object in your namespace. Try to get detailed information with `get -o=yaml` or `describe`. Note down the different ports exposed and try to access the application via the external IP.

Next try to access the service via the NodePort. Since the NodePort is opened on any cluster node, all you need, is the IP of a cluster node + the NodePort.
Run `kubectl get nodes -o wide` to get the IP addresses of all cluster nodes. You can take any of them and combine it with your NodePort.

## Step 3: create a service from a yaml file.
Before going on, delete the service you created with the `expose` command. Now write your own yaml to define the service.
Check, that the label selector matches the lables of your deployment/pods and (re-)create the service (`kubectl create -f <your-file>.yaml`).

**Important: don't delete this service, you will need it during the following exercises.**

## Step 4: optional/advanced - learn how to label
In this last step you will expose another pod through a service. Simply create the pod from the 2nd exercise again and try to expose it as `NodePort` with `kubectl expose pod ...`.

You will probably get an error message concerning missing labels. Solve this by adding a custom label to your pod and try again to expose it.

Once you are able to access the nginx via the `NodePort`, take a look at the pod and the service. Determine the label as well as the corresponding selectors. Now remove the label from the pod: `kubectl label pod <your-pod> --overwrite <your-label-key>-` and try again to access the nginx via the `NodePort`. Most likely this won't work anymore.

Finally, clean-up and remove the pod as well as the service you created in step 4.
