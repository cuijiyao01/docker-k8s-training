# Exercise 1 - Setup of Docker environment

In this exercise you will set up a basic docker environment on a plain SLES 12 machine and run your first container on it.

## Prerequisites

During these exercises, we are going to use Docker on Linux - after all, this is where it all started.
You can connect to your VM with any SSH client you like, if you do not have one already, we recommend you download and use [PyTTY](https://plx172/K8S_Training/putty.exe).

The VM will be assigned to you at the beginning of the training. Each VM has two users: `training`, who is unprivileged and `root`, who may do everything. The passwords will be given to you at the beginning of the training as well.

## Step 0: log in to your training virtual machine

Using your SSH client, log in to your virtual machine as user training and as user root. With the `id -u` and `whoami` commands, verify that training has a user-ID of 1000 and root has a user-id of 0.

## Step 1: install docker

Using the `zypper search` command, search for the docker packages. Once you found them, install them with the `zypper install` command. Verify if the packages installed successfully by checking if the files `/usr/bin/docker` and `/usr/bin/dockerd` exist.

Try to run the command `docker info` but don't be surprised if you get an error message in return.

## Step 2: start docker and run your first container

Start the docker daemon with `systemctl start docker.service`. The command `docker info` will now give you useful information about docker's configuration.

Use the docker command to pull and run the [whale-say image](https://hub.docker.com/r/docker/whalesay/).

**Hint:** If a command takes way too long to be right, it certainly is not. Abort with `Ctrl + C`.

## Step 3: set up the proxy server

Create a systemd drop-in by creating the directory `/etc/systemd/system/docker.service.d`. Create the file `/etc/systemd/system/docker.service.d/proxy.conf` and put this inside:

```bash
[Service]
Environment="http_proxy=http://proxy.wdf.sap.corp:8080"
Environment="https_proxy=http://proxy.wdf.sap.corp:8080"
```

Tell systemd to reload all of its configuration files with `systemctl daemon-reload` and restart the docker daemon.

## Step 4:  Run your first container... again

Even though it might feel like a déjà-vu: use the docker command to pull and run the [whale-say image](https://hub.docker.com/r/docker/whalesay/).
