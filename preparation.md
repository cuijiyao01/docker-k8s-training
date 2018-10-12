# Environment Setup and Prerequisites

This page describes the necessary **preparation steps** before the course and as well what you should fullfill as **prerequisites** before taking this course - with points to sources for that information.

## Environment setup

In the course you will use a Linux VM (Ubuntu based) that contains all the needed tools so that we lose no time for environment setup.
Follow the instructions on the [Getting Started with the k8s training VM Image](https://github.wdf.sap.corp/cloud-native-dev/k8s-training-vm/blob/master/VMImage_GettingStarted.md) page to install VMWare (VirtualBox= Blacklisted !) and download and configure the VM image.

Once you have your VM up and running, clone this repository to the VM:

```bash
git clone https://github.wdf.sap.corp/slvi/docker-k8s-training.git
```

## Prerequisite knowledge

- **Linux:** You should have a basic knowledge of Linux. If you are not familiar with Unix/Linux, you can check out [Learn Unix in 10 Minutes](https://csg.sph.umich.edu/docs/hints/learnUNIXin10minutes.html) or [Introduction to Linux](http://tldp.org/LDP/intro-linux/html/index.html) or with a little more detail [Learn Linux in 5 Days](https://linuxtrainingacademy.com/wp-content/uploads/2016/08/learn-linux-in-5-days.pdf) (it actually takes a lot less time). There is also a very good [Linux Commandline Cheat Sheet](https://www.linuxtrainingacademy.com/wp-content/uploads/2016/12/LinuxCommandLineCheatSheet.pdf).
- **bash**: We will occasionally work with shell scripts, bash in particular, or at least have to read them. You can look e.g. look at this [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial). 
- **vi**: Sometimes you will have to SSH into a container / remote machine where there is only vi available as editor. If you not familiar or rusty with vi, you can check out the [vi cheat sheet](https://github.wdf.sap.corp/slvi/docker-k8s-training/blob/master/resources/vi_cheat_sheet.pdf). We highlighted the most important commands.
- **yaml**: YAML (YAML Ain't Markup Language) is a human-readable data serialization language that is commonly used for configuration files. It is THE notation used in Kubernetes. See the [wikipedia article](https://en.wikipedia.org/wiki/YAML) or this [YAML cheat sheet](https://lzone.de/cheat-sheet/YAML).
- **small tools to know**: It would be good to know some small tools that we may use: apt-get, curl, wget, ...
- **networking basics**: You should know what IP addresses are, how subnetting works, what routes are good for and what happens if you forward a port. We started to prepare an overview [here](./resources/BasicNetworkKnowhow.md).
