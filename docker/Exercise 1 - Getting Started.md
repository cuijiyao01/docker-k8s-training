# Exercise 1 - Setup of Docker environment

## Preparations

In this exercise you will set up a basic Docker environment on your Ubuntu VM and run your first container on it. During these exercises, we are going to use Docker on Linux - after all, this is where it all started.


## Step 1: Install docker

- Open a command window. Type `sudo -i` to switch to `root` and open a sub-shell.
- Type `apt-get update` to update the apt package manager.
- Type `apt-get -y install docker-ce` to install the docker engine. 

Using the `zypper search` command, search for the Docker packages. Once you found them, install them with the `zypper install` command. Verify if the packages installed successfully by checking if the files `/usr/bin/docker` and `/usr/bin/dockerd` exist.

You can run `docker -v` to check the version.

## Step 2: Set up the proxy server
Docker also needs to know about the proxy settings to work properly.

- Create a systemd drop-in by creating the directory `/etc/systemd/system/docker.service.d`. Create the file `/etc/systemd/system/docker.service.d/proxy.conf` and put this inside:

```bash
[Service]
Environment="http_proxy=http://proxy.wdf.sap.corp:8080"
Environment="https_proxy=http://proxy.wdf.sap.corp:8080"
Environment="no_proxy=.wdf.sap.corp"
```

- Tell systemd to reload all of its configuration files by running `systemctl daemon-reload` and restart the docker daemon with `systemctl restart docker.service`.

- Type `exit` to exit the root shell and come back to the vagrant user and home directory. 

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
