# Setup Application Logging

Here you find a simple script `setup_logging.sh`, which deploys an complete EFK-Stack to your cluster (Elasticsearch, FluentBit, Kibana).

Kibana is reachable via an ingress with hostname `kibana`. Login to Kibana via ingress with username `admin` and password `T!;p&Nx:VsP!Sa$d` 

The setup is taken from a Gardener tutorial ([link](https://github.wdf.sap.corp/pages/kubernetes/gardener/015-tutorials/content/app/efk_logging/)).

## Clusterwide Resources

- Namespace: logging
- ClusterRole: fluent-bit-logging
- ClusterRoleBinding: fluent-bit-logging

## Namespaced Resources
All namespaced Resources are in the logging namespace

- ServiceAccount: fluent-bit
- DaemonSet: fluent-bit (+ ConfigMap, mounting Hostfilesystem)
- Deployment: kibana (+ Service, + Ingress with Gardener managed TLS cert & basic auth)
- StatefulSet: elasticsearch (+ two Services)
 