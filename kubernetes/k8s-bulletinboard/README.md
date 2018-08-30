# Microservice based Application in Kubernetes using Cloud Curriculum Sample Application "Bulletinboard"
- xx
- yy

<img src="images/k8s-bulletinboard-target-picture-detail-3.png" width="800" />

## [Exercise: "Setup Bulletinboard-Ads Database"](/exercise_01_ads_db.md)
- Create all required entities for ads DB: configmap-init, configmap, secret and service
- Create a statefull set for the ads DB


## [Exercise: "Setup Bulletinboard-Ads Application"](/exercise_02_ads_app.md)
- Create required configmap and deployment for ads
- Publish ads via service and ingress
- Check Ads running properly together with Ads DB (e.g. create ads via postman, display list of ads in browser, ...)

## [Exercise: "Increase security via Networkpolicies & TLS for Bulletinboard-Ads and -DB"](/exercise_05_ads_db_networkpolicy.md)
- Increase security and establish a network policy for
  - Ads DB
  - Ads

## [Exercise: "Using Users Helm-chart to setup Bulletinboard-Users Application and -Database](/exercise_08_users_app_and_db_by_helm.md)
- Create Users DB and Users Ads via existing helm chart


## OPTIONAL - [Exercise: "Create Helm chart for Bulletinboard-Ads Application and -DB"](/exercise_20_ads_helm_chart.md)
- Develop a Helm chart for Ads Db and Ads App


