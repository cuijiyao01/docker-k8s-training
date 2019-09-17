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

- If you are looking for incredibly slim container base images, have a look at Google's [distroless images](https://github.com/GoogleContainerTools/distroless).

### SAP specific
- Docker [build plugin](https://github.wdf.sap.corp/pages/xmake-ci/User-Guide/Setting_up_a_Build/Build_Plugins/Docker_Build_Plugin/About_Docker_Build_Plugin) with [xmake](http://go.sap.corp/xmake)

- infos about DMZ & customer facing stores can be found [here](https://shipments.pages.repositories.sap.ondemand.com/docs/).

-  more details about the repository based shipment channel implementation can be found [here]https://shipments.pages.repositories.sap.ondemand.com/docs/shipment.html#supported-user-stories).

## Kubernetes

#### @SAP: Gardener
- First of all: SAP offers an internal Kubernetes platform offering that is called Project Gardener. If you need a Kubernetes environment, this is the place to go: [Gardener](https://github.wdf.sap.corp/pages/kubernetes/gardener/)

- If you are looking for more detailed information about Gardener, check out this [kubernetes blog post](https://kubernetes.io/blog/2018/05/17/gardener/).

- Interested in the architecture behind Gardener? There was a talk about it at *devX*, too:
[Project Gardener: Multicloud Kubernetes Cluster Provisioning at Scale](https://video.sap.com/media/t/1_9ifoaxbx/84675141)

- Gardener's curated [link list](https://github.wdf.sap.corp/pages/kubernetes/gardener/doc/2017/01/16/howto-curated-links.html)

#### in general
- Do you want to watch Kelsey Hightower, one of the big brains behind Kubernetes play Tetris on the Jumbotron at d-Kom 2018 at SAP Arena? Check out [his keynote](https://broadcast.co.sap.com/event/dkom/2018#!video%2F18106).

- If there is a Container 101 talk at *devX*, there must be a Kubernetes 102 talk as well: [Kubernetes 102](https://video.sap.com/media/t/1_64gue1c2/84675141)

- Another talk at *devX* was about resource management in Kubernetes:
[Inside Kubernetes Resource Management (QoS) – Mechanics and Lessons from the Field](https://video.sap.com/media/t/1_hcnybwp9/84675141)

- The Kubernetes API reference can be found here: [Kubernetes API reference Documentation](https://kubernetes.io/docs/reference/).

- If you need to gather and combine the logs from several pods belonging to a deployment, you might want to have a look at [kubetail](https://github.com/johanhaleby/kubetail).

- Cluster federation / multi cluster: if you want to join several clusters into a federation and run your workloads, here is your entrypoint into this (alpha) topic: https://kubernetes.io/docs/tasks/administer-federation/cluster/

- with the introduction of the `horizontal pod autoscaler`, k8s is capable of auto scaling. Check the [documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and [tutorial](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) for further details.

- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) is a tool which helps creating API extensions including their controller/reconcile loops

- for managing access to multiple clusters, we put some small bash snippets into a [gist](https://github.wdf.sap.corp/gist/D051945/3f3daf9f71f7e012c1e25a48c1c6e8da)

- getting started locally - with [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/)

#### networking
- The nitty gritty details about the networking in and behind Kubernetes are explained in the final *devX* talk we would like to point you to: [Insights into Kubernetes Networking](https://video.sap.com/media/t/1_8fawa5io/84675141)

- More on networking? The [Life of a Packet](https://www.youtube.com/watch?v=0Omvgd7Hg1I) talk by Google's Michael Rubin at KubeCon EU '17 can be found [here on YouTube](https://www.youtube.com/watch?v=0Omvgd7Hg1I).

- If you are more into reading - here is a very good [blog post](https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/) about networking in Kubernetes context.

- SE radio: [container networking talk](http://www.se-radio.net/2018/10/se-radio-episode-341-michael-hausenblas-on-container-networking/)

- [Envoy](https://kubernetespodcast.com/episode/033-envoy/), with Matt Klein

### security
- wordpress & reverse shell - k8s security talk @ContainerConf by Jen Tong: https://vimeo.com/306157921 (demo starts around 30:20)

- another talk about Kubernetes security by Dirk Marwinski of SAP's Gardener team that he held at SAP's Security Summit 2019 can be found [here](https://video.sap.com/media/t/1_4g3e4aah) with the slides [here](https://jam4.sapjam.com/groups/0O5MDqirlZsPGRKP3y6Ydt/documents/GZr8SmrvBdWhP7miO0WhU9)

- [Three Years of Lessons Running Potentially Malicious Code Inside Containers](https://www.youtube.com/watch?v=kbPEE33HEHw) - Ben Hall, Katacoda 

- [root container](https://www.youtube.com/watch?v=ltrV-Qmh3oY&feature=youtu.be) @KubeCon by Liz Rice

- secret management with [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) or [vault](https://www.vaultproject.io/docs/what-is-vault/index.html).

### SAP Kubernetes Summits
- Slides and recordings from all the sessions at SAP's first Kubernetes Summit 2019 in Walldorf/Rot, Germany can be found in [Jam](https://jam4.sapjam.com/blogs/show/rW4XILnu81NbcUpiMQWWuu)

## Helm
- overview of available charts: https://github.com/kubernetes/charts/tree/master/stable
- official documentation: https://docs.helm.sh/
- Videos from internal events:
  - https://video.sap.com/playlist/dedicated/31122632/1_b597m58u/1_910vsh7f
  - https://video.sap.com/playlist/dedicated/31122632/1_b597m58u/1_hkwlxqmn

## SAP specific security aspects
- [container reference architecture security procedure](https://wiki.wdf.sap.corp/wiki/x/HkxOcQ)
- [Docker security procedure](https://wiki.wdf.sap.corp/wiki/x/Uk8GcQ)
- [Security approved container base images](https://wiki.wdf.sap.corp/wiki/x/UYYRd)

## General

- Brendan Burns, Distinguished Engineer at Microsoft and Chief Architect behind the container infrastructure within Azure released one of his books on distributed software design for free: [Designing Distributed Systems](https://azure.microsoft.com/en-us/resources/designing-distributed-systems/)

- [katacoda learning platform](https://www.katacoda.com/learn) offers browser-based tutorials around docker & kubernetes  

- [CTO Circle – Container Delivery Guidance](https://sap.sharepoint.com/sites/60001485/Shared%20Documents/01_Communication/CTO%20Circle%20%26%20Technology%20Board%20Meetings/CTO%20Circle/Container%20Delivery_RELEASED.pdf?csf=1&e=THkcxG)

## Further contact information

- [kubernetes mailing list @sap](https://listserv.sap.corp/mailman/listinfo/kubernetes-users)
- [Cloud Platform enabling Team JAM Contact Page](https://go.sap.corp/cpet)
- [Cloud Platform enabling Team offerings](https://github.wdf.sap.corp/pages/kubernetes/gardener/offering/)
- [K8s Gardener Canary slack channel](https://sap-cp.slack.com/messages/CBV3JS9S4/)
- [Gardener Jam Page](https://jam4.sapjam.com/groups/Niq7TSBxLlzgb3nroBZJVx/overview_page/e9uqTDxXBRFbk7FJXEA4Cd)
