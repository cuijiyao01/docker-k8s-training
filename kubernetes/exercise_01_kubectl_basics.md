# Exercise 01 - kubectl basics

In this exercise you will learn how `kubectl` can be used to communicate with the cluster.

## Step 0: check your environment
Login to your VM and locate the kubectl binary by running `which kubectl`.
The result should return the path to the binary. Run `kubectl config get-contexts` to ensure a configuration file is available.

## Step 1: check the nodes
Use the `kubectl get nodes` command to get the basic information about the clusters' nodes. Try to find out, how the output can be modified. Hint use the `-o <format>` switch. More information can be found by appending `--help` to your command.

## Step 2: get detailed information about a node
Now that you know the cluster's node names, query more information about a specific node by running `kubectl describe node <node-name>`. What is the `kubelet` version running on this node and which pods are running on this node?

## Step 3: advanced - talk to kubernetes like an application
If you access kubernetes as an application rather than an administrator, you cannot use the the convenient syntax of `kubectl`. Instead you have to send http requests to the cluster. Though there are client libraries available, in the end everything boils down to an http request.
In this step of the exercise, you will send an http request directly to the cluster asking for the available nodes. Instead of `kubectl` you can use the program `curl` to talk to the cluster and send requests.

To figure out, how `kubectl` converts your query into http requests, run the command from step 1 again and add a `-v=9` flag to it. This increases the verbosity of `kubectl` drastically, showing you all the information you need. Find the right request and send it yourself using curl.

Hint: if the output is not as readable as you expect it, consider changing the accepted return format to `application/yaml`.
