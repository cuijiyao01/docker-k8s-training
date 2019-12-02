# Exercise 5.3: Advanced topics

## Learning Goal
- Define dependencies to other charts by connection users ands ads.

## Prerequisite

- uninstall all charts for **users** and **ads**.

## Step 1: Add a `dependencies` section to `Charts.yaml` in the `bulletinboard-ads` folder

```yaml
dependencies:
- name: bulletinboard-users
  version: "0.1.0"
  repository: "file://../../../users/helm/bulletinboard-users"
``` 

Check the [Chart documentation](https://helm.sh/docs/topics/charts/#the-chart-yaml-file) for details about the dependencies.

## Step 2: Update dependencies

```bash
$ helm dependency update bulletinboard-ads
```

## Step 3: Make necessary changes to ads chart

When using dependencies it is important to know that templates (e.g. defined in _helpers.tpl files) are shared globally between subcharts and the main chart. This means that our "db-connection" template in ads overwrites the one in the users chart. For this not to happen please rename the `"db-connection"` template to `"ads-db-connection"` and adapt also the name in the application-k8s.txt file and templates/ads-app-deployment.yaml file where it is used.

## Step 4: Install chart

```bash
$ helm install <release-name> bulletinboard-ads
```

Now both charts should be installed


## Step 5: Check if the service is up and running

```bash
$ curl http://bulletinboard--<your namespace>.ingress.<cluster name>.<project name>.shoot.canary.k8s-hana.ondemand.com/ads/api/v1/ads
```

## Step 6: Configure app application to check users (optional)

Edit `ads-app-configmap.yaml` and set parameter `post_user_check` to `true`, if it is not already that.

Check URL of the user service to match your newly created service (Should be the same as before):


```yaml
data:
  profile: k8s
  post_user_check: "true"
  user_route: http://<YOUR_USER_SERVICE>/bulletinboard-users-service
```

Upgrade chart, kill app pod, check that application still works and that you can create ads. Experiment with request header `User-Id`

## Step 6: Bonus tasks (optional)

**Bonus 1:** We have a fixed user service name without the release name being part of it. Figure it out how to make the user service name configurable and how to path the name to the ads chart during installation. (Please send us your example.)

**Bonus 2:** Make app manifest files fully configurable (similar with db manifest files)

 
