#!/bin/bash

pushd `dirname "$BASH_SOURCE"`

CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)

if [ $(echo 'k.ingress.${CLUSTERNAME}.${PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com' | wc -m) -gt 64 ]; then
	echo "The short hostname for kibana is longer than 64 chars!"
	echo "Certification of url will not work, please use a shorter cluster name!"
	exit 1
fi

sed "s/<clustername>/$CLUSTERNAME/g" 03-kibana.yaml.template > 03-kibana.yaml
sed -i "s/<projectname>/$PROJECTNAME/g" 03-kibana.yaml

kubectl apply -f .

popd
