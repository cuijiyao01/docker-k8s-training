#!/bin/bash
#
# kubecfggen.sh      A small script for a trainer that creates namespaces for a Kubernetes training in an existing cluster. The local kubectl
#                    must be configured so that the cluster can be accessed.
#
#                    This script will create dedicated namespaces for each training participant in the cluster, set up a cluster-role-binding
#                    binds the cluster-admin role to the default service account of each namespace and finally create a unique kube.config
#                    file that can be distributed to training participants.
#
#                    This script requires the configuration file kubecfggen.conf to work.
#
# Written by:        Thomas Buchner (D044431) <thomas.buchner@sap.com>
#                    Juergen Heymann (D021619) <juergen.heymann@sap.com>
#
# History:           0.1 - 22-Mar-2018 - Initial release
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

# before we continue... there are two absolutely mandatory fields in the configuration file, if they are empty, it makes no sense to go on
source $CONFIG_FILE
if [ -z "$CA_CERT" -o -z "$API_SERVER" ]; then
	echo "ERROR: Make sure the settings for CA_CERT and API_SERVER are properly maintained in the configuration file."
	exit 2
fi

GLOBAL_UID=$(get_uid)

# set some pathes and fields
# each training (i.e. invokation of this script) gets a separate output dir
if [ -z "$OUTPUT_DIR" ]; then 
	OUTPUT_DIR="training-$GLOBAL_UID"
else
	OUTPUT_DIR="$OUTPUT_DIR/training-$GLOBAL_UID"
fi
if [ -d $OUTPUT_DIR ]; then
	echo "ERROR: The output directory $OUTPUT_DIR already exists. You seem to be very lucky as you managed to hit the small chance of a hash collision."
	echo "       Please run this script again."
	exit 42
fi
mkdir -p $OUTPUT_DIR
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to create the output directory $OUTPUT_DIR."
	exit 10
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

# let's start by creating a YAML file that contains the namespace and cluster-role-binding definitions
echo -e "> Compiling $YAML_FILE...\n"

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
  name: cluster-admin
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

# let's feed this YAML file to our cluster
echo -e "> Sending $YAML_FILE to the cluster...\n"
kubectl create -f $YAML_FILE
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Something went wrong while creating the namespaces and cluster role bindings."
	echo "       Chech the output of kubectl above."
	exit 11
fi


# now we create the kube.config files
echo -e "\n> Retrieving access tokens for default service accounts and creating kube.config files."
for ns in $NAMESPACES; do
	NS_UID=${ns##*-}
	KUBE_CONF_DIR="$OUTPUT_DIR/kube-configs/$NS_UID"
	mkdir -p $KUBE_CONF_DIR
	echo "  - processing namespace $ns"
	TOKEN=`kubectl get secret -n $ns -o json | jq '.items[0].data.token' | sed 's/"//g' | base64 --decode`
	
	# create kubeconfig
	cat << __EOF > $KUBE_CONF_DIR/kube.config
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


# create a printable sheet with participant information
PARTICIPANT_SHEET=$OUTPUT_DIR/participant-sheet.txt

echo "Training ID: $GLOBAL_UID" > $PARTICIPANT_SHEET
echo "Place the folder $OUTPUT_DIR into the share \\\\$KUBE_CONF_SHARE\\$OUTPUT_DIR." >> $PARTICIPANT_SHEET
echo -e "\n-----------------------------------------" >> $PARTICIPANT_SHEET
for ns in $NAMESPACES; do
	NS_UID=${ns##*-}
	echo "Your ID: $NS_UID" >> $PARTICIPANT_SHEET
	echo "Download location for your personal kube.config: " >> $PARTICIPANT_SHEET
	echo "  $KUBE_CONF_SHARE\\$OUTPUT_DIR\\$NS_UID\\kube.config" >> $PARTICIPANT_SHEET
	echo "-----------------------------------------" >> $PARTICIPANT_SHEET
done


# print out the final message (yes, I like here-docs)
cat << __EOF

------------------------------------------------------------------------------------
Some important pieces of information for you to write down:
------------------------------------------------------------------------------------
 > Unique ID for this training: $GLOBAL_UID
 > YAML file with cluster resources: $YAML_FILE
 > Location of kube.config files: $OUTPUT_DIR/kube-configs
  
 > Print the contents of $PARTICIPANT_SHEET and distribute 
   them your training participants.
-------------------------------------------------------------------------------------
__EOF
