# Setting up a Gardener Cluster in three easy steps

**Note:** This guide is meant for the training admins to create a new cluster for a training only. If you happen to be a trainer and you need a cluster for your training, please get in touch by sending an e-mail to the [Cloud Curriculum K8S Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@sap.com?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<Location>-<DateOfYourTraining>). Refer to the [Trainer Guide](trainer-guide.md) for more information.

## Create the cluster
Use the [Gardener canary landscape](https://dashboard.garden.canary.k8s.ondemand.com/login) to create a new cluster for a training. 

- The **name** of the cluster should **not exceed seven characters** as this might cause issues with ingress resources and their certificates. The general pattern is `<location>cw<calendar week>`, e.g. `wdfcw42`.
- The cluster should be deployed into GCP using the _gardener-canary-k8s-train_ secret.
- Make sure the cluster is located in a [region](https://cloud.google.com/compute/docs/regions-zones/) close to the training, e.g.:
  - _europe-west1_ for trainings in Europe
  - _asia-south1_ for trainings in India or 
  - _us-west1_ for trainings in North-America. **DO NOT USE us-west2!**
- Provide enough worker nodes - a maximum of 12 worker nodes of _n1-standard-4_ is a good measure for a training with up to 30 participants.
- Set the Maintenance Schedule to a time that does not interfere with the training (remember the different timezones).
- Delete the Hibernation Schedule.

## Deploy the kube.config
Retrieve the kube.config file from Gardener and send it to the requestor.
