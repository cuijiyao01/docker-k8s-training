# Exercise 10: Happy Helming

In this exercise, you will be dealing with **_Helm_**.

Helm is a tool to manage complex deployments of multiple components belonging to the same application stack. In this exercise, you will install the helm client locally. Once this is working you will deploy your first chart into your namespace.
For further information, visit the official docs pages (https://docs.helm.sh/)

**Note:** This exercise does not build on any of the previous exercises.

## Step 0: get the helm tool
Download and unpack the helm client:

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

Check, if everything worked well. The 1st command should return the location of the helm binary. The 2nd command should return the version of the client. 

```bash
which helm
helm version
```

## Step 1: no need to initialize helm (anymore)
The helm client uses the information stored in .kube/config to talk to the kubernetes cluster. This includes the user, its credentials but also the target namespace. Restrictions such as RBAC or pod security policies, which apply to your user, also apply to everything you try to install using helm. 

**And that's it - `helm` is ready to use!**

Compared to the previous v2 setup procedure, this is a significant improvement. The server-side component `tiller` has been removed completely.

## Step 2: looking for charts?
Helm organizes applications in so called charts, which contain parameters you can set during installation. By default, helm (v3) is not configured to search any remote repository for charts. So as a first step, add the `stable` repository, which hosts charts maintained on [github.com](https://github.com/helm/charts/tree/master/stable).

```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

helm repo list
```

Check out the available charts and search for the chaoskube:

```bash
helm search repo chaoskube
```

Found it? Check the github [page](https://github.com/kubernetes/charts/tree/master/stable/chaoskube) for a detailed description of the chart.

Of course, there are other ways to find charts. You can go to [charts org on github](https://github.com/kubernetes/charts) and take a look into the stable, test or incubator repositories. This is also where you find the yaml / template files of charts.
In addition the helm organization recently created [Helm Hub](https://hub.helm.sh/). It is a very convenient way to search for a chart and lets you access multiple / different repositories at once (like stable or incubator). Take a look and see, if you can find the chaoskube there as well.

## Step 3: install a chart
Run the following command to install the chaoskube chart. It installs everything that is associated with the chart into your namespace. Note the `--set` flags, which specify parameters of the chart.

```bash
helm install <any-name> stable/chaoskube --set namespaces=<your-namespace> --set rbac.serviceAccountName=chaoskube --debug
```

The parameter `namespaces` defines in which namespaces the chaoskube will delete pods. `rbac.serviceAccountName` specifies which serviceAccount the scheduled chaoskube pod will use. Here we give it the `chaoskube` account, which has been created as part of the cluster setup already. This is mainly because chaoskube wants to query pods across all namespaces - which requires a `ClusterRoleBinding` to the `ClusterRole  training:cluster-view`. As participants are not allowed to modify resources on cluster level, it is part of the setup to prepare for this exercise. If you want to know more defails, take a look at the [kubecfggen](../admin/kubecfggen/kubecfggen.sh) script.

To learn more about the configuration options the chaoskube chart provides, check again the github page mentioned above.

## Step 4: inspect your chaoskube
Next, check your installation by running `helm list`. It returns all installed releases including your chaoskube. You can reference it by its name.
Get more information by running `helm status <your-releases-name>`

Also check the pods running inside your kubernetes namespace. Don't forget to look into the logs of the chaoskube to see what would have happened with the dry-run flag set.
`kubectl logs -f pod/<your chaoskube-pod-name>`

## Step 5: clean up
Clean up by deleting the chaoskube:
`helm delete <your-releases-name>`

Now run `helm status <your-releases-name>` again. Though the pod has been removed from kubernetes, there are still meta information available.
To completely remove the list use `helm delete <your-releases-name>`.
