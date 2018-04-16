# Exercise: StatefulSet
In this exercise you will deploy a ngnix webserver as a StatefulSet and scale it.

## Step 0: Create a headless service
Firstly, you need to create a so called "headless" service. Services of this type explicitly specify their `clusterIP` with `None`. Try to create such a service and think of a suitable name as well as selector for labels. Either re-use an existing service yaml file or start a new one from scratch. Make sure, you refer to a [named port](https://stackoverflow.com/questions/48886837/how-to-make-use-of-kubernetes-port-names).
If you need inspiration, take a look at the example on [gitHub](./solutions/statefulset_with_svc.yaml).
Don't forget to deploy it to the cluster ;)

## Step 1: Build a StatefulSet
Now that you have the service, you meet the prerequisite to create a StatefulSet.

Next, describe your desired state in a yaml file. Use the snippets below to create a valid yaml file for a StatefulSet resource. Also fill in the blanks (marked with `???`) with values.
If you are looking for more info, check the official [api reference](https://kubernetes.io/docs/reference/) for StatefulSets.

```
apiVersion: apps/v1beta2 #change to apps/v1, when using a cluster with API v1.9 or greater
kind: StatefulSet
metadata:
  name: web
```   

```
volumeClaimTemplates:
- metadata:
    name: ???
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 1Gi
```

```
spec:
  replicas: 2
```

```
spec:
  containers:
  - name: nginx
    image: nginx:1.13.6
    ports:
    - containerPort: 80
      name: ???
    volumeMounts:
    - name: ???
      mountPath: /usr/share/nginx/html
```

```
serviceName: "???"
selector:
  matchLabels:
    ???: ???
```

```
template:
  metadata:
    labels:
      ???: ???
```

## Step 2: Ordered creation
Before you create the StatefulSet, open a 2nd terminal and start to watch the pods in you namespace: `watch kubectl get pods`

Now post your yaml file to the API server and monitor the upcoming new pods. You should observe the ordered creation of pods (by their ordinal index). Note that the pod name does not have any randomly generated string, but consists of the statefulset's name + the index.
Quickly connect to your pods and check the hostnames (change the loop's range here and in all following snippets, if you have more or less than 2 replicas): `for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done`

Additionally you should find new `PVC` resources in your namespace.

Quickly spin up a temporary deployment of a busybox and directly connect to it: `kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh`
Within this context, run `nslookup [pod-name].[service-name]` to check, if your individual pods are accessible via the service. You can also use `wget [pod-name].[service-name]` to download the index.html page from the nginx pod and look into it with `cat` or anything else.

## Step 3: Persist some data
To add some data to the attached storage, write the pod's hostname to the index.html page:
`for i in 0 1; do kubectl exec web-$i -- sh -c 'echo $(hostname) > /usr/share/nginx/html/index.html'; done`

Next, delete the pods of your StatefulSet while `watch`ing the pods in you namespace. Observe, how the pods will be re-created with the exact same names.

Again, spin up a temporary deployment of a busybox and directly connect to it. If you re-run `nslookup`, notice the IP addresses might have changed. Since you wrote the hostname to the index.html page, download it with `wget` and check for the expected content.

## Step 4 (optional): rolling udpate with canary
Statefulsets support advanced mechanisms to update to a new version (i.e. of the used container image). For this exercise, you will add an update strategy to your StatefulSet and perform an update with one pod serving as canary before moving all of your replicas to the new version.

Firstly increase the number of replicas to 3. Then continue by patching your Statefulset. The `partition` parameter controls the replicas that are patched based on an "equals or greater" evaluation of the ordinal index of the replica. If you have 3 replicas [0,1,2], a partition parameter with value "2" will limit the effect of an update to replica #2 only.  

`kubectl patch statefulset web -p '{"spec":{"updateStrategy":{"type":"RollingUpdate","rollingUpdate":{"partition":2}}}}'`

Examine the result (`get -o yaml`) or continue with the next step. Start a watch for the pods in you namespace. Then again, use the json path with the patch command to change the image version in your podSpec template:

`kubectl patch statefulset web --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"nginx:1.13.12"}]'`

Observe, how the pod `web-2` will be terminated and re-created. Check the image version of the updated pod:

`kubectl get po web-2 --template '{{range $i, $c := .spec.containers}}{{$c.image}}{{end}}'`

Once you tested the canary and want to move all replicas to the new version, move "partition" to "0".
