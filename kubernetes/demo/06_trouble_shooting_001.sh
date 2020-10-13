#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear

step "show the content of the yaml"
pe "cat 06a_crashloop.yaml|grep -E --color 'no-such-cmd|$'"


step "now let's create such pod"
pe 'kubectl apply -f 06a_crashloop.yaml'

step "check the pod now"
pe 'kubectl get pod|grep crash-loop'

step "check the pod again"
pe 'kubectl get pod|grep crash-loop'

step " run the App failure demo"

step "show the content of the yaml"
pe "cat 06b_app_failure.yaml|grep -E --color 'index-html|$'"


step "now let's create the pod"
pe 'kubectl apply -f 06b_app_failure.yaml'
pe "kubectl get pod|grep -E --color 'app-failure|$'"

step "forward the port"
pe 'kubectl port-forward app-failure 8080:80'

step "now open the browser"
pe "chrome.sh http://localhost:8080"

step "show logs"
pe 'kubectl logs app-failure'

step "quit and clear" "-p"
pe 'kubectl delete -f 06b_app_failure.yaml'