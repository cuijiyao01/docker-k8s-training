#!/bin/bash
#
# helm_init.sh       A small script for a trainer to download helm v2.13 and initialize tiller 
#                    with a separate service account in kube-system namespace. 
#                    The local kubectl must be configured so that the cluster can be accessed.

MYHOME=$(dirname $0)

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=`which kubectl`
if [ -z "$KUBECTL" -o ! -x "$KUBECTL" ]; then
	echo "Cannot find or execute kubectl. Download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
${KUBECTL} get nodes &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Unable to get the nodes of your cluster ('kubectl get nodes' returned with RC $RC)."
	echo "       Check that your kube.config is correct and points to the corrent cluster."
	exit 4
fi

# check if helm is available
[ -z "$HELM" ] && HELM=$(which helm 2> /dev/null)
if [ -z "$HELM" -o ! -x "$HELM" ]; then
	echo "HELM could not be found, downloading it..."
	curl --progress-bar -o $MYHOME/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz
    tar -zxvf $MYHOME/helm.tar.gz -C $MYHOME/
    sudo mv linux-amd64/helm /usr/local/bin/helm
    rm -rf $MYHOME/helm.tar.gz linux-amd64 
	HELM=/usr/local/bin/helm
fi

echo "setting up tiller with a dedicated service account in kube-system namespace ..."

# create service account
$KUBECTL create serviceaccount tiller -n kube-system

# create cluster role binding
cat <<__EOF | $KUBECTL create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
__EOF

# init tiller in kube-system namespace 
$HELM init --service-account tiller --tiller-namespace kube-system --upgrade --wait

# print helm & tiller version
$HELM version
RC=$?
if [ $RC -ne 0 ]; then
    echo "ERROR: Something went wrong during helm initialization."
    echo "       Check the error message above or run 'helm version' again"
    exit 4
fi

echo "** Successfully installed helm & tiller into your cluster **"
