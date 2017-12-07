# Exercise 5 - persistence

In this exercise you will again create a simple pod with an nginx webserver and attach some storage to it.

## Step 0: Check your environment
Take a look around: `kubectl get PersistentVolumes` and `kubectl get PersistentVolumeClaims`
Inspect the resouces you found and find out how they are related (hint - look for `status: bound`).

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
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Create the resource: `kubectl create -f pvc.yaml`. Verify that your respective claim has been created and is bound to a PV.

### Step 2: Attach storage to a pod
Create a new nginx pod but this time with a volume & mount section. Use the snippet or download from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/pod_with_pvc.yaml)

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-storage-test
spec:
  volumes:
    - name: content-storage
      persistentVolumeClaim:
       claimName: nginx-pvc
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: content-storage
```

### Step 3: Create some content
Open a shell session into the pod with `kubectl exec nginx-storage-test bash` and navigate to the location specified in the `mountPath`.
Re-use the index.html from the other day or create some custom content and insert it into the local index.html file.

### Step 4: Check the content
Within the pod-shell session, run the subsequently mentioned commands. It will install the program `curl` locally in your pod. By running `curl localhost` you will send a  HTTP GET request to nginx asking for the index.html you just created.
```
apt-get update
apt-get install curl
curl localhost
```

### Step 5: delete & re-create the pod
Remove the pod from the cluster & re-create it. Once again, create a shell session into the pod and try to run `curl localhost` - it should not be present in the container. Re-run the update and install commands from the previous step and verify, your index.html file is still the same.

### Step 6 (optional): create a service pointing to the pod
Do you remember how to create a service? Try to label your pod and spin up a service for it. Access the index.htlm page via the service. 

