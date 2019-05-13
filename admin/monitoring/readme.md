# Setup a monitoring with promethes and grafana

In this folder you find scripts & yaml files to deploy a **monitoring system** based on [**Prometheus**](https://prometheus.io/) & **visualization** based on [**Grafana**](https://grafana.com/). We use the `stable/prometheus` ([details](https://github.com/helm/charts/tree/master/stable/prometheus)) and `stable/grafana` ([details](https://github.com/helm/charts/tree/master/stable/grafana)) helm charts and install them with custom values.

**Prometheus** collects metrics from various endpoints such as the API server or kubelet. Data is stored as time series and can be queried via `prometheus-server`.

**Grafana** is used to run queries and visualize the results. Upon deployment we also import 2 predefined dashboards: 'Kubernetes cluster monitoring (via Prometheus)' and 'TrainingStats'. One provides information about the cluster state like memory or CPU usage. The other is more specific to the training. It shows the deployments, services or pod status per namespace or across all namespaces.

Grafana is exposed via an `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

## step-by-step setup

### preparation
* prepare `cfssl` tools:
  * if not present, download `cfssl` & `cfssljson` tools for your platform: https://pkg.cfssl.org/ (`curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl`)
  * make the binaries executable (`chmod +x`)
  * move them to a directory covered by your `$PATH` variable ( e.g. `/usr/local/bin/`).
* check, that `kubectl` works with your cluster
* If not yet done - setup `helm` in your `kube-system` namespace with a separate service account and cluster-admin permissions. Use the `helm_init.sh` [script](../helm_init.sh) to carry out all required steps.

### Run the setup script
run `setup_monitoring.sh [project name] [cluster name]` and supply the name or your Gardener project as well as the cluster name.

The script will
  * construct a URL for Gardener ingress
  * create a private key & a signing request
  * upload the signing request to k8s
  * approve the signing request & download the certificate
  * create a namespace `monitoring`
  * create a secret `grafana-tls` in the new namespace
  * deploy the chart `stable/prometheus` into the new namespace
  * deploy the chart `stable/grafana` into the new namespace
  * create a configmap with the dashboard json files and import it to grafana

Finally, follow the instructions printed by the Grafana chart to obtain the ingress URL and the admin password.
