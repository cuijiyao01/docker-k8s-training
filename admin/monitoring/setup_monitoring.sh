#!/bin/bash

## check prerequisites
# check if userinput is there
if [ $# -lt 2 ]; then
  echo "ERROR: Please specify your Gardener project name as 1st argument."
  echo "       Please specify your Gardener cluster name as 2nd argument"
  echo "       It is required to build the ingress URL"
  exit 5
fi

NAMESPACE="monitoring"

# this is where we expect our helm values files
MYHOME=$(dirname $0)
GRAFANA_CONFIG_FILE=$MYHOME/grafana-values.yaml
# read the configuration file
if [ ! -r $GRAFANA_CONFIG_FILE ]; then
	echo "Cannot read the configuration file $GRAFANA_CONFIG_FILE."
  echo "Please make sure, it's available."
	exit 1
fi

PROMETHEUS_CONFIG_FILE=$MYHOME/prometheus-values.yaml
# read the configuration file
if [ ! -r $PROMETHEUS_CONFIG_FILE ]; then
	echo "Cannot read the configuration file $PROMETHEUS_CONFIG_FILE."
  echo "Please make sure, it's available."
	exit 1
fi

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

## deploy prometheus components

# create a namespace for the monitoring
${KUBECTL} create ns $NAMESPACE

# install prometheus chart
${HELM} install --namespace $NAMESPACE -n prometheus stable/prometheus -f $PROMETHEUS_CONFIG_FILE

## prepare for grafana

# construct ingress hostname string
GARDENER_PROJECTNAME=$1
GARDENER_CLUSTERNAME=$2
INGRESS_HOSTNAME_SHORT=m.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com
INGRESS_HOSTNAME_LONG=training-monitoring.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

# set ingress url in values file
sed -i.bck "s/INGRESS_HOSTNAME_SHORT/${INGRESS_HOSTNAME_SHORT}/g" $GRAFANA_CONFIG_FILE
sed -i.bck "s/INGRESS_HOSTNAME_LONG/${INGRESS_HOSTNAME_LONG}/g" $GRAFANA_CONFIG_FILE

## deploy grafana components

${KUBECTL} -n $NAMESPACE create configmap monitoring-dashboards --from-file=./dashboards/cluster_stats.json --from-file=./dashboards/training_stats.json
${KUBECTL} -n $NAMESPACE label configmap monitoring-dashboards grafana_dashboard=1

# install grafana chart
${HELM} install --namespace $NAMESPACE -n grafana stable/grafana -f $GRAFANA_CONFIG_FILE

## print some help
echo "To access grafana, follow the instructions above."
