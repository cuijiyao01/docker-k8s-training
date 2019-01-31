# Exercise - Network Policy
In this exercise you create a network policy for your namespace to restrict access to your nginx deployment. From within any pod that is not labeled correctly you will not be able to access your nginx instances.

## Step 0: verify the setup
Before you deploy a network policy, check the connection from a random pod to the nginx pods via the service.

Start a busybox image and connect to it. Try to re-use the busybox.yaml from exercise 05 but without the volumes and mounts. Use the `exec` command to open a shell session into it.
Alternatively spin up a a temporary deployment with `kubectl run busybox --rm -ti --image=alpine:3.8 /bin/sh`.

Do you remember, that your service name is also a valid DNS name? Instead of using an IP address to connect to your service, you can use its actual name (like `nginx-https`).

Run `wget --spider --timeout=1 <your-serivce-name>` from within the pod to send an http request to the nginx service.

If everything works fine, the result should look like this (maybe with a different serivce name):
```
# wget --spider --timeout=1 nginx
Connecting to nginx (10.7.249.39:80)
```
It proves the network connection to the pods masked by the service is working properly.

## Step 1: create a network policy
To restrict the access, you are going to create a `NetworkPolicy` resource. Use the snippet below and fill in the correct values for the `matchLabels` selector.

Hint: you can take a look at the `nginx` service with `-o yaml`

```
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

Create the resource as usual with `kubectl create -f <your file>.yaml` and check its presence with `kubectl get networkpolicy`

## Step 2: Trying to connect, please wait ...
Again, connect to the busybox pod you used in step 0 or spin up a new one. Run the same `wget` command and check the output.

As the network policy is in place now, it should report a timeout: `wget: download timed out`

## Step 3: Regain access
To regain access you need to add the corresponding label to the pod from which you want to access the nginx service. The label has to match the `spec.ingress.from.podSelector.matchLabels` key-value pair specified in the network policy.

Use `kubectl label ...` or add a `-l <key>=<value>` to the `run` command. Then connect again to the pod and run `wget`. It should give you the same result as in step 0.
