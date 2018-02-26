# Exercise 1 - Setup of Docker environment

In this exercise you will set up a basic Docker environment on a plain SLES 12 machine and run your first container on it.

## Prerequisites

During these exercises, we are going to use Docker on Linux - after all, this is where it all started.
You can connect to your VM with any SSH client you like, if you do not have one already, we recommend you download and use [PuTTY](https://plx172/K8S_Training/putty.exe).

The VM will be assigned to you at the beginning of the training. Each VM has two users: `training`, who is unprivileged and `root`, who may do everything. The passwords will be given to you at the beginning of the training as well.

## Step 0: log in to your training virtual machine

Using your SSH client, log in to your virtual machine as user training and as user root. With the `id -u` and `whoami` commands, verify that training has a user-ID of 1000 and root has a user-id of 0. For the beginning of this exercise, you will need root privileges.

## Step 1: install docker

Using the `zypper search` command, search for the Docker packages. Once you found them, install them with the `zypper install` command. Verify if the packages installed successfully by checking if the files `/usr/bin/docker` and `/usr/bin/dockerd` exist.

Try to run the command `docker info` but don't be surprised if you get an error message in return.

## Step 2: set up the proxy server

Create a systemd drop-in by creating the directory `/etc/systemd/system/docker.service.d`. Create the file `/etc/systemd/system/docker.service.d/proxy.conf` and put this inside:

```bash
[Service]
Environment="http_proxy=http://proxy.wdf.sap.corp:8080"
Environment="https_proxy=http://proxy.wdf.sap.corp:8080"
Environment="no_proxy=.wdf.sap.corp"
```

Tell systemd to reload all of its configuration files with `systemctl daemon-reload` and restart the docker daemon with `systemctl restart docker.service`.

## Step 3: Run your first container

Start the Docker daemon with `systemctl start docker.service`. The command `docker info` will now give you useful information about Docker's configuration.

Use the `docker run` command to pull and run the [whale-say image](https://hub.docker.com/r/docker/whalesay/) (you will find useful information about how to run this image by following [this link](https://hub.docker.com/r/docker/whalesay/) ).

## Step 4: Make sure a non-privileged user can use Docker

Until here, we were working as *root* who may do anything. Since this is dangerous and certainly not what is advisable in a production environment, we will use the user *training* from now on.

Users must be members of the usergroup `docker` for them to able to use docker. Since this is not yet the case for user *training*, issue the following command as root to change that:

```bash
usermod -G docker training
```

Log out and log back in as user *training*. From now on, we will continue as user *training* you will no longer need the *root* shell.
