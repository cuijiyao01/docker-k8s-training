#!/bin/bash

pushd `dirname "$BASH_SOURCE"`

CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)

sed "s/<clustername>/$CLUSTERNAME/g" 03-kibana.yaml.template > 03-kibana.yaml
sed -i "s/<projectname>/$PROJECTNAME/g" 03-kibana.yaml

kubectl apply -f .

popd
