# Exercise 05: Reviews Service with Helm

## Scope
The bulletinboard-reviews service will be installed with a provided helm chart.
You only have to edit/insert a few values in a `customValues.yaml`
After the Service is running we will finally be able to test our "complete" bulletinboard application.

### Overall purpose:

Get experience with a bit more complex helm chart compared to the helm exercise.
Also it gives us an easy way to setup the user service without you having to write all the yaml files again.

## The helm chart

We provide an almost complete helm chart for the reviews-service: **bulletinboard-reviews.tar.gz**.
The chart is rather similar to the setup of the bulletinboard-ads but can't be deployed right away.
Some parameters are required:

```
Db.StorageSize (optional - defaults to "512Mi")
App.Image (mandatory)
App.ImagePullSecret (optional - defaults to 'training-registry')
Ingress.Domain: (mandatory)
Ingress.ShortName: (mandatory)
Ingress.LongName: (mandatory)
```

## Step 0: Prerequisites
If you have done so already install helm. This was also a prerequisite of the helm exercise.

Go to your project base folder `k8s-bulletinboard`, which you created at the beginning of exercise 2, and create a sub-folder `reviews`.
Download the chart into that folder and extract it:

```bash
wget https://github.wdf.sap.corp/slvi/docker-k8s-training/raw/master/kubernetes/k8s-bulletinboard/bulletinboard-reviews-chart.tgz
tar -xvzf bulletinboard-reviews-chart.tar.gz
```

## Step 1: Helm

Purpose: Get familiar with the provided template files and deploy bulletinboard-reviews.

Providing all necessary parameters through the command line is cumbersome.
Therefore create a new file next to the chart-folder called `customValues.yaml` and provide all parameters there.
Remember to use the url that you gave put in the bulletinboard-ads config as ingress url.

Now do `helm install <release-name> ./helm-chart --values customValues.yaml` in the directory containing the helm-chart folder and the `customValues.yaml`. (Or adapt the path in command accordingly)

You can test that the reviews-service is running by executing `kubectl get all -l "component=reviews"`.
The pods should be on state running.

## Step 2: Test Bulletinboard

- Do some stuff in the UI of both services and test your deployment.


## Troubleshooting tips
If you encounter difficulties you can use `--dry-run --debug` with the helm install command to view the generated yaml files.
