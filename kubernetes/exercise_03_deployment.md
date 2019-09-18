# Exercise 3: Deployment

In this exercise, you will be dealing with _Pods_, **_Labels & Selectors_** and **_Deployments_**.

With the deletion of the pod all information associated with it have been removed as well. Though an unplanned, forcefully deletion is an unlikely scenario, it illustrates the lack of resilience of the pod construct quite well.

To overcome this shortage kubernetes offers a hierarchical constructed api. The pod, which encapsulated the container, is now wrapped in a more complex construct that takes care of the desired state - the deployment. In this case "desired state" means that a specified quorum of running instances is fulfilled.


## Step 0: deployments - the easy way
Run the following command and check what happens:
`kubectl create deployment nginx --image=nginx:1.12.2`
It should create a new resource of type `deployment` named "nginx". Use `kubectl get deployment nginx -o yaml` and `kubectl describe deployment nginx` to get more detailed information on the deployment you just created. Based on those information, determine the labels and selectors used by your deployment.

Can you figure out the name of the pod belonging to your deployment by using the label information? Hint: use the `-l` switch in combination with `kubectl get pods`

## Step 1: scaling
Congratulations, you created your first deployment of a webserver. Now it's time to scale:
`kubectl scale deployment nginx --replicas=3`
Check the number of pods and the status of your deployment. Also don't miss the labels being attached to the pods. Run `kubectl get pods -l app=nginx` to filter for the pods belonging to your deployment.

## Step 2: delete a pod :boom:
In this step you will test the resilience of your deployment. To be able to monitor the events open a second shell and run the following command:
`watch kubectl get pods`
Now delete a pod from your deployment and observe, how the deployment's desired state (replicas=3) is kept.
`kubectl delete pod <pod-name>`

## Step 3: rolling update
Basically you could also achieve all the previous steps with a so called ReplicaSet. And in fact, you did. A deployment itself does not manage the number of replicas. It just creates a ReplicaSet and tells it, how many replicas it should have.
Checkout the ReplicaSet created by your deployment:
`kubectl get replicaset`, try also `-o yaml` to see its full configuration.

But a deployment can do more than managing replicasets in order to scale. It also allows you to perform a rolling update. Run `watch kubectl rollout status deployment/nginx` to monitor the process of updating. Now trigger the update with the following command:

`kubectl set image deployment/nginx nginx=nginx:mainline --record`

Note that the `--record` option "logs" the `kubectl` command and stores it in the deployment's annotations. When checking the rollout history later, the command will be shown as change cause.

Once finished, check the deployment, pods and ReplicaSets available in your namespace. By now there should be two ReplicaSets - one scaled to 0 and one scaled to 3 (or whatever number of replicas you had before the update).

This way you would be able to roll back in case of an issue during update or with the new version. Check `kubectl rollout history deployment/nginx` for the existing versions of your deployment. By specifying `--revision=1` you will be able to get detailed on revision number one.


## Step 4: update & rollback
Now that already you know the `rollout status/history` commands, let's take a look at `undo`. 

Similar to the previous step, initiate another update while monitoring the rollout status (`kubectl rollout status deployment/nginx`) in parallel. However this time set the image version to an not existing tag. It could be a typo like `mianlin` or something completely different.

When listing the pods you should get one pod with an `ImagePullBackOff` error and the rollout should be stuck with the update of 1 new replica. 

Why is the responsible controller not attempting to patch all the other replicas in parallel? The deployment specifies a `maxUnavailable` parameter as part of its update strategy (`kubectl explain deployment.spec.strategy.rollingUpdate`). It defaults to 25%, which means in our case, that with 3 replicas no more than one pod at a time is allowed to be unavailable.

Since the attempt to patch the deployment to a new image obviously failed, you have to undo action:

`kubectl rollout undo deployment nginx`

Check the `rollout status` again to make sure, your image is `nginx:mainline` and all pods are up and running.

## Step 5: from file
Of course it is possible to create deployments from a yaml file. The following step gives an example, how it could look like.

Firstly, delete the deployment you just created:
`kubectl delete deployment nginx`

Secondly, try to write your own yaml file for a new deployment that creates 3 replicas of an `nginx` image, with version tag `mainline`.

Below is a skeleton of a deployment, however it is still missing some essential fields. Check the [api reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#deployment-v1-apps) for details.

* `kind: Deployment`
* `containers` (check the pod spec from exercise 2 or the deployment created with run)
* values for `matchLabels`

```yaml
apiVersion: apps/v1
metadata:
  name: nginx-deployment
  labels:
    tier: application
spec:
  replicas: 3
  selector:
    matchLabels:
  template:
    metadata:
      labels:
        run: nginx
    spec:
```

## Step 6: deploy(ment)!
Now create the deployment again. Remember that you can always use the `--dry-run` flag to test. Use the yaml file you just wrote instead of the `create` generator.

`kubectl apply -f <your-file>.yaml`

## Finally, do not delete the latest version of your deployment. It will be used throughout the following exercises.

## Troubleshooting
In case of issues with the labels, make sure that the `deployment.spec.selector.matchLabels` query matches the labels specified within the `deployment.spec.template.metadata.labels`.

The structure of a deployment can be found in the API documentation. Go to [API reference](https://kubernetes.io/docs/reference/) and choose the corresponding version (usually the training features a cluster with the latest or 2nd latest version). Within the API docs select the "Deployment".

Alternatively use `kubectl explain deployment`. To get detailed information about a field within the pod use its "path" like this: `kubectl explain deployment.spec.replicas`.

To create a new file with a skeleton of a deployment, right-click the Desktop within the training VM, select the context menu "new document" and choose "deployment". Additionally the solution to this exercise contains further explanatory comments.

## Further information & references
- [Deployments in K8s concepts documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [doing it the old way - replication controller](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)
- [labels in K8s](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
