# Exercise 5 - Dockerfiles Part 1: Extending existing images

In this exercise, you will use a Dockerfile to extend an existing nginx image so that it is SSL enabled.

## Step 0: Setting up a build context

Create an empty directory on your VM, change into it and create an empty `Dockerfile`.

We want to copy a custom (yet very simple) website to the image, so we will download the files into our build context:

```bash
wget -O train.jpg http://plx172.wdf.sap.corp:1080/K8S_Training/train.jpg
wget -O index.html http://plx172.wdf.sap.corp:1080/K8S_Training/train.html
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

**Shortcut:** You can also download this configuration file from http://plx172.wdf.sap.corp:1080/K8S_Training/ssl.conf.

Again, with the help of the `COPY` directive, make sure that this file ends up in your image at `/etc/nginx/conf.d/ssl.conf`.

## Step 4: add the certificates to image

For SSL/TLS to work, we will need an encryption key and a certificate. These have already been prepared and should be downloaded directly into the image using the `ADD` directive.

The encryption key can be downloaded from http://plx172.wdf.sap.corp:1080/K8S_Training/key/nginx.key and should end up at `/etc/nginx/ssl/nginx.key`. The certificate can be obtained from http://plx172.wdf.sap.corp:1080/K8S_Training/key/nginx.crt and should end up at `/etc/nginx/ssl/nginx.crt` inside the image.

**Disclaimer/WARNING:** Placing the encryption key for an SSL/TLS certificate on a publicly accessible webserver is a *very bad* idea. This has only been done for the sake of simplicity during this training and of course, this key-certificate combination is to be considered compromised and insecure. Do not try this at home!

## Step 5: expose the secure HTTP port

The default _nginx_ image only exposes port 80 for unencrypted HTTP. Since we want to enable encrypted HTTPS, it is a good idea to expose port 443 as well. Use the `EXPOSE` directive accordingly.

## Step 6: build the image

Use the `docker build` command to build the image. Make note of the UID of the new image. Use `docker history` to examine how the image was built and how the output differs from when you use a simple `docker commit`.

## Step 7: tag the image

With `docker tag`, give your image a nice name such as *secure_nginx* and a release number (again, use your hostname as release number). 

If you want to push this image to our registry on **pvxka22.wdf.sap.corp**, tag your image accordingly and use `docker push` to push the image to the registry.

## Step 8: run a container

Create and run a new container from your image. Do not forget to run the container in detached mode. Let Docker automatically assign port forwardings, find out to where the ports have been mapped and use your web browser to connect to them. Use them both, the non-SSL (that gets mapped to port 80) and the SSL port (the one that gets mapped to 443).
