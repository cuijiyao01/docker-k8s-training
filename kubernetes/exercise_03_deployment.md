# Exercise 3: Deployment
With the deletion of the pod all information associated with it have been removed as well. Though an unplanned, forcefully deletion is an unlikely scenario, it illustrates the lack of resilience of the pod construct quite well.

To overcome this shortage kubernetes offers a hierachical constructed api. The pod, which encapsulated the container, is now wrapped in a more complex construct that takes care of the desired state - the deployment. In this case "desired state" means that a specified quorum of running instances is fulfilled.


## Step 0: deployments - the easy way
Run the following command and check what happens:
`kubectl run  nginx --image=nginx:1.12.2`
It should create a new resource of type `deployment` named "nginx". Use `kubectl get deployment nginx -o yaml` and `kubectl describe deployment nginx` to get more detailed information on the deployment you just created. Based on those information, determine the labels & selectors used by your deployment.

Can you figure out the name of the pod belonging to your deployment by using the label information? Hint use `-l` switch in combination with `kubectl get pods` 

## Step 1: scaling
Congratulations, you created your first deployment of a webserver. Now it's time to scale:
`kubectl scale deployment nginx --replicas=3`
Check the number of pods and the status of your deployment. Also don't miss the labels being attached to the pods. Run `kubectl get pods -l run=nginx` to filter for the pods belonging to your deployment.

## Step 2: delete a pod :boom:
In this step you will test the resilience of your deployment. To be able to monitor the events open a second shell and run the following command:
`watch kubectl get pods`
Now delete a pod from your deployment and observe, how the deployment's desired state (replicas=3) is kept.
`kubectl delete pod <pod-name>`

## Step 3: rolling update
Basically you could also achieve all the previous steps with a so called ReplicaSet. And in fact, you did. A deployment itself does not manage the number of replicas. It just creates a ReplicaSet and tells it, how many replicas it should have.
Checkout the ReplicaSet created by your deployment:
`kubectl get replicaset`, try also `-o yaml` to see its full configuration.

But a deplyoment can do more than managing replicasets in order to scale. It also allows you to perform a rolling update. Run `watch kubectl rollout status deployment/nginx` to monitor the process of updating. Now trigger the  update with the following command:

`kubectl set image deployment/nginx nginx=nginx:1.13.6`

Once finished, check the deplyoment, pods and ReplicaSets available in your namespace. By now there should be two ReplicaSets - one scaled to 0 and one scaled to 3 (or whatever number of replicas you had before the update).

This way you would be able to roll back in case of an issue during update or with the new version. Check `kubectl rollout history deployment/nginx` for the existing versions of your deployment. By specifying `--revision=1` you will be able to get detailed on revision number one.

## Step 4 - optional: prepare for the hard way
Of course it is possible to create deployments from a yaml file. The following steps give an example, how it could look like.

Firstly, delete the deployment you just created:
`kubectl delete deployment nginx`
Secondly, create a new yaml file from the snippet below
```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    run: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.13.6
        ports:
        - containerPort: 80
```

or download from github with `wget https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/deployment_example.yaml`.

## Step 5 - optional: deploy(ment)!
Now create the deployment again. However this time it will be created based on the yaml file:
`kubectl create -f <your-file>.yaml`
