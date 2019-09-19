# Exercise - Network Policy

In this exercise, you will be dealing with _Pods_, _Deployments_, _Labels & Selectors_, _Services_ and **_Network Policies_**.

Network policies in your namespace help you restrict access to your nginx deployment. From within any pod that is not labeled correctly you will not be able to access your nginx instances.

**Note:** This exercise loosely builds on the previous exercises as you will need a deployment and a service. In case you do not have a deployment with a service ready because you did not manage to finish [exercise 5](exercise_05_persistence.md), use the script  [prereq-exercise-06.sh](solutions/prereq-exercise-06.sh) in the *solutions* folder. Please use this script only if you do not have a working deployment that has been exposed through a service.

## Step 0: verify the setup
Before you deploy a network policy, check the connection from a random pod to the nginx pods via the service.

Start an alpine image and connect to it. Try to re-use the storage-pod.yaml from exercise 05 but without the volumes and mounts. Use the `exec` command to open a shell session into it.
Alternatively spin up a a temporary deployment with `kubectl run tester --generator=run-pod/v1 -i --tty --restart=Never --rm --image=alpine:3.8 /bin/sh`.

Do you remember, that your service name is also a valid DNS name? Instead of using an IP address to connect to your service, you can use its actual name (like `nginx-https`).

Run `wget --timeout=1 -q -O - <your-service-name>` from within the pod to send an HTTP request to the nginx service.

If everything works fine, the result should look like this (maybe with a different service name):
```bash
# wget --timeout=1 -q -O - nginx-https
Connecting to nginx (10.7.249.39:80)
```
It proves the network connection to the pods masked by the service is working properly.

## Step 1: create a network policy
To restrict the access, you are going to create a `NetworkPolicy` resource. 

The network policy features two selector sections: 
- `networkpolicy.spec.podSelector.matchLabels` determines the target pods -> traffic to all matching pods will be filtered (allow or drop)
- `networkpolicy.spec.ingress.from` lists the sources, from which traffic is accepted. There are different ways to identify trusted sources
  - by `podSelector.matchLabels` - to filter for labels of pods in the same namespace
  - by `namespaceSelector.matchLabels`- to filter for traffic from a specific namespace (can be combined with `podSelector`)
  - by `piBlock.cidr` - an IP address range defined as trustworthy

Use the snippet below and fill in the correct values for the `matchLabels` selector.

Hint: you can take a look at the `nginx` service with `-o yaml` to get correct labels.

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: access-nginx
spec:
  podSelector:
    matchLabels:
      ???: ???
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: "true"
# allow access originating from SAP networks
    - ipBlock:
        # Germany WDF
        cidr: 155.56.0.0/16
    - ipBlock:
        # Germany WDF
        cidr: 193.16.224.0/28
    - ipBlock:
        # Ireland
        cidr: 84.203.229.48/29
    - ipBlock:
        # Palo Alto
        cidr: 169.145.89.192/26
    - ipBlock:
        # Montreal
        cidr: 68.67.33.0/25
    - ipBlock:
        # Montreal
        cidr: 208.49.239.224/28
```
If you're location is not on the list, check with your trainer to get the address blocks. You can also check the [network information portal](https://nip.wdf.sap.corp/nip2/faces/networking/wan/PublicAddresses.xhtml) and search for your location.

If you are unsure about the labels, run the queries you are about to implement manually - e.g. `kubectl get pods -l <my-ke>=<my-value>`. This way you can check, if the results match your intention.

Create the resource as usual with `kubectl apply -f <your file>.yaml` and check its presence with `kubectl get networkpolicy`

## Step 2: Trying to connect, please wait ...
Again, connect to the busybox pod you used in step 0 or spin up a new one. Run the same `wget` command and check the output.

As the network policy is in place now, it should report a timeout: `wget: download timed out`

## Step 3: Regain access
To regain access you need to add the corresponding label to the pod from which you want to access the nginx service. The label has to match the `spec.ingress.from.podSelector.matchLabels` key-value pair specified in the network policy.

Use `kubectl label ...` or add a `-l <key>=<value>` to the `run` command. Then connect again to the pod and run `wget`. It should give you the same result as in step 0.

## Troubleshooting
If you're having trouble regaining or limiting access, check the label selectors in use. A network policy often uses the same selectors as the service to identify, the target pods to which traffic management should apply.

When it comes to `networkpolicy.spec.ingress.from`, note that it is explicit whitelisting of trusted sources. So if your traffic originates from a different source (like a different external IP address), it will be dropped. Make sure that your temporary helper pod has the labels which are specified in `networkpolicy.spec.ingress.from.podSelector.matchLabels`.

## Further information & references
- [network policy basics](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [example / tutorial on network policies](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/)
