#!/bin/bash
#

# this is the central location where all the kube.config files are stored
BASE_URL=https://cc-admin.mo.sap.corp/userContent/k8s-trainings

# this is the location in the local filesystem where the kube.config file needs to be placed
TARGET=$HOME/.kube/config


if [ $# -lt 2 ]; then
	echo "Usage: get_kube_config.sh <training_id> <your_namespace_id>"
	echo "       Pass the IDs handed out to you in the training."
	exit 1
fi

if [ `id -u` -eq 0 ]; then
	echo "ERROR: Please do not run this script as root."
	exit 1
fi


function trust_registry {
	# extract CA from kubeconfig & move to ca store
	TMPCRT=`mktemp`

	kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed -e "s/^\"//g" -e "s/\"$//g" | base64 -d > $TMPCRT
	sudo cp $TMPCRT /usr/local/share/ca-certificates/k8s-ca.crt
	sudo chmod 644 /usr/local/share/ca-certificates/k8s-ca.crt
	rm -f $TMPCRT

	# update ca store
	sudo update-ca-certificates
	if [ $? -ne 0 ]; then
		echo "ERROR: An error occured while trying to import the cluster certificate."
	else
		echo "*** Successfully imported the cluster certificate to trusted store."
	fi
}


CFG_URL="$BASE_URL/training-$1/kube-configs/$2/kube.config"
TMPFILE=`mktemp --dry-run`

curl -s -S -o $TMPFILE $CFG_URL

if [ -n "$(grep '<html>' $TMPFILE)" ]; then
	echo "ERROR: Did not receive a valid kube.config file."
	echo "       Please check that you entered the correct training ID and participant ID."
	rm -f $TMPFILE
	exit 1
fi

mkdir -p `dirname $TARGET`
mv $TMPFILE $TARGET

echo "*** Successfully copied kube config to local $TARGET"

if [ "$3" != "--no-trust-registry" ]; then
	trust_registry
fi
