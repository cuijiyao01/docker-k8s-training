#!/bin/bash

# Step 0: pull the image
docker pull nginx:stable-perl

# Step 1: run the container
docker run -d --name tmp_nginx nginx:stable-perl

# Step 2: use docker exec to run several commands inside the container
docker exec -e http_proxy=http://proxy.wdf.sap.corp:8080 -e https_proxy=http://proxy.wdf.sap.corp:8080 -e no_proxy=.wdf.sap.corp tmp_nginx /bin/bash -c 'apt-get update && apt-get -y install wget && wget -O /usr/share/nginx/html/evil.jpg http://plx172.wdf.sap.corp:1080/K8S_Training/evil.jpg && wget -O /usr/share/nginx/html/index.html http://plx172.wdf.sap.corp:1080/K8S_Training/evil.html'

# Step 3: commit the modified container to an image and (Step 5) tag it
docker commit tmp_nginx evil_nginx:latest

# get rid of the container
docker rm --force tmp_nginx

# finally start the container with nginx on port 1084
docker run -p 1084:80 -d --name evil-nginx evil_nginx:latest
