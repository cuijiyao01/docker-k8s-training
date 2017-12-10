# Exercise 6 - Dockerfiles Part 2: Building your own image from scratch

In this exercise, you will create your very own nginx image from scratch.

## Step 0: Setting up your build context

Create an empty directory that will be your build context. Download the archive that contains an empty Debian root filesystem to it.

```
wget -O rootfs.tar.bz2 http://plx172.wdf.sap.corp:1080/K8S_Training/debian_rootfs.tar.bz2

```

We also want to use a custom nginx configuration inside our image so download it to your build context as well.

```
wget -O nginx.conf
http://plx172.wdf.sap.corp:1080/K8S_Training/nginx.conf
```

## Step 1: Creating the Dockerfile

Create an new Dockerfile that starts `FROM scratch`. Since you want to get some credit for what you are doing, put a `LABEL maintainer="<your D/I-number>"` in there.

## Step 2: Setting up the Environment

At SAP we are behind a proxy which requires us to set the `http_proxy` and `https_proxy` environment before we can continue. Use the `ENV` directive to set both variables to http://proxy.wdf.sap.corp:8080.

We also need to make sure that the proxy is bypassed for computers within SAP so set the variable `no_proxy` to `.wdf.sap.corp` (the leading period(.) is important).


## Step 3: Adding the root filesystem

Next, `ADD` the archive containing the root filesystem to the root `/` of your image.

**Bonus question**: Could you use `COPY` instead of `ADD`?

## Step 4: Install nginx

Since we just added a Debian root filesystem to our image, we have the package manager ready. Use the `RUN` command to build the package cache first (`apt-get` will not run without this step).

**Hint:** For those of you who are not familiar with Debian, here is the command:

```bash
apt-get update
```

Use the `RUN` command to install nginx and wget. Make sure that apt-get runs does not ask questions interactively.

**Hint:** For those of you who do not know Debian so well, here is the command:

```bash
apt-get -y install nginx wget
```

**Bonus question:** You just used how many layers for these commands? Can you reduce them by combining commands?

## Step 5: Download a custom website into the images

Use the `RUN` directive to call `wget` to download an image and a custom HTML file into the image.

```
wget -O /usr/share/nginx/html/yo.jpg http://plx172.wdf.sap.corp:1080/K8S_Training/yo.jpg
wget -O /usr/share/nginx/html/index.html http://plx172.wdf.sap.corp:1080/K8S_Training/yo.html
```

## Step 6: Copy a custom nginx configuration into the image

In Step 0, you downloaded a custom nginx configuration file to your build context. Use the `COPY` directive to copy it to `/etc/nginx/nginx.conf` in your image.

**Bonus question:** Could you use `ADD` instead of `COPY`?

## Step 7: Make sure that Docker can collect nginx' logs

The nginx program by default dumps its logs to `/var/log/nginx/access.log` for informative messages and to `/var/log/nginx/error.log` for error message.

Use the `RUN` directive to create symlinks to `/dev/stdout` and `/dev/stderr` respectively so that Docker can collect and display the logs.

## Step 8: Exposing the port

Since nginx is a webserver, it needs to expose a port which in this case is port 80. Use the `EXPOSE` directive to expose port 80.

## Step 9: Specify the command to run

When a new container is created from your image, nginx must run as its main process.
Use the `CMD` directive to start nginx.

The options to the `CMD` directive are:

```Dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

## Step 10: Build the images

Use the `docker build` command to build your image. Tag it along the way so you can find it easily.

## Step 11: Run your image

Run the image im detached mode, create a port forwarding from port 80 in the container to port 1081 on your host and connect with your webbrowser to it.

If you see an image of Xzibit, you can consider yourself lucky as you have managed to complete this exercise.
