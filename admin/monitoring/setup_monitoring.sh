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

# this is where we expect our helm values file
MYHOME=$(dirname $0)
CONFIG_FILE=$MYHOME/grafana-values.yaml
# read the configuration file
if [ ! -r $CONFIG_FILE ]; then
	echo "Cannot read the configuration file $CONFIG_FILE."
  echo "Please make sure, it's available."
	exit 1
fi

# check if cfssl is available
[ -z "$CFSSL" ] && CFSSL=$(which cfssl 2> /dev/null)
if [ -z "$CFSSL" -o ! -x "$CFSSL" ]; then
	echo "cfssl could not be found, downloading it from from https://pkg.cfssl.org..."
	curl --progress-bar -o $MYHOME/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
	chmod 755 $MYHOME/cfssl
	CFSSL=$MYHOME/cfssl
fi
# check if cfssl-json is available
[ -z "$CFSSLJSON" ] && CFSSLJSON=$(which cfssljson 2> /dev/null)
if [ -z "$CFSSLJSON" -o ! -x "$CFSSLJSON" ]; then
	echo "cfssljson could not be found, downloading it from from https://pkg.cfssl.org..."
	curl --progress-bar -o $MYHOME/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
	chmod 755 $MYHOME/cfssljson
	CFSSLJSON=$MYHOME/cfssljson
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
${HELM} install --namespace $NAMESPACE -n prometheus stable/prometheus --set networkPolicy.enabled=true

## prepare for grafana

# construct ingress hostname string
GARDENER_PROJECTNAME=$1
GARDENER_CLUSTERNAME=$2
INGRESS_HOSTNAME=test-monitoring.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

# generate a private key & certificate signing request
cat <<__EOF | $CFSSL genkey - | $CFSSLJSON -bare server
{
  "hosts": [
    "$INGRESS_HOSTNAME"
  ],
  "CN": "$INGRESS_HOSTNAME",
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
__EOF

# upload certificate signing request to k8s
cat <<__EOF | $KUBECTL create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
 name: training-monitoring.monitoring
spec:
 groups:
 - system:authenticated
 request: $(cat server.csr | base64 | tr -d '\n')
 usages:
 - digital signature
 - key encipherment
 - server auth
__EOF

# approve certificate signing request
${KUBECTL} -n $NAMESPACE certificate approve training-monitoring.monitoring

# download certificate
${KUBECTL} -n $NAMESPACE get csr training-monitoring.monitoring -o jsonpath='{.status.certificate}' | base64 -d > server.crt

# create a secret
${KUBECTL} -n $NAMESPACE create secret tls grafana-tls --cert=./server.crt --key=./server-key.pem

# set ingress url in values file
sed -i.bck "s/INGRESS_HOSTNAME/${INGRESS_HOSTNAME}/g" $CONFIG_FILE

## deploy grafana components

${KUBECTL} -n $NAMESPACE create configmap monitoring-dashboards --from-file=./dashboards/cluster_stats.json --from-file=./dashboards/training_stats.json
${KUBECTL} -n $NAMESPACE label configmap monitoring-dashboards grafana_dashboard=1

# install grafana chart
${HELM} install --namespace $NAMESPACE -n grafana stable/grafana -f $CONFIG_FILE

# clean-up
rm server.csr server.crt server-key.pem

## print some help
echo "To access grafana, follow the instructions above."
