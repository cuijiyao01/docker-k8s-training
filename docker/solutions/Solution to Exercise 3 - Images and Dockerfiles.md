# Solution to Exercise 3 - Images

In this exercise, you will build an image with a Dockerfile, tag it and upload it to a registry. You will use the Dockerfile to extend the NGINX image to enable SSL and deliver a custom website that is embedded into the image.

## Step 0: Prepare the environment

Run the following commands, to prepare your local environment inside the VM. Replace _<training_id>_ and _<your_namespace_id>_ with the values that have been given to you by your trainer.

```
~/setup/get_kube_config.sh <training_id> <your_namespace_id>
sudo systemctl restart docker.service
```

## Step 1: Set up a build context

Create an empty directory on your VM and change into it.

```bash
mkdir dbuild
cd dbuild
```

Download the files into your build context:

```bash
wget -O evil.jpg https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/evil.jpg
wget -O index.html https://github.wdf.sap.corp/raw/slvi/docker-k8s-training/master/docker/res/evil.html
```

## Step 4: Create an SSL configuration for _nginx_

Create a new file `ssl.conf` inside your build context and paste the SSL configuration into it.

```bash
cat << __EOF > ssl.conf
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

## Step 5: Add the certificates to image

Create a self-signed SSL certificate.

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout nginx.key -out nginx.crt -days 365 -subj "/CN=$(hostname)"
```

## Step 2, 3, 4, 5 & 6 - Create the Dockerfile

Create a Dockerfile with the following contents:

```Dockerfile
FROM nginx:mainline

# copy the custom website into the image
COPY index.html /usr/share/nginx/html
COPY evil.jpg /usr/share/nginx/html

# copy the SSL configuration file into the image
COPY ssl.conf /etc/nginx/conf.d/ssl.conf

# download the SSL key and certificate into the image
COPY nginx.key /etc/nginx/ssl/
COPY nginx.crt /etc/nginx/ssl/

# expose the HTTPS port
EXPOSE 443
```

## Step 7: Build the image

Be sure you are still in the `dbuild` directory. Use the `docker build` command to build image.

```bash
docker build .
```

Write down (or memorize) the ID that Docker returns, you will need it for the next step.

## Step 8: Tag the image

For this step, you will need the image ID from step 7. Assuming that ID is `28ffc0efbc9b` and your participants-ID is `part-0001`, tag your image like this:

```bash
docker tag 28ffc0efbc9b secure-nginx:0001
```

## Step 9: Push the image to a registry

Tag your image (again) so that it will have a reference to a registry. The URL for the registry is  **registry.ingress.*\<cluster-name\>*.*\<project-name\>*.shoot.canary.k8s-hana.ondemand.com**, the values for `<cluster-name>` and `<project-name>` **must be substituted** with those given to you by your trainer.

Assuming that `<cluster-name>` is `wdfcw01`, that `<project-name>` is `k8s-train`, that your participant-ID is `part-0001` and that the image ID returned to you in Step 7 is `28ffc0efbc9b`, tag your image like this:

```bash
docker tag 28ffc0efbc9b registry.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com/secure-nginx:part-0001
```

In order to push to the registry, you need to log on to it first. Run the command and enter the password `2r4!rX6u5-qH`:

```bash
docker login -u participant registry.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com
```

Finally, push the image to the registry:

```bash
docker push registry.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com/secure-nginx:part-0001
```

**Hint:** Here is a command to find our your cluster and projectname:
```bash
echo "Clustername: $(kubectl config view -o json | jq  ".clusters[0].cluster.server" | cut -d. -f2)"; echo "Projectname: $(kubectl config view -o json | jq  ".clusters[0].cluster.server" | cut -d. -f3)"
```
