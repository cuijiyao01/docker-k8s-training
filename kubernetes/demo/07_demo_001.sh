#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear
p 'This demo is about how we can manage config map.'

step "create a config map 'test-config' with two keys"
pe "kubectl create configmap test-config --from-literal=test.type=unit --from-literal=test.exec=always"

step 'Show the config map now'
pe 'kubectl get configmap'
pe 'kubectl describe configmap/test-config'

step "Lets inject the config map as ENV to the container "
p 'show the content of the file : 07b_pod_with_configmap.yaml '

echo "======Content of 07b_pod_with_configmap.yaml"
cat 07b_pod_with_configmap.yaml |grep -E --color "env|name: test-config|$"
echo "======"

step "start a pod"
pe 'kubectl apply -f 07b_pod_with_configmap.yaml'
pe 'kubectl get pod|grep -E --color "test-configmap|$"'
p 'wait if to be completed'
status=`kubectl get pod|grep test-configmap|awk -F'[[:space:]]+' '{print $3}'`
until [ "X$status" == "complete" ];
do
  status=`kubectl get pod|grep test-configmap|awk -F'[[:space:]]+' '{print $3}'`
done

step 'show the log of the pod'
pe 'kubectl logs pod/test-configmap|grep -E --color "TEST|$"'


step "clear"
pe 'kubectl delete configmap/test-config'
pe 'kubectl get configmap'
pe 'kubectl delete pod/test-configmap'
pe 'kubectl get pod'