# Exercise 4: Expose your application

Now that the application is running and resilient to failure of a single pod, it is time to make it available to other users inside and outside of the cluster.

**Note**: This exercise builds upon the previous exercise. If you did not manage to finish the previous exercise successfully, you can use the YAML file [03_deployment.yaml](solutions/03_deployment.yaml) in the *solutions* folder to create a deployment. Please use the file only if you did not manage to complete the previous exercise.

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

## Troubleshooting
In case your service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to. 

Check the correctness of the label - selector combination by running the query manually. Firstly, get the selector from the service by running `kubectl get service <service-name> -o yaml`. Use the `<key>: <value>` pairs stored in `service.spec.selector` to get all pods with the corresponding label set: `kubectl get pods -l <key>=<value>`. These pods are what the service is selecting / looking for. Quite often the selector used within service matches the selector specified within the deployment.

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level, request a dedicated resource like the index page: `http:<LoadBalancer IP>/index.html`.

The structure of a deplyoment can be found in the API documentation. Go to [API reference](https://kubernetes.io/docs/reference/) and choose the corresponding version (usually the training features a cluster with the latest or 2nd latest version). Within the API docs select the "Deployment".

Alternatively use `kubectl explain service`. To get detailed information about a field within the pod use its "path" like this: `kubectl explain deployment.spec.ports`.

To create a new file with a skeleton of a deployment, right-click the Desktop within the training VM, select the context menu "new document" and choose "service". Additionally the solution to this exercise contains further explanatory comments.

## Further information & references
- [services in K8s](https://kubernetes.io/docs/concepts/services-networking/service/)
- [connecting a front end to a backend](https://kubernetes.io/docs/tasks/access-application-cluster/connecting-frontend-backend/)
- [cluster internal DNS](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
