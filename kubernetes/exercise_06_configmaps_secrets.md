# Exercise 6 - ConfigMaps and Secrets

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, _Persistent&nbsp;Volume&nbsp;Claims_, **_Config&nbsp;Maps_** and **_Secrets_**.

ConfigMaps and secrets bridge the gap between the requirements to build generic images but run them with a specific configuration in an secured environment.
In this exercise you will move credentials and configuration into the Kubernetes cluster and make them available to your pods.

**Note**: This exercise builds upon the previous exercises. If you did not manage to finish the previous exercises successfully, you can use the script [prereq-exercise-06.sh](solutions/prereq-exercise-06.sh) in the *solutions* folder to create the prerequisites. Please use this script only if you did not manage to complete the previous exercises.

## Step 0: clean-up
Before you start with this exercise, remove the deployment(s) and service(s) from the previous exercises. **However do NOT delete the persistentVolumeClaim!** We will use it in this exercise as well. Check the cheat sheet for respective delete commands.

## Step 1: Create a certificate
In the first exercises you ran a webserver with plain http. Now you are going to rebuild this setup and add https to your nginx.

Start by creating a new certificate:

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"`

## Step 2: Store the certificate in Kubernetes
In order to use the certificate with our nginx, you need to add it to kubernetes and store it in a `secret` resource of type `tls` in your namespace. Note that Kubernetes changes the names of the files to a standardized string. For example, `nginx.crt` should become `tls.crt`.

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

## Step 3: Create a nginx configuration
Once the certificate secret is prepared, create a configuration and store it to kubernetes as well. It will enable nginx to serve https traffic on port 443 using a certificate located at `/etc/nginx/ssl/`.

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

Verify the configmap exists with `kubectl get configmap`.

## Step 5: Combine everything into a deployment
Now it is time to combine the persistentVolumeClaim, secret and configMap in a new deployment. As a result nginx should display the custom index.html page, serve http traffic on port 80 and https on port 443. In order for new the setup to work, use `app: nginx-https` as label/selector for the "secured" nginx.

Complete the snippet below by inserting the missing parts (look for `???` blocks):

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-https-deployment
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

Derive the ports you have to expose and extend the service.yaml from the previous exercise. Make sure, that the labels used in the deployment and the selector specified by the service match.

Once the service has an external IP try to call it with an https prefix. Check the certificate it returns - it should match the subject and organization specified in step 1. Since we signed the certificate ourself, your Browser will complain about the certificate (depending on your browser) and you have to accept the risk browsing the url. 

**Important: do not delete this setup with deployment, PVC, configMap, secret and service.**


## Troubleshooting
The deployment has grown throughout this exercise. There should be 3 volumes specified as part of `deployment.spec.template.spec.volumes` (a pvc, configMap & secret). Each item of the volumes list defines a (local/pod-internal) name and references the actual K8s object. Also these 3 volumes should be used and mounted to a specific location within the container (defined in `deployment.spec.template.spec.containers.volumeMount`). The local/pod-internal name is used for the `name` field.

When creating the service double check the used selector. It should match the labels given to any pod created by the new deployment. The value can be found at `deployment.spec.template.metadata.labels`. In case your service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to. 

Also check, if the IP addresses point to the pods created during this exercise. In case of doubt check the correctness of the label - selector combination by running the query manually. Firstly, get the selector from the service by running `kubectl get service <service-name> -o yaml`. Use the `<key>: <value>` pairs stored in `service.spec.selector` to get all pods with the corresponding label set: `kubectl get pods -l <key>=<value>`. These pods are what the service is selecting / looking for. Quite often the selector used within service matches the selector specified within the deployment.

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level and display the custom page, request index.html directly: `http:<LoadBalancer IP>/index.html`.

## Further information & references
- [secrets in k8s](https://kubernetes.io/docs/concepts/configuration/secret/)
- [options to use a configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)