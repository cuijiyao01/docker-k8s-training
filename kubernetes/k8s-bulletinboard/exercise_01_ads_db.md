# Exercise: Setup Bulletinboard-Ads Database


## Scope

- In this first exercise we will focus on the setup of Bulletinboard-Ads Database, where the Bulletinboard-Ads Microservice can store the advertisements.

<img src="images/k8s-bulletinboard-target-picture-ads-db-3.png" width="800" />

- As we do not need horizontal scaling for the database we will use a **Statefulset** (instead of a K8s deployment) with only one instance (replicaset=1).

- As database we will use Postgresql, where on Docker hub we can find a well suiting offical [Postgresql Docker image](https://hub.docker.com/_/postgres/).

- The Postgresql Docker image gives us the possibility to override several default values via **environment variables** for e.g. the location for the database files (`PGDATA`) and the superuser password (`POSTGRES_PASSWORD`).

- As well we can run any **initdb scripts**, which we will use to create a new database with a specific user and password (Not using the default user postgres).

- To make available the Bulletinboard-Ads Database **Pod** from "outside" we have to provide use a **"headless" Service**.

<img src="images/k8s-bulletinboard-target-picture-ads-db-detail.png" width="800" />


## Step 1: Create a Configmap to initialize the database

- Use the following sql script to create a new database `adsuser` and a specific user `adsuser` with password `initial`.

 ```
 -- This is a postgres initialization script for the postgres container. Execute it with psql as:
 -- $> psql postgres -f initdb.sql
 CREATE ROLE adsuser WITH LOGIN PASSWORD 'initial' INHERIT CREATEDB;
 CREATE DATABASE ads WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;
 GRANT ALL PRIVILEGES ON DATABASE ads TO adsuser;
 CREATE SCHEMA ads AUTHORIZATION adsuser;
 -- ALTER DATABASE ads SET search_path TO 'ads';
 ALTER DATABASE ads OWNER TO adsuser;
```

- Create a **Configmap** 'ads-db-init' (incl. proper labels for component and module) and store above sql script under the data section with name `initdb.sql` and save the **Configmap** spec under the filename `ads-db-configmap-init.yaml`.

- Now call `kubectl apply -f ads-db-configmap-init.yaml` to create the **Configmap**.


## Step 2: Configmap
Purpose: Specify en environment variable PGDATA for the location of the Postgresql database files
https://hub.docker.com/_/postgres/

kubectl apply -f ads-db-configmap.yaml 


## Step 3: Secret
Purpose: Superuser password for PostgreSQL (default user: postgres)

kubectl apply -f ads-db-secret.yaml 


## Step 4: "Headless" Service
Purpose: Create the "headless" service, required to access to the pod created by the statefulset.

kubectl apply -f ads-db-service.yaml 

## Step 5: Statefulset
Purpose: Create the statefulset, based on Configmap-Init, Configmap, Secret and Headless service (defined in steps 1-4).

kubectl apply -f ads-db.yaml 



