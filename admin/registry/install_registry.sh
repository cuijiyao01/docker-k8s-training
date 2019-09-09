#!/bin/bash

# this is where we expect our helm values file
CONFIG_FILE=`dirname $0`/helm-docker-reg-values.yaml
MYHOME=$(dirname $0)
# read the configuration file
if [ ! -r $CONFIG_FILE ]; then
	echo "Cannot read the configuration file $CONFIG_FILE."
  echo "Please make sure, it's available."
	exit 1
fi

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=$(which kubectl 2> /dev/null)
if [ -z "$KUBECTL" -o ! -x "$KUBECTL" ]; then
	echo "kubectl could not be found, download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl"
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

# check if we have a working helm ready
[ -z "$HELM" ] && HELM=`which helm`
if [ -z "$HELM" -o ! -x "$HELM" ]; then
	echo "Cannot find or execute helm. Download it from https://github.com/kubernetes/helm#install."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
${HELM} list &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: helm does not work currently."
	echo "       Please make sure tiller is installed & has required premissions."
	exit 4
fi

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)

INGRESS_HOSTNAME_LONG=registry.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com
INGRESS_HOSTNAME_SHORT=r.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

if [ $(echo $INGRESS_HOSTNAME_SHORT | wc -m) -gt 64 ]; then
	echo "The short hostname for registry is longer than 64 chars!"
	echo "Certification of url and usage of registry would not work, please use a shorter cluster name!"
	exit 5
fi

# create htpasswd file for basic authentication
echo 'participant:$apr1$5KiSajCb$WS1TN7L0KTOltFHuDYle1/' > auth

# create a namespace for the registry
${KUBECTL} create ns registry

# create a secret with username/password for basic authentication
${KUBECTL} -n registry create secret generic basic-auth --from-file=auth

## prepare values file and install helm chart
sed -i.bck "s/INGRESS_HOSTNAME_SHORT/${INGRESS_HOSTNAME_SHORT}/g" $CONFIG_FILE
sed -i.bck "s/INGRESS_HOSTNAME_LONG/${INGRESS_HOSTNAME_LONG}/g" $CONFIG_FILE
${HELM} install stable/docker-registry --namespace registry -f $CONFIG_FILE

# cleanup
rm auth