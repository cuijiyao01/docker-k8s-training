#!/bin/bash
#
# kubecfggen.sh     A small script that creates namespaces for a Kubernetes training in a cluster, sets up a cluster-role-binding for all
#                   default service account in each namespace that grant cluster-admin access and creates individual kube.config files
#                   for each namespace.
#
#                   This is meant to provide a unique K8S environment for each training participant that he/she can access with the
#                   kube.config that was created by this script.
#
#                   This script requires the configuration file kubecfggen.conf to work.
#
# Written by:       Thomas Buchner (D044431) <thomas.buchner@sap.com>
#                   Juergen Heymann (D021619) <juergen.heymann@sap.com>
#
# History:          0.1 - 22-Mar-2018 - Initial release
#

# this is where we expect our configuration file
CONFIG_FILE=`dirname $0`/kubecfggen.conf

# a function to create (more or less) unique IDs with 8 digits
function get_uid {
	UUID=`uuidgen | md5sum`
	UUID=${UUID:0:8}
	echo $UUID
}

# read the configuration file
if [ ! -r $CONFIG_FILE ]; then
	echo "Cannot read the configuration file $CONFIG_FILE."
	exit 1
fi
source $CONFIG_FILE
GLOBAL_UID=$(get_uid)

# set some pathes and files
# each training (i.e. invokation of this script) gets a separate output dir
[ -z "$OUTPUT_DIR" ] && OUTPUT_DIR="."
OUTPUT_DIR=$OUTPUT_DIR/training_$GLOBAL_UID
if [ -d $OUTPUT_DIR ]; then
	echo "ERROR: The output directory $OUTPUT_DIR already exists. You seem to be very lucky as you managed to hit the small chance of a hash collision."
	echo "       Please run this script again."
	exit 42
fi
mkdir -p $OUTPUT_DIR
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to create the output directory $OUTPUT_DIR."
	exit 2
fi

# this is the YAML file to which the cluster resource definitions get written
YAML_FILE=$OUTPUT_DIR/cluster-resources.yaml

# this is the unique name for the cluster role binding
ROLEBINDING_NAME=training-roles-$GLOBAL_UID

# we store the list of namespaces in this variable
NAMESPACES=""

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=`which kubectl`
if [ -z "$KUBECTL" -o ! -x $KUBECTL ]; then
	echo "Cannot find or execute kubectl. Download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
kubectl get nodes &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Unable to get the nodes of your cluster ('kubectl get nodes' returned with RC $RC)."
	echo "       Check that your kube.config is correct and points to the corrent cluster."
	exit 4
fi

# do we even know how many namespaces to create
if [ -z "$NS_COUNT" -o $NS_COUNT -lt 1 ]; then
	echo "Please specify how many namespaces you want to create in the config file."
	exit 5
fi

# Do we have a namespace prefix? If not, we fall back to a default.
[ -z "$NS_PREFIX" ] && NS_PREFIX="part"

# create the namespace ojects for the YAML file
for i in `seq -w 01 1 $NS_COUNT`; do
	NS_NAME=$NS_PREFIX-$(get_uid)
	NAMESPACES="$NAMESPACES $NS_NAME"
	
	cat << __EOF >> $YAML_FILE
---
apiVersion: v1
kind: Namespace
metadata:
  name: $NS_NAME
__EOF
done

# create the rolebinding object to give namespace default service accounts cluster admin rights
# first the header for the rolebindingobject
cat << __EOF >> $YAML_FILE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $ROLEBINDING_NAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admins
subjects:
__EOF

# and then the rolebindings for the default service accounts for each namespace
for ns in $NAMESPACES; do
	cat << __EOF >> $YAML_FILE
- kind: ServiceAccount
  name: default
  namespace: $ns
__EOF
done

echo -e "> Creating namespaces and clusterrolebindings on the cluster.\n"

# let's feed this YAML file to our cluster
echo -e "> Sending $YAML_FILE to the cluster...\n"
kubectl create -f $YAML_FILE
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Something went wrong while creating the namespaces and cluster role bindings."
	echo "       Chech the output of kubectl above."
	exit 6
fi

echo -e "\n> Retrieving access tokens for default service accounts and creating kube.config files."
# now we create the kube.config files
for ns in $NAMESPACES; do
	NS_UID=${ns##*-}
	KUBE_CONFIG="$OUTPUT_DIR/kube-configs/$NS_UID/kube.config"
	mkdir -p `dirname $KUBE_CONFIG`
	echo "  - processing namespace $ns"
	TOKEN=`kubectl get secret -n $ns -o json | jq '.items[0].data.token' | sed 's/"//g' | base64 --decode`
	
	# create kubeconfig
	cat << __EOF > $KUBE_CONFIG
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_CERT
    server: https://$API_SERVER
  name: k8s_training_cluster
users:
- name: default
  user:
    token: $TOKEN
contexts:
- context:
    cluster: k8s_training_cluster
    user: default
    namespace: $ns
  name: k8s-training-$ns
current-context: k8s-training-$ns
__EOF
done

FINAL_MESSAGE="\n> Done\n\n
------------------------------------------------------------------------------------\n
Information for you to write down:\n
------------------------------------------------------------------------------------\n
  > Unique ID for this training: $GLOBAL_UID\n
  > YAML file with cluster resources: $YAML_FILE\n
  > Location of kube.config files: $OUTPUT_DIR/kube-configs\n
-------------------------------------------------------------------------------------"
echo -e $FINAL_MESSAGE
