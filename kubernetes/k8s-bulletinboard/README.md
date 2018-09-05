# Microservice based Application in Kubernetes using Cloud Curriculum Sample Application "Bulletinboard"
- In the following **5 exercises** you will learn how to make available a microservice based business application in Kubernetes. 
- As sample application we are using a slightly adapted version of **Bulletinboard from the Cloud Curriculum**. The Bulletinboard is build up by two individual microservices - Bulletinboard-Ads and Bulletinboard-Users, which communicate across each others to list, create and delete Advertisements. Both have an own database to store data.
- The overall structure of Bulletinboard, incl. the different K8s entities, needed for Kubernetes can be found in the following picture.

<img src="images/k8s-bulletinboard-target-picture-detail-3.png" width="800" />

## Exercises
### [Exercise: "Setup Bulletinboard-Ads Database"](exercise_01_ads_db.md)
- Create all required entities for ads DB: configmap-init, configmap, secret and service
- Create a statefull set for the ads DB


### [Exercise: "Setup Bulletinboard-Ads Application"](exercise_02_ads_app.md)
- Create required configmap and deployment for ads
- Publish ads via service and ingress
- Check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

### [Exercise: "Networkpolicies & TLS for Bulletinboard-Ads and -DB"](exercise_03_ads_app_and_db_networkpolicy.md)
- Increase security and establish a network policy for
  - Ads DB
  - Ads

### [Exercise: "Using Helm-chart to setup Bulletinboard-Users Application and -DB](exercise_08_users_app_and_db_by_helm.md)
- Create Users DB and Users Ads via existing helm chart


### [Optional - Exercise: "Create Helm chart for Bulletinboard-Ads Appl. and -DB"](exercise_20_ads_helm_chart.md)
- Develop a Helm chart for Ads Db and Ads App


