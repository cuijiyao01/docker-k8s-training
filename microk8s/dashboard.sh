#!/bin/bash

#microk8s.enable dashboard
#token=$(microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
#microk8s.kubectl -n kube-system describe secret $token
token=$(microk8s.kubectl -n kube-system get secret | grep kubernetes-dashboard-token | cut -d " " -f1)
microk8s.kubectl -n kube-system describe secret $token
DASHBOARD_IP=`microk8s.kubectl get service -n kube-system kubernetes-dashboard -o=jsonpath='{.spec.clusterIP}'`

firefox https://$DASHBOARD_IP

