# Exercise 6 - ConfigMaps and Secrets
ConfigMaps and secrets bridge the gap between the requirements to build generic images but run them with a specific configuration in an secured environment.
In this exercise you will move credentials and configuration into the Kubernetes cluster and make them available to your pods.

## Step 0: clean-up
Before you start with this exercise, remove the deployment(s) and service(s) from the previous excercises. **However do NOT delete the persistentVolumeClaim!** We will use it in this excercise as well. Check the cheat sheet for respective delete commands.

## Step 1: Create a certificate
In the first exercises you ran a webserver with plain http. Now you are going to rebuild this setup and add https to your nginx.

Start by creating a new certificate:

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"`

## Step 2: Store the certificate in Kubernetes
In order to use the certificate with our nginx, you need to add it to kubernetes and store it in a `secret` resource of type `tls` in your namespace.

`kubectl  create secret tls nginx-sec --cert=/tmp/nginx.crt --key=/tmp/nginx.key`

Check, if the secret is present by running `kubectl get secret nginx-sec`.

Run `kubectl describe secret nginx-sec` to get more detailed information. The result should look like this:

```
Name:         nginx-sec
...

Type:  kubernetes.io/tls

Data
====
tls.crt:  1143 bytes
tls.key:  1708 bytes
```

**Important: remember the file names in the data section of the output. They are relevant for the next step.**

## Step 3: Create a ngnix configuration
Once the certificate secret is prepared, create a configuration and store it to kubernetes as well.

Download from [gitHub](./solutions/06_default.conf) or create a file `default.conf` with the following content. In any case, ensure the file's name is `default.conf`.

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

        location /healthz {
          access_log off;
          return 200 'OK';
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }

}
```

Make sure, the values for `ssl_certificate` and `ssl_certificate_key` match the names of the files within the secret. In this example output the files are named `tls.crt` and `tls.key` in the secret as well as the configuration. The location in the filesystem will be set via the `volumeMount`, when you create your deployment.
Also note, that there is a location explicitly defined for a healthcheck. If called, `/healthz` will return a status code `200` to satisfy a liveness probe.

## Step 4: Upload the configuration to kubernetes
Run `kubectl create configmap nginxconf --from-file=<path/to/your/>default.conf` to create a configMap resource with the corresponding content from default.conf.

Verify the configmap exists with `kubectl get configmap`

## Step 5: Combine everything into a deployment
Now it is time to combine the persistentVolumeClaim, secret and configMap in a new deployment. In order for new the setup to work, use `app: nginx-https` as label/selector for the "secured" nginx.

Complete the snippet below by inserting the missing parts (look for `???` blocks):

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-https-deplyoment
  labels:
    tier: application
spec:
  replicas: 3
  selector:
    matchLabels:
      ???: ???
  template:
    metadata:
      labels:
        app: nginx-https
    spec:
      volumes:
      - name: content-storage
        persistentVolumeClaim:
          claimName: nginx-pvc
          readOnly: true
      - name: tls-secret
        secret:
          secretName: nginx-sec
      - name: nginxconf
        configMap:
          name: nginxconf
      containers:
      - name: nginx
        image: nginx:mainline
        ports:
        - containerPort: 80
          name: http
        - containerPort: 443
          name: https
        livenessProbe:
          httpGet:
            path: ???
            port: http
          initialDelaySeconds: 3
          periodSeconds: 5
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: content-storage
          readOnly: true
        - mountPath: /etc/nginx/ssl
          name: ???
          readOnly: true
        - mountPath: /etc/nginx/conf.d
          name: ???
```

Verify that the newly created pods use the pvc, configMap and secret by running `kubectl describe pod <pod-name>`.

## Step 6: create a service
Finally, you have to create a new service to expose your https-deployment.

Derive the ports you have to expose and extend the service.yaml from the previous exercise.

Once the service has an external IP try to call it with an https prefix. Check the certificate it returns - it should match the subject and organization specified in step 1. Since we signed the certificate ourself, your Browser will complain about the certificate (depending on your browser) and you have to accept the risk browsing the url. 

**Important: do not delete this setup with deployment, PVC, configMap, secret and service.**
