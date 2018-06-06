# Kubernetes High-Level Concept Overview

## Concepts 

Concept | Purpose | Defines / controls / has feature 
--------|---------|----------------
Label   | Tag and select sets of K8S objects; <br/>attached to resources/objects | Sets of name-value pairs used to define dependencies (e.g. who-uses-who) 
Pod | Runs co-located containers <br/>smallest deployable unit | Defines: which **containers** (images) to run; provide ephemeral - or attach persistent storage (volume) <br/> containers share network, common IP address, different ports, communicate via localhost; <br/> optionally define liveness and readiness check endpoints
Container | Lightweight and portable executable image that contains software and all of its dependencies | Get ENV from pod  
Node | Run multiple pods <br/>provide system services to pods | Node is a VM that is part of the cluster 
ReplicaSet | Ensures that a target number of pod instances is always running  | Uses **ReplicaSet** (to define # of replicas) and **pod** template which container to use
Service   | Provide access to logical set of pods  | Defines: Logical set of **pods** (by label selectors), single stable IP address and DNS name to access them (only within the cluster i.e. between pods!)  
Deployment  | Run stateless pods and manage scaling and updates  | Defines: **ReplicaSet** (define pods and # of replicas), provides controlled updates (zero-downtime, rolling, ...)  
Volume | | 
Secret   | Provide sensitive information to pods  |  
ConfigMap   | Provide configuration to pod  |  
NameSpace   | Group most K8S objects to separate/share<br/> permissions and resource quotas  |  
DeamonSet  | Deploy pods (containers) to do system stuff  | One pod runs per node  
Cluster |    |  Set of nodes, storage (volume), ... plus all system services: API server, etcd, ...
   |    |  
StatefulSet | Manage deploy and scaling of stateful pods  | Provides unique identity to its pods and guarantees on ordering of deployment and scaling
Job   | Run pods as one-time job |  Define: **Pod** to run, number of pods, parallelism mode
CronJob  | Run time.based jobs    |  Run **job**s at given times; one-time or repeatedly by time & date
Ingress  | Provide external access to some services in the cluster   |  Define: ....  
   |    |  

   
   
