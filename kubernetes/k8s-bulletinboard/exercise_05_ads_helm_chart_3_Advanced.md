Exercise 5.3: Advanced topics
====================================================

## Learning Goal
- Define dependencies to other charts by connection users ands ads.

## Prerequisite

- uninstall all charts for **users** and **ads**.

## Step 1: Create file `requirements.yaml` in the `bulletinboard-ads` folder

```
dependencies:
- name: bulletinboard-users
  version: "0.1.0"
  repository: "file://../../../users/helm/bulletinboard-users"

``` 

## Step 2: Update dependencies

```bash
$ helm dependency update bulletinboard-ads
```

## Step 3: Install chart

```bash
$ helm install bulletinboard-ads
```

Now both charts should be installed


## Step 4: Check if the service is up and running

```bash
$ curl http://bulletinboard--<your namespace>.ingress.<cluster name>.<project name>.shoot.canary.k8s-hana.ondemand.com/ads/api/v1/ads
```

## Step 5: Configure app application to check users (optional)

Edit `ads-app-configmap.yaml` and set parameter `post_user_check` to `true`, if it is not already that.

Check URL of the user service to match your newly created service (Should be the same as before):


```bash
data:
  profile: k8s
  post_user_check: "true"
  user_route: http://<YOUR_USER_SERVICE>/bulletinboard-users-service
```

Upgrade chart, kill app pod, check that application still works and that you can create ads. Experiment with request header `User-Id`

## Step 6: Bonus tasks (optional)

**Bonus 1:** WE have a fixed user service name without the release name being part of it. Figure it out how to make the user service name configurable and how to path the name to the ads chart during installation. (Please send us your example.)

**Bonus 2:** Make app manifest files fully configurable (simiar with db manifest files)

 
