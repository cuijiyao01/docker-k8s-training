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

step "Create the sceret files"
pe "echo admin > username.txt"
pe "echo Secret4ever > password.txt"

step "Create a secret from the command line or use the yaml"
pe "kubectl create secret generic admin-access --from-file=./username.txt --from-file=./password.txt"

step 'Show the secret now'
pe 'kubectl get secret |grep -E --color "admin-access|$"'
pe 'kubectl describe secret/admin-access'

step "Print the secret in yaml format and send the value for password to base64 -decode"
pe 'kubectl get secret admin-access -o=yaml'
pe 'echo U2VjcmV0NGV2ZXIK | base64 -d'

step "Schedule the demo pod for secrets (make sure the secret name matches) and query the logs"
p 'show the content of the file : 07e_demo_pod_with_secret.yaml '

echo "======Content of 07e_demo_pod_with_secret.yaml"
cat 07e_demo_pod_with_secret.yaml |grep -E --color "name: admin|$"
echo "======"

step "start a pod"
pe 'kubectl apply -f 07e_demo_pod_with_secret.yaml'
pe 'kubectl get pod|grep -E --color "secret-input|$"'

step 'show the log of the pod and highlight that the values are accessible in clear text within the pod context'
pe 'kubectl logs pod/secret-input|grep -E --color "admin|Secret4ever|$"'

step "clear"
pe 'kubectl delete secret/admin-access'
pe 'kubectl get secret'
pe 'kubectl delete pod/secret-input'
pe 'kubectl get pod'