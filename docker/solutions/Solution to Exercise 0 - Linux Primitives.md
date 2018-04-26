## chroot
Call the man page:

```bash
man chroot
```

Create the `container` directory, change to user `root`, `cd` into it and run `chroot` for the first time:

```bash
mkdir -p $HOME/container
sudo -s
cd $HOME/container
chroot .
```

Please note, `$HOME` should still point to `/home/vagrant`. If it does not, please substitute $HOME with the absolute path.

Since `chroot` does not work without a `bash`, copy the binary to `$HOME/container/bin`:
```bash
mkdir $HOME/container/bin
cp /bin/bash $HOME/container/bin/
```

Run `chroot .` again.

The executable `bash` needs the following libraries:
```bash
ldd /bin/bash
       linux-vdso.so.1 =>  (0x00007fffdfe71000)
       libtinfo.so.5 => /lib/x86_64-linux-gnu/libtinfo.so.5 (0x00007f2a43840000)
       libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f2a43630000)
       libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f2a43260000)
       /lib64/ld-linux-x86-64.so.2 (0x00007f2a43c00000)
```

Copy them to a `lib` folder:

```bash
mkdir $HOME/container/lib
cp /lib/x86_64-linux-gnu/libtinfo.so.5 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libdl.so.2 $HOME/container/lib
cp /lib/x86_64-linux-gnu/libc.so.6 $HOME/container/lib
mkdir $HOME/container/lib64
cp /lib64/ld-linux-x86-64.so.2 $HOME/container/lib64
```
and try again:
```bash
chroot .
```
