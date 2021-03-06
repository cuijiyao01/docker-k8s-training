# Trainer Guide

## Overview

#### Course Prep steps
These are the logical steps for a trainer to prep for a course (details below):
- Make sure your training is 'officially' requested and schedules in SuccessMap Learning
- Sent email with preparation steps to participants
- Get/ create a Gardener cluster for your training
- Download your trainer .kube/config from Gardener that lets you control the cluster
- On your VM, run the script to generate the kube configs for the participants
- Copy the generated configs to the config share of this course
- Print the access IDs sheet to be handed out to the participants (with their config IDs)

All artifacts / scripts / info needed as trainer is in this admin folder.
You can use the participant VM also for all work as a trainer.


## Course preparation

### Planning
- Make sure the training is officially requested ([Team Request Template](https://jam4.sapjam.com/wiki/show/H8gZq0zBgHoRfttFe6TDyt?_lightbox=true)) and scheduled in SuccessMap Learning.

- If it is done this way, then our Global Coordinator from Cloud Curriculum (Rosemary Berberian) will check the utilization of our Cluster and also organizes/help to organize the room and send the calendar entry to the participants, so you don't have to worry about that.

- The event will then also appear in the [event calendar on the Cloud Curriculum Jam page](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/events).

### K8s cluster in Gardener

- **Contact the [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<Location>-<DateOfYourTraining>) to get a Gardener K8s Cluster** for the training (~ 2 weeks in advance to the training), in case you want to use the Cloud Curriculum Resources in [Gardener](https://github.wdf.sap.corp/pages/kubernetes/gardener/) (incl. Cloud Curriculum Google Account). In the email body please refer to the corresponding event in the [Cloud Curriculum Event Calendar](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/events) (e.g. link/ URL of event).

- In case you have already a Gardener K8s cluster, you can take this cluster for the training.

  **Note:** This training has been developed and tested using K8S clusters on GCP provided by Gardener. Clusters on other platforms and/or not provided by Gardener might result in some demos and exercises (e.g. Ingress, persistence volumes, LoadBalancers, etc.) not working as designed. Therefore, please make sure your K8S cluster is running on GCP and has been provided by Gardener.

### Create your trainer .kube/config

On your VM / machine
- Create a directory `.kube` under HOME (e.g. /home/vagrant on VM) and cd into it
- Create new file `config` and paste the kubeconfig yaml, you have got from [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>) for your training.
- run `kubectl get nodes` - this command must complete by giving you a short list of nodes in the cluster

### Generate the kube configs for the participants

Download or clone this repo into the VM / your linux machine.

CD into `./docker-k8s-training/admin/kubecfggen` and there do `chmod 755 kubecfggen.sh`.

Now run the script `kubecfggen.sh`. Give it the number of participants/namespaces it should create (e.g. `kubecfggen.sh 10` creates 10 different namespaces for 10 participants).
- It creates a new directory with a new training ID `training-xxxxxxxx` (8 char ID) where all generated files will be.
- Generates a yaml to create all namespaces etc in the cluster and already execute / apply it. The cluster will then already be set up for the participants.
- Generates the kubeconfig files for the participants in the subdir for the training
- Packages all files for this training into a tar.

**Please note:** The script creates not only the namespaces. It also deploys a ResourceQuota & LimitRange to each namespace. With this, abuse of the training cluster should become harder. The ResourceQuota limits the number of pods accepted by each namespace to 15. Any participant trying to scale a deployment to a hundred pods or more will not harm other participants. The LimitRange assigns default values for memory and CPU requested by a pod. It also give a default limit. If a pod does not specify any of these it will inherit the defaults. In other terms, by specifying a cpu/memory request & limit, the defaults can be overwritten.

### Copy the configs to the share

Upload the tar file using this Jenkins job: https://cc-admin.mo.sap.corp/view/K8s/job/upload-k8s-training-namespaces/

You will need to log in to that Jenkins with your D-/I-User and your global domain password. Use the "Build with arguments" button to upload the tarball with the config files.

Participants will download 'their config' using the trainings and participant ID.


### Print the participant config codes sheet

Print the file that was generated by the `kubecfggen` run that contains the trainings ID and config codes for each participant. Cut the page at the lines so that you can hand out each code to one participant.

## Sending the preparation mail to participants

You should send a **'preparation mail'** to all participants about a week before the course starts. You should add the below information in your mail:

```
------- adapt & add this info
- Please follow these instructions to download a VM and prep for the course:
  <link to repo>/blob/master/preparation.md
---------- end -----------
```
Also it is recommended to refer to the cheat-sheets for [docker](../docker/Docker%20Cheat%20Sheet.docx) and [Kubernetes](../kubernetes/cheat%20sheet.docx). Ask participants to print and bring them along, if they deem it would be helpful.

An other option would be to take one of our **mail templates**, we have prepared: [Template 1](preparation_email_sample1.txt), [Template 2](preparation_email_sample2.txt)

Technically it would be possible to run most of the exercises also with Docker on Windows/Mac and a local kubectl. **However, we would recommend explicitly exclude support for this setup during the training.**

## Setting you up for the training
**Important: Forking is no longer necessary! But feel free to do so, if you feel more comfortable with it.**

### Clone the repo
There are demo scripts/files for the container, docker and kubernetes parts. Simply clone the repo to your VM and work with this copy:

`git clone https://github.wdf.sap.corp/slvi/docker-k8s-training.git`

We are referencing stable versions of our repo with a release tag, so you can use one of these for the training as well.

### Get the cluster and project name
You will need the information to setup components like the registry. It is also required for some docker exercises and k8s demos.

Look into your (trainer) kubeconfig. The file contains a URL for the API server of the cluster. You can derive the cluster as well as the project name from this URL.

The URL pattern on Gardener looks like this:

 `[custom-endpoint].ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com`

**Example:** If your API server URL were `https://api.ccdev.k8s-train.shoot.canary.k8s-hana.ondemand.com`, the project name would be `k8s-train` and the cluster name would be `ccdev`.

### Adapt the ingress URLs
Gardener deploys an ingress controller to each cluster and allows you to register custom URLs to a specific subdomain. Since the subdomain contains the name of the Gardener project as well as the cluster, you have to adapt the ingress resources locally (on your VM) to match with your setup.

Check the following files for `<cluster-name>` and `<project-name>` placeholders and replace them with the actual cluster/project names:
* [sock-shop](../kubernetes/demo/00_sock-shop.yaml)
* [simple ingress with tls](../kubernetes/demo/09a_tls_ingress.yaml)
* [fanout & virtual host ingress](../kubernetes/demo/09b_fanout_and_virtual_host_ingress.yaml)


### Check IP address ranges
Most likely, the Gardener cluster runs on SAP external infrastructure like AWS or GCP. To make our setup a bit more secure, we/[Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>) have limited the access to whatever you expose in the cluster to traffic originating from the SAP network at your training location. Therefor we have configured the firewall rules to block traffic, that does not originate from these addresses.

Furthermore, during the training these ranges will be used for the network policy exercise. Check the yaml files in the [demo](../kubernetes/demo/11c_network_policy_ingress.yaml) and [solutions](../kubernetes/solutions/08_network_policy_ingress.yaml) folder and adapt it to your local IP blocks, if necessary.

You can use the [network information portal](https://nip.wdf.sap.corp/nip2/faces/networking/wan/PublicAddresses.xhtml) to get your local office's CIDR blocks. For the exercise 8 you can give the info to participants as well or ask them to search for it.

### Setup helm & tiller
To continue with the setup, you have to initialize tiller in `kube-system` namespace. Run the [helm_init](helm_init.sh) script within your VM to download the helm client (if not present) and bring up tiller with a dedicated service account & cluster admin permissions.

### Setup a docker registry (~1 day before course starts)
For the docker exercises you need a private docker registry. Participants will upload their custom images to it during the course. Recommendation is to spin up a registry without any persistence in the k8s cluster you use for the training.
In the admin folder of this repo, you find a registry folder with `install.registry.sh` script. Check the prerequisites and run the script as described [here](./registry/readme.md) to deploy a registry and make it available via an ingress.

### Setup cluster monitoring (~1 day before course starts)
If you want to keep track of things happening in the cluster, you can use these [scripts](./monitoring) to setup prometheus/grafana based monitoring.

### (Optional) [Gain access to the Dashboard](accessDashboard.md)

## During the Course

### Use the "master" kube.config 
For all demos to work properly (especially the RBAC demo), you have to use an "admin" user when talking to the cluster. When you use the `kube.config` you got along with the cluster details, you are on the save side. However if you use a participant user / namespace, the RBAC demo will fail due to missing authorization. 

Of course, you can create a separate namespace (!= `default`) and add it to the `kube.config` context definition to send requests to it by default.

### Node ports won't work for external access
Please be aware, that Gardener does no longer assign external IP addresses to cluster nodes. Hence, accessing applications externally via node ports does not work any longer. Node ports are still used to route traffic into the cluster network but they are only exposed within the GCP VPC of the cluster.

### Get support from Gardener Team
- Raise your question via email in the [kubernetes-users Mailinglist](https://listserv.sap.corp/mailman/listinfo/kubernetes-users) or in the [K8s CaaS in SAP Cloud Platform Jam Group](https://jam4.sapjam.com/groups/Niq7TSBxLlzgb3nroBZJVx/overview_page/e9uqTDxXBRFbk7FJXEA4Cd) or in the Slack Channel [k8s-landscape-gardener](https://sap-cp.slack.com/messages/CBV3JS9S4/).

### Add nodes to K8s cluster
In exceptional cases it might happen that your cluster needs more resources to deal with all the participants pods because autoscaler configuration is not sufficient high. In order to scale the cluster up, get in contact with [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>).

## After the course

- Contact the [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>) to let destroy the Gardener cluster, you used for the training. If needed you can request to keep the cluster for one additional week, so participants can rework on their exercises.
- If you ask for one additional week please run [Cleanup Script](cluster_cleanup.sh) `cluster_cleanup.sh all` after the last day of training on the trainings cluster to help us save some money. In all but kube-system and logging namespace it
  - scales statefulsets and deployments down to one replica.
  - removes unused pvcs.
  - scales LoadBalancer Services to NodePorts.   
- As well request to delete the kube config files, you stored for your training at https://cc-admin.mo.sap.corp/userContent/k8s-trainings/
