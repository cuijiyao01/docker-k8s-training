#!/bin/bash
## custom scheduler
# looks for any pod with schedulerName = "my-scheduler" and assigns it to a random node

## prerequisites:
# expects kubectl proxy running and serving on port 8001
# expects a target namespace to be specified

SERVER='localhost:8001'

if [ $# -lt 1 ]; then
  echo "ERROR: Please specify your target namespace"
  exit 5
fi
NAMESPACE=$1

curl -Is localhost:8001 > /dev/null
RC=$?
if [ $RC -ne 0 ]; then
  echo "ERROR: connection to API server via localhost:8001 not possible"
  echo "ERROR: Please run 'kubectl proxy &' and make sure it's serving on port 8001"
  exit 5
fi

while true;
do
    for PODNAME in $(kubectl --server $SERVER -n $NAMESPACE get pods -o json | jq '.items[] | select(.spec.schedulerName == "my-scheduler") | select(.spec.nodeName == null) | .metadata.name' | tr -d '"')
#;
    do
        NODES=($(kubectl --server $SERVER get nodes -o json | jq '.items[].metadata.name' | tr -d '"'))
        NUMNODES=${#NODES[@]}
        CHOSEN=${NODES[$[ $RANDOM % $NUMNODES ]]}
        curl --header "Content-Type:application/json" --request POST --data '{"apiVersion":"v1", "kind": "Binding", "metadata": {"name": "'$PODNAME'"}, "target": {"apiVersion": "v1", "kind"
: "Node", "name": "'$CHOSEN'"}}' http://$SERVER/api/v1/namespaces/$NAMESPACE/pods/$PODNAME/binding/
        echo "Assigned $PODNAME to $CHOSEN"
    done
    sleep 1
done
