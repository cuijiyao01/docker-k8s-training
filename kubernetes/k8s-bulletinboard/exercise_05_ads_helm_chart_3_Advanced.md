Exercise 4: Advanced topics
====================================================

## Learning Goal
- Define dependencies to other charts
- ...

## Prerequisite

- uninstall all charts

## Step 1: Create file `requirements.yaml` in the `bulletinboard-ads` folder


```
dependencies:
- name: bulletinboard-users
  version: "0.1.0"
  repository: "file://../../../users/helm/bulletinboard-users"

``` 

## Step 2: Update dependencies

```bash
$  helm dependency update bulletinboard-ads
```

## Step 3: Install chart

```bash
$  helm install bulletinboard-ads
```

Now both charts should be installed


## Step 4: Check if the service is up and running

```bash
http://ads.ingress.ccdev01.k8s-train.shoot.canary.k8s-hana.ondemand.com/<YOUR_USER_NAME>/api/v1/ads
```

## Step 5: Configure app application to check users (optional)

Edit `ads-app-configmap.yaml` and set parameter `post_user_check` to `true`

Change URL of the user service to match your newly created service:


```bash
data:
  profile: k8s
  post_user_check: "true"
  user_route: http://<YOUR_USER_SERVICE>/bulletinboard-users-service
```

Upgrade chart, kill app pod, check that application still works and that you can create ads. Experiment with request header `User-Id`

## Step 6: Bonus tasks (optional)

**Bonus 1:** Figure it out how to make the user service name configurable

**Bonus 2:** Make app manifest files fully configurable (simiar with db manifest files)

 