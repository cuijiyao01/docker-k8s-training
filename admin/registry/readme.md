# Setup a Docker registry in K8s

In this folder you find scripts & yaml files to deploy a docker registry into the K8s cluster used for the training.
The participants should use this registry for the docker exercises, where they push their own images to.

We use the `stable/docker-registry` helm chart to deploy our registry. It uses the docker image for a registry from docker hub.

The registry is exposed via `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

Additionally we strongly recommend to use certificates around the registry. With the `install_registry.sh` script the cluster's root CA is used to sign a certificate for the ingress URL. The script also sets up basic authentication terminating at the ingress controller (together with TLS).

## step-by-step setup

### preparation
* prepare `cfssl` tools:
  * if not present, download `cfssl` & `cfssljson` tools for your platform: https://pkg.cfssl.org/ (`curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl`)
  * make the binaries executable (`chmod +x`)
  * move them to a directory covered by your `$PATH` variable ( e.g. `/usr/local/bin/`).
* check, that `kubectl` works with your cluster
* If not yet done - setup `helm` in your `kube-system` namespace with a separate service account and cluster-admin permissions. Use the `helm_init.sh` [script](../helm_init.sh) to carry out all required steps.

### Install the registry
run `install_registry.sh [project name] [cluster name]` and supply the name or your Gardener project as well as the cluster name.

The script will
  * construct a URL for Gardener ingress
  * create a private key & a signing request
  * upload the signing request to k8s
  * approve the signing request & download the certificate
  * create a namespace `registry`
  * create a secret `registry-certs` in the new namespace
  * create a secret `basic-auth` in the new namespace
  * deploy the chart `stable/docker-registry` into the new namespace

Finally, test your registry by opening `[ingress.url]/v2/_catalog` (e.g. `https://registry.ingress.cpwdfcw06.k8s-train.shoot.canary.k8s-hana.ondemand.com/v2/_catalog`).

The connection should default to `https` and you should be asked to supply a username (`participant`) & password (`2r4!rX6u5-qH`).
