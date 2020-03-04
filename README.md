# Docker and Kubernetes fundamentals  

This is the repo for the "docker & kubernetes fundamentals course". Gain basic Docker knowledge and learn to orchestrate your containers with Kubernetes. Get started with Docker and run your first container as well as build custom Docker images. When working with Kubernetes you will get to know the common entities in Kubernetes and apply your knowledge during exercises.
For an overview of topics see the agenda pages on top level.

Official course information: [Docker and Kubernetes Fundamentals](https://jam4.sapjam.com/blogs/show/P2dUZRL6WyEY8FYqqGyaAR)  (part of [Cloud Curriculum](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/overview_page/Y1fECzZLQ8qjIlyCQTRi76)  )

> For a comparison of SAP CP platforms and when to use what, see the [Platform Guide](https://wiki.wdf.sap.corp/wiki/x/Vwg4bg) and [CF vs K8s](https://jam4.sapjam.com/groups/UvgtUwzohySLY8dDvClacv/documents/F36I53Tz8JVEGyVWesgGuV/slide_viewer?_lightbox=true)

## Course outline
High level topics are:

### [Why Docker & Kubernetes?](./00_why_docker_k8s.pptx)

### [Docker](./docker) (day 1)
- Linux foundations: Containers under the hood ([slides](./docker/01_Basics_of_containers.pptx), [exercise 0](./docker/Exercise%200%20-%20Linux%20Primitives.md))
- How Docker works ([slides](./docker/02_Docker_Fundamentals.pptx) & [exercise 1](./docker/Exercise%201%20-%20Container%20Lifecycle.md))
- Ports and volumes: Docker networking, persisting data ([slides](./docker/02_Docker_Fundamentals.pptx) & [exercise 2](./docker/Exercise%202%20-%20Ports%20and%20Volumes.md))
- Images: Loading, creating, push/pull, image registries ([slides](./docker/03_Images.pptx))
- Dockerfiles: Automated creation of docker images ([slides](./docker/04_Dockerfiles.pptx), [exercise 3](./docker/Exercise%203%20-%20Images%20and%20Dockerfiles.md) & [optional exercise 4](./docker/Exercise%204%20-%20Dockerfiles%20Extended.md))

### [Kubernetes](./kubernetes) (day 2+3)
- Introduction ([slides](./kubernetes/00_intro.pptx))
- components of a K8s cluster ([slides](./kubernetes/01_k8s_core_components.pptx) & [exercise 1](./kubernetes/exercise_01_kubectl_basics.md))
- scheduling of workloads with
    - pods ([slides](./kubernetes/02_pods.pptx) & [exercise 2](./kubernetes/exercise_02_create_pod.md))
    - deployments  ([slides](./kubernetes/03_labels_and_deployments.pptx) & [exercise 3](./kubernetes/exercise_03_deployment.md))
- networking in k8s with services ([slides](./kubernetes/04_networking_services.pptx) & [exercise 4](./kubernetes/exercise_04_services.md))
- storage API in k8s ([slides](./kubernetes/05_persistence.pptx) & [exercise 5](./kubernetes/exercise_05_persistence.md))
- basic troubleshooting ([slides](./kubernetes/06_troubleshooting.pptx))
- configure applications with config maps and secrets ([slides](./kubernetes/07_configmap_secrets.pptx) & [exercise 6](./kubernetes/exercise_06_configmaps_secrets.md))
- expose applications via ingress ([slides](./kubernetes/09_ingress.pptx) & [exercise 7](./kubernetes/exercise_07_ingress.md))
- run stateful applications with stateful sets ([slides](./kubernetes/10_statefulset.pptx) & [exercise 8](./kubernetes/exercise_08_statefulset.md))
- security: RBAC, resource limits, security policies, network policies ([slides part 1](./kubernetes/11_1_accessControll_and_resourceConsumption.pptx), ([slides part 2](./kubernetes/11_2_security.pptx), & [exercise 9](./kubernetes/exercise_09_network_policy.md)) and some attack scenarios
- introduction to jobs, scheduling, image pulling, kubernetes dashboard and Gardener ([slides](./kubernetes/11_3_morePods_Sheduling_and_Gardener.pptx))
- deploy packaged applications with helm ([slides](./kubernetes/12_helm.pptx) & [exercise 10](./kubernetes/exercise_10_helm_basics.md))
- write a helm chart ([slides](./kubernetes/12_helm.pptx) & [exercise 11](./kubernetes/exercise_11_write_a_helm_chart.md))

### [Kubernetes: HowTo 'bring' Bulletinboard in K8s](./sample-app/README.md) (day 4)

## Preparation and Setup

Follow the instructions on the page [Prerequisites and Environment Setup](preparation.md).

## Trainers and Course developers

* As trainer please check out the [Trainer Guide](./admin/trainer-guide.md) in advance to the training.
* The VM to be used by participants is built here: https://github.wdf.sap.corp/cloud-native-dev/k8s-training-vm
