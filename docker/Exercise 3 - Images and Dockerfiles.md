# Exercise 3 - Images and Dockerfiles

In this exercise, you will build an image with a Dockerfile, tag it and upload it to a registry. You will use the Dockerfile to extend the NGINX image to enable SSL and deliver a custom website that is embedded into the image.

## Step 0: Set up a build context

Create an empty directory on your VM, change into it and create an empty `Dockerfile`.

We want to copy a custom (yet very simple) website to the image. You can either write your own _index.html_ or you can download a ready-made website with an image into your build context:

[evil.jpg](res/evil.jpg)

[evil.html](res/evil.html)


## Step 1: extend an existing image

As we want to extend an existing _nginx_ image, we need to come `FROM` it. It is a good idea to also specify the release number of the image you want to extend, but **mainline** is a good idea too.

Have a look at [DockerHub](https://hub.docker.com/_/nginx) for possible image tags that you can come from.

## Step 2: copy a new default website into the image

Use the `COPY` directive to the place the custom website files you created or downloaded in Step 1 into the image at `/usr/share/nginx/html`.

## Step 3: (Optional) create an SSL configuration for _nginx_

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

## Step 4: (Optional) add the certificates to image

For SSL/TLS to work, we will need an encryption key and a certificate. We use OpenSSL to create a self-signed certificate. Use the following command to create an encryption key and a certificate.

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout nginx.key -out nginx.crt -days 365 -subj "/CN=$(hostname)"
```

With the COPY directive, make sure the files `nginx.key` and `nginx.crt` end up inside your image in the directory `/etc/nginx/ssl/` (the trailing `/` is important here).

## Step 5: expose the (secure) HTTP port

The default _nginx_ image only exposes port 80 for unencrypted HTTP. Since we want to enable encrypted HTTPS, we will have to expose port 443 with the `EXPOSE` directive as well.

## Step 6: build the image

Use the `docker build` command to build the image. Make note of the UID of the new image. Start the image with `docker run` and make sure you forward the containers ports 80 and 443 so that you can view the website with a browser.

## Step 7: tag the image

With `docker tag`, give your image a nice name such as *secure_nginx* and a release number (again, use your participant's ID as release number).

