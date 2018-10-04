# Optional exercise - Ingress

__Please note this is an optional exercise. It has an increased level of difficulty.__

Ingress resources allow us to expose services through a URL. In addition, it is possible to configure an Ingress so that traffic can be directed to different services, depending on the URL that is used for a request. In this exercise, you will set up a simple Ingress resource first and enhance it to eventually serve two different services.

In addition to all that, you will use Init-Containers to initialize your nginx deployment and load the application's content.

## Step 0 - obtain necessary detail information
Since the ingress controller is specific to the cluster, you need a few information to get started with this exercise.

Check with your trainers to get:
- cluster name
- Gardener project name

You will need these info to construct a valid URL processible by the controller.

## Step 1 - init: prepare pods and services
For this exercise you can either re-use already existing deployments, pods and services or create them from scratch. Please continue to use an nginx webserver as backend application. For sake of resource consumption, please use `replica: 1` for new resources.

When you create a new deployment, you can try to add an [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/). The init container should write a string like the hostname or "hello world" to and `index.html` on an emptyDir volume. Use this volume in the nginx container as well to get a customized `index.html` page.

The snippet below might give an idea, how to pass the parameters to a busybox running as init container.

```
command:
- /bin/sh
- -c
- echo HelloWorld! > /work-dir/index.html
```

More details about init containers can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-initialization/) and [here](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

## Step 2 - write a simple ingress and deploy it
To expose your application via an ingress, you need to construct a valid URL. Within the Gardener environment you have to use the following schema: `<your-custom-endpoint>.ingress.<GARDENER-CLUSTER-NAME>.<GARDENER-PROJECT-NAME>.shoot.canary.k8s-hana.ondemand.com`

For `<your-custom-endpoint>` it is recommended to use your generated participant ID. You are going to expose the URL to public internet and most likely you don't want to publish information like your d/i -user there. Also insert the cluster and project names you obtained from your trainer accordingly.

Check the [help section](https://github.wdf.sap.corp/pages/kubernetes/gardener/doc/2017/01/16/howto-service-access.html) to get more information.

Write the ingress yaml file and reference to your service. Check the [kubernetes API reference](https://kubernetes.io/docs/reference/) for details and further info. You can also look into the [demo example](./demo/09a_tls_ingress.yaml) (but don't include TLS for now) or the Gardener page linked above.
Finally, deploy your ingress and test the URL.

## Step 3 - annotate!
Besides the labels, K8s uses also a concept called "[annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)". Annotations are part of the metadata section and can be written directly to the yaml file as well as added via `kubectl annotate ...`. Similar to the labels, annotations are also key-value pairs.
Most commonly annontations are used to store additional information, describe a resource more detailed or tweak it's behaviour.

In our case, the used ingress controller knows several annotations and reacts to them in a predefined way. The known annotations and their effect are described [here]( https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/).

So let's assume, you want to change the timeout behaviour of the nginx exposed via the ingress. Check the list of [annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for the `proxy-connect-timeout` and apply a suitable configuration to your ingress. Of course don't forget to test the URL.

## even more optional step 4 - rewrite target
Now that you know how an annotation works and how it affects your ingress, lets move on the fanout scenario. Assume you want your ingress to serve something different at its root level `/` and you want to move your application to `/my-app`. Your URL would look like this `<your-custom-endpoint>.ingress.<GARDENER-CLUSTER-NAME>.<GARDENER-PROJECT-NAME>.shoot.canary.k8s-hana.ondemand.com/my-app`.

In a first step, you need to add `path: /my-app` to your backend configuration within the ingress. Take a look at the [fanout demo](./demo/09b_fanout_and_virtual_host_ingress.yaml), if you need inspiration. Once you applied your the change, go to your URL and test the different paths. But don't be surprised, if you don't see the expected pages.

The ingress is forwarding traffic to `/my-app` also to `/my-app` at the backend. So unless you configured your nginx pods to serve at `/my-app` there is no valid endpoint available. You can solve the issue by rewriting the target to `/` of the backend pods. Check the `rewrite-target` [annotation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#rewrite) for details and apply it accordingly.
