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
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
	HELM=$(which helm)
fi

# print helm & tiller version
$HELM version
RC=$?
if [ $RC -ne 0 ]; then
    echo "ERROR: Something went wrong during helm setup."
    echo "       Check the error message above or run 'helm version' again"
    exit 4
fi

$HELM repo add stable https://kubernetes-charts.storage.googleapis.com/

echo "** Successfully installed helm client locally **"
