#!/bin/bash

# this is where we expect our helm values file
CONFIG_FILE=`dirname $0`/helm-docker-reg-values.yaml
# read the configuration file
if [ ! -r $CONFIG_FILE ]; then
	echo "Cannot read the configuration file $CONFIG_FILE."
  echo "Please make sure, it's available."
	exit 1
fi

# check if cfssl is available
[ -z "$CFSSL"] && CFSSL=`which cfssl`
if [ -z "$CFSSL" -o ! -x $CFSSL ]; then
	echo "Cannot find or execute cfssl. Download it from https://pkg.cfssl.org/."
	exit 3
fi
# check if cfssl-json is available
[ -z "$CFSSLJSON"] && CFSSLJSON=`which cfssljson`
if [ -z "$CFSSLJSON" -o ! -x $CFSSLJSON ]; then
	echo "Cannot find or execute cfssljson. Download it from https://pkg.cfssl.org/."
	exit 3
fi

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=`which kubectl`
if [ -z "$KUBECTL" -o ! -x $KUBECTL ]; then
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
if [ -z "$HELM" -o ! -x $HELM ]; then
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

# check if userinput is there
if [-z $1]; then
  echo "ERROR: Please specify your Gardener project name as 1st argument."
  echo "       Please specify your Gardener cluster name as 2nd argument"
  echo "       It is required to build the ingress URL"
  exit 5
fi

if [-z $2]; then
  echo "ERROR: please specify your Gardener cluster name."
  echo "       It is required to build the ingress URL"
  exit 5
fi

# construct ingress hostname string
GARDENER_PROJECTNAME=$1
GARDENER_CLUSTERNAME=$2
INGRESS_HOSTNAME=registry.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.k8s.sapcloud.io
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
 name: training-registry.registry
spec:
 groups:
 - system:authenticated
 request: $(cat server.csr | base64 | tr -d '\n')
 usages:
 - digital signature
 - key encipherment
 - server auth
__EOF

# create a namespace for the registry
${KUBECTL} create ns registry

# approve certificate signing request
${KUBECTL} -n registry certificate approve training-registry.registry

# download certificate
${KUBECTL} -n registry get csr training-registry.registry -o jsonpath='{.status.certificate}' | base64 -d > server.crt

# create a secret
${KUBECTL} -n registry create secret tls registry-certs --cert=./server.crt --key=./server-key.pem

## prepare values file and install helm chart
sed -i.bck "s/INGRESS_HOSTNAME/${INGRESS_HOSTNAME}/g" $CONFIG_FILE
${HELM} install stable/docker-registry --namespace registry -f $CONFIG_FILE

# clean-up
rm server.csr server.crt server-key.pem
