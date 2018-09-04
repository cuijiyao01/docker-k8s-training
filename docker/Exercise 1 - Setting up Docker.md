# Exercise 1 - Setup of Docker environment

## Preparations

In this exercise you will set up a basic environment inlcuding Docker on your Ubuntu VM and run your first container on it. During these exercises, we are going to use Docker on Linux - after all, this is where it all started.

## Step 0: Prepare your VM
During this training you will use this VM not only to run Docker on it, but also to connect to the K8s cluster. Even though we are not dealing with Kubernetes right now (that will tomorrow's topic), we are going to use a Docker registry that we deployed to a Kubernetes cluster.

In order for you to set up your Docker environment so that it can connect to said registry, it is necessary to import some TLS certificates into your VM. Your trainer has given you information, how to get the kubeconfig and now it's time to download it to your VM. Run the script located at `~/setup/get_kube_config.sh`and hand over the IDs.

## Step 1: Install docker

**EMERGENCY SOLUTION FOR DNS OUTAGE AT SAP**

Install docker like this:
```bash
sudo -s
echo "nameserver 8.8.8.8" > /etc/resolv.conf
rm /etc/apt/apt.conf.d/01proxy
export http_proxy=""
export https_proxy=""
apt-get install docker-ce
exit
```

**END OF EMERGENCY SOLUTION FOR DNS OUTAGE AT SAP**


- Open a command window.
- **Switch to root:** Type `sudo -s` to switch to `root` and open a sub-shell.
- Type `apt-get update` to update the apt package manager.
- Type `apt-get -y install docker-ce` to install the docker engine.

Verify if the packages installed successfully by checking if the files `/usr/bin/docker` and `/usr/bin/dockerd` exist. You can run `docker -v` to check the version.

## Step 2: Set up the proxy and DNS server
SAP is slowly becoming proxy-less, i.e. the explicit proxy server that you all probably know gets replaced by a transparent proxy which you won't even notice it is there. Bangalore is already proxy-less so we do not have to think about this right now. 

- On the training VMs, Docker will try to use Google's DNS servers for all containers. This will not work reliably as we are referencing to SAP internal addresses and Google's DNS cannot resolve those. To force Docker to use SAP's internal DNS server, we need to create the configuation file `/etc/docker/daemon.json` with the following content:

```json
{
    "dns": ["8.8.8.8"]
}
```

- Tell systemd to reload all of its configuration files by running `systemctl daemon-reload` and restart the docker daemon with `systemctl restart docker.service`.

The command `docker info` will now give you useful information about Docker's configuration.

## Step 3: Run your first container

Use the `docker run hello-world` command to run your first container and check that docker works correctly.

## Step 4: Make sure a non-privileged user can use Docker

Until here, we were working as *root* who may do anything. Since this is dangerous and certainly not what is advisable in a production environment, we will use the default user of the VM *vagrant* from now on.

- Users that want to user docker must be members of the usergroup `docker`. Since this is not yet the case for user *vagrant*, issue the following command as root to change that:

```bash
usermod -G docker vagrant
```

- Type `exit` to exit the root shell and come back to the vagrant user and home directory.
- **In order for the group assignment to take effect, you must logout (top-right icon --> logout) and log back in** (use the same user  `vagrant`) with password `vagrant` (unless you changed your VM password).


## Step 5: Test docker as vagrant user

Type `docker run docker/whalesay` to pull and run the [whalesay image](https://hub.docker.com/r/docker/whalesay/). At first you get no output from the run. You will find useful information about this image and how to run it following [this link](https://hub.docker.com/r/docker/whalesay/) .
