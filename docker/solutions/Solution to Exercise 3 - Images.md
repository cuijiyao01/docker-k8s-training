# Solution to Exercise 3 - Images

In this exercise, you will run a specific version of an image, modify its contents and commit the changes into a new image.

## Step 0: Pulling a specific image

Search on [Docker Hub](https://hub.docker.com) for the _nginx_ image in version 1.15.3 and pull it to your computer.
Run the following command to pull the image to your Docker installation.

```bash
docker pull nginx:1.15.3
```

**Bonus question:** There are three ways to get the image, which are those?

The image is available with the tags nginx:1.153, nginx:mainline and nginx:1.15, so the following three commands will yield equal results:

```bash
docker pull nginx:1.15.3
docker pull nginx:mainline
docker pull nginx:1.15
```

Use the image to start a new container in detached mode - do not forget to have a port assigned to the container. Use your web browser to connect to the webserver in your container - you should see a banner page.

```bash
docker run -d -p 1080:80 --name perly-monkey nginx:1.15.3
```

## Step 1: Enhancing the container

Execute an interactive shell in your _nginx_ container using the `docker exec` command. We are going to install the download manager wget into the container and use it to change the default website that _nginx_ is delivering.

```bash
docker exec -it perly-monkey /bin/bash
```

### Setting up the package manager

As the _nginx_ image is built upon Debian, you can use the apt package manager to download and install wget. Use these commands to get you started:

- **Only if proxy server is required:**
```bash
export http_proxy=http://proxy.wdf.sap.corp:8080
export https_proxy=http://proxy.wdf.sap.corp:8080
export no_proxy=.wdf.sap.corp
```
- Install wget:
```bash
apt-get update && apt-get -y install wget
```

### Using wget to download a custom website to your container

Use the wget download manager to download a custom website into nginx' website directory.

```bash
wget --no-check-certificate -O /usr/share/nginx/html/evil.jpg https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/evil.jpg
wget --no-check-certificate -O /usr/share/nginx/html/index.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/evil.html
```

Reload the webpage in your browser and see how the output changed. Exit from the shell but do not stop the container.

## Step 2: Committing the change to a new image

Use the `docker commit` command to commit the changes you made to the container into an image. Make note of the new images' ID.

```bash
docker commit perly-monkey evil_nginx:1.0
```

## Step 3: Tagging the new image

Use the `docker tag` command to assign the name *evil_nginx:stable* to your new image.

```bash
docker tag evil_nginx:1.0 evil_nginx:latest
```

## Step 4: Lauching your custom images

In case you haven't done it yet, stop your existing container using `docker stop`.

```bash
docker stop perly-monkey
```

Launch a new container from your custom image, make sure its port is forwarded to the host and connect with your web browser to it.

```bash
docker run -d -p 1081:80 --name evil_doctor evil_nginx:latest
```

## Step 5: Examining an images history

Use the `docker history` command to examine the history of your custom image.

```bash
docker history evil_nginx:latest
```

You will see that you will get the information that some change was comitted to the image a few minutes ago but no detailed information on what that change actually was.

## Step 6: Pushing the image to a registry

Tag the image so that it refers to a remote registry. Give it a name so that it is uniquely identifieable. For this, replace the 760d7ca6 in the following commands with your training ID. Again, substiture *\<cluster-name\>* and *\<project-name\>* with the values given to you by your trainer.

```bash
docker tag evil_nginx:latest registry.ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com/evil_nginx:760d7ca6
```

Use `docker push` to upload your image to the registry.

```bash
docker push registry.ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com/evil_nginx:760d7ca6
```
