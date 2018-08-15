Create all required entities for ads DB: configmap-init, configmap, secret and service

kubectl apply -f ads-db-configmap-init.yaml 
kubectl apply -f ads-db-configmap.yaml 
kubectl apply -f ads-db-secret.yaml 
kubectl apply -f ads-db-service.yaml 

test
