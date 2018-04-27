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
