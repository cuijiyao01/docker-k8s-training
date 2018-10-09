# - D R A F T/ Under Construction !

# Exercise: Setup Bulletinboard-Ads Database


## Scope

- In this first exercise we will focus on the **setup of Bulletinboard-Ads Database**, where the Bulletinboard-Ads Microservice can store the advertisements (See picture below).

<img src="images/k8s-bulletinboard-target-picture-ads-db-3.png" width="800" />

- As we do not need horizontal scaling for the database (by our assumned requirements) we will use a **Statefulset** (instead of a K8s deployment) with only one instance (replica count=1).

- As database we will use Postgresql, where on Docker hub we can find a well suiting offical [Postgresql Docker image](https://hub.docker.com/_/postgres/).

- The Postgresql Docker image gives us the possibility to override several default values via **environment variables** for e.g. the location for the database files (`PGDATA`) and the superuser password (`POSTGRES_PASSWORD`).

- As well we can run any **initdb scripts**, which we will use to create a new database with a specific user and password (Not using the default user postgres).

- To make available the Bulletinboard-Ads Database **Pod** from we setup a **"headless" service** to allow the app to talk to the database.

- The structure for **Labels** (and with this for **Selectors**) has 2 levels. To separate **Bulletinboard-Ads** from **Bulletinboard-Users** we introduce the **Label** `component` with value `ads` and `users`. To separate the App-part from the Database-part within each "Component" we introduce the **Label** `module` with value `app` and `db`.  
To shorten names, entities will be references by their component & module values, like __ads:app__ to name the pod(s) for bulletinboard-ads application pod.

<img src="images/k8s-bulletinboard-target-picture-ads-db-labels-1.png" width="800" />


## Step 0: Preparation

- Create a folder `k8s-bulletinboard` in your home directory for the various yaml-files, you will create in the exercises.
- Create a sub-folder `ads` for all yaml-files, related to **Bulletinboard-Ads** (App/Microservice + DB).

## Step 1: Create a Configmap with location of Postgres database files

- Specify a **Configmap** `ads-db-config` with an environment variable `PGDATA` for the new location of the Postgresql database files: `/var/lib/postgresql/data/pgdata` and save the **Configmap** spec under the filename `ads-db-configmap.yaml` in folder `k8s-bulletinboard/ads`. Do not forget to specify proper labels for component and module !

- Now call `kubectl apply -f ads-db-configmap.yaml` to create the **Configmap**.

## Step 2: Create a Secret to initialize the database

- Use the following sql script to create a new database `adsuser` and a specific user `adsuser` with password `initial`. 
  You can change the password (in line 3) to something else, however we will need it in Exercise 2 too, so remember it. 
  Since the file contains censitive data like password, we will store it as a generic **secret**. First save this script in an `initdb.sql` named file.

 ```
 -- This is a postgres initialization script for the postgres container. 
 -- Will be executed during container initialization ($> psql postgres -f initdb.sql)
 CREATE ROLE adsuser WITH LOGIN PASSWORD 'initial' INHERIT CREATEDB;
 CREATE DATABASE ads WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;
 GRANT ALL PRIVILEGES ON DATABASE ads TO adsuser;
 CREATE SCHEMA ads AUTHORIZATION adsuser;
 -- ALTER DATABASE ads SET search_path TO 'ads';
 ALTER DATABASE ads OWNER TO adsuser;
```

- Because the data in a secret is base64 encoded we will use *kubectl* itself to generate the yaml: 
```
 kubectl create secret generic ads-db-secret --from-file initdb.sql --dry-run -o yaml > ads-db-secret.yaml
```
  Because of the `--dry-run` parameter this will only generate a yaml and does not create the secret itself. 

- Now open the `ads-db-secret.yaml` and add the proper labels for component and modul. Add `type: Opaque` and also remove the `creationTimestamp`. Save the changes. 

- Now call `kubectl apply -f ads-db-secret.yaml` to create the **Secret**.

## Step 3: Secret for Postgres Superuser Password

Purpose: Create a Secret with password for Postgres superuser

We could create a 2nd secret for this. Yet, we will instead add this info to the above secret so we have less files and entities on kubernetes. 
- Open `ads-db-secret.yaml` and add a data element with key `PG_PASSWORD` and with a value of your choice which will become the PostgreSQL master password. You will have to base64 encode the password before entering it into the YAML file. Save the **Secret** under the filename `ads-db-secrets.yaml` in folder `k8s-bulletinboard/ads`. Do not forget to specify proper labels for component and module!  
To can take any String as a master password, but if you want a random string you could do e.g. `openssl rand -base64 15 | base64` which will already give you a random already encoded password. (The first `-base64` option is used to only have alphanumerics in the password). 

- Now call `kubectl apply -f ads-db-secret.yaml` to update the **Secret** with the 2nd data item.

## Step 4: "Headless" Service
Purpose: Create the **"headless" Service**, required to access the pod, created by the statefulset.

- Specify a **"headless" Service** `ads-db-service` with proper labels and selector for component and module. Use the default port, given by the Docker image (port 5432 as depicted by the description on [Docker Hub](https://hub.docker.com/_/postgres/)) and make sure you are using a named port. Save the service under the filename `ads-db-service.yaml` in folder `k8s-bulletinboard/ads`.

- Now call `kubectl apply -f ads-db-service.yaml` to create the **"headless" Service**.

## Step 5: Statefulset

Purpose: Create the **Statefulset**, which uses both Configmaps, the Secret and the "headless" Service, created in step 1-4 (Creation of Statefulset will fail, if those entities are not yet available !).

<img src="images/k8s-bulletinboard-target-picture-ads-db-statefulset.png" width="300" />

_Hint: In the following sections we will provide you yaml-snippets of the Statefulset specification. Just substitute the place holders `<...>` by proper values !_

- Specify a **Statefulset** for the Postgres Database Pod with name `ads-db` with proper labels and selector for component and module. 

```
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: <name-of-statefulset>
  labels:
    component: <name-of-component>
    module: <name-of-module>
```

- Refer to the "headless" service, created earlier and make shure that only one DB pod gets created. 
- Additional refer under `volumes` to the secret item with database initialization script and refer to the configmap and right secret item when setting up Postgres environment variables in the Docker container.

```
spec:
  serviceName: <name-of-headless-service
  replicas: <#-of-DB-pods>
  selector:
    matchLabels:
      component: <name-of-component>
      module: <name-of-module>
  template:
    metadata:
      labels:
        component: <name-of-component>
        module: <name-of-module>
    spec:
      volumes:
      - name: init
        secret:
          secretName: <name-of-init-secret>
          items:
          - key: <key-name-of-INITDB.SQL-file>
            path: initdb.sql
      containers:
      - name: ads-db
        image: postgres:9.6
        ports:
        - containerPort: 5432
          name: ads-db
        volumeMounts:
        - name: ads-db-volume
          mountPath: /var/lib/postgresql/data/
        - name: init
          mountPath: /docker-entrypoint-initdb.d/
        env:
        - name: <postgres-environment-variable-for-path-of-datebase-files>
          valueFrom:
            configMapKeyRef:
              name: <name-of-configmap>
              key: <name-of-data-specified-in-configmap>
        - name: <postgres-environment-variable-for-superuser-password>
          valueFrom:
            secretKeyRef:
              name: <name-of-secret>
              key: <name-of-data-specified-in-secret>
```

- For the creation of the PVC we are using the volumeClaimTemplates mechanism. Here just make shure you are using proper labels for component and module. 

```
  volumeClaimTemplates:
  - metadata:
      name: ads-db-volume
      labels:
        component: <name-of-component>
        module: <name-of-module>
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

- When you are ready with the specification of the **Statefulset** save it under the filename `ads-db.yaml` in folder `k8s-bulletinboard/ads` and call `kubectl apply -f ads-db.yaml` to create the **Statefulset** `ads-db`.

- After successful creation of the **Statefulset** check, wether the **Pod** `ads-db-0` got created properly  via `kubectl get pod ads-db-0 -o yaml` or in more detail via `kubectl describe pod ads-db-0` . Also check wether the Database is ready to be connected via `kubectl logs ads-db-0`. There should be the line: `LOG:  database system is ready to accept connections` in the logs. 


## Optional- Step 6: Detailled Check wether Pod with postgres DB is running properly

Purpose: check wether the database is running and accepting connections. Use the pgadmin tool for that.

- Install pgadmin locally on your virtual machine. For the training virtual machine, use the following command to install the software: `sudo apt install pgadmin3`

- Use `kubectl port-forward` to forward the database port from the database pod of your statefulset to your local virtual machine. 

- With pgadmin, connect to the forwarded database port on your `localhost` and supply the credentials for the user that got created on the database by the initialization script. If the login succeeds, your database is up and running and this part of the exercise is complete.
