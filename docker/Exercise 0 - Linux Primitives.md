# Exercise 0 - chroot, unshare and lots of typing

Before you get used to the convenience of the [**Docker** Command Line Interface (CLI)](https://docs.docker.com/engine/reference/commandline/cli/), it is important to understand how Linux containers are working under the hood.

In this exercise you will use the `chroot` command to create file system isolation. You will also learn to isolate the process ID namespace using `unshare`.

## Step 0: chroot into a directory
What does `chroot` do? Well, take a look at the man-page and find out.

Now that you know, how it works, give it a try. As user `vagrant` create a new directory `container` in your `$HOME`. Change to user `root` and make the `container` directory your new `/` with `chroot`. **Do not be surprised if it does not work... yet.**

## Step 1: prepare your chroot environment first

Since chroot isolates a directory from the rest of the file system, the process to be started must be present inside the chroot directory tree - and so do all the libraries and accompanying files that binary needs. For this, we need to create the basic directory layout of the Linux file system within your chrooted directory.

Create the directories `bin`, `lib`, `lib64` and `proc` in your `container` directory. Copy the binary for BASH into `container/bin`. Use `ldd` to find out, which libraries are needed to run bash and copy them into the appropriate directories inside your container. Note that `ld-linux-x86-64.so.2` goes into the `lib64` directory, the rest goes into `lib`.

Repeat this process for `/bin/ls` and all the libraries it needs.

Try to change root into your container directory again and use `ls` and `cd` to navigate around and look at the files and directories that are there.

## Step 2: use unshare to run a process in a seperate namespace

Make sure you are `root` for this step.

In order to create run a process in a new namespace, we need to use the command `unshare`. Look at its manpage to find out how to use it. We want to run a BASH in a new PID namespace, so that options that need to be passed to unshare are `--pid`, `--mount-proc` and `--fork`.

Once your shell is started in a new namespace, use the `ps` command to look at the processes visible to your shell. How many are those? Which is the process with PID 1?

## Step 3: combine unshare and chroot to run a container

You can now combine the unshare and the chroot command to run a container with isolated namespaces and an isolated filesystem.
