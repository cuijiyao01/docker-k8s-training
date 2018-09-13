# Exercise: Setup Bulletinboard-Ads Microservice/ Application


## Scope

- In this second exercise we will focus on the setup of **Bulletinboard-Ads Application/Microservice** itself (See picture below) and make it available within the K8s cluster via a **Service** and publish externally via an **Ingress**.
- Finally we will check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

<img src="images/k8s-bulletinboard-target-picture-ads-app.png" width="800" />

- We decided our initial demand requires at least 2 instances of our app. Therefore we need horizontal scaling for the Ads app we will use a **Deployment**  with 2 instances (replicaset=3).

- A specific version of **Bulletinboard-Ads**, slighty adapted for this training, is available as [Docker Image](https://docker.repositories.sap.ondemand.com/webapp/#/artifacts/browse/tree/General/cc-k8s-course/k8s/bulletinboard-ads/latest) in **SAP Artifactory in DMZ**.

- **Bulletinboard-Ads** is a **Spring Boot** application and can read [configuration from various external sources](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html). The Docker Image of **Bulletinboard-Ads** is reading the configuration from an **Application properties file** with name `application-k8s.yml`.

- Additional we can configure **Bulletinboard-Ads** via environment variables for de-/activation of a check against **Bulletinboard-Users** when creating an advertisement (`POST_USER_CHECK`), the Service-URL to the **Bulletinboard-Users** (`USER_ROUTE`) and the [Active Spring Profile](https://docs.spring.io/spring-boot/docs/current/reference/html/howto-properties-and-configuration.html#howto-set-active-spring-profiles) (`SPRING_PROFILES_ACTIVE`).

- The structure for **Labels** (and with this for **Selectors**) has 2 levels as in exercice 1: To separate **Bulletinboard-Ads** from **Bulletinboard-Users** we introduce the **Label** `component` with value `ads` and `users`. To separate the App-part from the Database-part within each "Component" we introduce the **Label** `module` with value `app` and `db`.

<img src="images/k8s-bulletinboard-target-picture-ads-app-labels-1.png" width="800" />

## Step 0: Create ImagePullSecret for SAP artifactory repo cc-k8s-course

The Dockerimage for Bulletinboard-ads is pushed to the SAP artifactory. To retrieve it from there you need to create a docker-registry secret named _artifactory_ by executing the command below:
```
kubectl create secret docker-registry artifactory --docker-server=cc-k8s-course.docker.repositories.sap.ondemand.com --docker-username=cc-k8s-course-r1 --docker-password=oQHCMaS05Z1i
```
We will uses the name to identify in the deployment what ImagePullSecret to use.

## Step 1: Configmap for Application properties file

Purpose: Create a single **Configmap** for the external (outside the docker image) configuration  of **ads:app**.

Contrary to what we did for __ads:db__ where we used two configmaps, one for the environment variables and one for the initdb.sql file/script, will will only use one CM for both files and environment variables.

- Create a file `ads-app-configmap.yaml` in folder `k8s-bulletinboard/ads` where we will specify a **Configmap** `ads-app-config` for all the external configuration information for Bulletinboard Ads App. Do not forget to specify proper labels for component and module !

- First part of the data is the content of the **Application properties file** - finally created at the filesystem of the Docker Container - with name `application-k8s.yml`. You can store its content under a key `application-k8s` in the configMap. The content should look like the following:  
**_Hint: Please substitute the place holders below <...> by proper values !_**
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
You can use the same way to store it as for `initdb.sql` script string. Please keep the indents, we store a yaml.

- The second information the app needs to specify is which profile spring should use. We will uses the name __k8s__ for the profile (thus the name application-__k8s__.yml). One way Spring gets this information is by providing an environment variable `SPRING_PROFILES_ACTIVE` in the Dockercontainer. So the 2nd data key will be `SPRING_PROFILES_ACTIVE_VALUE` with the value `k8s`.

- By default **Bulletinboard-Ads** does not check against **Bulletinboard-Users** when creating an advertisement. Anyhow a **Bulletinboard-Users** App is not yet available/ running in our K8s Cluster (Will be done in [Exercise 04](exercise_04_users_app_and_db_by_helm.md)). Therefor we do not need to specify/ "pass" the environment variables `POST_USER_CHECK` and `USER_ROUTE` now.

- Now call `kubectl apply -f ads-db-configmap.yaml` to create the **Configmap**.

_Further informations on [Configmap and Container Environment Variables](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#define-container-environment-variables-using-configmap-data)_
_Further informations on [Configmap from files](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-configmaps-from-files)_

## Step 2: Deployment

Purpose: Create the **Deployment**, which is dependend on the Configmap, created in step 1 (Creation of Deployment will fail, if it is not yet available !). Also the `artifactory` secret is needed to pull the image.

<img src="images/k8s-bulletinboard-target-picture-ads-app-deployment.png" width="300" />

_Hint: In the following sections we will provide you yaml-snippets of the Deployment specification. Just substitute the place holders `<...>` by proper values !_

- Specify a **Deployment** for the **Bulletinboard Ads** with 3 instances, with name `ads-app` and with proper labels and selector for component and module. 

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ads-app
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
  replicas: <#-of-instances>
  selector:
    matchLabels:
      component: <name-of-component>
      module: <name-of-module>
```

- Assign to the volume `ads-app-properties` from the **Configmap** the key for the **Applicaton Properties file** and choose as Docker container the **Bulletinboard-Ads** Docker Image:  
```
cc-k8s-course.docker.repositories.sap.ondemand.com/k8s/bulletinboard-ads:latest
```
Addtional refer for the environment variable `STRING_PROFILES_ACTIVE` the corresponding **Configmap** (key & name).

```  
  template:
    metadata:
      labels:
        component: <name-of-component>
        module: <name-of-module>
    spec:
      volumes:
      - name: ads-app-properties
        configMap:
          name: <name-of-configmap>
          items:
          - key: <name-of-the-key-with-the-file-content> 
            path: application-k8s.yml
      imagePullSecrets:
      - name: artifactory
      containers:
      - name: ads
        image: <bulletinboard-ads-docker-image>
        ports:
        - containerPort: 8080
          name: ads-app
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom:
            configMapKeyRef:
              key: <name-of-data-specified-in-configmap>
              name: <name-of-configmap>
        volumeMounts:
        - mountPath: /config/
          name: ads-app-properties    
```

- When you are ready with the specification of the **Deployment** save it under the filename `ads-app.yaml` in folder `k8s-bulletinboard/ads` and call `kubectl apply -f ads-app.yaml` to create the **Deployment** `ads-app`.

- After successful creation of the **Deployment** check, wether **3** Pods got created properly via `kubectl get pods`. The names of the 3 pods should be something like `ads-app-xx-yx`, `ads-app-xx-yy` and `ads-app-xx-yz`.


## Step 4: Service & Ingress

Purpose: Make **Bulletinboard-Ads** available within your K8s Cluster via **Service** and "publish" externally into the Internet via a **Ingress**.

_Hint: In the following sections we will provide you yaml-snippets of the Deployment specification. Just substitute the place holders `<...>` by proper values !_

### Service

- Specify a **Service** for the **Bulletinboard Ads**, with name `ads-app-service`, a named targetPort `ads-app` and with proper labels and selector for component and module. 


```
---
apiVersion: v1
kind: Service
metadata:
  name: ads-service
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: ads-app
  selector:
    component: <name-of-component>
    module: <name-of-module>
  type: ClusterIP
```
- When you are ready with the specification of the **Service** save it under the filename `ads-app-service.yaml` in folder `k8s-bulletinboard/ads` and call `kubectl apply -f ads-app-service.yaml` to create the **Service** `ads-app-service`.

### Ingress

- Additional specify an **Ingress** for the **Bulletinboard Ads**, with name `ads-app-ingress` and with proper labels and selector for component and module. 

- As the host URL has to be unique across the whole K8s Cluster, add `--<name-of-your-namespace>` as suffix to the hostname 'bulletinboard', so the host URL would look like: `bulletinboard--part-40a86f44.ingress.wdfcw43.k8s-train.shoot.canary.k8s-hana.ondemand.com`.

- Refer to the above created **Service** `ads-app-service` in field `serviceName` and `servicePort` (Section '- backend').

```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ads-app-ingress
  labels:
    component: <name-of-component>
    module: <name-of-module>
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com
    http:
      paths: 
      - path: /ads
        backend:
          serviceName: <name-of-ads-service>
          servicePort: <name-of-ads-port>
```
- When you are ready with the specification of the **Ingress** save it under the filename `ads-app-ingress.yaml` in folder `k8s-bulletinboard/ads` and call `kubectl apply -f ads-app-ingress.yaml` to create the **Ingress** `ads-app-ingress`.

- Check wether the **Ingress** is properly created via `kubectl get ingress ads-app-ingress`.

- Additional check wether you can call your **Bulletinboard-Ads** on the `/health` endpoint via the **Ingress** Url with the following **cURL** command:

`curl http://bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com/ads/health`.

- If all works fine, you should get the following result: `{"status":"UP"}`


## Step 4: Check proper working Ads App with Ads DB

Purpose: Check **Bulletinboard-Ads** App running properly together with **Bulletinboard-Ads** database with Postman and Browser/ Web-UI

### Postman

- List and create advertisements with [Postman](helper_ads_app_postman.md)

### Browser/ Web-UI

Now, access the application using the browser.
- Open Chromium browser
- Open a new tab
- Paste the following URLs into the adress field and check the results.
  - **REST API, Get All**: `http://bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com/ads/ads/api/v1/ads`
  - **REST API, Get Single**: `http://bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com/ads/ads/api/v1/ads/<advertisement-id>`
  - **Web-UI**: `http://bulletinboard--<your-name-space>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com/ads`


