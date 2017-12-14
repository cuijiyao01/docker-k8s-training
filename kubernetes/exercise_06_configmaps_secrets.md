# Exercise 6 - ConfigMaps & Secrets
ConfigMaps and secrets bridge the gap between the requirements to build generic images but run them with a specific configuration in an secured environment.
In this exercise you will move credentials and configuration into the Kubernetes cluster and make them available to your pods.

## Step 0: Create a certificate
In the first exercises you ran a webserver with plain http. Now you are going to rebuild this setup and add https to your nginx.
In order for the setup to work, we will use `app: nginx-https` as label/selector for the "secured" nginx.

Start by creating a new certificate:

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"`

## Step 1: Store the certificate in Kubernetes
In order to use the certificate with our nginx, you need to add it to kubernetes and store it in a `secret` resource in your namespace.

`kubectl  create secret tls nginx-sec --cert=/tmp/nginx.crt --key=/tmp/nginx.key`

Check, if the secret is present by running `kubectl get secret nginx-sec`.

## Step 2: Create a ngnix configuration
Once the certificate is prepared, the next step is to create a configuration and store it to kubernetes as well.

Download from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/default.conf) or create a file `default.conf` with the following content:

```
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        listen 443 ssl;

        root /usr/share/nginx/html;
        index index.html;

        server_name localhost;
        ssl_certificate /etc/nginx/ssl/tls.crt;
        ssl_certificate_key /etc/nginx/ssl/tls.key;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

Make sure, the files referenced in the ssl section are named correctly in the secret.
Run `kubectl describe secret nginx-sec`. The result should look like this:

```
Name:         nginx-sec
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1143 bytes
tls.key:  1708 bytes
```

As you can see in the data section, the files are named tls.crt & tls.key. It matches to the file names given in the configuration file.

## Step 3: Upload the configuration to kubernetes
Run `kubectl create configmap nginxconf --from-file=<path/to/your/>default.conf` to create a configMap resource with the corresponding content from default.conf.

Verify the configmap exists with `kubectl get configmap`

## Step 4: Combine everything into a deployment
Now you will create a new deployment that makes use of the configMap and the secret.

Download the yaml file from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/deployment_https.yaml) and store it locally.

Verify that the newly created pod uses the configMap and secret by running `kubectl describe pod <pod-name>`.

## Step 5: create a service
Finally, you have to create a new service to expose your https-deployment. Either run a `kubectl expose` and figure out the ports needed or download the service.yaml from [gitHub](https://github.wdf.sap.corp/raw/D051945/docker-k8s-training/master/kubernetes/service_https.yaml).

Once the service has an external IP try to call it with an https prefix. Check the certificate it returns - it should match the subject specified in step 0.
