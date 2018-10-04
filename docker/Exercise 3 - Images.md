# Exercise 3 - Images

In this exercise, you will run a specific version of an image, modify its contents and commit the changes into a new image.

## Step 0: Pulling a specific image

Search on [Docker Hub](https://hub.docker.com) for the _nginx_ image in version 1.15.3 and pull it to your computer.

**Bonus question:** There are three ways to get the image, which are those?

Use the image to start a new container in detached mode - do not forget to have a port assigned to the container. Use your web browser to connect to the webserver in your container - you should see a banner page.

## Step 1: Enhancing the container

Execute an interactive shell in your _nginx_ container using the `docker exec` command. We are going to install the download manager wget into the container and use it to change the default website that _nginx_ is delivering.

### Setting up the package manager

As the _nginx_ image is built upon Debian, you can use the apt package manager to download and install wget into your container.

- **Only if a proxy server is required:**
```bash
export http_proxy=http://proxy.wdf.sap.corp:8080
export https_proxy=http://proxy.wdf.sap.corp:8080
export no_proxy=.wdf.sap.corp
```

- wget is installed with this command:
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

## Step 3: Tagging the new image

Use the `docker tag` command to assign the name *evil_nginx* to your new image. You might want to give it a release number, too.

## Step 4: Lauching your custom images

In case you haven't done it yet, stop your existing container using `docker stop`. Launch a new container from your custom image, make sure its port is forwarded to the host and connect with your web browser to it.

## Step 5: Examining an images history

Use the `docker history` command to examine the history of your custom image. Can you see what the drawback of using `docker commit` is?

## Step 6: Pushing the image to a registry

The K8s cluster prepared for the training is also serving a docker registry at  **registry.ingress.*\<cluster-name\>*.*\<project-name\>*.shoot.canary.k8s-hana.ondemand.com** to which you can push your image. The values for *\<cluster-name\>* and *\<project-name\>* will be given to you by your trainer and **must be substituted** respectively.

Use the `docker tag` command to tag your image correctly so that the registry is used. The name of your image should be **evil_nginx with the ID of your K8s namespace** as release tag. For instance, if you are working on *part-760d7ca6*, tag your image like **"\<registry name\>/evil_nginx:760d7ca6"**.

Use `docker push` to upload your image to the registry.

If the push succeeded, open the registry in a browser: **registry.ingress.*\<cluster-name\>*.*\<project-name\>*.shoot.canary.k8s-hana.ondemand.com/v2/_catalog**

Ideally you would see an "evil_nginx" repository there. To browse the list of tags use **/v2/< repo-name >/tags/list**, where the repo name should be *evil_nginx*.
