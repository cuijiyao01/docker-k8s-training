# Exercise: Setup Bulletinboard-Ads Database


## Scope

- Create all required entities for ads DB: configmap-init, configmap, secret and service
- Create a statefull set for the ads DB

<img src="images/k8s-bulletinboard-target-picture-ads-db-3.png" width="800" />
xxx

<img src="images/k8s-bulletinboard-target-picture-ads-db-detail.png" width="800" />
xxx

## Step 1: Configmap-init
Purpose: 
- Create a new DB for the Ads app to store the advertisements. 
- As well create a specific user with password (Not to use the default Postgesql user/ password.

kubectl apply -f ads-db-configmap-init.yaml 


## Step 2: Configmap
Purpose: Specify en environment variable PGDATA for the location of the Postgresql database files
https://hub.docker.com/_/postgres/

kubectl apply -f ads-db-configmap.yaml 


## Step 3: Secret
Purpose: Superuser password for PostgreSQL (default user: postgres)

kubectl apply -f ads-db-secret.yaml 


## Step 3: "Headless" Service
Purpose: Create the "headless" service, required to access to the pod created by the statefulset.

kubectl apply -f ads-db-service.yaml 



