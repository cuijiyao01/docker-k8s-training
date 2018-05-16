# Solution to Exercise 0 - Linux Primitives

In this exercise you will spin up a process inside a container by using only the Linux primitives that made container environments possible.

## Step 0: chroot
Call the man page:

```bash
man chroot
```

Create the `container` directory, `cd` into it, change to user `root` and run `chroot` for the first time:

```bash
mkdir -p $HOME/container
cd $HOME/container
sudo -s
chroot .
```

**Note:** This will (intentionally) fail with the following error message:

```
chroot: failed to run command ‘/bin/bash’: No such file or directory
```


## Step 1: prepare your chroot environment first

Since `chroot` does not work without a shell and all the files required to start it, we will need to create the basic directory layout in our container and copy the BASH binary into it.

```bash
mkdir -p $HOME/container/bin $HOME/container/lib $HOME/container/lib64 $HOME/container/proc
cp /bin/bash $HOME/container/bin
```

Use `ldd` to find out which libraries need to be copied into the container as well.

```bash
ldd $HOME/container/bin/bash
```

Copy the required libraries into the appropriate directories. Note that `ld-linux-x86-64.so.2` goes into the `lib64` directory, the rest goes into `lib`.

```bash
cp /lib/x86_64-linux-gnu/libtinfo.so.5 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libdl.so.2 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libc.so.6 $HOME/container/lib
cp /lib64/ld-linux-x86-64.so.2 $HOME/container/lib64
```

In order to have a working `ls` command, we have to copy some more files:

```bash
cp /bin/ls $HOME/container/bin
cp /lib/x86_64-linux-gnu/libselinux.so.1 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libpcre.so.3 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libpthread.so.0 $HOME/container/lib
```

Try to change root again:

```bash
cd $HOME/container
sudo -s
chroot .
```

In this new shell, try to look at which files are there and which directories you can see.

You can leave the chroot session as expected via `exit`.

## Step 2: use unshare to run a process in a seperate namespace

Make sure you are root for this step.

```bash
sudo -s
```

Use the unshare command to run a BASH in a new namespace.

```bash
unshare --pid --mount-proc --fork /bin/bash
```

Use the `ps` command to look at the running processes.

```bash
ps -ef
```

You should only get a list of two processes: your shell (with PID 1) and the `ps` command itself. The output should look something like this:

```bash
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  2 12:46 pts/6    00:00:00 /bin/bash
root        41     1  0 12:46 pts/6    00:00:00 ps -ef
```

Exit the namespaced shell with `exit`.

## Step 3: combine unshare and chroot to run a container

You can now combine the unshare and the chroot command to run a container with isolated namespaces and an isolated filesystem.

```bash
unshare --pid --mount-proc --fork chroot $HOME/container /bin/bash
```

Since we did not populate our container directory with the files required to run the `ps` command, you just have to believe that the process isolation still works.
