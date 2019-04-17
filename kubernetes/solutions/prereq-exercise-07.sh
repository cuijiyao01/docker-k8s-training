#!/bin/bash

function create_pvc {
  cat << '__EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  storageClassName: default
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-storage-pod
spec:
  volumes:
    - name: content-storage
      persistentVolumeClaim:
       claimName: nginx-pvc
  containers:
  - name: helper
    image: alpine:3.8
    command: ["/bin/sh", "-c", "echo '<html><head><title>My first webpage...</title></head><body><h1>This is my custom webpage, this is so great.</h1></body></html>' > /usr/share/nginx/html/index.html"]
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: content-storage
  restartPolicy: Never
__EOF

  echo "Waiting for the storage pod to complete..."
  i=0
  while [ -z "$completed" ]; do
  	status=$(kubectl get pod nginx-storage-pod -o jsonpath={.status.containerStatuses[0].state.terminated.reason})
	  if [ "$status" == "Completed" ]; then
	  	completed="true"
	  fi
  	i=$((i+1))
	  if [ $i -gt 60 ]; then
	  	echo "This took longer than two minutes. Something seems to be wrong, stopping here..."
	  	exit 1
	  fi
	  sleep 2
  done
  
  kubectl delete pod nginx-storage-pod
  echo "Waiting 15 seconds to make sure volumes got unmounted from nodes..."
  sleep 15
}

pvc_status=$(kubectl get pvc nginx-pvc -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$pvc_status" != "Bound" ]; then
	create_pvc
fi

cat << '__EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: nginx-sec
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJakNDQWdxZ0F3SUJBZ0lKQUlWYjA5Nm81M2srTUEwR0NTcUdTSWIzRFFFQkN3VUFNQ1l4RVRBUEJnTlYKQkFNTUNHNW5hVzU0YzNaak1SRXdEd1lEVlFRS0RBaHVaMmx1ZUhOMll6QWVGdzB4T1RBME1UQXhORE16TUROYQpGdzB5TURBME1Ea3hORE16TUROYU1DWXhFVEFQQmdOVkJBTU1DRzVuYVc1NGMzWmpNUkV3RHdZRFZRUUtEQWh1CloybHVlSE4yWXpDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBSzdObzNEVklWbHgKRDFZcVBIZjhjV1licmtXMUtEZC9xTVR2c1VaMWtDWXFkMjFXbEcyeU84NGk3WkdnK21xcTErSUhtY2gyeDN3MQpGRHBiN1pMYU1ucGpoc1NCZDlVa05kcnloMlJ3alJDRWpCZU1PTTJrdi92YTV4VGJUcjRxYkY4UUM0dUp1MjdPCjlOU2JZWTlLZzhnUGpHUTdJTzdxaDhjN2N2eGhlOFpyc1JvOFVaVHpxWDRrdkQ1MmprTjdtN3dXMWVrZ2ZqMjcKeWJoRmlVWFJZQmp5dklaQndGd1huOGx4TG1Jd3loQXFGTUdtQ3BVTDE4cUx2UmdyS0h6QW1kYUxPTnVENGlYdwpmMVM0eEQ5OGw3bTlVVDcvZEZtUWRoanZ5R2pTdG1XZzRHR3dTeGUrZVpIVnpmTTZRYzNYeVlsZEx5MnJqWHpZCnVmNHVzSHlRWk1VQ0F3RUFBYU5UTUZFd0hRWURWUjBPQkJZRUZGaXBQQmMwMUxZUit6Z1l2K1ZKbkFMMDV4UEMKTUI4R0ExVWRJd1FZTUJhQUZGaXBQQmMwMUxZUit6Z1l2K1ZKbkFMMDV4UENNQThHQTFVZEV3RUIvd1FGTUFNQgpBZjh3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUNZQmdKWWlZMmxOOCtuR2g3ZjVUUi9aSDhHYXprU3NETEhCCm5mRzlDQ20xVlNWSkRTRm5lUWJzOE93V09KU0k3dTg2RW8xdmoxUStKa1JCelU2V052ZEE4ck9MSzkxRnF6SisKMUxqekZTSnU1cFdjWC93VWhhYUE4MHpIamgxOUo2azU4WW9yR3QyOGtjdFR5dUJyN3R5ODVqbWJkNmx1VzBtWgpyUVZyWHJWVjl5RklZOFdVcVNpTEx3UlFXMXdEZmNTQ09vSzM0RVJneTdDQVpxRndvT3RMeUw5N2xmR3hxTk5XCmRYUUpjU3BNaDFVaVRtbzZIclV6MHRwVFpDb3N5ZVYrcjM4NjUxUXFXLzRXaWQxaTJ6c1lrMkNBUUxrRjdtYWwKdmhWWjRxTm1UTmZTVlpJWENpMHhsZUdxcFdVRW1yWFRzSERLdVV4U1NNYUE3UXJWSU9JPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQ3V6YU53MVNGWmNROVcKS2p4My9IRm1HNjVGdFNnM2Y2akU3N0ZHZFpBbUtuZHRWcFJ0c2p2T0l1MlJvUHBxcXRmaUI1bklkc2Q4TlJRNgpXKzJTMmpKNlk0YkVnWGZWSkRYYThvZGtjSTBRaEl3WGpEak5wTC83MnVjVTIwNitLbXhmRUF1TGlidHV6dlRVCm0yR1BTb1BJRDR4a095RHU2b2ZITzNMOFlYdkdhN0VhUEZHVTg2bCtKTHcrZG81RGU1dThGdFhwSUg0OXU4bTQKUllsRjBXQVk4cnlHUWNCY0Y1L0pjUzVpTU1vUUtoVEJwZ3FWQzlmS2k3MFlLeWg4d0puV2l6amJnK0lsOEg5VQp1TVEvZkplNXZWRSsvM1Jaa0hZWTc4aG8wclpsb09CaHNFc1h2bm1SMWMzek9rSE4xOG1KWFM4dHE0MTgyTG4rCkxyQjhrR1RGQWdNQkFBRUNnZ0VBRERQZ3gveW80bFNKTEl1d1F2UUZlb3BPSlNHYldCeDZUSjBxOCs4N0M5OEYKRFVYeEFLTmpsMlZLemxLOWlIcTZyVlc0ZjQwREtnR09rdkJkNmxWL0Zwb2lDMCs2Yk0rbFRzNkZjeGFFVW5YZQpUYnFGTUozaXBSTkg5R1hHM25HWnRSMHFvU2dSUkkvLytXT0xjUFJUdE1DWkhWb2ZWMjVaNGllZFJFOE4wL0VOCkZlRWQ4Y245WG9CdnQwZ0RSekNieXZLM1BLK1Q3MXF0aDBSQkJBTWJKZ2dlZzBRMDhFTGJJbldMWjIvY2huYUYKV3RtWTVwUTJuT3pGa083ckR2blg2NTk0bTB2TzlWN2FSOHFsV2hzQ1V2OTFvRDlCd3JjajhOMU0zWjBvbnJzcApuVm8vVTVPbHF0b1F6KzdLU0hSWVFxVkxueStaZHA2SXNWOGcrRmhBSVFLQmdRRFlvMEw3Z1FSZ0hOYU9VMFNoCktoRVBOVThiS1I5ZEdDV3ZuR0hTZnA5NGo2Q1d4Zk5UK3pjUHlmMmhKV3dwbkZPRTJUYnQyNXpYWkxlRFRCYlQKRkFYdGtjQSsyOXhvOUVqTWdkMTM4UTI5M3hNVEZJTU1wRktFaDg2WXRRdG1hU05BZ09UMTFyWG13YjJkakpIVQppZlR1S2pWb0dzWDRuQStLaUovNVVZeUNuUUtCZ1FET2tIcU1sYVVpdmlYU25TYTBIOXVHa0dCUDJkM1huOEswCnFjNkw5T2VIa0V6cHZwWmZKWVRpU3JzRCtrYnplVFVWSG4yUUdLb3hTN3RhakZGd045UXgzY0ZsS3Y5QksvVkcKQWpNa014c3NIQWkzMU5MTkdqRlJGWUk2eVZJRDFnRkZNem5Bc3krUHRSVWhXVTUrTk14OWlKYUFDZEhLNjJydwpBcFBKMUxmZVNRS0JnQnhNajJadFB4WVREay8vUHByUzlQR0lwREhIR0dxL3ljUjc2Q2RvRlFyWnNEK2gwaHhwClY1TC9idHRMR1NzQ1djS2o0VklHK3lFRDdoai9xb2VlT1B3RXF4bEsvU3JVcG1IWW9RYVcvWldNKzEvbHNRekkKdG1MTG5zaEI5aUJGb2E0K2FDcFpCdUFDOVBNTXRzd056V29ESjREVzVuK0lXMXRjWjVGWS9zTGRBb0dBYmUyTAptbGRsQzJrLy9hYXVXenQ4KzA3SVFwYUNMZWNTbWt5bjQrbVFjWitFbnZ4VFVBMUtlNWNqa1lsV3l1bWRLMEVQCnQyaTQ0Z1VZanFhUURIVlprclFkNExZU0kxKytadVJ5elBmNXBPN0NZUHA4dUxRUXZNTUNqRUJwU2l0UWY4QTAKSXUzNUNMUm9xMWU0b3dkOEwrNUprWmdvTXFJNFJjUkpYQ2E5TnlrQ2dZRUFyYUJKcVFOWWtjeWdpV0hQS3BmaQpTc0lpM0pqK2NleVZ1RzIxYTJRT1NUSDk0N1M1QXZ4ZWZnL0dhV1p6LzllMlRTU1cwdEpNL2dsdDNrV2d6YWVICkYwRHo0RW9sNTJFNER6a3lYN0tiNWk3bWl0a28ybGhnRGIxTkpPbE42UG9pNmV0WThPQkZnSHlISmplaUV3Z3IKeG9EMzBlektrK1N2Z05zSG5scCtLR2s9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginxconf
data:
  default.conf: |
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
---
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
      app: nginx-https
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
            path: /healthz
            port: http
          initialDelaySeconds: 3
          periodSeconds: 5
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: content-storage
          readOnly: true
        - mountPath: /etc/nginx/ssl
          name: tls-secret
          readOnly: true
        - mountPath: /etc/nginx/conf.d
          name: nginxconf
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-https-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    name: http
  - port: 443
    protocol: TCP
    targetPort: 443
    name: https
  selector:
    app: nginx-https
  type: LoadBalancer
__EOF
