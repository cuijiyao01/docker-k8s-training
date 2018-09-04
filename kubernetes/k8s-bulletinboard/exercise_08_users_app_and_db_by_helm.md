# Exercise: Users Service with Helm

## Scope
The User Service (App) will be installed with a provided helm chart. You only have to edit/insert a few values and work on the post-install-job which we will use to intialize the DB with some data. 
After the Service is running we will adapt our Ads deployment to provide the user route and enable the checking of the user service. 

<img src="images/k8s-bulletinboard-target-picture-users-app-and-db-helm.png" width="800" />

### Overall purpose:

We provide a helm chart first for you to work with a bit more complex one compared to the helm exercise. Also it gives us an easy way to setup the user service without you having to write all the yamls again. 

## The helm chart

We provide a almost complete helm chart for the User Service: <LINK TO CHART>
In it we use 2 images:  
First, like for ads, a postgres docker image to persist data. And second the user service image described in detail below. The structure of the K8s entities in this chart is similar to the ones you created for ads. 

## User Service Docker image

We provide a Docker image with Tomcat and user.war which is used in the helm chart: `cc-k8s-course.docker.repositories.sap.ondemand.com/k8s/bulletinboard-users:v4.0`. 
The version of the user service user here only needs a postgresql db to store the user data and has no other dependencies.
The following endpoints are given: 
- `/`: gives a 'Users: OK' string and 200 code.
- `/api/v1.0/users`: takes GET/POST to read or post user data
- `/api/v1.0/users/{id}`: GET/PUT/DELETE to read,change or delete a certian user. 

UserData is e.g.: `{"id" : "42", "premiumUser" : true, "email" : "john.doe@sample.org" }`, here permiumUser determines if the user can post ads or not. This is the attribute tested in the Ads-service.


## Step 0: prerequisites
If you did not do the helm exercise, install the tiller service to enable helm in your namespace: `helm init --tiller-namespace <your-namespace>`.

## Step 1: helm

__Purpose: Get familar with the provided template files and the user service.__

Before you can install the helm chart, open the *values.yaml* file. We left out the value of a few entries, you have to fill them out yourself.  
Now do `helm install bulletinboard-users`. In the current state the user-service will run, but there will be no data in the database. 
You can test that the user-service is runing by doing:  
- `kubectl port-forward <name-of-user-app-pod> 8081:8080`: this terminal is blocked by the open connection to the pod, either put it in the background (`crtl + z` + `bg`) or open a second terminal (`crtl + shift + t`)
- get users: `curl localhost:8081/bulletinboard-users-service/api/v1.0/users`
- post a user: `curl -i -X POST localhost:8081/bulletinboard-users-service/api/v1.0/users -H "Content-Type: text/json" --data '{"id" : "42", "premiumUser" : true, "email" : "john.doe@sample.org"}'`

With this you have a running users service and a way to fill the DB with users.

## Step 2: Job to fill DB
Now you added a premiumUser to the DB by hand, which we now want to automate.

__Purpose: Learn how to use a *job* and a bit more about *strings* in yamls__

In the bulletinboard-users/templates subfolder there is a `post-install-job.yaml`, this is almost complete, only the command to fill the DB is missing. Currently there is an `echo "hello k8s trainee"` executed where we want the command to put a user in the DB. Change this echo to the curl above, and think about how to handle the single and double quotes. (In a yaml, if you want to use a ' in a single quoted string use ''.) After you adapted the file you can activated it in the chart by setting the value `InitPostJobEnabled: true` (in `values.yaml`).  
Now delete the old helm chart, and be sure that also the presisted volume of the user db gets removed. Use `helm list` to get the name of the installed chart and then do `helm delete <name of installed bulletinboard>`. 

After it is gone you can execute again `helm install bulletinboard-users`. 
Now there should also be a job with a corresponding pod, which runs once and stops after it is done. 
Again you can check the user service with:
- `kubectl port-forward <name-of-user-app-pod> 8081:8080`
- get users: `curl localhost:8081/bulletinboard-users-service/api/v1.0/users`, now you should get the user which our job put in. 

## Step 3: Adapt Ads

__Purpose: communication between apps through a service; finsish bulletinboard__

Up till now your Ads was not asking a User Service for information on a certain user. The ads app we use has a flag with which we can turn this on. To work the app needs 2 more environment variables: 
- `POST_USER_CHECK = true`: turns the checking of users on.
- `USER_ROUTE = <route to users>`: contains the route to the user service app, without the api/v1.0/users ending. 
Adapt your configmap for the environment variables to also contain these values and also add them to the deployment with the right names. After `kubectl apply -f ads-app.yaml` to update the deployment on the cluster itself, the old pod should stop and a new one started. Test that you now need a header `User-id : 42` in your POSTS to `api/v1/ads` to be able to create a new advertisement. 

