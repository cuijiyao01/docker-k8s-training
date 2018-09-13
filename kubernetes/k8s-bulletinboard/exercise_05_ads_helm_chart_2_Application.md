Exercise 3: Authoring the chart to include the ads application itself
====================================================

## Learning Goal
- Include application manifest files in the Helm chart
- Connect the application to the database (use parameterized DB coordinates)
- Configure app to wait until DB is up and running

## Prerequisite

- Chart from Excercise 2 correctly installed (check out solution 2 branch if not done)

## Step 1: Copy all app K8s manifest files (`ads-app-*.yaml`) to the `templates` folder


Now the contents of the `templates` directory should look like this:
```
templates
  ads-app.yaml
  ads-app-configmap.yaml
  ads-app-ingress.yaml
  ads-app-networkpolicy.yaml
  ads-app-service.yaml

  ads-db-configmap-init.yaml 
  ads-db-configmap.yaml      
  ads-db-networkpolicy.yaml  
  ads-db-secret.yaml         
  ads-db-service.yaml
  ads-db.yaml

``` 

## Step 2: Change configuration so that the app can talk to the database installed with Helm

> **IMPORTANT: Do not parameterize everything like in the Exercise 2 again **

### `ads-app-configmap.yaml`

```yaml
data:
  application-k8s.yml: |
    ---
    spring:
      datasource:
        url: jdbc:postgresql://{{ template "db-service-fullname" . }}:{{ .Values.Db.Postgres.Port }}/{{ .Values.Db.Postgres.Database }}
        username: {{ .Values.Db.Postgres.User}}
        password: {{ .Values.Db.Postgres.Password }}
        driverClassName: org.postgresql.Driver
        driver-class-name: org.postgresql.Driver
```

## Step 2: Add ingress rewriting configuration for your application


### `ads-app-ingress.yaml`

```yaml
spec:
  rules:
  - host: ads.ingress.ccdev01.k8s-train.shoot.canary.k8s-hana.ondemand.com
    http:
      paths:
      - path: /<YOUR_USER_NAME>
        backend:
          serviceName: ads-service
          servicePort: ads-app
```


## Step 3: Upgrade the Chart

```bash
$ helm upgrade <release-name> bulletinboard-ads 
```


## Step 4: Check if the service is up and running

```bash
http://ads.ingress.ccdev01.k8s-train.shoot.canary.k8s-hana.ondemand.com/<YOUR_USER_NAME>/api/v1/ads
```


## Step 5: Introduce init container to check that DB is up (optional)

Do a fresh install of the chart

```bash

helm delete <release-name>

helm install bulletinboard-ads

```

Watch for the pods coming to live:

```bash


$ kubectl get pods
NAME                            READY     STATUS              RESTARTS   AGE
ads-app-54fd856ccb-k79sb        1/1       Running             0          12s
queenly-newt-ads-db-sset-0      0/1       ContainerCreating   0          12s


$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
ads-app-54fd856ccb-k79sb        0/1       Error     0          16s
queenly-newt-ads-db-sset-0      1/1       Running   0          16s

$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
ads-app-54fd856ccb-k79sb        1/1       Running   1          1m
queenly-newt-ads-db-sset-0      1/1       Running   0          1m

```

You'll notice that ads app pod starts before the db pod starts, which leads to error. Of course, kubernetes we'll retry to start the pod until it succeeds.


However, you can configure the app pod to start only after db pod is started by using init containers.

Add following configuration to the specification for the app deployment (`ads-app.yaml`)

```yaml

      initContainers:
      - name: init-postgres
        image: alpine
        command: ['sh', '-c', 'for i in $(seq 1 200); do nc -z -w3 {{ template "db-service-fullname" . }} {{ .Values.Db.Postgres.Port }} && exit 0 || sleep 3; done; exit 1']


```

Now the pod for the app will be started only after the db service is listening on defined port.

Do a fresh install and check it out.


```bash
$ kubectl get pods
NAME                            READY     STATUS        RESTARTS   AGE
ads-app-79578544d9-fh58k        0/1       Init:0/1      0          12s
idle-peahen-ads-db-sset-0       1/1       Running       0          12s
tiller-deploy-9ddfc8877-mxn52   1/1       Running       0          18d
```