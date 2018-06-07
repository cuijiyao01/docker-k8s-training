#!/bin/bash

if [ `id -u` -eq 0 ]; then
	echo "Please do not run this script as root."
	exit 1
fi

########################
# include the magic
########################
dir=$(realpath $(dirname $0))
PATH=$PATH:$dir/magic
source $dir/magic/demo-magic.sh -w2

TYPE_SPEED=50
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W $ "

CGROUP_NAME=mydemocpugroup

# clean up to have a green field
if [ -d /sys/fs/cgroup/cpu/$CGROUP_NAME ]; then
	sudo rmdir /sys/fs/cgroup/cpu/$CGROUP_NAME
fi
clear


# let the fun begin
echo -e "\033[1;31mfor this demo to work, please open a second terminal and run 'top' in it\nso that you can see the CPU consumption of all processes"
echo "press ENTER once you did that"
read

p "# let's start a process that uses a lot of CPU"
pe "dd if=/dev/zero of=/dev/null bs=1M &"
p "# you can see that this dd process is taking as much CPU as it can"
p "# let's start two more of those"
pe "dd if=/dev/zero of=/dev/null bs=1M &"
pe "dd if=/dev/zero of=/dev/null bs=1M &"
p "# they all should get a more or less equal amount of CPU shares"
p "# now, cgroups are managed through the /sys filesystem"
pe "ls -la /sys/fs/cgroup"
p "# here we can see the different resource types that can be controlled through cgroups"
p "# we focus on CPU"
pe "cd /sys/fs/cgroup/cpu"
p "# let's create a new cgroup that governs CPU usage"
pe "sudo mkdir mydemocpugroup"
pe "cd mydemocpugroup"
p "# this directory get's automatically populated with control files"
pe "ls -al"
p "# the processes that are controlled by this cgroup can be seen in the tasks file"
pe "cat tasks"
p "# right now, no process is under this cgroup's control"
p "# we put two of our three dd processes into this group, watch how this affects their CPU consumption"

sudo chmod 666 tasks cpu.shares
k=0
for i in `pidof dd`; do
        pe "sudo echo $i >> tasks"
        k=$((k+1))
        [ $k -eq 2 ] && break
done

p "# we can even control further how many CPU shares these processes get by altering the value in cpu.shares"
pe "cat cpu.shares"
p "# watch how the following command affects the CPU consumption of our dd's"
pe "sudo echo 10 > cpu.shares"
p "# this is used to resource limit to individual processes or process groups - very useful for containers"
p "# before we finish, we better stop those dd's..."
pe "killall dd"


# now clean up the mess
sudo rmdir /sys/fs/cgroup/cpu/$CGROUP_NAME 
cd ~
