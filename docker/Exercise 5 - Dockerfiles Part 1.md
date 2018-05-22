# Exercise 5 - Dockerfiles Part 1: Extending existing images

In this exercise, you will use a Dockerfile to extend an existing nginx image so that it is SSL enabled.

## Step 0: Setting up a build context

Create an empty directory on your VM, change into it and create an empty `Dockerfile`.

We want to copy a custom (yet very simple) website to the image, so we will download the files into our build context:

```bash
wget -O train.jpg https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/train.jpg
wget -O index.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/train.html
```

## Step 1: extend an existing image

As we want to extend an existing _nginx_ image, we need to come `FROM` it. It is a good idea to also specify the release number of the image you want to extend, **stable** is normally a good idea.

## Step 2: copy a new default website into the image

Use the `COPY` directive to the place the two files you downloaded in Step 0 to your build context into the image at `/usr/share/nginx/html`.

## Step 3: create an SSL configuration for _nginx_

In order to enable SSL for nginx, you will have to place an additional configuration file into the image.

Create a new file `ssl.conf` inside your build context and paste this into it:

```nginx
server {
    listen       443 ssl;
    server_name  localhost;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```

**Shortcut:** You can also download this configuration file from https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/ssl.conf.

Again, with the help of the `COPY` directive, make sure that this file ends up in your image at `/etc/nginx/conf.d/ssl.conf`.

## Step 4: add the certificates to image

For SSL/TLS to work, we will need an encryption key and a certificate. We use OpenSSL to create a self-signed certificate. Use the following command to create an encryption key and a certificate.

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout nginx.key -out nginx.crt -days 365 -subj "/CN=`hostname`"
```

With the COPY directive, make sure the files `nginx.key` and `nginx.crt` end up inside your image in the directory `/etc/nginx/ssl/`.

## Step 5: expose the secure HTTP port

The default _nginx_ image only exposes port 80 for unencrypted HTTP. Since we want to enable encrypted HTTPS, it is a good idea to expose port 443 as well. Use the `EXPOSE` directive accordingly.

## Step 6: build the image

Use the `docker build` command to build the image. Make note of the UID of the new image. Use `docker history` to examine how the image was built and how the output differs from when you use a simple `docker commit`.

## Step 7: tag the image

With `docker tag`, give your image a nice name such as *secure_nginx* and a release number (again, use your hostname as release number).

If you want to push this image to our registry on **registry.ingress.wdftr01.k8s-train.shoot.canary.k8s-hana.ondemand.com**, tag your image with the name *secure_nginx* and your unique training ID and use `docker push` to push the image to the registry.

## Step 8: run a container

Create and run a new container from your image. Do not forget to run the container in detached mode. Let Docker automatically assign port forwardings, find out to where the ports have been mapped and use your web browser to connect to them. Use them both, the non-SSL (that gets mapped to port 80) and the SSL port (the one that gets mapped to 443). Since we used a self-signed certificate, you will get an error-message from your browser, just ignore it.
