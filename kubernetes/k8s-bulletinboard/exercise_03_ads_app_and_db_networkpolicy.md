# Exercise: Secure your connections


## Scope

Increase security and establish a network policy for ads DB and enable TLS (https) for the ingress. 

## Step 0: prerequisites

Currently none.

## Step 1: Network policy for DB

__Purpose: control traffic to and from *ads:db* pod__ 

<img src="images/bulletinboard-networkpolicy-ads.png" width="800"/>

We want only that  __ads:db__ only takes messages from __ads:app__. Configure a network policy in a file named `ads-db-networkpolicy.yaml` accordingly. 
You can check the [network policy exercise](../exercise_08_network_policy.md) and [this reference](https://kubernetes.io/docs/concepts/services-networking/network-policies/) on how to write a network policy. 


## Step 2: Network policy for Ads

__Purpose: control traffic to and from *ads:app* pod, learn how to select a pod in a different namespace in your policy__ 

<img src="images/bulletinboard-networkpolicy-ads.png" width="800"/>

We want that __ads:app__ only takes messages from the ingress. 
The ingress controller is in the `kube-system` namespace and has the following labels you can use: 
```
app: nginx-ingress 
component: controller 
origin: gardener
```
Futher we can also allow  __ads:app__ to send traffic only to certian pods. This would currently be __ads:db__ and the dns server in our cluster. This dns server is also in the `kube-system` namespace and has a label `k8s-app: kube-dns`. 

Configure a network policy in a file named `ads-app-networkpolicy.yaml` accordingly.  
Hints: [this example](https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/07-allow-traffic-from-some-pods-in-another-namespace.md) and the egress rules. (See above reference and [here](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#networkpolicyspec-v1-networking-k8s-io)). 

## Step 3: TLS

We also want to enable TSL for our communication with ads. Therefore we activate TLS on our ingress service. 
We follow the steps of the [configmap and secrets](../exercise_06_configmaps_secrets.md) exercise to optain the key and certificate files and create the tls-secret.
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"
kubectl create secret tls ingress-tls-sec --cert=nginx.crt --key=nginx.key --dry-run -o yaml > tls.yaml
kubectl apply -f tls.yaml
``` 
With this we can change `spec:` of ingress in the yaml to the following and apply the change:
```
spec:
  rules:
  - host: ads--bulletinboard-integration.ingress.ccdev01.k8s-train.shoot.canary.k8s-hana.ondemand.com
    http:
      paths:
      - backend:
          serviceName: ads-service
          servicePort: ads-app
  tls:
  - secretName: ingress-tls-sec
```
Now we have enabled https connection for the ingress and therefore also for the ads service behind the ingress.
Open `https://<firstpart of url>.ingress.<clustername>.k8s-train.shoot.canary.k8s-hana.ondemand.com/` and after the warning that the certificate is insecure you can use the UI with https. 





