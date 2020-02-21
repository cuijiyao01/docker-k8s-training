# Exercise 01 - Make Images Available

## Scope
- In this first exercise you will build and push a docker images for the bulletinboard-ads and bulletinboard-reviews micro services.
- The cluster can't access these images if they are just on your local machine, therefore we need to push them to a registry which is available in the public internet.
- You can uses the registry provided for this training ([Hint](/docker/Exercise%203%20-%20Images%20and%20Dockerfiles.md#step-8-push-the-image-to-a-registry)).
- An ImagePullSecret is needed to pull images from secured registries.

## Step 1: clone ads repository

Let us start with the [bulletinboard-ads](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-ads-java) microservice. Go a head and clone the repository to your VM.

```SHELL
git clone https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-ads-java
```

## Step 2: build and push the ads image

The microservice is written in Java and uses maven as a build tool. You can find a simple Dockerfile already in the repository. Since it is not utilizing a Docker-Multi-Stage-Build, maven has to be executed before the docker-build.

Push your image to the registry and remember to give it a unique name, e.g. `bulletinboard-ads-<participant-id>`.

```SHELL
mvn package
docker build -t <registry-url>/bulletinboard-ads-<participant-id> .
docker push <registry-url>/bulletinboard-ads-<participant-id>
```

## Step 3: clone reviews repository

Now proceed with the [bulletinboard-reviews](https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-reviews-nodejs) microservice. Clone the repository to your VM.

```SHELL
git clone https://github.wdf.sap.corp/cloud-native-bootcamp/bulletinboard-reviews-nodejs
```

## Step 4: build and push the reviews image

The microservice is written in NodeJS and uses npm as a dependency management tool. Again there is a simple Dockerfile already in place. This time around npm is executed as part of the docker-build hence nothing has to be done beforehand.

Push your image to the registry and remember to give it a unique name, e.g. `bulletinboard-ads-<participant-id>`.

```SHELL
docker build -t <registry-url>/bulletinboard-reviews-<participant-id> .
docker push <registry-url>/bulletinboard-reviews-<participant-id>
```

## Step 5: create imagePullSecret

The registry is secured with basic authentication. You need to provide the credentials as a ImagePullSecret in order to uses the images from there inside the cluster.
Let's be prepared for that an create the secret already.

```bash
kubectl create secret docker-registry training-registry --docker-server=<registry-url> --docker-username=<registry-username> --docker-password=<registry-password>
```

