## Step 1: Install docker

Open a command window.

Run the following commands in order to install Docker:

```bash
sudo -s
apt-get update
apt-get install docker-ce
```

Run the following commands to verify that the Docker binaries have been installed:

```bash
test -x /usr/bin/docker && echo "Docker client is installed and executable."
test -x /usr/bin/dockerd && echo "Docker daemon is installed and executable."
```

Check the Docker version and get some info about its environment:

```bash
docker -v
docker info
```

## Step 2: Set up the proxy and DNS server

Open a command window and enter the following commands in order to create a systemd configuration drop-in:

```bash
sudo -s
mkdir /etc/systemd/system/docker.service.d
cat << '__EOF' > /etc/systemd/system/docker.service.d/proxy.conf
[Service]
Environment="http_proxy=http://proxy.wdf.sap.corp:8080"
Environment="https_proxy=http://proxy.wdf.sap.corp:8080"
Environment="no_proxy=.wdf.sap.corp"
__EOF
```

Create the Docker configuration file that sets the DNS configuration to SAP's own internal DNS servers:

```bash
cat << '__EOF' > /etc/docker/daemon.json
{
    "dns": ["10.17.121.30", "10.17.220.80"]
}
__EOF
```

Tell systemd to reload its configuration files and restart the Docker daemon with the new configuration:

```bash
systemctl daemon-reload
systemctl restart docker.service
```

## Step 3: Run your first container

Run the following command in a command window:

```bash
sudo -s
docker run hello-world
```

The expected output looks somehow like this:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

## Step 4: Make sure a non-privileged user can use Docker

Open a command window and run the following two commands:
```bash
sudo -s
usermod -G docker vagrant
```

Close your command window, log out from your user session (top-right icon --> logout) and log back in with user vagrant (password vagrant).

## Step 5: Test docker as vagrant user

After loggin in, open a command window. Do not use the `sudo -s` command any longer, we no longer want to work as root.

```bash
docker run docker/whalesay cowsay "Everything seems to be fine."
```

The expected output looks like this:
```
 ______________________________
< Everything seems to be fine. >
 ------------------------------
    \
     \
      \     
                    ##        .            
              ## ## ##       ==            
           ## ## ## ##      ===            
       /""""""""""""""""___/ ===        
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
       \______ o          __/            
        \    \        __/             
          \____\______/   
```
