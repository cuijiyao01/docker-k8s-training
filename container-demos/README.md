# Scripts to demo linux primitives
The scripts in this folder are designed to explain the behavior and concepts of various linux primitives used to create & isolate a container.

All scripts run fully automated until the end. However you can pause and continue with some keyboard-shortcuts. 

**Use `ctrl + s` to pause and `ctrl + q` to continue script execution.**

## 01 chroot
The script will do the setup of a minimal environment (basically only a bash + libs) and chroot into it.

Explain the importance of libraries to binaries. Without the corresponding libs in their respective directories, no binary will work. And after all, (container) processes are based on binaries.

It is also worth to mention, that the file system you chroot into is the foundation of every container. Luckily in most cases you can rely on others building the base images with all binaries and libs. The only thing you have to do as a developer is move your own stuff into it.
 
So if there is something called centos or ubuntu later, remember that this is no full-fledged OS but only a collection of bins/libs making your life a lot easier.

## 02 ushare namespaces
The script will fork a new process with a separate PID namespace. It'll also explore the space of the newly created processes. Please note, the demo does not use chroot. 

With namespaces you can isolate aspects of a processes or process groups (like the process tree or networking stack). As mentioned on the previous slide, this is another building block for Linux containers to work.

## 03 cgroups
The script will demonstrate how cgroups can be used to control processes. The example is focusing on CPU usage.

Docker as well as Kubernetes can make use of cgroups to manage resources in a container environment.

## 04 seccomp (based on Docker for convenience)
The script will demonstrate how seccomp profiles can be used to control access to the kernel via syscalls. To make things easier, this demo is based on Docker so it might give already an impression on how Docker works. 

While the syscalls are blocked in this demo, it is worth to mention, that you can also implement trap wires to inform the underlying platform of what's going on and potentially invoke countermeasures.
