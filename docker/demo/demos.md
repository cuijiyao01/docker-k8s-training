## Demo of Docker networks

You can use network-demo.sh script. 
It executes all necessary docker command for this demo and awaits a "enter" before it cleans up and goes to the next part.

### Description

Let's get back to our nginx examples.

#### First part
`docker run -d -p 8081:80 nginx:mainline`
Access the nginx on port localhost:8081

#### Second part
Run the same with -P and get the port via docker container list
Access the nginx via the random port

It's important to remember – the first port is referencing the port that is opened on the docker host, the 2nd port is referencing the container port.

#### Docker network
Talking about networking:
`docker network list`
Show the different docker networks and create a new bridge network (docker network create test)
If you want to wire 2 containers, you have to put them into the same docker network. But be careful, DNS resolution doesn't work in the default network!
create test network: `docker network create test`
Spin up a nginx: `docker run -d --name nginx --network test nginx:mainline`
Spin up a helper: `docker run -it --name helper --network test alpine:3.8`
From within the helper container, show the dns resolution : `nslookup nginx`
And connect to the webserver: `wget nginx`
Show the downloaded index.html page: `cat index.html`
Exit the pod and end the script

## Demo of Docker volumes

You can use volume-demo.sh script. 
It executes all necessary docker command for this demo and awaits a "enter" before it cleans up and goes to the next part.

### First part

Let's start simple and (bind) mount a directory into a container. Therefore assume you have a toolbox container and you need some environment in there (like a config file or ssh keys).

`docker run -it --mount type=bind,source=/home/vagrant,target=/mnt/home alpine:3.8`
Show the content of /mnt/home, which would be you're home directory

### Second part

Let's see what else you could do with a bind mount:
`docker run -it --mount type=bind,source=/home/vagrant,target=/etc alpine:3.8`
What happens? Well, our home directory is mounted to /etc. The original content of /etc is still there but hidden.

Of course you can also inject a nginx index page or any configuration this way, but that's part of the exercise ;)

### Hacker part

Let's see what else you could do with a bind mount:
`docker run -it --mount type=bind,source=/etc,target=/hostetc alpine:3.8`
In Container we are root and can e.g. see shadow file: `cat /hostetc/shadow`.

Even more fun, mount host / into the container and chroot inside container into it....

### Jenkins part

Let's move on to docker volumes. When working with a container, you might want to persist some data during runtime. For this example you will use a Jenkins and make it's home a volume.
`docker run -d -P --mount source=jenkins_home,target=/var/jenkins_home jenkins/jenkins:lts`
Next, get the ports and connect the port that forwards to container port 8080
On the jenkins logon page, you're asked for a password, run "docker logs \<container name>"  and obtain the logon token
Logon to the jenkins and choose "select plugins to install", select "none" (upper left corner) and continue. 
Create a user e.g 'root' with a simple password and finish the setup.
Now stop the container and restart it – obviously you're still able to logon with the credentials created before.
Finally, delete the container and with that also the RW layer and re-execute the docker run jenkins command. 
Connect to your new jenkins (get the ports before) and logon with the same credentials as you're still referring to the same jenkins home.
Inspect the jenkins_home volume (docker volume inspect jenkins_home) and go to it's path (probably you need to be root for that) and show the content.

Highlight, that the volume upon creation was empty. With the first start of jenkins, content was written to it. However when launching the 2nd jenkins container the content was not overwritten / re-initialized. So if you need to persist some initial data, a named volume might be useful.

Downsides: it's hard to move a volume to another host, but the k8s storage api will provide better ways of adding persistence.
