# Agenda Day 1 - Docker

## Basics of Containers and Docker
* Recap: What are Containers
  * Differences between containers and VMs
  * process and resource isolation
  * Demo: processes inside and outside of containers
* Overview over different container solutions
* Docker technologies

## Members of the Docker universe
* Linux features that enable containers
  * namespaces (with demo)
  * netfilter, cgroups, netlink, SELinux, capabilities, seccomp
* Exercise 0: Create naked containers with Linux primitives
* Containers
* Images
* Layers in images and containers
* Registries
* Docker's client/server architecture
* runC

## Working with containers
* Container lifecycle
* Running containers
  * creating, starting, stopping & destroying containers
  * attached/detached modes
  * getting logs from containers
* Debugging containers
  * executing commands in containers
  * getting logs
* Exercise 1: experiencing the container lifecycle, running commands in a container and searching through the logs
* Networking and persistent storage
  * network port forwarding
  * storage volumes
* Exercise 2: making a container accessible from the network and attaching a storage volume to it

## Images
* Recap: Image layers
  * read-only layers for images
  * read-write layer for containers
* committing changes to a container into an image
* dealing with registries
  * Docker Hub
  * Artifactory
  * private registries and logging on

## Creating Docker images
* outline of the Docker image build process
* Dockerfiles and the build context
* Structure and syntax of Dockerfiles
  * commonly used commands
  * do's and don'ts
* Exercise 4: Creating Images with Dockerfiles and uploading to a registry
* Structure and contents of an image
  * absolutely necessary files
  * directory structure
  * setup of Docker's logging facility
* Optional Exercise 5: Creating a Docker image from scratch
