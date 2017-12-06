# Exercise 2 - Container lifecycle

In this exercise, you will experience the container lifecycle, connect to running container instances and check log files for potential problems.

## Step 0: Creating a container

Create and run a new [busybox](https://hub.docker.com/_/busybox/) container. Make sure you let this container run interactively and connect a pseudo terminal to it.

Inside your container, use the `top` find out which program is running as process with the PID 1 and if there are other processes. Do not exit from top, let it keep running.

## Step 1: Detaching from containers

Detach from your busybox container. Check with `docker ps` what state your container is in and find out its ~~silly~~ friendly name.

## Step 2: Executing commands in containers

Use the `docker exec` command to start another shell in your container. Use `ps` to find out how many programs are running in your container now. Once finished, detach from your container again.

## Step 3: Reattaching to Containers

Reattach to your container with the `docker attach` command and see what will appear on your screen.

**Bonus question:** Since you have several running processes in your container now, two things might show up on your screen upon reattaching - the output of the `top` commandthat you detached from in step 1 or an empty shell that you detached from in step 2. What will appear on your screen and why?

## Step 4: Killing Containers

Detach from your container and use the `docker stop` command to kill it.

## Step 5: Cleaning up

Get a list of all currently running and already exited containers. Remove them with `docker rm`.

**Hint:** To clean up all containers on your host, you can combine the `docker rm` with the `docker ps` command: `docker rm $(docker ps -aq)`. **Use with caution.**
