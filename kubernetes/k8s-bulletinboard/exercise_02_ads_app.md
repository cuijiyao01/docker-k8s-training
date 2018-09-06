# Exercise: Setup Bulletinboard-Ads Microservice/ Application


## Scope

- In this second exercise we will focus on the setup of **Bulletinboard-Ads Application/Microservice** itself (See picture below) and make it available within the K8s cluster via **Service** and publish externally via an **Ingress**.
- Finally we will check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

<img src="images/k8s-bulletinboard-target-picture-ads-app.png" width="800" />

- As we need horizontal scaling for the Ads app we will use a **Deployment** with 3 instances (replicaset=3).

- A specific version of **Bulletinboard-Ads**, slighty adapted for this training, is available as [Docker Image](https://docker.repositories.sap.ondemand.com/webapp/#/artifacts/browse/tree/General/cc-k8s-course/k8s/bulletinboard-ads/latest) in **SAP Artifactory in DMZ**.

- **Bulletinboard-Ads** is a **Spring Boot** application and can read [configuration from various external sources](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html). The Docker Image of **Bulletinboard-Ads** is reading the configuration from an **Application properties file** with name `application-k8s.yml`.

- Additional we can configure **Bulletinboard-Ads** via environment variables for de-/activation of a check against **Bulletinboard-Users** when creating an advertisement (`POST_USER_CHECK`), the Ingress-URL to the **Bulletinboard-Users** (`USER_ROUTE`) and the [Active Spring Profile](https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html#howto-set-active-spring-profiles)(`SPRING_PROFILES_ACTIVE`).


<img src="images/k8s-bulletinboard-target-picture-ads-app-detail.png" width="800" />


## Step 1: Configmaps Environment variables + Application profile

Purpose: 
- Create required configmap and deployment for ads
- Publish ads via service and ingress
- Check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

- xx 
- xx

kubectl apply -f ads-app-configmap-envs.yaml 
kubectl apply -f ads-app-configmap-files.yaml 


## Step 2: Deployment

Purpose: 
- xx

kubectl apply -f ads-app.yaml 

## Step 3: Service & Ingress

Purpose: 
- Publish ads via service and ingress

kubectl apply -f ads-app-service.yaml 
kubectl apply -f ads-app-ingress.yaml

## Step 4: Check proper working ads app with ads DB

Purpose:

- xxx


