# Exercise 01 - kubectl basics

In this exercise you will learn how `kubectl` can be used to communicate with the cluster.

## Step 0: check your environment
Login to your VM and locate the kubectl binary by running `which kubectl`.
The result should return the path to the binary. Run `kubectl config get-contexts` to ensure a configuration file is available.

## Step 1: check the nodes
Use the `kubectl get nodes` command to get the basic information about the clusters' nodes. Try to find out, how the output can be modified. Hint: use the `-o <format>` switch. More information can be found by appending `--help` to your command.

## Step 2: get detailed information about a node
Now that you know the cluster's node names, query more information about a specific node by running `kubectl describe node <node-name>`. What is the `kubelet` version running on this node and which pods are running on this node?

## Step 3: kubectl proxy
The `kubectl proxy` command allows you to open a tunnel to the API server and make it available locally - usually on `localhost:8001` / `127.0.0.1:8001`. When you want to explore the API, this is an easy way to gain access.

Run the proxy command in a new terminal window and open `localhost:8001` in your VM's browser. Traverse through the `api/v1/` and search for the cluster nodes.  

## Step 4: talk to kubernetes like an application
If you access kubernetes as an application rather than an administrator, you cannot use the the convenient syntax of `kubectl`. Instead you have to send http requests to the cluster. Though there are client libraries available, in the end everything boils down to an http request.
In this step of the exercise, you will send an http request directly to the cluster asking for the available nodes. Instead of `kubectl` you can use the program `curl`.

To figure out, how `kubectl` converts your query into http requests, run the command from step 1 again and add a `-v=9` flag to it. This increases the verbosity of `kubectl` drastically, showing you all the information you need. Go through the command's output and find the correct curl request.

Before you continue, make sure `kubectl proxy` is running and serving on `localhost:8001`. Now modify the request to be send via the proxy. Since the proxy has already taken care of authentication, you can omit the bearer token in your request.

Hint: if the output is not as readable as you expect it, consider changing the accepted return format to `application/yaml`.

## Step 5: api-versions & api-resources
Dealing with the API directly can be cumbersome. Therefore `kubectl` offers the `api-versions` command. Give it a try and compare the output with results from step 4.

With kubernetes version 1.11 the `kubectl` binary was extend with an `api-resources` function. It lets you discover resources available in your cluster.
Run the command and search for the short name for the `nodes` resource. Can you `describe` a node using the short name notation?  

## optional Step 6 - learn some tricks
There is a forum-like page hosted by K8s with lots of information around `kubectl` and how to use it best. If you are curious, take a look at https://discuss.kubernetes.io/t/kubectl-tips-and-tricks/.
