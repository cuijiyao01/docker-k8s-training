# Further Reading/Watching

If you would like to get some more information on Docker and/or Kubernetes inside and outside of SAP, we would like to share some links with you.

## Docker

- Our talk about the absolute container basics at SAP's *devX* event: [Container 101](https://video.sap.com/media/t/1_gxz1oox7/84675141)

- The Dockerfile reference can be found on Docker's website: [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

- Docker architecture - read about [containerd](https://containerd.io/) and how it [relates](https://hackernoon.com/docker-containerd-standalone-runtimes-heres-what-you-should-know-b834ef155426?gi=c8140ae48de2) to the docker universe.

- You have to be careful about which Docker images you download - [this is why](https://kromtech.com/blog/security-center/cryptojacking-invades-cloud-how-modern-containerization-trend-is-exploited-by-attackers).

- resource management with Docker - [how to limit a container's resources](https://docs.docker.com/config/containers/resource_constraints)

- [dive](https://github.com/wagoodman/dive/blob/master/README.md) is a tool for image inspection

- building images without docker is possible with [kaniko](https://github.com/GoogleContainerTools/kaniko)

## Kubernetes

- First of all: SAP offers an internal Kubernetes platform offering that is called Project Gardener. If you need a Kubernetes environment, this is the place to go: [Gardener](https://github.wdf.sap.corp/pages/kubernetes/gardener/)

- If you are looking for more detailed information about Gardener, check out this [kubernetes blog post](https://kubernetes.io/blog/2018/05/17/gardener/).

- Do you want to watch Kelsey Hightower, one of the big brains behind Kubernetes play Tetris on the Jumbotron at d-Kom 2018 at SAP Arena? Check out [his keynote](https://broadcast.co.sap.com/event/dkom/2018#!video%2F18106).

- If there is a Container 101 talk at *devX*, there must be a Kubernetes 102 talk as well: [Kubernetes 102](https://video.sap.com/media/t/1_64gue1c2/84675141)

- Interested in the architecture behing Gardener? There was a talk about it at *devX*, too:
[Project Gardener: Multicloud Kubernetes Cluster Provisioning at Scale](https://video.sap.com/media/t/1_9ifoaxbx/84675141)

- Gardener's curated [link list](https://github.wdf.sap.corp/pages/kubernetes/gardener/doc/2017/01/16/howto-curated-links.html)

- Another talk at *devX* was about resource management in Kubernetes:
[Inside Kubernetes Resource Management (QoS) – Mechanics and Lessons from the Field](https://video.sap.com/media/t/1_hcnybwp9/84675141)

- The nitty gritty details about the networking in and behind Kubernetes are explained in the final *devX* talk we would like to point you to: [Insights into Kubernetes Networking](https://video.sap.com/media/t/1_8fawa5io/84675141)

- More on networking? The [Life of a Packet](https://www.youtube.com/watch?v=0Omvgd7Hg1I) talk by Google's Michael Rubin at KubeCon EU '17 can be found [here on YouTube](https://www.youtube.com/watch?v=0Omvgd7Hg1I).

- If you are more into reading - here is a very good [blog post](https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/) about networking in Kubernetes context.

- The Kubernetes API reference can be found here: [Kubernetes API reference Documentation](https://kubernetes.io/docs/reference/).

- If you need to gather and combine the logs from several pods belonging to a deployment, you might want to have a look at [kubetail](https://github.com/johanhaleby/kubetail).

- Cluster federation / multi cluster: if you want to join several clusters into a federation and run your workloads, here is your entrypoint into this (alpha) topic: https://kubernetes.io/docs/tasks/administer-federation/cluster/

- with the introduction of the `horizontal pod autoscaler`, k8s is capable of auto scaling. Check the [documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [tutorial](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) for further details.

- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) is a tool which helps creating API extensions including their controller/reconcile loops

## Helm
- overview of available charts: https://github.com/kubernetes/charts/tree/master/stable
- offical documentatio: https://docs.helm.sh/
- Videos from internal events:
  - https://video.sap.com/playlist/dedicated/31122632/1_b597m58u/1_910vsh7f
  - https://video.sap.com/playlist/dedicated/31122632/1_b597m58u/1_hkwlxqmn

## SAP specific security aspects
- [container reference architecture security procedure](https://wiki.wdf.sap.corp/wiki/x/HkxOcQ)
- [Docker security procedure](https://wiki.wdf.sap.corp/wiki/x/Uk8GcQ)
- [Security approved container base images](https://wiki.wdf.sap.corp/wiki/x/UYYRd)

## General

- Brendan Burns, Distinguished Engineer at Microsoft and Chief Architect behind the container infrastucture within Azure released one of his books on distributed software design for free: [Designing Distributed Systems](https://azure.microsoft.com/en-us/resources/designing-distributed-systems/)

- [katacoda learning platform](https://www.katacoda.com/learn) offers browser-based tutorials around docker & kubernetes  

- [CTO Circle – Container Delivery Guidance](https://sap.sharepoint.com/sites/60001485/Shared%20Documents/01_Communication/CTO%20Circle%20%26%20Technology%20Board%20Meetings/CTO%20Circle/Container%20Delivery_RELEASED.pdf?csf=1&e=THkcxG)
