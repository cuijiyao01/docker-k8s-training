# Exercise 5 - Dockerfiles Part 1: Extending existing images

In this exercise, you will use a Dockerfile to extend an existing nginx image.

## Step 0: Setting up a build context

Create an empty directory on your VM, change into it and create an empty `Dockerfile`.

We want to copy two files to the image, so we need to place them into our build context:

```bash
wget -O train.jpg http://plx172.wdf.sap.corp:1080/K8S_Training/train.jpg
wget -O index.html http://plx172.wdf.sap.corp:1080/K8S_Training/train.html
```

## Step 1: extend an existing image

As we want to extend an existing _nginx_ image, we need to come `FROM` it. It is a good idea to also specify the release number of the image you want to extend, **stable** is normally a good idea.

## Step 2: copy a new default website into the image

Use the `COPY` directive to the place the two files you downloaded in Step 0 to your build context into the image at `/usr/share/nginx/html`.

## Step 3: move the default configuration file to a different place

Use the `RUN` directive to create the directory `/etc/nginx/var` inside the image.

Use another `RUN` directive to move the file `/etc/nginx/conf.d/default.conf` to the new directory `/etc/nginx/var`.

Finally, use a third `RUN` directive to create a symlink from `/etc/nginx/var/default.conf` to `/etc/nginx/conf.d/default.conf`.

**Hint:** In case you are not that familiar with Linux, here are the commands to create the directory, move the file and make a symlink.

```bash
mkdir -p /etc/nginx/var
mv /etc/nginx/conf.d/default.conf /etc/nginx/var
ln -sf /etc/nginx/var/default.conf /etc/nginx/conf.d
```

## Step 4: expose the secure HTTP port

The default _nginx_ image only exposes port 80 for unencrypted HTTP. In case you want to enable encrypted HTTPS, it is a good idea to expose port 443 as well. Use the `EXPOSE` directive accordingly.

## Step 5: build the image

Use the `docker build` command to build the image. Make note of the UID of the new image. Use `docker history` to examine how the image was built and how the output differs from when you use a simple `docker commit`.

## Step 6: tag the image

With `docker tag`, give your image a nice name such as _mynginx_ and a release number.

## Step 7: run a container

Create and run a new container from your image. Do not forget to run the container in detached mode. Let Docker automatically assign port forwardings, find out to where the ports have been mapped and use your web browser to connect to them.
