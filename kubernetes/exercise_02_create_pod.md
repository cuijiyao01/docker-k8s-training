# Exercise 2 - create your first pod
Now that you know, how kubectl works and what the smallest entity on kubernetes looks like, it is time to create your own pod.

## Step 0: prepare a yaml file
In kubernetes all resources have a well-described schema that is documented in the API definition. For example, the `Pod` resource is defined by `kind: Pod` and contains a `PodSpec`, which has a `Container`, which has an `Image`, which specifies the docker image to use, when running the pod.

In this step you are going to describe a pod in a yaml file (`pod.yaml`). Take the skeleton listed below and insert the field/values mentioned below at the right place.
* `kind: Pod`
* `name: nginx-liveness-pod` (metadata)
* `image: nginx:mainline`

Either check the official [API reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#pod-v1-core) of the pod resource for help or use `kubectl explain pod` to get a command-line based description of the resource. By appending `.<field>` to the resource type, the explain command will provide more details on the specified field (example: `kubectl explain pod.spec`).

```
apiVersion: v1
metadata:
spec:
  containers:
  - name: nginx
    ports:
    - containerPort: 80
      name: http-port
    livenessProbe:
      httpGet:
        path: /
        port: http-port
      initialDelaySeconds: 3
      periodSeconds: 30
```

## Step 1: create the pod
Now tell the cluster that you would like it to schedule the pod for you. To do so, run the following command:

`kubectl create -f pod.yaml`

If it does not work as expected, check the indentation and consult the API reference linked above.

## Step 2: verify that the pod is running
Use `kubectl`with the `get` verb, to check, if your pod has been scheduled. It should be up and running after a few seconds. Check the [cheat-sheet](./cheat-sheet.md) for help.
Experiment with `-o=yaml` to modify the output. Compare the result with your local `pod.yaml` file. Can you spot the odd/differences?

## Step 3: get the logs
Use `kubectl` with the `logs` command and get the logs of your pod. Check the [cheat-sheet](./cheat-sheet.md) for help.
You should see the liveness probe requests coming in.

## Step 4: exec into your pod
In case `logs` or `describe` or any other of the output generating commands don't help you to get to the root cause of an issue, you may want to take a look yourself.
The `exec` command helps you in this situation. Adapt and run the following command, to open a shell session into the container running as part of the pod:

`kubectl exec -ti <my-pod> bash`

## Step 5: clean-up
It's time to clean-up - go and delete the pod you created. But before open a second shell and run `watch kubectl get pods`.
Now you can remove the pod from the cluster by running a `delete` command. Check the [cheat-sheet](./cheat-sheet.md) for help.
Which phases of the pod do you observe in your second shell?
