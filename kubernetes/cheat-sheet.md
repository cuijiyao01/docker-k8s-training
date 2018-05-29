# cheatsheet

## kubectl syntax
`kubectl` commands usually follow a fixed schema:

* a `verb` like get, describe, create, delete - tells kubectl what to do.
* a `resource` like pod, node - or any other valid resource - specifies for which resource type the action defined by the `verb` should be executed.
* a more detailed specification of the requested resource by ID/name or label (use `-l <key=value>`)
* parameters or modifiers like
  * `-n=<your-namespace>`: to route your query to another namespace than default
  * `-o=wide`: more detailed output. The flag also accepts `yaml` or `json` as format.

Example: `kubect get pod -n=my-namespace -o=wide`

Detailed information can be found [here](https://kubernetes.io/docs/user-guide/kubectl-overview/)

## most common kubectl commands

| command | expected result |
| --- | ---|
| `kubectl get all -n=my-namespace` | get all objects of the most common resources (services, pods, ...) present in the specified namespace `my-namesapce`
| `kubectl get pods -n=my-namespace`| get all pods within the specified namespace `my-namespace`. Instead of resource type pod any other valid resource can be used (i.e. deployment, service, ...) |
| `kubectl get pods -n=my-namespace --show-labels=true`| similar to the command above, but output shows all labels attached to the pods |
| `kubectl get pods my-pod -n=my-namespace` | get the pod `my-pod` within `my-namespace`. Works also with other resource types |
| `kubectl get pods -l status=awesome -n=my-namespace`| get all pods with label "status=awesome" in `my-namespace` |
| `kubectl describe pod my-pod -n=my-namespace` | gives a detailed description of the the pod `my-pod`. Works also with other resource types|
| `kubectl create -f pod.yaml` | create 1..n resources that are specified in the `pod.yaml` file |
| `kubectl logs my-pod -n=my-namespace`| prints the logs written by `my-pod`|
| `kubectl exec -it my-pod bash -n=my-namesapce` | starts a `bash`shell session in within the context of `my-pod`|
| `kubectl label pod my-pod -n=mynamespace status=awesome`| attaches a lable `status=awesome` to my-pod |
| `kubectl delete pod my-pod -n=my-namespace` | Deletes the pod `my-pod`. Works also with other resource types |

**Please note, the parameter -n=<namespace> is optional. If not specified all requests will target the `default` namespace or the namesapce specified in your kubeconfig.**

## shortcuts
kubectl wants you to reference resources by type. To do so, there are different formats availalbe. Most common is the following `kubect <verb> <resource type> <name>` like `kubectl get deployment nginx`. However it is also possible to connect resource type and name like this `deployment/nginx`.

For several of the resource types there are also shortend identifiers available. For example the type `service` can be referenced by `svc`. A full list is available [here](https://kubernetes.io/docs/user-guide/kubectl-overview/) in section "resource types".
Furthermore it is possible to get all resources of different types belonging to a name or label: `kubectl get svc,pod,deploy -l name=nginx`.
