# Setup Application Logging

Here you find a simple script `setup_logging.sh`, which deploys an complete **EFK-Stack** to your cluster (Elasticsearch, FluentBit, Kibana).

Kibana is reachable via an ingress with hostname `kibana`. Login to Kibana via ingress with username `admin` and password `T!;p&Nx:VsP!Sa$d`. 

The setup is inspired by a Gardener tutorial ([link](https://github.wdf.sap.corp/pages/kubernetes/gardener/015-tutorials/content/app/efk_logging/)). 

## Usage
Open up a terminal on a system where `kubectl` is installed and a `kubeconfig` is in place targeting the cluster.
Executing the script will deploy all necessary resources.
When opening Kibana the first time, on the Welcome-Screen you should choose the "Explore on my own" option.
After that you need to create an Index-Pattern `logstash*` with a Time-Filter `@timestamp`.

## Clusterwide Resources

- Namespace: `logging`
- ClusterRole: `fluent-bit-logging`
- ClusterRoleBinding: `fluent-bit-logging`

## Namespaced Resources
All namespaced Resources are in the logging namespace

- ServiceAccount: `fluent-bit`
- DaemonSet: `fluent-bit` (+ ConfigMap, mounting Hostfilesystem)
- Deployment: `kibana` (+ Service, + Ingress with Gardener managed TLS cert & basic auth)
- StatefulSet: `elasticsearch` (+ two Services)

## Additional Comments
When deploying such a logging system inside of the cluster itself you schould be carefully and exclude any logs that are produced by the components, which are doing the logging. Otherwise you can easily produce logs in a loop. 
To reduce that problem it might be a good option to run the database and kibana outside of the cluster. 
A Gardener tutorial following this approach using a `SAP Application Logging Service` can be found [here](https://github.wdf.sap.corp/pages/kubernetes/gardener/015-tutorials/content/howto/logging-as-a-service/).
 
