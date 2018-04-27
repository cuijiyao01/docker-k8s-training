#!/bin/bash
#

if [ $# -ne 2 ]; then
    echo "Usage: get_cube_config.sh <training_id> <your_ns_id>"
    echo "Pass the IDs given to you in the training."
    exit 1
fi

BASE_URL=https://cc-admin.mo.sap.corp/userContent/k8s-trainings
CFG_URL="$BASE_URL/training-$1/kube-configs/$2/kube.config"
TARGET=$HOME/.kube/config

mkdir -p $HOME/.kube

curl -s -S -o $TARGET $CFG_URL

echo "*** Copied kube config to local $TARGET"
