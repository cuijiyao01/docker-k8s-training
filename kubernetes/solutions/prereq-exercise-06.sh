#!/bin/bash

function create_pvc {
  cat << '__EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  storageClassName: default
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
---
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
  - name: helper
    image: alpine:3.8
    command: ["/bin/sh", "-c", "echo '<html><head><title>My first webpage...</title></head><body><h1>This is my custom webpage, this is so great.</h1></body></html>' > /usr/share/nginx/html/index.html"]
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: content-storage
  restartPolicy: Never
__EOF

  echo "Waiting for the storage pod to complete..."
  i=0
  while [ -z "$completed" ]; do
  	status=$(kubectl get pod nginx-storage-pod -o jsonpath={.status.containerStatuses[0].state.terminated.reason})
	  if [ "$status" == "Completed" ]; then
	  	completed="true"
	  fi
  	i=$((i+1))
	  if [ $i -gt 60 ]; then
	  	echo "This took longer than two minutes. Something seems to be wrong, stopping here..."
	  	exit 1
	  fi
	  sleep 2
  done
  
  kubectl delete pod nginx-storage-pod
  echo "Waiting 15 seconds to make sure volumes got unmounted from nodes..."
  sleep 15
}

pvc_status=$(kubectl get pvc nginx-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$pvc_status" != "Bound" ]; then
	create_pvc
fi

cat << '__EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-pvc
spec:
  replicas: 3
  selector:
    matchLabels:
      run: nginx-deployment
      storage: attached
  template:
    metadata:
      labels:
        run: nginx-deployment
        storage: attached
    spec:
      volumes:
      - name: content-storage
        persistentVolumeClaim:
          claimName: nginx-pvc
          readOnly: true
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
          name: http-port
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: content-storage
          readOnly: true
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-deployment
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    name: http
  selector:
    run: nginx-deployment
  type: LoadBalancer
__EOF
