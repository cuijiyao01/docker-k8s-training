#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear

#Create a PVC from yaml
#Show the storage class reference in the PVC yaml and the corresponding storage class within the cluster (kubectl get storageclass). These have to match!
#Query the PV’s and outline the connection between the PVC in the namespace and the PV. Print out the PV yaml and highlight that there is no namespace as PV resources are not namespaced.

#Create a pod where the PVC is mounted. Discuss the volume & volumeMount section and highlight the matching names for the volume within the pod spec to make it referenceable.
#Once the pod is created, logon to it and create some content.
#In parallel, create a deployment that attempts to mount the same PVC. 
#Discuss the error message (kubectl describe pod <pod of a deployment>)
#Outline the implication of the access-mode. If the PVC is already bound once in RWO mode, it cannot be bound in any other mode. 
#To get the example working the first pod would need to be removed and all other pods would  need to be re-created.

step "show PV"
pe 'kubectl --kubeconfig=/home/vagrant/.kube/train.admin.config.yaml get pv -A'
p 'check if there is a namespace '

pe 'kubectl get pv'
p 'check if there is a namespace '

step "show PVC"
pe 'kubectl --kubeconfig=/home/vagrant/.kube/train.admin.config.yaml get pvc -A'

step "show storage calss"
pe "kubectl --kubeconfig=/home/vagrant/.kube/train.admin.config.yaml get storageclass"


step 'create a PVC'
pe 'kubectl apply -f ./05_pvc.yaml'

step 'check/list PVC'
pe 'kubectl get pvc'

step 'create a pod and mount the PVC to a container'
pe 'kubectl apply -f 05_pod_with_pvc.yaml'
p 'check the service and pod'
pe 'kubectl get pod'
pe 'kubectl get pvc'
pe 'kubectl get pv|grep 0007'

pe "kubectl describe pod/nginx-storage-pod|sed -n '/Mounts/,/Qos/p;'|grep -E --color 'VolumeC|$'"

step "clear up"
pe 'kubectl delete pod/nginx-storage-pod'
pe "kubectl get pv|grep 0007|grep -E --color 'Bound|$'"
pe "kubectl get pvc|grep -E --color 'Bound|$'"
pe 'kubectl delete -f 05_pvc.yaml'
p 'check again'
pe "kubectl get pv|grep 0007"
pe "kubectl get pvc"