#!/bin/bash
#

if [ $# -ne 2 ]; then
	echo "Usage: get_kube_config.sh <training_id> <your_namespace_id>"
	echo "Pass the IDs given to you in the training."
	exit 1
fi

if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

BASE_URL=https://cc-admin.mo.sap.corp/userContent/k8s-trainings
CFG_URL="$BASE_URL/training-$1/kube-configs/$2/kube.config"
TARGET=$HOME/.kube/config

TMPFILE=`mktemp --dry-run`

curl -s -S -o $TMPFILE $CFG_URL

if [ -n "$(grep '<html>' $TMPFILE)" ]; then
	echo "ERROR: Did not receive a valid kube.config file."
	echo "Please check that you entered the correct training ID and participant ID."
	rm -f $TMPFILE
	exit 1
fi

mkdir -p `dirname $TARGET`
mv $TMPFILE $TARGET

echo "*** Successfully copied kube config to local $TARGET"
