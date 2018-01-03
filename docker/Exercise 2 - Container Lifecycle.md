# Exercise 2 - Container lifecycle

In this exercise, you will experience the container lifecycle, connect to running container instances and check log files for potential problems.

## Step 0: Creating a container

Create and run a new [busybox](https://hub.docker.com/_/busybox/) container. Make sure you let this container run interactively and connect a pseudo terminal to it.

Inside your container, use the `top` command to find out which program is running as process with the PID 1 and if there are other processes. Do not exit from top, let it keep on running.

## Step 1: Detaching from containers

Detach from your _busybox_ container. Check with `docker ps` what state your container is in and find out its ~~silly~~ friendly name.

## Step 2: Executing commands in containers

Use the `docker exec` command to start another shell (`/bin/sh`) in your container. Use `ps` to find out how many programs are running in your container now. Once finished, detach from your container again.

## Step 3: Reattaching to Containers

Reattach to your container with the `docker attach` command and see what will appear on your screen.

**Bonus question:** Since you have several running processes in your container now, two things might show up on your screen upon reattaching - the output of the `top` command that you detached from in step 1 or an empty shell that you detached from in step 2. What will appear on your screen and why?

Exit from your container by ending top (simply press Q for Quit) and issuing the `exit` command to its shell.

## Step 4: Getting logs of a container

Use `docker logs` to display the logs of the container you just exited from. What do you see?

## Step 5: Killing Containers

Run a new container from the [nginx](https://hub.docker.com/_/nginx/) image. Make sure you start this container in detached mode. Since the container was started in detached mode it will continue to run until it gets explicitly stopped. Use the `docker stop` command to end it.

## Step 6: Cleaning up

Get a list of all currently running and already exited containers. Remove them with `docker rm`.

**Hint:** To clean up _all_ containers on your host, you can combine the `docker rm` with the `docker ps` command: `docker rm $(docker ps -aq)`. **Use with caution.**
