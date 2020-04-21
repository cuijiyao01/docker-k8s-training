#!/bin/bash
cd "$(dirname "$0")"
sudo snap install microk8s --classic
sudo iptables -P FORWARD ACCEPT
sudo usermod -a -G microk8s vagrant
sudo microk8s.enable registry
sudo microk8s.enable dns
sudo microk8s.enable metrics-server
sudo microk8s.enable ingress
sudo microk8s.enable dashboard
sudo microk8s.enable rbac 
sudo microk8s.enable cilium 
sudo microk8s.enable storage

microk8s.kubectl delete -f crb-dashbaord.yaml
microk8s.kubectl create -f crb-dashbaord.yaml
# Simulate Loadbalancer
microk8s.kubectl apply -f loadBalancerPatch.yaml
# Create a storage calls with the name default
microk8s.kubectl apply -f storageclass.yaml

source ./set-kube-config.sh
