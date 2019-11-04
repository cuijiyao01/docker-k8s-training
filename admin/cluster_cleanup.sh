#!/bin/bash


function cleanupNamespace () {
	NAMESPACE=$1

	if [ "$NAMESPACE" == "" ]; then
		echo "Please specify the namespace."
		exit 1
	fi

	if [ "$NAMESPACE" == "kube-system" ]; then
		echo "Not doing anything to the kube-system namespace."
		return
	fi

	# scale down Deployments
	DEPLOY=$(kubectl -n $NAMESPACE get deploy -o jsonpath="{.items[*].metadata.name}")
	for d in $DEPLOY; do
		REPLICAS=$(kubectl -n $NAMESPACE get deploy $d -o jsonpath="{.spec.replicas}")

		if [ $REPLICAS -gt 1 ]; then
			kubectl -n $NAMESPACE scale deployment $d --replicas=1
		else
			echo "Deployment $d has only $REPLICAS replicas - skipping."
		fi
	done


	# scale down StatefulSets and delete their PVCs
	STS=$(kubectl -n $NAMESPACE get sts -o jsonpath="{.items[*].metadata.name}")

	for s in $STS; do
		REPLICAS=$(kubectl -n $NAMESPACE get sts $s -o jsonpath="{.spec.replicas}")

		if [ $REPLICAS -gt 1 ]; then
			VOLUMES=$(kubectl -n $NAMESPACE get sts $s -o jsonpath="{.spec.volumeClaimTemplates[*].metadata.name}")
			kubectl -n $NAMESPACE scale sts $s --replicas=1
			for vol in $VOLUMES; do
				for k in $(seq 1 1 $((REPLICAS - 1))); do
					kubectl -n $NAMESPACE delete pvc $vol-$s-$k
				done
			done
		else
			echo "Statefulset $s has only $REPLICAS replicas - skipping."
		fi
	done


	# demote LoadBalancers to just NodePorts
	LB=$(kubectl -n $NAMESPACE get svc -o jsonpath="{range .items[?(@.spec.type == 'LoadBalancer')]}{.metadata.name} ")

	for l in $LB; do
		kubectl -n $NAMESPACE patch svc $l -p '{"spec": {"type": "NodePort"}}'
	done

}

if [ "$1" == "all" ]; then 
	echo "Retrieving all namespaces and running cleanup on each"
	NAMESPACELIST=$(kubectl get ns -o json | jq -r ".items[].metadata.name")

	for namespace in $NAMESPACELIST; do
		case $namespace in 
			'logging'|'kube-system'|'monitoring') echo "Skipping this namespace $namespace";;
			*) echo "Starting cleanup in $namespace"; cleanupNamespace $namespace;;
		esac
	done

	exit 0
fi

cleanupNamespace $1