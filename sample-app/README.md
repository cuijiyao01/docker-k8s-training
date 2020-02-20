# Microservice based Application in Kubernetes using Cloud Curriculum Sample Application "Bulletinboard"
- In the following **5 exercises** you will learn how to make available a microservice based business application in Kubernetes. 
- As sample application we are using the **[Bulletinboard from the Cloud-Native-Boot-Camp](https://github.wdf.sap.corp/cloud-native-bootcamp/info)**. 
- The Bulletinboard is build up by two individual microservices - **[Bulletinboard-Ads](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-ads)** (Java), which can **list**, **create** and **delete Advertisements** and **[Bulletinboard-Reviews](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-reviews)** (NodeJs), which contains ratings for users. The advertisements are presented differently depending of the rating of the user, who created the advertisement.
- The overall structure of **Bulletinboard 'in K8s'**, incl. the different **K8s entities**, needed for Kubernetes can be found in the following picture.

<img src="images/k8s-bulletinboard-target-picture-detail-3.png" width="800" />

_Legend: `ingr`: Ingress, `svc`: Service, `nwp`: Network policy, `cm`: Configmap, `sec`: Secret_


## Exercises
### [01 Exercise: "Setup Bulletinboard-Ads Database"](exercise_01_ads_db.md)
- Database will run as a **Statefulset**: Create prerequisites and configuration entities: configmap, secret and service
- Create a **Statefulset** for the Ads DB, based on above entities.


### [02 Exercise: "Setup Bulletinboard-Ads Application"](exercise_02_ads_app.md)
- Create required **Configmap** and **Secret**
- Create **Deployment** for Ads App, based on above entities
- Publish Ads App via **Service** and **Ingress**
- Check Ads App running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

### [03 Exercise: "Networkpolicies & TLS for Bulletinboard-Ads and -DB"](exercise_03_ads_app_and_db_networkpolicy.md)
- Increase security and establish a **Network policy** for
  - Ads DB
  - Ads App
- Enable HTTPS connection by adding TLS certificates to **Ingress**

### [04 Exercise: "Using Helm-chart to setup Bulletinboard-Users Application and -DB](exercise_04_users_app_and_db_by_helm.md)
- Create Users DB and Users App via existing **Helm chart**

### [Optional - 05.1-05.3 Exercise: "Create Helm chart for Bulletinboard-Ads Appl. and -DB"](exercise_05_ads_helm_chart.md)
- Develop a **Helm chart** for Ads Db and Ads App

## Naming conventions of files and labels 

The chosen structure for **Labels** (and with this for **Selectors**) has 2 levels. To separate **Bulletinboard-Ads** from **Bulletinboard-Users** we introduce the **Label** `component` with value `ads` and `users`. To separate the Application-part from the Database-part within each "Component" we introduce the **Label** `module` with value `app` and `db`.  
For name of files and of the entities itself we choose the schema: `<component>-<module>-<entity>.yaml` so e.g the yaml for the service for Bulletinboard-ads application would be named `ads-app-service.yaml`.  
To shorten names in the exercise descriptions, entities will be referenced by their component & module values, like __ads:app__ to name the pod(s) for bulletinboard-ads application pod.

## Links to the resources/repos used

- [Bulletinboard Ads source with Jenkinsfile and Dockerfile](https://github.wdf.sap.corp/cloud-native-dev/bulletinboard-ads-k8s) and [Jenkins job](https://cc-cloudnative-jenkins.mo.sap.corp/job/bulletinboard-ads-k8s/)
- [Bulletinboard Users source with Jenkinsfile and Dockerfile](https://github.wdf.sap.corp/cloud-native-dev/bulletinboard-users-bootwar) and [Jenkins job](https://cc-cloudnative-jenkins.mo.sap.corp/job/bulletinboard-users-k8s-piper/job/master/)
- [Bulletinboard JSL library used in the Jenkinsfiles](https://github.wdf.sap.corp/cc-refapp/bulletinboard-JSL)
- [Piper also used in the Jenkinsfile](https://github.wdf.sap.corp/pages/ContinuousDelivery/piper-doc/)
- [Postgres docker images](https://hub.docker.com/_/postgres)


