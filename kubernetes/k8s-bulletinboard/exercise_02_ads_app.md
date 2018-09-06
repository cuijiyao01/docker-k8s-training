# Exercise: Setup Bulletinboard-Ads Microservice/ Application


## Scope

- In this second exercise we will focus on the setup of **Bulletinboard-Ads Application/Microservice** itself (See picture below) and make it available within the K8s cluster via **Service** and publish externally via an **Ingress**.
- Finally we will check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

<img src="images/k8s-bulletinboard-target-picture-ads-app.png" width="800" />

- As we need horizontal scaling for the Ads app we will use a **Deployment** with 3 instances (replicaset=3).

- A specific version of **Bulletinboard-Ads**, slighty adapted for this training, is available as [Docker Image](https://docker.repositories.sap.ondemand.com/webapp/#/artifacts/browse/tree/General/cc-k8s-course/k8s/bulletinboard-ads/latest) in **SAP Artifactory in DMZ**.

- **Bulletinboard-Ads** is a **Spring Boot** application and can read [configuration from various external sources](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html). The Docker Image of **Bulletinboard-Ads** is reading the configuration from an **Application properties file** with name `application-k8s.yml`.

- Additional we can configure **Bulletinboard-Ads** via environment variables for de-/activation of a check against **Bulletinboard-Users** when creating an advertisement (`POST_USER_CHECK`), the Ingress-URL to the **Bulletinboard-Users** (`USER_ROUTE`) and the [Active Spring Profile](https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html#howto-set-active-spring-profiles) (`SPRING_PROFILES_ACTIVE`).


<img src="images/k8s-bulletinboard-target-picture-ads-app-detail.png" width="800" />


## Step 1: Configmap for Application properties file

Purpose: Create a **Configmap** for the **Application properties file**.

- Specify a **Configmap** `ads-app-config-files` for the **Application properties file** with name `application-k8s.yml`.

- The content of the file - finally created at the filesystem of the Docker Container (ToDO: better Pod ? or PV or PVC ?)- should look like the following:

```
---
spring: 
  datasource: 
    url: jdbc:postgresql://<name-of-ads-db-pod>.<name-of-ads-db-headless-service>:5432/ads
    username: <name-of-ads-db-postgres-user> 
    password: <password-of-ads-db-postgres-user> 
    driverClassName: org.postgresql.Driver
    driver-class-name: org.postgresql.Driver
```

- The specification in the **Configmap** should look like following. Please be aware, that you have to build up a proper yaml structure with new lines and correct indends. New lines can be done with `\n` and indends with ` `:
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ads-app-config-files
  labels:
    component: <name-of-component>
    module: <name-of-module>
data:
application-k8s.yml: "---\nspring:\n  datasource:\n    url: jdbc:postgresql://<name-of-ads-db-pod>.<name-of-ads-db-headless-service>:5432/ads\n    username: <name-of-ads-db-postgres-user>\n    password: <password-of-ads-db-postgres-user>\n    driverClassName: org.postgresql.Driver\n    driver-class-name: org.postgresql.Driver\n"
```

**_Hint: Please substitute the place holders below <...> by proper values !_**

- Save the **Configmap** spec under the filename `ads-app-configmap-files.yaml` in folder `k8s-bulletinboard/ads`. Do not forget to specify proper labels for component and module !

- Now call `kubectl apply -f ads-app-configmap-files.yaml` to create the **Configmap**.


## Step 2: Configmap for Environment variable

Purpose: Create a **Configmap** for environment variable `SPRING_PROFILES_ACTIVE`, we want to "pass" to **Bulletinboard-Ads**.

- Specify a **Configmap** `ads-app-config-envs` with data entry `spring_profiles_active_value` and value `k8s` for the **Active Spring Profile**.

- By default **Bulletinboard-Ads** does not check against **Bulletinboard-Users** when creating an advertisement. Anyhow a **Bulletinboard-Users** App is not yet available/ running in our K8s Cluster (Will be done in [Exercise 04](exercise_04_users_app_and_db_by_helm.md)). Therefor we do not need to specify/ "pass" the environment variables `POST_USER_CHECK` and `USER_ROUTE` now.

- Save the **Configmap** spec under the filename `ads-app-configmap-envs.yaml` in folder `k8s-bulletinboard/ads`. Do not forget to specify proper labels for component and module !

- Now call `kubectl apply -f ads-db-configmap-envs.yaml` to create the **Configmap**.


## Step 3: Deployment

Purpose: Create the **Deployment**, which is dependend on both Configmaps, created in step 1-2 (Creation of Deployment will fail, if those entities are not yet available !).

<img src="images/k8s-bulletinboard-target-picture-ads-app-deployment.png" width="300" />

_Hint: In the following sections we will provide you yaml-snippets of the Deployment specification. Just substitute the place holders <...> by proper values !_


- Specify a **Deployment** for the **Bulletinboard Ads** with 3 instances, with name `ads-app` and with proper labels and selector for component and module. 

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ads-app
  labels:
    component: ads
    module: app
```

```
spec:
  replicas: <#-of-instances>
  selector:
    matchLabels:
      component: ads
      module: app
  template:
    metadata:
      labels:
        component: ads
        module: app
    spec:
      volumes:
      - name: ads-app-properties
        configMap:
          name: ads-app-config-files
      imagePullSecrets:
      - name: artifactory
      containers:
      - name: ads
        image: cc-k8s-course.docker.repositories.sap.ondemand.com/k8s/bulletinboard-ads:latest
        ports:
        - containerPort: 8080
          name: ads-app
        env:
        - name: USER_ROUTE
          valueFrom:
            configMapKeyRef:
              key: user_route_value
              name: ads-app-config-envs
        - name: SPRING_PROFILES_ACTIVE
          valueFrom:
            configMapKeyRef:
              key: spring_profiles_active_value
              name: ads-app-config-envs
        - name: POST_USER_CHECK
          valueFrom:
            configMapKeyRef:
              key: post_user_check_value
              name: ads-app-config-envs 
        volumeMounts:
        - mountPath: /config/
          name: ads-app-properties    
```



- When you are ready with the specification of the **Deployment** save it under the filename `ads-app.yaml` in folder `k8s-bulletinboard/ads` and call `kubectl apply -f ads-app.yaml` to create the **Deployment** `ads-app`.

- After successful creation of the **Deployment** check, wether **3** Pods got created properly via `kubectl get pods`. The names of the 3 pods should be something like `ads-app-xx-yx`, `ads-app-xx-yy` and `ads-app-xx-yz`.


## Step 4: Service & Ingress

Purpose: 
- Publish ads via service and ingress

kubectl apply -f ads-app-service.yaml 
kubectl apply -f ads-app-ingress.yaml

## Step 5: Check proper working ads app with ads DB

Purpose:

- xxx


- Publish ads via service and ingress
- Check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

