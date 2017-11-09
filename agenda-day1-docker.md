# Agenda Day 1 - Docker

## Basics of Containers
* Recap: What are Containers
* Differences between containers and VMs
  * process and resource isolation
* Overview over current container solutions
  * Docker
  * RKT
  * LXC/LXD
# Docker
* Where is it used, what is it good for?
* Members of Docker's universe
  * Client-Server architecture and the docker client
  * Containers, Images and registries
  * dockerd
  * runC
  * Layers, OverlayFS
  * Linux namespaces, cgroups, capabilities, seccomp profiles, app-armor
  * configuring the docker daemon
* Working with containers
  * Container lifecycle
  * persistent storage
  * Containers, networks and ports
* Creating Images
  * Dockerfiles
  * Docker build
  * Resources
  * Publishing Images
* Container Networks
  * IP addressing and NAT-ing
  * DNS lookups
  * ports
  * overlay networking
