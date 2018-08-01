# Docker and Kubernetes fundamentals  
#### (UNDER DEVELOPMENT)

This is the repo for the "docker & kubernetes fundamentals course". Gain basic Docker knowledge and learn to orchestrate your containers with Kubernetes. Get started with Docker and run your first container as well as build custom Docker images. When working with Kubernetes you will get to know the common entities in Kubernetes and apply your knowledge during exercises.
For an overview of topics see the agenda pages on top level.

Official course information: [Docker and Kubernetes Fundamentals](https://jam4.sapjam.com/blogs/show/P2dUZRL6WyEY8FYqqGyaAR)  (part of [Cloud Curriculum](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/overview_page/Y1fECzZLQ8qjIlyCQTRi76)  )

> For a comparison of SAP CP platforms and when to use what, see the [Platform Guide](https://wiki.wdf.sap.corp/wiki/x/Vwg4bg)

## Course outline
High level topics are:

### [Docker](./docker) (day 1)
- Container basics: Linux primitives, Containers vs. VMs ([slides](./docker/01_Basics_of_containers.pptx), [demo](./container-demos), [exercise](./docker/Exercise/Exercise%200%20-%20Linux%20Primitives.md))
- Linux foundations: How docker works 
- Using containers; Load, start, stop, inspect, debugging
- Images: Loading, creating, push/pull, image registries
- Storage / volumes: Assigning and using persistent disks
- Dockerfiles: Automated creation of docker images

### [Kubernetes](.kubernetes) (day 2+3)
- components of a K8s cluster
- scheduling of workloads with pods & deployments or statefulSets
- networking in k8s with services and ingress
- storage API in k8s
- configure applications with config maps and secrets
- manage a cluster with namespaces, role based authorization and network policies
- deploy packaged applications with helm

## Preparation and Setup

Follow the instructions on the page [Prerequisites and Environment Setup](https://github.wdf.sap.corp/slvi/docker-k8s-training/blob/master/preparation.md).

## Course developers and Trainers

* The VM to be used by participants is built here: https://github.wdf.sap.corp/cloud-native-dev/k8s-training-vm
* See also the [Trainer Guide](https://github.wdf.sap.corp/slvi/docker-k8s-training/blob/master/admin/trainer-guide.md)
