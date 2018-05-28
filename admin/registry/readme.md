# Setup a Docker registry in K8s

In this folder you find scripts & yaml files to deploy a docker registry into the K8s cluster used for the training.
The participants should use this registry for the docker exercises, where they push their own images to.

We use the `stable/docker-registry` helm chart to deploy our registry. It uses the docker image for a registry from docker hub.

The registry is exposed via `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

Additionally we strongly recommend to use certificates around the registry. Use the cluster's root CA to sign a certificate for the ingress URL.

## step-by-step setup

### preparation
* prepare `cfssl` tools:
  * if not present, download `cfssl` & `cfssljson` tools for your platform: https://pkg.cfssl.org/ (`curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl`)
  * make the binaries executable (`chmod +x`)
  * move them to a directory covered by your `$PATH` variable ( e.g. `/usr/local/bin/`).
* check, that `kubectl` works with your cluster
* Setuo `helm` in your `kube-system` namespace.
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
  * run `helm list` to verify the setup. It should return an empty string.

### create a certificate for your registry's ingress
run `install_registry.sh [project name] [cluster name]` and supply the name or your Gardener project as well as the cluster name.

The script will
  * construct a URL for Gardener ingress
  * create a private key & a signing request
  * upload the signing request to k8s
  * approve the signing request & download the certificate
  * create a namespace `registry`
  * create a secret `registry-certs` in the new namespace
  * deploy the chart `stable/docker-registry` into the new namespace

Finally, test your registry by opening `[ingress.url]/v2/_catalog`

## troubleshooting / workarounds

In case https://github.com/gardener/gardener/issues/188 is not yet fixed, you need to hack the ingress controller in kube-system namespace :( . The issue is about the size of a request body, which is to small to push docker image layers.

In order for the registry to work, try the following workaround:
 *   exec into the ingress-controller pod in kube-system namespace (e.g.  `kubectl exec -ti -n kube-system addons-nginx-ingress-controller-67b9555bdc-24tns /bin/bash`)
 * check if `vim` is installed and if not, install it with `apt-get update && apt-get install vim`
 * edit the nginx configuration `/etc/nginx/nginx.conf` and go to the entry for the registry. There is a server configuration for each ingress resource in your cluster.
 * change the value of the parameter `client_max_body_size` to `400m` and change the file
 * reload the nginx config with `nginx -s reload`

**Important: the changes you make to `/etc/nginx/nginx.conf` are only temporary. As soon as the pod goes down or a new ingress resource is posted to the cluster, the nginx controller will overwrite your changes!**
