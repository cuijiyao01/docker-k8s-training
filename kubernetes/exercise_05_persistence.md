# Exercise 5: Persistence

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, **_Persistent&nbsp;Volumes_**, **_Persistent&nbsp;Volume&nbsp;Claims_** and **_Storage Classes_**.

After you exposed your webserver to the network in the previous exercise, we will now add some custom content to it which resides on persistent storage outside of pods and containers. 

**Note**: This exercise loosely builds upon the previous exercise. If you did not manage to finish the previous exercise successfully, you can use the YAML file [04_service.yaml](solutions/04_service.yaml) in the *solutions* folder to create a service. Please use this file only if you did not manage to complete the previous exercise.

## Step 0: Prepare and check your environment
Firstly, remove the deployment you created in the earlier exercise. Check the cheat sheet for the respective command.

Next, take a look around: `kubectl get persistentvolume` and `kubectl get persistentvolumeclaims`. Are there already resources present in the cluster?
Inspect the resources you found and try to figure out how they are related (hint - look for `status: bound`).

By the way, you don't have to type `persistentvolume` all the time. You can abbreviate it with `pv` and similarly use `pvc` for the claim resource.

## Step 1: Create a PersistentVolume and a corresponding claim
Instead of creating a PersistentVolume (PV) first and then bind it to a PersistentVolumeClaim (PVC), you will directly request storage via a PVC using the default storage class.
This is not only convenient, but also helps to avoid confusion. PVC are bound to a namespace, PV resource are not. When there is a fitting PV, it can be bound to any PVC in any namespace. So there is some conflict potential, if your colleagues always claim your PV's :)
The concept of the storage classes overcomes this problem. The tooling masked by the storage class auto-provisions PV's of a defined volume type for each requested PVC.

Download the resource from [gitHub](./solutions/05_pvc.yaml) or copy the snippet from below to your VM:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nginx-pvc
spec:
  storageClassName: default
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
```

Create the resource: `kubectl create -f pvc.yaml`. Verify that your respective claim has been created and is bound to a PV.

## Step 2: Attach the PVC to a pod
Create a helper pod with a volume and mount section to get access to your PVC. The snippet below is not complete, so fill in the `???` with the corresponding values.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-storage-pod
spec:
  volumes:
    - name: content-storage
      persistentVolumeClaim:
       claimName: ???
  containers:
  - name: helper
    image: alpine:3.8
    args:
    - sleep
    - "1000"
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: ???
```

### Step 3: create custom content
Locate the alpine pod and open a shell session into it: `kubectl exec -ti nginx-storage-pod ash`
Alpine Linux has no `bash` binary, `ash` is actually correct :wink:
Navigate to the directory mentioned in the `volumeMounts` section and create a custom `index.html`. You can re-use the code you used in the docker exercises the other day. Once you are done, disconnect from the pod and close the shell session.

### Step 4: Remove and re-attach the storage
Delete the alpine helper pod, you created earlier: ` kubectl delete pod nginx-storage-pod`
Then create a new deployment that uses the `nginx-pvc`. However `create nginx` will not work this time, since you need to specify the volume mount. Extend the deployment.yaml from exercises 3 with a `volumes` and `volumeMounts` section. You can use the pod spec listed above as an example.

Please note that our storage backend (`default` storage class based on [`gcePersistentDisk`](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk)) does not support `readWriteMany` mounts. You can either mount the volume once for write access (like you did in step 2) or several times as readOnly. Since our deployment has 3 replicas and we don't want to modify the `index.html`, mount the `nginx-pvc` by adding `readOnly: true` to both the `volumeMounts` and the `volumes.persistentVolumeClaim` sections.

Once you successfully created the deployment, check that all replicas are up and running.

### Step 5: Check the content
Remember the service from the previous exercise? Since the labels where not changed, the service will route incoming traffic to the new pods with the attached storage volume. Open a web browser and verify that your custom index.html page is displayed properly.

**Important: do not delete the deployment,service or PVC**


## Troubleshooting
In case the pods of the deployment stay in status `Pending` or `ContainerCreation` for quite some time, make sure the pod `nginx-storage-pod` got deleted. Also check the events of one of the pods by running `kubectl describe pod <pod-name>`. 

#### Resource already in use?

If one of the events is a warning that contains something like "resource already in use", delete the deployment as well as the pod `nginx-storage-pod` (if not already done) but do NOT delete the PVC. Next, wait around 1-2min, to ensure that the referenced storage device is unmounted from the node, where it was used before. Then re-create the deployment.  

#### How to check if a disk is mounted!

You can try to see if the storage device is unmounted by:
1. Use `kubectl get pvc <pcv-name>` to get the name of the bounded persistent volume.
2. Use `kubectl get pv <pv-name> -o json | jq ".spec.gcePersistentDisk"` to get the name of the physical disk used by the persistent volume.
3. Use `kubectl get nodes -o yaml | grep <physical-disk-name>` to see if the physical disk is still conected to a node? If it is you get  3 lines per connected node. 

#### ReadOnly is needed twice

If only **one** pod of your deployment reaches running state make sure you have defined `readOnly: true` at the volumes ***and*** at the volumeMounts part of the deployment. If you forgot, add both readOnly statements, delete the old deployment, wait for the unbinding of the disk from the nodes and reapply the fixed deployment to the cluster.  
You need it in both places because: 
- The addition of `readOnly: true` at the volumes part tells k8s to mount the disk with readOnly to each node. This is needed to be able to mount the disk to multiple nodes. 
- The addition of `readOnly: true` at the volumeMounts part tells k8s to do the docker bind mount into the container also with readOnly. Since the disk is mounted readOnly docker **can not** mount the volume with read&write access into the container. 

#### Service Problems

In case your service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to. 

#### Caching issues

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level and display the custom page, append a URL parameter with a random number (like 15): `http:<LoadBalancer IP>/?random=15`.

## Further information & references
- descripton of the [volumes API](https://kubernetes.io/docs/concepts/storage/volumes/)
- how to use [PV & PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [volume snapshots](https://kubernetes.io/docs/concepts/storage/volume-snapshots/)
