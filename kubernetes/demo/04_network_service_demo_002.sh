#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear

step 'create a deployment of an nginx webserver first'
pe 'kubectl run nginx-demo --image=nginx:mainline'

step 'Create a service'
 
echo 'expose a service(type=NodePort) for your deployment'
pe 'kubectl expose deployment nginx-demo --port=80 --target-port=80 --type=NodePort'
#Explain the command and the ports (port = service, target-port = pod)
step 'Show the service with the clusterIP address and associated end points'
pe "kubectl describe svc/nginx-demo"

step "Scale the deployment up and show again the updated list of end points"
pe "kubectl scale --replicas=2 deployment/nginx-demo"

step "show service again"
pe "kubectl describe svc/nginx-demo"

step "connect to the service in VM directly"
#nodePort=`kubectl get svc/nginx-demo -o=jsonpath='{.spec.ports[0].nodePort}'`
pe "nodePort=`kubectl get svc/nginx-demo -o=jsonpath='{.spec.ports[0].nodePort}'`"
# kubectl get nodes -o=wide|awk -F'[[:space:]]+' '{print $6}' |sed '1d'
pe "nodeIp=`kubectl get nodes -o=wide|awk -F'[[:space:]]+' '{print $6}' |sed '1d'`"
pe "wget ${nodeIp}:${nodePort}"

step "delete the service"

pe "kubectl delete svc/nginx-demo"
pe "kubectl delete deployment/nginx-demo"

step "check the services"
pe "kubectl get deployment"
pe "kubectl get svc"