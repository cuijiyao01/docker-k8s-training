# Exercise 01 - kubectl basics

In this exercise you will learn how `kubectl` can be used to communicate with the cluster.

## Step 0: check your environment
Login to your VM and locate the kubectl binary by running `which kubectl`.
The result should return the path to the binary. Run `kubectl config get-contexts` to ensure a configuration file is available. 

## Step 1: check the nodes
Use the `kubectl get nodes` command to get the basic information about the clusters' nodes. Try to find out, how the output can be modified. Hint use the `-o <format>` switch. More information can be found by appending `--help` to your command.

## Step 2: get detailed information about a node
Now that you know the cluster node names, query more information about a specific node by running `kubectl describe node <node-name>`

## Step 3: advanced
Run the same query using `curl`. Hint: use `-v=9` to increase kubectl's verbosity and find the request.
