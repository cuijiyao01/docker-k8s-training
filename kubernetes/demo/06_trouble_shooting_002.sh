#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear
p 'This demo is about services and how they relate to endpoints.'
step "Start by deploying 06c_service_issues.yaml"
pe "kubectl apply -f 06c_service_issues.yaml"

p 'Get the public IP of the service and open it in a browser'
pe 'kubectl get svc/webserver-service'

loadBalancerIP=`kubectl get svc/webserver-service|sed -n '2p'|awk -F'[[:space:]]+' '{print $4}'`
until [[ $loadBalancerIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];
do
  pe "IP not assigned, let's try again"
  pe 'kubectl get svc/webserver-service'
  loadBalancerIP=`kubectl get svc/webserver-service|sed -n '2p'|awk -F'[[:space:]]+' '{print $4}'`
done

step "now open the browser"
pe "chrome.sh http://${loadBalancerIP}:80"

step "now describe the service"
p 'The answer should be something like “this site can’t be reached”'
p 'Show the service with describe highlight the empty “endpoints” list'
echo ""
echo ""
pe "kubectl describe svc/webserver-service |grep -E --color 'Endpoints.*$|$'"

step "Scale the deployment up to 3 and reload the page to display the welcome text"
pe 'kubectl scale --replicas=3 deployment/webserver'

replicas=`kubectl get deployment/webserver -o=jsonpath='{.status.availableReplicas}'`
until [ "X$replicas" == "X3" ];
do
  p "only $replicas/3 pods are ready, let wait for all pods to be ready"
  replicas=`kubectl get deployment/webserver -o=jsonpath='{.status.availableReplicas}'`
done
p "Now $replicas/3 pods are ready"
p 'Again, describe the service and show the endpoints list' 
pe "kubectl describe svc/webserver-service |grep -E --color 'Endpoints.*$|$'"


step "Check If it works"
p "Refresh your browser"
curl http://${loadBalancerIP}:80 | grep -E --color "This is my web-frontend|$"

step "Next, run the selection query of the service manually"
pe "kubectl get pods -l tier=web-frontend -o wide"

p "The IP addresses of the pods and the service endpoints should match"

step "show document"
echo  "10 most common reasons why k8s deployments fail"
echo  'https://kukulinski.com/10-most-common-reasons-kubernetes-deployments-fail-part-1/'
echo  'https://kukulinski.com/10-most-common-reasons-kubernetes-deployments-fail-part-2/'