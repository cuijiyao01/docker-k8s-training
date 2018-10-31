#!/bin/bash
#
# create_ingress_tls.sh         Very quick and dirty script to create a cetificate for an ingress resource for the K8S training.
#
# WARNING:      DO NOT use this script to produce certificates for network traffic that you consider sensitive.
#


CLUSTER=$1
PROJECT=$2

MYHOME=$(dirname $0)

if [ -z "$PROJECT" -o -z "$CLUSTER" ]; then
        echo "Specify project and cluster name."
        echo -e "\nUsage:"
        echo "  $0 <gardener cluster name> <gardener project name>"
        exit 1
fi

# check if cfssl is available
[ -z "$CFSSL" ] && CFSSL=$(which cfssl 2> /dev/null)
if [ -z "$CFSSL" -o ! -x "$CFSSL" ]; then
        echo "cfssl could not be found, downloading it from from https://pkg.cfssl.org..."
        curl --progress-bar -o $MYHOME/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
        chmod 755 $MYHOME/cfssl
        CFSSL=$MYHOME/cfssl
fi
# check if cfssl-json is available
[ -z "$CFSSLJSON" ] && CFSSLJSON=$(which cfssljson 2> /dev/null)
if [ -z "$CFSSLJSON" -o ! -x "$CFSSLJSON" ]; then
        echo "cfssljson could not be found, downloading it from from https://pkg.cfssl.org..."
        curl --progress-bar -o $MYHOME/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
        chmod 755 $MYHOME/cfssljson
        CFSSLJSON=$MYHOME/cfssljson
fi

URL="simple-nginx.ingress.${CLUSTER}.${PROJECT}.shoot.canary.k8s-hana.ondemand.com"

cat << _EOF > ca-config.json
{
    "signing": {
        "default": {
            "expiry": "168h"
        },
        "profiles": {
            "server": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "8760h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            }
        }
    }
}
_EOF

cat << _EOF > ca-csr.json
{
    "CN": "$PROJECT Gardener Self Signed Certificate",
    "hosts": [
        "$URL"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "DE",
            "ST": "BW",
            "L": "Walldorf"
        }
    ]
}
_EOF

$CFSSL gencert -initca ca-csr.json | $CFSSLJSON -bare ca -

cp ca-csr.json server-csr.json

$CFSSL gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server-csr.json | $CFSSLJSON -bare server

rm -f ca.csr ca-csr.json server.csr server-csr.json

echo -e "\n\nThe files you are looking for right now:"
echo "    server-key.pem  - TLS private key"
echo "    server.pem      - TLS certificate"
echo -e "\n upload them into a tls secret:"
echo "    kubectl create secret tls simple-nginx-ingress-tls --key=server-key.pem --cert=server.pem"
