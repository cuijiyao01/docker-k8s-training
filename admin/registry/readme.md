# Setup a Docker registry in K8s

In this folder you find scripts & yaml files to deploy a docker registry into the K8s cluster used for the training.
The participants should use this registry for the docker exercises, where they push their own images to.

We use the `stable/docker-registry` helm chart to deploy our registry. It uses the docker image for a registry from docker hub.

The registry is exposed via `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

In it's current version, the helm chart values will be set in a way to instruct Gardener to provision a let's encrypt certificate for the ingress. Due to the long URL (more than 64 characters), there will be 2 hostnames. The first one has to have less than 64 characters to fit into the CN field and the 2nd will be written into the SAN field when requesting the certificates. Details can be found [here](https://gardener.cloud/050-tutorials/content/howto/x509_certificates/).

## step-by-step setup

### preparation
* check, that `kubectl` works with your cluster
* If not yet done - setup `helm` in your `kube-system` namespace with a separate service account and cluster-admin permissions. Use the `helm_init.sh` [script](../helm_init.sh) to carry out all required steps.

### Install the registry
run `install_registry.sh [project name] [cluster name]` and supply the name or your Gardener project as well as the cluster name.

The script will
  * construct a URL for Gardener ingress
  * create a namespace `registry`
  * create a secret `basic-auth` in the new namespace
  * deploy the chart `stable/docker-registry` into the new namespace
  * request a let's encrypt certificate for the grafana ingress

Finally, test your registry by opening `[ingress.url]/v2/_catalog` (e.g. `https://registry.ingress.cpwdfcw06.k8s-train.shoot.canary.k8s-hana.ondemand.com/v2/_catalog`).

The connection should default to `https` and you should be asked to supply a username (`participant`) & password (`2r4!rX6u5-qH`).
