#!/bin/bash

curl -L -o /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

if [ -e /usr/local/bin/kubectl ]; then
    sudo mv /usr/local/bin/kubectl /usr/local/bin/kubectl.bak
    sudo chmod 644 /usr/local/bin/kubectl.bak
fi

sudo mv /tmp/kubectl /usr/local/bin/kubectl
sudo chmod 755 /usr/local/bin/kubectl
sudo chown 0:0 /usr/local/bin/kubectl

exit 0

