# Exercise: Secure your connections


## Scope

Increase security and establish a network policy for ads DB

kubectl apply -f ads-db-networkpolicy.yaml 

img src="images/xxx.png" width="800" />

## Step 0: prerequisites
xxx

## Step 1: TLS
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

## Step 2: xxx
xxx


## Step 3: xxx
xx

