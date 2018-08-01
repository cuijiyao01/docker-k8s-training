#!/bin/bash

CA_CERT=$(kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed -e "s/^\"//g" -e "s/\"$//g")
API_SERVER=$(kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.server" | sed -e "s/^\"//g" -e "s/\"$//g")
SA_SECRET=$(kubectl get sa pod-master -o json | jq ".secrets[0].name" | sed -e "s/^\"//g" -e "s/\"$//g")
NS=$(kubectl get sa pod-master -o json | jq ".metadata.namespace" | sed 's/"//g')
TOKEN=$(kubectl get secret ${SA_SECRET} -o json | jq '.data.token' | sed 's/"//g' | base64 --decode)

POD_MASTER_CONFIG=/tmp/__pod-master-kube.config

cat << __EOF > $POD_MASTER_CONFIG
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_CERT
    server: $API_SERVER
  name: k8s_training_cluster
users:
- name: pod-master
  user:
    token: $TOKEN
contexts:
- context:
    cluster: k8s_training_cluster
    user: pod-master
    namespace: $NS
  name: k8s-training-pod-master
current-context: k8s-training-pod-master
__EOF

OLDKUBECONFIG=$KUBECONFIG
export KUBECONFIG=$POD_MASTER_CONFIG
echo "Starting a temporary shell with a kube.config for service account pod-master."
echo -e "Exit from this shell once you are finised.\n"
bash --noprofile --norc
export KUBECONFIG=$OLDKUBECONFIG
rm -f $POD_MASTER_CONFIG
