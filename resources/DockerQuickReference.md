# Docker quick reference

## Basic Commands

```
docker --help
docker <cmd> --help
docker info

docker images   : list local images
docker run      :create and run container from image with command (optional)
        -d      : as deamon
        -P      : all exposed ports mapped to host (random high)
        -p 80:5000  : map port 5000 (exposed from image) to 80 on host (virtualbox)
        -rm     : delete container after completion
        --tmpfs : mount a /tmp file system
docker ps       : list running containers
        -s      : show size used by container on read-write file system; 
                 'virtual' is the read-only shared part     
        -a      : show all containers, not just running ones
docker logs [-f]: show log of running container (by name); -f: tail
                  example: docker logs <cont-id> 
docker top      : look at processes
docker inspect  : internal info on container
docker stop     : stop container
docker rm       : remove a stopped container

docker pull <image> : load a prebuilt image from a remote repo 

docker commit <container-id> commit-name  : commit changed state to image

docker stats <container-id>: shows CPU, mem, io etc. 
                - curl -s https::/localhost:2375/v1/containers/<cont-id>/stats
                  shows lots more data as a stream (stop with ctrl-C)
```

## Building Images

Dockerfile		: specifies build commands
.dockerignore : spec files to be ignored from image root; at least ".git"

see also
- https://docs.docker.com/engine/reference/builder/
- https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/ 


-----------------------------------------------------
### Dockerfile commands

```
FROM  img:ver : specify start image and optionally version (or 'latest')
WORKDIR       : sets working directory (= cd) during build; creates it (path) if not exists
RUN <cmd>     : run a command during build, mostly mkdir, ... apt-get to install stuff
CMD           : specify command / software to be run inside the container (runtime) on startup
                (shell form or JSON form)
EXPOSE <port> : container will listen on (local) port; mapped in "docker run -p target:port". 
                Can specify protocal "port/prot"; TCP is default, UDP is possible
COPY f t      : copy local file to target t
ADD src dest  : same as COPY but src can be tar.gz or url that will be unpacked
ENV n=v n=v   : set environment vars (use \ to continue the line; use one ENV so get only one cache layer)
VOLUME <dir>  : expose mount point (e.g. VOLUME /data/jenkins) that can be shared with other containers
                (shared directory); the local mount point must exist (created before with "WORKDIR ..." or
                "RUN mkdir -p /data/jenkins"); host directory is declared / assigned at container runtime
                by the "docker run -v .." argument
USER          : switch to given user
```



## Managing data in containers

- "Data volumes are designed to persist data, independent of the container’s life cycle. "
This can be a file or more generally a directory and is then mounted. Data Volumes bypass the Union File System (which is per container).
- A volume creates / mounts a directory in the container to a directory in the host VM.
- Docker keeps volumes in the host VM at: `/var/lib/docker/volumes/`. This is inside the VM in virtualbox, (not visible in the docker console window.)
- A volume can be mounted into multiple containers and is then shared. 
- Volumes are created by `docker volume create` or as parameter of a `docker run -v ...`
- Normally volumes are stored on the docker host VM but you can also use a 'volume driver' from a provider that e.g. offers network file storage (e.g. on AWS)
- "tmpfs mount" can be used to store non-persistent state (in-memory / local fs)
- Volume use cases:
  - Read access of static files shared between all the containers (e.g. static mimes)
  - History and config shared between VMs (needs unique work dirs, e.g. for jenkins)
- Examples
  - `$ docker run --rm -v test:/opt/test ubuntu bash -c 'echo $HOSTNAME >> /opt/test/hostnames'` 




## Questions and Answers 

- Difference between images and containers?
  - Image is a template that is turned into a container. Container is image + read-write file system. Stopped container persists the file system changes and other settings - and it can be restarted.
- How much space does an inactive container need?
  - Totally depends on the write space of the file system. 
- Why keep old containers around and not just the image?
  - Only if you want to restart them or want to analyze issues, e.g. look at logs. Otherwise DELETE!
- Why does each statement in a Dockerfile create another layer? 
  - Why: ... ???
  - What it means: Each layer is totally independent from the others, i.e. they can and will be shared among all containers (in memory)
  - When you do a 'docker pull', each layer of an image is pulled separately and exists only once in the cache.
- How see hierarchy of layers in an image (with command, date created and size)?
  - `docker history <image_id>`
- How ssh into a running container so I can 'continue' and try out commands 
  - `docker exec -it /bin/bash ...`
- Where are docker files stored? In the host VM. 
  - linux: /var/lib/docker/  .../containers,  .../aufs/layers, ...  
- Shared data?
  - /data is mounted into each container?



### Important scripts & snippets

Show container IDs
- `$ docker ps -q` 

Clean up all exited containers
- `$ docker rm -v $(docker ps -a -q -f status=exited)`
- `$ docker ps -aq | xargs docker rm`

Connect into a running container and start a bash
- `$ docker exec -it <container-id> /bin/bash`

Run a docker container to get a result and return code
- `$ docker run <ubuntu-container> /bin/cat/ /etc/passwd `
- `$ echo $? `
