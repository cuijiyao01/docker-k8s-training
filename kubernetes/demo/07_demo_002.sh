#!/bin/bash
if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

dir=$(realpath $(dirname $0))
source $dir/common.sh

# let the fun begin
clear
p 'This demo is about how we can create and use secret in different ways.'

step "create several secrets"
p 'show the content of 07c_demo_secret.yaml'

echo "======Content of 07c_demo_secret.yaml"
cat 07c_demo_secret.yaml |grep -E --color "env|name: data|$"
echo "======"
echo ""
pe "kubectl apply -f 07c_demo_secret.yaml"

step 'Show the secret now'
pe 'kubectl get secret |grep -E --color "admin-access|$"'
pe 'kubectl describe secret/admin-access-encoded'
pe 'kubectl describe secret/admin-access-plain'
pe 'kubectl describe secret/admin-access-file'

step "Lets inject the secrets as ENV to the container "
p 'show the content of the file : 07d_demo_pod_with_secret.yaml '

echo "======Content of 07d_demo_pod_with_secret.yaml"
cat 07d_demo_pod_with_secret.yaml |grep -E --color "name: admin|$"
echo "======"

step "start a pod"
pe 'kubectl apply -f 07d_demo_pod_with_secret.yaml'
pe 'kubectl get pod|grep -E --color "secret-input|$"'


step 'show the log of the pod'
pe 'kubectl logs pod/secret-input-encoded|grep -E --color "Secret4Ever|$"'
pe 'kubectl logs pod/secret-input-plain|grep -E --color "Secret4Ever|$"'
pe 'kubectl logs pod/secret-input-file|grep -E --color "Secret4Ever|$"'


step "clear"
pe 'kubectl delete secret/admin-access-encoded'
pe 'kubectl delete secret/admin-access-plain'
pe 'kubectl delete secret/admin-access-file'
pe 'kubectl get secret'
pe 'kubectl delete pod/secret-input-encoded'
pe 'kubectl delete pod/secret-input-plain'
pe 'kubectl delete pod/secret-input-file'
pe 'kubectl get pod'