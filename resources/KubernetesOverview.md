# Kubernetes High-Level Concept Overview

## Concepts 

Concept | Purpose | Defines / controls / has feature 
--------|---------|----------------
Label   | Tag and select sets of K8S objects  | Set of name-value pairs used to define dependencies (who-uses-who)  
Pod | Runs co-located containers <br/>smallest deployable unit | Defines: which containers (images) to run; optional storage (volume) <br/> has shared exposed IP addr + ports, containers communicate via localhost 
Container | Lightweight and portable executable image that contains software and all of its dependencies | Get ENV from pod  
ReplicaSet | Ensures that a target number of pod instances is always running  | Uses ReplicaSet to define # of replicas, pod template  which container to use
Service   | Provide access to logical set of pods  | Defines: Logical set of pods (by label selectors), single stable IP address and DNS name to access them (only within the cluster i.e. between pods!)  
Deployment  |   |  
StatefulSet |   | 
Volume | | 
Secret   | Provide sensitive information to pods  |  
ConfigMap   |   |  
   |   |  
   |   |  
   
   
