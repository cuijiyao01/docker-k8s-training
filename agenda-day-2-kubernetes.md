# Agenda Day 2 Kubernetes

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
* Exercise 01 - kubectl basics
  * use kubectl to query information about the cluster

## Core concepts
* Entities part 1
  * namespaces
  * pods - schedule, describe, logs, exec
  * liveness & readiness probes
* Exercise 02
  * schedule a pod in your own namespace
  * get logs from your pod
  * exec into pod
* Entities part 2
  * labels
  * replica sets, deployments
* Exercise 03 - make your pod resilient to failure
  * create a deployment
  * how to scale
  * rolling updates
* Entities part 3
  * cluster networking
  * services (clusterIP, NodePort, Loadbalancer)
  * communication via services
* Exercise 04 - add a service and expose an application

## Storage
* Entities part 4
  * persistent volume
  * persistent volume claims
  * storage classes
* Exercise 05 - add persistent storage to your application

## Troubleshooting
* a short introduction to k8s troubleshooting
* how to gather information
* common errors & related pitfalls
