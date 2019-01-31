# Solution to optional Exercise 4 - Dockerfiles Extended: Building your own image from scratch

In this exercise, you will create your very own _nginx_ image from scratch.

## Step 0: Set up your build context

Create an empty directory on your VM that will be your build context. Download the archive that contains the basic Debian root filesystem and a custom NGINX configuration to it.

```bash
mkdir dbuild
cd dbuild
wget -O rootfs.tar.xz https://github.com/debuerreotype/docker-debian-artifacts/raw/b024a792c752a5c6ccc422152ab0fd7197ae8860/jessie/rootfs.tar.xz
wget -O nginx.conf https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/nginx.conf
```

## Steps 1 to 8: Create the Dockerfile

Create the following Dockerfile in your build context.

```Dockerfile
FROM scratch

# give yourself some credit
LABEL maintainer="<inser C/D/I-number here>"

# add and unpack an archive that contains a Debian root filesystem
ADD rootfs.tar.xz /

# use the apt-get package manager to install nginx and wget
RUN apt-get update && \
        apt-get -y install nginx wget

# use wget to download a custom website into the image
RUN wget --no-check-certificate -O /usr/share/nginx/html/cheers.jpg https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/cheers.jpg && \
        wget --no-check-certificate -O /usr/share/nginx/html/index.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/cheers.html

# copy the custom nginx configuration into the image
COPY nginx.conf /etc/nginx/nginx.conf

# link nginx log files to Docker log collection facility
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
        ln -sf /dev/stderr /var/log/nginx/error.log

# expose port 80 - the standard port for webservers
EXPOSE 80

# and make sure that nginx runs when a container is created
CMD ["nginx", "-g", "daemon off;"]
```

## Step 9: Build the images

Build and tag the image. Again, use your participant-ID as release tag.

```bash
docker build -t custom_nginx:part-0001 .
```

## Step 10: Run your image

Run the image im detached mode, create a port forwarding from port 80 in the container to port 1081 on your host and connect with your webbrowser to it.

```bash
docker run -d -p 1081:80 custom_nginx:part-0001
```
