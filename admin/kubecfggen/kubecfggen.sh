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
#                    Hendrik Kahl (D051945) <hendrik.kahl@sap.com>
#
# History:           0.1 - 22-Mar-2018 - Initial release
#                    0.2 - 03-Apr-2018 - Fields CA_CERT and API_SERVER will be automatically retrieved from current kube context
#                    0.3 - 19-Apr-2018 - Resource quotas and limits will be created per namespace now.
#                    0.4 - 19-Apr-2018 - Package generated configs as tar and switch to download from jenkins
#                    0.5 - 18-Oct-2018 - Introducing the access service account which gets ClusterAdmin rights
#                    0.6 - 31-Oct-2018 - Simply numbering the namespace IDs - K.I.S.S.
#                    0.7 - 08-Nov-2018 - Added security by locking participants into their namespaces
#                    0.8 - 30-Jan-2019 - Use client certificates instead of service account tokens
#                    0.9 - 26-Nov-2019 - Rename service account 'tiller' to 'chaoskube' 
#                    0.10- 19-Feb-2020 - Add `lease` resource to cluster-wide view role
#

# version tag
_VERSION=0.8

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

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=`which kubectl`
if [ -z "$KUBECTL" -o ! -x $KUBECTL ]; then
	echo "Cannot find or execute kubectl. Download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
${KUBECTL} get nodes &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Unable to get the nodes of your cluster ('kubectl get nodes' returned with RC $RC)."
	echo "       Check that your kube.config is correct and points to the corrent cluster."
	exit 4
fi

# before we continue, we try to figure out the API server and its CA_CERT
source $CONFIG_FILE
if [ -z "$CA_CERT" ]; then
	echo "> Using API server authentication token from current kube.config"
	CA_CERT=`${KUBECTL} config view --minify --flatten -o json | jq ".clusters[0].cluster.\"certificate-authority-data\"" | sed -e "s/^\"//g" -e "s/\"$//g"`
fi

if [ -z "$API_SERVER" ]; then
	echo "> Using API server address from current kube.config."
	API_SERVER=`${KUBECTL} config view --minify --flatten -o json | jq ".clusters[0].cluster.server" | sed -e "s/^\"//g" -e "s/\"$//g"`
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
ROLEBINDING_NAME=training:participant-is-clusteradmin
ROLEBINDING_YAML=$OUTPUT_DIR/emergency_clusteradmin-rolebinding.yaml

# we store the list of namespaces in this variable
NAMESPACES=""

# do we even know how many namespaces to create
if [[ "$1" =~ ^[0-9]+$ ]]; then
	NS_COUNT=$1
fi

if [ -z "$NS_COUNT" -o $NS_COUNT -lt 1 ]; then
	echo "Please specify how many namespaces you want to create in the config file."
	exit 5
fi

# maybe we do not want to start counting from 1, so which is our start number?
if [[ "$2" =~ ^[0-9]+$ ]]; then
	NS_START=$2
	NS_END=$((NS_START+NS_COUNT-1))
else
	NS_START=1
	NS_END=$NS_COUNT
fi

# let's start by creating a YAML file that contains the namespace and cluster-role-binding definitions
echo -e "> Compiling $YAML_FILE...\n"

# Do we have a namespace prefix? If not, we fall back to a default.
[ -z "$NS_PREFIX" ] && NS_PREFIX="part"

# create the namespace ojects for the YAML file along with the chaoskube service account
for i in $(seq $NS_START 1 $NS_END); do
	NS_NUM=$(printf "%04d" $i)
	NS_NAME=$NS_PREFIX-$NS_NUM

	${KUBECTL} get ns $NS_NAME >& /dev/null
	if [ $? -eq 0 ]; then
		echo "The namespace $NS_NAME already exists in the cluster."
		echo "Please check if you need to start counting from a different value than $NS_START."
		exit 1
	fi

	NAMESPACES="$NAMESPACES $NS_NAME"

	cat << __EOF >> $YAML_FILE
---
apiVersion: v1
kind: Namespace
metadata:
  name: $NS_NAME
  labels:
    heritage: kubecfggen
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: chaoskube
  namespace: $NS_NAME
  labels:
    heritage: kubecfggen
__EOF
done



# create a rolebinding in each namespace to give appropriate permissions to participants
# also add resource quotas and limits to each namespac
# max 15 pods per namespace, by default container consume 0.2 cpu & 200 MiB memory
for ns in $NAMESPACES; do
        cat << __EOF >> $YAML_FILE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: training:participant-is-admin
  namespace: $ns
  labels:
    heritage: kubecfggen
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: User
  name: $ns
  namespace: $ns
- kind: ServiceAccount
  name: chaoskube
  namespace: $ns
---
apiVersion: v1
kind: LimitRange
metadata:
  name: training-resource-containment
  namespace: $ns
  labels:
    heritage: kubecfggen
spec:
  limits:
  - default:
      cpu: 0.5
      memory: 300Mi
    defaultRequest:
      cpu: 0.1
      memory: 100Mi
    type: Container
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: training-pod-limit
  namespace: $ns
  labels:
    heritage: kubecfggen
spec:
  hard:
    pods: "15"
    services.loadbalancers: "3"
    requests.storage: "10Gi"
    persistentvolumeclaims: "10"
__EOF
done

# finally, create a Role and a rolebinding that lets participants see what's going on in the
# kube-system namespace as well as a ClusterRole and a ClusterRoleBinding lets people see
# nodes, pvs, etc...
cat << __EOF >> $YAML_FILE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: training:kube-system-view
  namespace: kube-system
  labels:
    heritage: kubecfggen
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "endpoints", "events", "persistentvolumeclaims", "podtemplates", "serviceaccounts", "services", "configmaps", "replicationcontrollers"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["daemonsets", "deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: training:kube-system-view
  namespace: kube-system
  labels:
    heritage: kubecfggen
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: training:kube-system-view
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: participants
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: training:cluster-view
  labels:
    heritage: kubecfggen
rules:
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods", "componentstatuses", "namespaces", "nodes", "persistentvolumes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions", "policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["storage.k8s.io"]
  resources: ["storageclasses"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: training:cluster-view
  labels:
    heritage: kubecfggen
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: training:cluster-view
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: participants
__EOF

for ns in $NAMESPACES; do
        cat << __EOF >> $YAML_FILE
- kind: ServiceAccount
  name: chaoskube
  namespace: $ns
__EOF
done

# let's feed this YAML file to our cluster
echo -e "> Sending $YAML_FILE to the cluster...\n"
${KUBECTL} apply -f $YAML_FILE
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Something went wrong while creating the namespaces and cluster role bindings."
	echo "       Chech the output of kubectl above."
	exit 11
fi

## just for emergency purposes: if the locking in of participants does not work
## we create a clusterrolebinding which grants cluster-admin to all participants
# first the header for the rolebindingobject
cat << __EOF >> $ROLEBINDING_YAML
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $ROLEBINDING_NAME
  labels:
    heritage: kubecfggen
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: Group
  name: participants
__EOF
## end of emergency rolebindings

# now we create the client certificates & kube.config files
echo -e "\n> Generating certificates for the participants and creating kube.config files."
for ns in $NAMESPACES; do
	NS_UID=${ns##*-}
	KUBE_CONF_DIR="$OUTPUT_DIR/kube-configs/$NS_UID"
  CLIENT_CERT_DIR="$OUTPUT_DIR/certs/$NS_UID"
	mkdir -p $KUBE_CONF_DIR
  mkdir -p $CLIENT_CERT_DIR
	echo "  - processing namespace $ns"

  # create key & csr files
  openssl genrsa -out $CLIENT_CERT_DIR/client.key 4096
  openssl req -new -key $CLIENT_CERT_DIR/client.key -out $CLIENT_CERT_DIR/client.csr -subj "/O=participants/CN=$ns"

  # send csr to cluster
  cat <<__EOF | $KUBECTL create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: $ns.client-auth.training
spec:
  groups:
  - system:authenticated
  request: $(cat $CLIENT_CERT_DIR/client.csr | base64 | tr -d '\n')
  usages:
  - client auth
__EOF

 # approve csr & download signed crt 
${KUBECTL} certificate approve ${ns}.client-auth.training
${KUBECTL} get csr ${ns}.client-auth.training -o jsonpath='{.status.certificate}' > $CLIENT_CERT_DIR/client.crt

	# create kubeconfig
	cat << __EOF > $KUBE_CONF_DIR/kube.config
---
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_CERT
    server: $API_SERVER
  name: k8s_training_cluster
users:
- name: participant
  user:
    client-certificate-data: $(cat  $CLIENT_CERT_DIR/client.crt)
    client-key-data: $(cat  $CLIENT_CERT_DIR/client.key | base64 --wrap=0)
contexts:
- context:
    cluster: k8s_training_cluster
    user: participant
    namespace: $ns
  name: k8s-training-$ns
current-context: k8s-training-$ns
__EOF
done

# remove certificates from file system
rm -rf ${OUTPUT_DIR}/certs

# create a printable sheet with participant information
PARTICIPANT_SHEET=$OUTPUT_DIR/participant-sheet.txt

OUTPUT_TAR=${OUTPUT_DIR}.tar.gz
echo "Trainer: Upload the $OUTPUT_TAR to Jenkins via $KUBE_CONF_BASE" >> $PARTICIPANT_SHEET
echo "Training ID: $GLOBAL_UID" > $PARTICIPANT_SHEET
echo -e "\n-----------------------------------------" >> $PARTICIPANT_SHEET
for ns in $NAMESPACES; do
	NS_UID=${ns##*-}
	echo "Your ID is $NS_UID, your namespace name is $NS_PREFIX-$NS_UID" >> $PARTICIPANT_SHEET
	echo "In your VM: Download your personal kube.config by running the script (with args): " >> $PARTICIPANT_SHEET
	echo "  ~/setup/get_kube_config.sh $GLOBAL_UID $NS_UID" >> $PARTICIPANT_SHEET
	echo "-----------------------------------------" >> $PARTICIPANT_SHEET
done


# package created training configs in a tar to be uploaded in jenkins
echo -e "> Packing everything into a handy tarball ${OUTPUT_TAR}...\n"
tar -zcvf ${OUTPUT_TAR} $OUTPUT_DIR

# at last we give kube-system namespace a label for network policies to work.
if [ "$(${KUBECTL} get namespaces kube-system -o json | jq '.metadata.labels.name == null')" == "true" ]; then
	${KUBECTL} label namespaces kube-system name=kube-system
fi

# print out the final message (yes, I like here-docs)
cat << __EOF

------------------------------------------------------------------------------------
Some important pieces of information for you to write down:
------------------------------------------------------------------------------------
 > Unique ID for this training:      $GLOBAL_UID
 > Number of namespaces created:     $NS_COUNT
 > YAML file with cluster resources: $YAML_FILE
 > Location of kube.config files:    $OUTPUT_DIR/kube-configs

 > Print the contents of $PARTICIPANT_SHEET and distribute
   them your training participants.
-------------------------------------------------------------------------------------
__EOF
