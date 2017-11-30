# Things to prepare for a training
* Kubernetes cluster
  * namespace per participant - name matches with vm name
  * kubeconfig per participant linking to namespace
  * check cluster roles, participants should be able to query nodes and see other participant's namespaces
  * enable master authorized networks to restrict access to API server.
