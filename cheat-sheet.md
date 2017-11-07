# cheatsheet

## kubectl syntax
`kubectl` commands usually follow a fixed schema:

* a `verb` like get, describe, create, delete - tells kubectl what to do.
* a specification of the `resource` like pod, node or any other valid resource - specifies on which resource type the action defined by the `verb` should be executed.
* a concretization of the requested resource by ID/name or label (use `-l <key:value>`)
* parameters or modifier like
  * `-n=<your-namespace>`: to route your query to another namespace than default
  * `-o=wide`: more detailed output. The flag also accepts `yaml` or `json` as format.

Example: `kubect get pod -n=my-namespace -o wide`

Detailed information can be found [here](https://kubernetes.io/docs/user-guide/kubectl-overview/)

## most common kubectl commands

| command | expected result |
| --- | ---|
| `kubectl get all -n=my-namespace` | get all resources present in the specified namespace `my-namesapce`
|`kubectl get pods -n=my-namespace`| get all pods within the specified namespace `my-namespace`. Instead of resource type pod any other valid resource can be used (i.e. deployment, service, ...) |
|`kubectl get pods my-pod -n=my-namespace` | get the pod `my-pod` within `my-namespace`. Works also with other resource types |
| `kubectl create -f pod.yaml` | create 1..n resources that are specified in the `pod.yaml` file |
| `kubectl describe pod my-pod -n=my-namespace` | gives a detailed description of the the pod `my-pod`. Works also with other resource types|
| `kubectl logs my-pod -n=my-namespace`| prints the logs written by `my-pod`|
| `kubectl exec my-pod bash -n=my-namesapce` | starts a `bash`shell session in within the context of `my-pod`|
| `kubectl delete pod my-pod -n=my-namespace` | Deletes the pod `my-pod`. Works also with other resource types |

**Please note, the parameter -n=<namespace> is optional. If not specified all requests will target the `default` namespace.**
