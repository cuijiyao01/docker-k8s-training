# Exercise: Setup Bulletinboard-Ads Microservice/ Application


## Scope


- Create required configmap and deployment for ads
- Publish ads via service and ingress
- Check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

<img src="images/k8s-bulletinboard-target-picture-ads-app.png" width="800" />


## Step 1: Configmap
Purpose: 
- xx 
- xx

kubectl apply -f ads-app-configmap.yaml 


## Step 2: Deployment
Purpose: 
- xx

kubectl apply -f ads-app.yaml 

## Step 3: Service & Ingress
Purpose: 
- Publish ads via service and ingress

kubectl apply -f ads-app-service.yaml 
kubectl apply -f ads-app-ingress.yaml
