# Agenda Day 2 & 3 Kubernetes

## Basics
* Introduction to Kubernetes
  * Origin, release cycles, ...
  * Sock-Shop Demo
* Core components
  * nodes
  * kubelet
  * api server & rest API
  * etcd
  * kube-proxy
  * kubectl
  * yaml & json + basic structure of k8s resources
* Exercise - kubectl basics
  * use kubectl to query information about the cluster

## Core concepts
* Entities part 1
  * namespaces
  * pods - schedule, describe, logs, exec
  * liveness & readiness probes
* Exercise
  * schedule a pod in your own namespace
  * get logs from your pod
  * exec into pod
* Entities part 2
  * labels
  * replica sets, deployments
* Exercise - make your pod resilient to failure
  * create a deployment
  * how to scale
  * rolling updates
* Entities part 3
  * cluster networking
  * services (clusterIP, NodePort, Loadbalancer)
  * communication via services
* Exercise - add a service and expose an application

## Storage & configuration
* Entities part 4
  * persistent volume
  * persistent volume claims
  * storage classes
* Exercise - add persistent storage to your application
* Entities part 5
  * secrets
  * config maps
* Exercise - configure your nginx & add certificates

## Furhter entities
* networking
* workloads
* administration

## Administration
* User management - service accounts
* Role based authorization (RBAC)
* Image pull secrets
* Network policies
  * Excercise - add a network policy to the nginx deployment
* Node management
* Kubernetes Dashboard
* Scheduling pods on dedicated nodes
* get your own cluster

## Helm
* what is helm?
* how to use it?
* Exercise - happy helming
