# Exercise: Expose your application

Now that the application is running, it is time to make it available to other users inside and outside of the cluster.

## Step 0: prerequisites
Once again make sure,  everything is up and running. Use `kubectl` and check your deployment + the respective pods.

## Step 1: create a services
Kubernetes provides a convenient way to expose applications for testing. Simply run `kubectl expose deployment nginx --type=LoadBalancer --port=80 --target-port=80`.
Checkout the newly created `service` object in your namespace. Try to get detailed information with `get -o=yaml` or `describe`. Note down the different ports exposed and try to access the application via the external IP.

## Step 2:
Since we don't want our webserver to be exposed permanently, we are going to recreate it with a clusterIP only.
Firstly, delete the service you just created with `kubectl delete service nginx`.

Then download the content from [servic.yaml](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/service.yaml) to your machine and re-create the service (`kubectl create -f <your-file>.yaml`). Don't forget to change the namespace.

Check the service again and verify, it has only a cluster internal IP.
