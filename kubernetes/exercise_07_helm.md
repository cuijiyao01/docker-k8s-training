# optional exercise: Happy Helming
>This is an optional exercise. If you've already finished everything else, feel free to give it a try.

Helm is a tool to manage complex deployments of multiple components belonging to the same application stack. In this exercise, you will install the helm client locally and deploy its counterpart, the tiller server, to your own namespace. Once this is working you will deploy your first chart.
For futher information, visit the official docs pages (https://docs.helm.sh/)

## Step 0: get the helm tool
Download $ unpack the helm client:
```
wget -O helm.tar.gz https://kubernetes-helm.storage.googleapis.com/helm-v2.7.2-linux-amd64.tar.gz
tar -xzf helm.tar.gz
```
Next locate the `helm` binary in the extracted folder and move it to a directory in your `PATH`.

as user root or with sudo: `mv linux-amd64/helm /usr/local/bin/helm`

Change the permissions of the binary accordingly that also the `training` user can run it.

as user root or with sudo: `chmod +x /usr/local/bin/helm`

## Step 1: initialize helm
The helm client uses the information stored in .kube/config to talk to the kubernetes cluster. But before you set up the tiller-server, you need to specify the namespace to be used. Otherwise, everyone will deploy their tiller-server into the kube-system namespace resulting in an overwrite of what was there before.   

`helm init --tiller-namespace <your-namespace>`

Verify your installation by running `helm list --tiller-namespace <your-namespace>`. You should also check, if a tiller pod is running in your namespace.

## Step 2: looking for charts?
Now that helm is able to talk to its tiller in Kubernetes it is time to use it. Helm organizes applications in so called charts, which contain parameters you can set during installation. By default there is a local and an official repository where you can look for charts, but of course you can also add futher repos. Check out the available repos and search for a chaoskube chart
`helm repo list`
`helm search chaoskube`
Found it? Check the github [page](https://github.com/kubernetes/charts/tree/master/stable/chaoskube) for a description of the chart.

## Step 3: install a chart
Run the following command to install the chaoskube chart:
`helm install --name <any-name> stable/chaoskube --set namespaces=<your-namespace> --tiller-namespace <your-namespace>`
It installs eveything that is associated to the chart into your namespace. Note the `--set` flag, it specifies a parameter of chart. Check the github page mentioned above again, if you want to learn what it does and which other parameters are available.

Next, check your installation by running
`helm list --tiller-namespace <your-namespace>`
Also check the resources running inside your kubernetes namespace. Don't forget to look into the logs of the chaoskube.

# Step 4 (optional): clean-up
Clean up by deleting the chaoskube:
`helm delete <name-given-to-your-release> --tiller-namespace <your-namespace>`