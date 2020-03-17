sudo microk8s.config > $HOME/.kube/config-microk8s
echo "Use export 'KUBECONFIG=$HOME/.kube/config-microk8s' to point kubectl to microk8s. (Or source this script)"
export KUBECONFIG=$HOME/.kube/config-microk8s
