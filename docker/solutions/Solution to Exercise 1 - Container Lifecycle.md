# Solution to Exercise 1 - Container lifecycle

## Step 0: Creating a container

Start a container with:

```bash
docker run -it busybox
top
```

You will now see the processes inside your container:

```
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
    1     0 root     S     1248  0.0   1  0.0 sh
   10     1 root     R     1240  0.0   0  0.0 top
```

## Step 1: Detaching from containers

To detach from container use `Ctrl+p` and then `Ctrl+q`. You may then do `clear` to clean your terminal.
When doing `docker ps`, you'll get something like (your container ID and Name will be different):

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
567d71edcab0        busybox             "sh"                5 minutes ago       Up 5 minutes                            vivid_shirley
```

## Step 2: Executing commands in containers

Start another shell into the container by issueing the following command. You will need your container's ID or its simple name.

```bash
docker exec -it <your container ID or Silly_Name> /bin/sh
```

Using the example above, it would be:

```bash
docker exec -it 567d71edcab0 /bin/sh
```

Perform `ps` or again `top` to see the processes that run in there.
If you started top, quit by pressing `q`. Detach from container using `Ctrl+p` and then `Ctrl+q`.

## Step 3: Reattaching to containers

Reattach with the following command. Again, you will need your container's ID or friendly name:

```bash
docker attach <your container ID or Silly_Name>
```

With the example above:

```bash
docker attach 567d71edcab0
```

**Bonus answer:** You'll see that you're still running the `top` command from Step 0 you had on screen before performing Step 1.
As per [documentation](https://docs.docker.com/engine/reference/commandline/attach/) `docker attach` will always connect to `ENTRYPOINT/CMD` process, i.e. the special process running with PID 1. So no matter how often you perform `docker attach`, you'll always get the terminal from Step 0.  The other terminals are lost once you detached from them.

## Step 4: Getting logs of a container

`docker logs <your container ID or Silly_Name>`  displays the logs present at the time of execution as [documented](https://docs.docker.com/engine/reference/commandline/logs/). In our case it displays the `top` output, and if you run this command several times while container still runs, you'll see the output changes.

## Step 5: Killing containers

Run a new container from the nginx image:

```bash
docker run -d nginx
```

Perform `docker ps` to see the running containers.
Perform `docker stop <your container ID or Silly_Name>` (e.g. `docker stop 94cb514de45e`) to end your container.

# Step 6: Cleaning up

Unless you want to use the command `docker rm $(docker ps -aq)` (which REALLY deletes ALL the containers - and this might be dangerous !), you may also perform: `docker ps -a` to see a list with all the running & exited containers and then delete multiple of them with one command: `docker rm <container1> <container2> <containerN>`.

**Shortcut:** If you want to remove all containers, you can do it with these commands (use with caution).

```bash
docker container prune
```

or

```bash
docker rm $(docker ps -aq)
```
