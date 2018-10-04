# Solution to Exercise 4 - Dockerfiles Part 1: Extending existing images

In this exercise, you will use a Dockerfile to extend an existing nginx image so that it is SSL enabled.

## Step 0: Setting up a build context

Create an empty directory on your VM and change into it.

```bash
mkdir dbuild
cd dbuild
```

Download the files into your build context:

```bash
wget -O train.jpg https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/train.jpg
wget -O index.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/train.html
```


## Step 3: create an SSL configuration for _nginx_

Create a new file `ssl.conf` inside your build context and paste this into it:

```bash
cat << '__EOF' > ssl.conf
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
__EOF
```

## Step 4: add the certificates to image

For SSL/TLS to work, we will need an encryption key and a certificate. We use OpenSSL to create a self-signed certificate. Use the following command to create an encryption key and a certificate.

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout nginx.key -out nginx.crt -days 365 -subj "/CN=$(hostname)"
```

## Step 1, 2 & 5: write the Dockerfile

Create a Dockerfile with this content:

```Dockerfile
FROM nginx:stable

# copy the custom website into the image
COPY train.jpg /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/

# copy the SSL configuration file into the image
COPY ssl.conf /etc/nginx/conf.d/ssl.conf

# download the SSL key and certificate into the image
COPY nginx.key /etc/nginx/ssl/nginx.key
COPY nginx.crt /etc/nginx/ssl/nginx.crt

# expose the https port
EXPOSE 443
```

## Step 6 & 7: build and tag the image

Be sure you are still in the `dbuild` directory. Use the `docker build` command to build and tag the image.

```bash
docker build -t secure_nginx:1.0 .
```

## Step 8: run a container

Run the container and forward the ports:

```bash
docker run -d -p 443:443 -p 1082:80 secure_nginx:1.0
```

Use your webbrowser and connect to http://localhost:1082 for unencrypted HTTP and to https://localhost:443 for TLS encrypted HTTPS.
