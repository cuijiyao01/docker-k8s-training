# Exercise 2 - create your first pod
Now that you know, how kubectl works and how the smallest entity on kubernetes looks like, it is time to create your own pod.

## Step 0: prepare a yaml file
Create a file named pod.yaml with the following content:
```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-http
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
```
Or download the raw file from [github](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/pod_example.yaml) with `curl` or `wget`.

In case you have issues with the creation of the pod, check the indentation or refer to the api specification [here](https://kubernetes.io/docs/reference/).

## Step 1: create the pod
Now tell the cluster that you would like it to schedule the pod for you. To do so, run the following command:
`kubectl create -f pod.yaml`

## Step 2: verify that the pod is running
Use `kubectl`with the `get` verb, to check, if your pod has been scheduled. It should be up and running after a few seconds. Check the [cheat-sheet](https://github.wdf.sap.corp/D051945/docker-k8s-training/blob/master/cheat-sheet.md) for help.
Experiment with `-o=yaml` to modify the output. Compare the result with your local `pod.yaml` file. Can you spot the odd/differences?

## Step 3: get the logs
Use `kubectl` with the `logs` command and get the logs of your pod. Check the [cheat-sheet](https://github.wdf.sap.corp/D051945/docker-k8s-training/blob/master/cheat-sheet.md) for help.

## Step 4: exec into your pod
In case `logs` or `describe` or any other of the output generating commands don't help you to get to the root cause of an issue, you may want to take a look yourself.
The `exec` command helps you in this situation. Adapt & run the following command, to open a shell session into the container running as part of the pod:

`kubectl exec <my-pod> bash`

## Step 5: clean-up
It's time to clean-up - go and delete the pod you created. But before open a second shell and run `watch kubectl get pods`. As usual adapt the namespace.
Now you can remove the pod from the cluster by running a `delete` command. Check the [cheat-sheet](https://github.wdf.sap.corp/D051945/docker-k8s-training/blob/master/cheat-sheet.md) for help.
Which phases of the pod do you observe in your second shell?
