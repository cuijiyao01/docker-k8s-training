# Exercise 5 - persistence

In this exercise you will add some content to the pods in your deployment

## Step 0: Prepare & check your environment
Firstly, remove the deployment you created in the earlier exercise. Check the cheat sheet for the respective command.

Next, take a look around: `kubectl get PersistentVolumes` and `kubectl get PersistentVolumeClaims`. Are there already PV and PVC resources?
Inspect the resouces you found and try to figure out how they are related (hint - look for `status: bound`).

## Step 1: Create a PersistentVolume and a corresponding claim
Instead of creating a PersistentVolume (PV) first and then bind it to a PersistentVolumeClaim (PVC), you will directly request storage via a PVC using the default storage class.
This is not only convenient, but also helps to avoid confusion. PVC are bound to a namespace, PV resource are not. When there is a fitting PV, it can be bound to any PVC in any namespace. So there is some conflict potential, if your colleagues always claim your PV's :)
The conecpt of the storage classes overcomes this problem. The tooling masked by the storage class auto-provisions PV's of a defined volume type for each requested PVC.

Download the resource from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/pvc.yaml) or copy the snippet from below to your machine:

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nginx-pvc
spec:
  storageClassName: standard
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
```

Create the resource: `kubectl create -f pvc.yaml`. Verify that your respective claim has been created and is bound to a PV.

### Step 2: Attach the PVC to a pod
Create a new nginx pod but this time with a volume & mount section. Use the snippet or download from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/pod_with_pvc.yaml)

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-storage-pod
spec:
  volumes:
    - name: content-storage
      persistentVolumeClaim:
       claimName: nginx-pvc
  containers:
  - name: busybox
    image: busybox
    args:
    - sleep
    - "1000"
    volumeMounts:
    - mountPath: "/usr/share/nginx/"
      name: content-storage
```

### Step 3: Remove and re-attach the storage
Fistly, delete the busybox helper pod, you created earlier: ` kubectl delete pod nginx-storage-pod -n training-master`
Then create a new deployment that uses the `nginx-pvc`. However `run nginx` will not work this time, since you need to specify the volume mount. Try to extend the deployment.yaml from exercises 3 with a `volumes` and `volumeMounts` section. You can use the pod spec listed above as example.

Please note that our storage backend (`standard` storage class based on `gcePersistentDisk`) does not support `readWriteMany` mounts. You can either mount the volume once for write access (like you did in step 2) or several times as readOnly. Since our deployment has 3 replicas and we don't want to modify the `index.html`, mount the `nginx-pvc` by adding `readOnly: true` to both the `volumeMounts` and the `volumes.persistentVolumeClaim` sections.

In case you need a hint, check the prepared yaml file on [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/deployment_pvc.yaml).

Once you successfully created the deployment, check that all replicas are up and running.

### Step 4: Check the content
Remember the service from the previous exercise? Since the labels where not changed, the service will route incoming traffic to the new pods with the attached storage volume. Open a web browser and verfiy that your custom index.html page is displayed properly.
