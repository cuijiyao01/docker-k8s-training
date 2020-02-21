# Microservice-based Application in Kubernetes using Cloud Curriculum Sample Application "Bulletinboard"

In the following **5 exercises** you will learn how to deploy a microservice-based business application in a Kubernetes-cluster. 
As sample application we are using the **[Bulletinboard from the Cloud-Native-Boot-Camp](https://github.wdf.sap.corp/cloud-native-bootcamp/info)**. 

The Bulletinboard is build up by two individual microservices:
- **[Bulletinboard-Ads](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-ads-java)** (Java), which can **list**, **create** and **delete advertisements**
- **[Bulletinboard-Reviews](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-reviews-nodejs)** (NodeJs), which contains ratings for users.

The advertisements are presented differently depending of the rating of the user, who created the advertisement.
The overall structure of **Bulletinboard 'in K8s'**, incl. the different **K8s entities** needed for Kubernetes can be found in the following picture.

<img src="images/k8s-bulletinboard-target-picture-detail-3.png" width="800" />

_Legend: `ingr`: Ingress, `svc`: Service, `nwp`: Network policy, `cm`: Configmap, `sec`: Secret_

## Exercises

### [01 Exercise: "Build and Push the Docker Images"](exercise_01_make_images_available.md)
- Database will run as a **Statefulset**: Create prerequisites and configuration entities: configmap, secret and service
- Create a **Statefulset** for the Ads DB, based on above entities.

### [02 Exercise: "Setup Bulletinboard-Ads Database"](exercise_02_ads_db.md)
- Database will run as a **Statefulset**: Create prerequisites and configuration entities: configmap, secret and service
- Create a **Statefulset** for the Ads DB, based on above entities.

### [03 Exercise: "Setup Bulletinboard-Ads Application"](exercise_03_ads_app.md)
- Create required **Configmap** and **Secret**
- Create **Deployment** for Ads App, based on above entities
- Publish Ads App via **Service** and **Ingress**
- Check Ads App running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

### [04 Exercise: "Networkpolicies & TLS for Bulletinboard-Ads"](exercise_04_networkpolicies_and_certificate.md)
- Increase security and establish a **Network policy** for
  - Bulletinboard-Ads Database
  - Bulletinboard-Ads App
- Enable HTTPS connection by adding TLS certificates to **Ingress**

### [05 Exercise: "Using Helm-chart to setup Bulletinboard-Reviews](exercise_05_reviews_as_helm_chart.md)
- Deploy Bulletinboard-Reviews via existing **Helm chart**

## Naming conventions of files and labels 
The chosen structure for **Labels** (and hence **Selectors** as well) has 2 levels.
To separate **Bulletinboard-Ads** from **Bulletinboard-Reviews** we introduce the **Label** `component` with value `ads` and `reviews`.
To separate the Application-part from the Database-part within each "Component" we introduce the **Label** `module` with value `app` and `db`.
For name of files and of the entities itself we choose the schema: `<component>-<module>-<entity>.yaml` so e.g the yaml for the service for Bulletinboard-ads application would be named `ads-app-service.yaml`.
To shorten names in the exercise descriptions, entities will be referenced by their component & module values, like __ads:app__ to name the pod(s) for bulletinboard-ads application pod.
