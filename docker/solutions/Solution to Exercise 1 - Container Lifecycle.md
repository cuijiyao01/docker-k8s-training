# Solution to Exercise 1 - Container lifecycle

## Step 0: Creating a container

Start a container with:

```bash
docker run -it busybox
top
```

You will now see the processes inside your container:

```bash-output
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
    1     0 root     S     1248  0.0   1  0.0 sh
   10     1 root     R     1240  0.0   0  0.0 top
```

## Step 1: Executing commands in containers

Start a new nginx container in detached mode and get its name:

```bash
docker run -d nginx
docker container list
```

Start another shell into the container by issuing the following command. You will need your container's ID or its simple name.

```bash
docker exec -it <your container ID or Silly_Name> /bin/sh
```

Install `ps` within the container invoke it to see the processes running in the context of the container.

```bash
apt-get update && apt-get install -y procps
ps -ef
```

Once finished, exit from the shell. Check whether or not the container is still running.
```bash
docker container list -a
```

## Step 2: Getting logs of a container

`docker logs <your container ID or Silly_Name>`  displays the output of PID 1 as [documented](https://docs.docker.com/engine/reference/commandline/logs/). Since PID 1 runs an nginx webserver, there is nothing to view (yet).

## Step 3: Killing containers

Perform `docker ps` or `docker container list` to see the running containers.
Perform `docker stop <your container ID or Silly_Name>` (e.g. `docker stop 94cb514de45e`) to end your container.

## Step 4: Clean up

Unless you want to use the command `docker rm $(docker ps -aq)` (which REALLY deletes ALL the containers - and this might be dangerous !), you may also perform: `docker ps -a` to see a list with all the running & exited containers and then delete multiple of them with one command: `docker rm <container1> <container2> <containerN>`.

**Shortcut:** If you want to remove all containers, you can do it with these commands (use with caution).

```bash
docker container prune
```

or

```bash
docker rm $(docker ps -aq)
```
