# Exercise 10: Happy Helming

In this exercise, you will be dealing with **_Tiller_** and **_Helm_**.

Helm is a tool to manage complex deployments of multiple components belonging to the same application stack. In this exercise, you will install the helm client locally and deploy its counterpart, the tiller server, to your own namespace. Once this is working you will deploy your first chart.
For further information, visit the official docs pages (https://docs.helm.sh/)

**Note:** This exercise does not build on any of the previous exercises.

## Step 0: get the helm tool
Download and unpack the helm client:

```bash
curl -L https://git.io/get_helm.sh | bash
```

Check, if everything worked well. The 1st command should return the location of the helm binary. The 2nd command should return the version of the client and an error for the tiller version since it has not been setup yet. 

```bash
which helm
helm version
```

## Step 1: initialize helm
The helm client uses the information stored in .kube/config to talk to the kubernetes cluster. But before you set up the tiller-server, you need to specify the namespace to be used. Otherwise, everyone will deploy their tiller-server into the kube-system namespace resulting in an overwrite of what was there before. 
You also should use a dedicated service account for you helm installation. To make your life a little bit easier, a `tiller` service account with sufficient permissions was already created in your namespace.

`helm init --tiller-namespace <your-namespace>  --service-account tiller`

Verify your installation by running `helm version --tiller-connection-timeout=5 --tiller-namespace <your-namespace>`. The command should return a version for the client as well as the server. In case the server does not respond properly, you can check, if the `tiller`pod is already up and running.

Hint: If you are getting tired of typing in your tiller namespace for every command, you can set an environment variable `TILLER_NAMESPACE` with your tiller server's namespace as value. However for sake of completeness the following code samples will continue to use the `--tiller-namespace` flag where required.

<details><summary>Bash command to set TILLER_NAMESPACE to namespace of kube config</summary><p> 

You can use this bash line to set TILLER_NAMESPACE:  
`export TILLER_NAMESPACE=$(kubectl config view -o json | jq -r ".contexts[0].context.namespace")` 
</p></details>

## Step 2: looking for charts?
Now that helm is able to talk to its tiller in Kubernetes it is time to use it. Helm organizes applications in so called charts, which contain parameters you can set during installation. By default there is a local and an official repository where you can look for charts, but of course you can also add further repos. Check out the available repos and search for a chaoskube chart

`helm repo list`

`helm search chaoskube`

Found it? Check the github [page](https://github.com/kubernetes/charts/tree/master/stable/chaoskube) for a description of the chart.

Of course, there are other ways to find charts. You can go to [charts org on github](https://github.com/kubernetes/charts) and take a look into the stable, test or incubator repositories. This is also where you find the yaml / template files of charts.
In addition the helm organization recently created [Helm Hub](https://hub.helm.sh/). It is a very convenient way to search for a chart and lets you access multiple / different repositories at once (like stable or incubator). Take a look and see, if you can find the chaoskube there as well.

## Step 3: install a chart
Run the following command to install the chaoskube chart:
`helm install --name <any-name> stable/chaoskube --set namespaces=<your-namespace> --set rbac.serviceAccountName=tiller --tiller-namespace <your-namespace> --debug`
It installs everything that is associated to the chart into your namespace. Note the `--set` flag, it specifies a parameter of chart.
The parameter `namespaces` defines in which namespaces the choaskube will delete pods, `rbac.serviceAccountName` tells helm which serviceAccount chaoskube will get. Here we give it the tiller account because it has to be able to delete pods.  
Check the github page mentioned above again, if you want to learn what it does and which other parameters are available.

## Step 4: inspect your chaoskube
Next, check your installation by running `helm list --tiller-namespace <your-namespace>`. It returns all installed releases including your chaoskube. You can reference it by its name.
Get more information by running `helm status <your-releases-name> --tiller-namespace <your-namespace>`

Also check the pods running inside your kubernetes namespace. Don't forget to look into the logs of the chaoskube to see what would have happened with the dry-run flag set.
`kubectl logs -f pod/<your chaoskube-pod-name>`

# Step 5: clean-up
Clean up by deleting the chaoskube:
`helm delete <your-releases-name> --tiller-namespace <your-namespace>`

Now run `helm status <your-releases-name>` again. Though the pod has been removed from kubernetes, there are still meta information available.
To completely remove the list use `helm delete --purge <your-releases-name> --tiller-namespace <your-namespace>`.
