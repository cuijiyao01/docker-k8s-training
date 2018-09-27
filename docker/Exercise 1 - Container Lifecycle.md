# Exercise 2 - Container lifecycle

In this exercise, you will experience the container lifecycle, connect to running container instances and check log files for potential problems.

## Step 0: Creating a container

Create and run a new [busybox](https://hub.docker.com/_/busybox/) container. Make sure you let this container run interactively and connect a pseudo terminal to it.

Inside your container, use the `top` command to find out which program is running as process with the PID 1 and if there are other processes. If you are done exploring your container, just exit from it.

## Step 1: Executing commands in containers

Start a new [nginx](https://hub.docker.com/_/nginx/) container. Make sure you start it in detached mode.

Use the `docker exec` command to start another shell (`/bin/sh`) in your container. Use `ps` to find out how many programs are running in your container now. Once finished, exit from the shell. Check whether or not the container is still running.

## Step 2: Getting logs of a container

Use `docker logs` to display the logs of the container you just exited from. What do you see?

## Step 3: Killing Containers

Use the `docker stop` command to end your nginx container.

## Step 4: Cleaning up

Get a list of all currently running and already exited containers. Remove them with `docker rm`.

**Hint:** To clean up _all_ containers on your host, you can combine the `docker rm` with the `docker ps` command: `docker rm $(docker ps -aq)`.  **Use with caution.**
