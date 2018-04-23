# CHROOT, unshare and a lot of typing
Before you get used to the convenience of the Docker cli, it is important to understand how Linux containers are working under the hood of Docker.

In this exercise you will use the `chroot` command to create file system isolation. You will also learn to isolate the process ID namespace using `unshare`.

## chroot
What does `chroot` do? Well, take a look at the man-page and find out.

Now that you know, how it works, give it a try. As user `vagrant` create a new directory `container` in your `$HOME`. Change to user `root` and make the `container` directory your new `/` with `chroot`.

Has it worked? If not, try to solve the error reported and if a binary is missing, copy it to your `container` directory. Does it work now?

...

Well, an executable needs also some libraries. Use `ldd` to find out what's missing and add them to your `container` directory.
