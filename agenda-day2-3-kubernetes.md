# Agenda Day 2 & 3 Kubernetes

## Basics
* Introduction to Kubernetes
  * Origin, release cycles, ...
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

## Core concepts
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
* Exercise - add a service and connect to application

## Storage & configuration
* Entities part 4
  * persistent volume
  * persistent volume claims
  * storage classes
* Exercise - add storage to your application
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
* Network policies
* Node management
* Scheduling pods on dedicated nodes
* get your cluster

## Helm
* what is helm?
* how to use it?
* Exercise - happy helming
