# Setup a monitoring with promethes and grafana

In this folder you find scripts & yaml files to deploy a **monitoring system** based on [**Prometheus**](https://prometheus.io/) & **visualization** based on [**Grafana**](https://grafana.com/). We use the `stable/prometheus` and `stable/grafana` helm charts and install them with custom values.

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
* If not yet done - setup `helm` in your `kube-system` namespace (via the following 5 steps).
  * create a new service account: `kubectl -n kube-system create sa tiller`
  * generate a clusterrolebinding for the new service account:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: tiller
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: tiller
      namespace: kube-system
    ```
  * download the helm client like in [exercise 09](../../kubernetes/exercise_09_helm.md).
  * initialize helm: `helm init --tiller-namespace kube-system --service-account tiller`
  * run `helm list --tiller-namespace kube-system` to verify the setup. It should return an empty string.

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
