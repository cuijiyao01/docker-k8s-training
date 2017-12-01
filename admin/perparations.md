# Things to prepare for a training

## Kubernetes cluster
To prepare the cluster you need a jumpbox with gcloud sdk & a working kubectl connection to the cluster.
  * namespace per participant - name matches with vm name (pvxka[00-22])
  * kubeconfig per participant linking to namespace
  * check cluster roles, participants should be able to query nodes and see other participant's namespaces => grant cluster-admin to all for training purpose
  * enable master authorized networks to restrict access to API server.

### create a namespace:
`kubectl create ns pvxka<number>`

### generate kubeconfig
Basic structure:
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: << cert >>
    server: https://<< api server ip>>
  name: k8s-training
contexts:
- context:
    cluster: k8s-training
    user: default
    namespace: pvxka[01-22]
  name: k8s-training
current-context: k8s-training
users:
- name: default
  user:
    token:
```

Create a local file called `master-config` and give it the content mentioned above. Run the following command to:
* create a kubeconfig per namespace (01-22)
* insert the namespace into the configuration
* extract the token for the respective default service account and insert it into the configuration

```
for i in `seq -w 01 1 22`; do  
  cp master-config config-pvxka$i;
  sed -i '/namespace:/ s/$/ pvxka'$i'/' config-pvxka$i;
  sed -i '/token:/ s/$/ '`kubectl get secret -n pvxka$i -o json | jq '.items[0].data.token' | sed 's/"//g' |base64 --decode`'/' config-pvxka$i;
done
```
