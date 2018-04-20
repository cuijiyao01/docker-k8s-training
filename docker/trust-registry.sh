#!/bin/bash

# check availability of kubeconfig
KUBECONFIG=${HOME}/.kube/config
if [ ! -r $KUBECONFIG ]; then
  echo "No kubeconfig found!"
  echo "Please make sure a valid config is available at $KUBECONFIG."
  exit 1
fi

# extract CA from kubeconfig & move to ca store
TMPFILE=`mktemp`

kubectl config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed -e "s/^\"//g" -e "s/\"$//g" | base64 -d > $TMPFILE
sudo cp $TMPFILE /usr/local/share/ca-certificates/k8s-ca.crt
sudo chmod 644 /usr/local/share/ca-certificates/k8s-ca.crt
rm -f $TMPFILE

# update ca store
sudo update-ca-certificates

# display certificates
if [ "$1" == "-v" ]; then
        openssl x509 -text -noout -in /usr/local/share/ca-certificates/k8s-ca.crt
fi
