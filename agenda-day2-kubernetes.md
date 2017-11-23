# Agenda Day 2 Kubernetes

## Basics
* Introduction to Kubernetes
  * Origin, release cycles, fun facts?
  * Demo
* Core components
  * nodes
  * kubelet
  * api server & rest API
  * etcd
  * kube-proxy
  * kubectl
  * yaml & json
* Exercise - kubectl basics
  * use kubectl to query information
* Entities part 1
  * namespaces
  * pods - schedule, describe, logs, exec
* Exercise
  * schedule a pod in your own namespace
  * get logs from your pod
  * exec into pod
* Entities part 2
  * labels
  * replica sets, deployments
* Exercise - make your pod resilient to failure
* Entities part 3
  * services
  * overlay network
* Exercise - add a service and connect to application
* Entities part 4
  * persistent volume
  * persistent volume claims
  * storage classes
* Exercise - add storage to your application
* Entities part 5
  * secrets
  * credentials
  * config maps
* Exercise - configure your nginx & add certificates
* Entities part 6
  * user management - service accounts

## Special interest topics
* Lifecycle mechanisms - rolling updates
* further entities - jobs, daemonsets
* custom scheduling
* administration - taint, ready, no scheduling, ...
