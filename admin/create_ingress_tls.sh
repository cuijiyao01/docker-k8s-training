#!/bin/bash
#
# create_ingress_tls.sh         Very quick and dirty script to create a cetificate for an ingress resource for the K8S training.
#
# WARNING:      DO NOT use this script to produce certificates for network traffic that you consider sensitive.
#


PROJECT=$1
CLUSTER=$2

if [ -z "$PROJECT" -o -z "$CLUSTER" ]; then
        echo "Specify project and cluster name."
        echo -e "\nUsage:"
        echo "  $0 <gardener project name> <gardener cluster name>"
        exit 1
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

cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

cp ca-csr.json server-csr.json

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server-csr.json | cfssljson -bare server

rm -f ca.csr ca-csr.json server.csr server-csr.json

echo -e "\n\nThe files you are looking for right now:"
echo "    server-key.pem  - TLS private key"
echo "    server.pem      - TLS certificate"
echo "\n upload them into a tls secret:"
echo "    kubectl create secret tls simple-nginx-ingress-tls --key=server-key.pem --cert=server.pem"
