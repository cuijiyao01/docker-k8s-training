# Exercise: Secure your connections


## Scope

Increase security and establish a network policy for ads DB and enable TLS (https) for the ingress. 

## Step 0: prerequisites

Currently none.

## Step 1: Network policy for DB
We want only that __ads:app__ is allowed to talk to __ads:db__. Configure a network policy in a file named `ads-db-networkpolicy` accordingly. 
You can check the network policy exercise and [this reference](https://kubernetes.io/docs/concepts/services-networking/network-policies/) on how to write a network policy. 

## Step 2: Network policy for Ads
Currently we want __ads:app__ to be able to only talk to the db. And we want that __ads:app__ only takes messages from the ingress. 
The ingress controller is in the `kube-system` namespace and has the following labels you can use: 
```
app: nginx-ingress 
component: controller 
origin: gardener
```

## Step 3: TLS
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"
kubectl create secret tls ingress-tls-sec --cert=nginx.crt --key=nginx.key --dry-run -o yaml > tls.yaml
kubectl apply -f tls.yaml
``` 
Change spec of ingress to the following and apply the change:
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
Now you have enabled https connection for the ingress and therefore also for the ads service behind the ingress.
Open `https://<firstpart of url>.ingress.<clustername>.k8s-train.shoot.canary.k8s-hana.ondemand.com/` and after the warning that the certificate is insecure you can use the UI with https. 





