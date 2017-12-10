# Exercise 4 - Images

In this exercise, you will run install a specific version of an image, modify its contents and create a new image out of it.

## Step 0: Pulling a specific image

Search on [Docker Hub](https://hub.docker.com) for the nginx image in version 1.12.2 that has Perl in it and pull it to your computer.

**Bonus question:** There are three ways to get the image, which are those?

Use the image to start a new container in detached mode - do not forget to have a port assigned to the container. Use your webbrowser to connect to the webserver in your container - you should see a banner page.

## Step 1: Enhancing the container

Execute an interactive shell in your nginx container using the `docker exec` command. We are going to install the download manager wget into the container and use it to change the default website that nginx is delivering.

### Setting up the package manager

As the nginx image is built upon Debian, you can use the apt package manager to download and install wget. Use these commands to get you started:

```bash
export http_proxy=http://proxy.wdf.sap.corp:8080
export https_proxy=http://proxy.wdf.sap.corp:8080
export no_proxy=.wdf.sap.corp
apt-get update && apt-get -y install wget
```

### Using wget to download a custom website to your container

Use the wget download manager to download a custom website into nginx' website directory.

```bash
wget -O /usr/share/nginx/html/evil.jpg http://plx172.wdf.sap.corp:1080/K8S_Training/evil.jpg
wget -O /usr/share/nginx/html/index.html http://plx172.wdf.sap.corp:1080/K8S_Training/evil.html
```

Reload the webpage in your browser and see how the output changed.

## Step 2: Committing the change to a new image

Use the `docker commit` command to commit the changes you made to the container into an image. Make note of the new images' ID.

## Step 3: Tagging the new image

Use the `docker tag` command to assign the name _evil-nginx_ to your new image.

## Step 4: Lauching your custom images

In case you haven't done it yet, stop your existing container using `docker stop`. Launch a new container from your custom image, make sure its port is forwarded to the host and connect with your webbrowser to it.

## Step 5: Examining an images history

Use the `docker history` command to examine the history of your custom image. Can you see what the drawback of using `docker commit` is?
