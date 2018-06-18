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

# clean up to have a green field
clear


# some preparation
cat << _EOF > /tmp/_demo-02-unshare-1.sh
#!/bin/bash
source $dir/magic/demo-magic.sh -w2
DEMO_PROMPT="${GREEN}➜ ${RED}USER namespace ${CYAN}\W # "
TYPE_SPEED=50

p "# so who are we now?"
pe "whoami"
p "# we are root? let's check again"
pe "id -u"
p "# so we are really root. let's do some madness..."
pe "rm -f /boot/vmlinuz-*"
p "# seems that did not work"
pe "cat /etc/shadow"
p "# aren't we root? permission denied? what?"
pe "ls -al /proc/self/ns"
USER_NS=\$(readlink /proc/self/ns/user | cut -d : -f 2)
p "# if you watch closely, you will realize that the number for the user namespace has changed, it is now \$USER_NS"
pe "cat /proc/self/uid_map"
p "# uid 0 in our namespace has been remapped to the uid of user vagrant in kernel context"
p "# it appears as if we are root, but in fact, we got isolated from the usual user management"
wait
pe "ps -ef"
p "# we can still see all the processes from the system, so the isolation is still not perfect"
pe "exit"
_EOF


cat << '_EOF' > /tmp/_demo-02-unshare-2.sh
#!/bin/bash

GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
COLOR_RESET="\033[0m"

DEMO_PROMPT="${GREEN}➜ ${RED}PID namespace ${CYAN}$(basename $(pwd)) # ${COLOR_RESET}"
WAIT_SHORT=1
WAIT=2

echo -e "${DEMO_PROMPT}# you can see that the number of our PID namespace has changed"
sleep $WAIT
echo -e "${DEMO_PROMPT}ls -al /proc/self/ns/pid"
sleep $WAIT_SHORT
ls -al /proc/self/ns/pid
sleep $WAIT
echo -e "${DEMO_PROMPT}# and now, we have the PID isolation we were looking for"
sleep $WAIT
echo -e "${DEMO_PROMPT}ps -ef"
sleep $WAIT_SHORT
ps -ef
sleep $WAIT
echo -e "${DEMO_PROMPT}# note that the current shell, the one that started the new namespace, is PID 1"
sleep $WAIT
echo -e "${DEMO_PROMPT}exit"
sleep $WAIT_SHORT
exit
_EOF


# let the fun begin
p "# who are we?"
pe "whoami"
pe "id -u"
p "# our current process runs in (default) namespaces, we can see them in the /proc filesystem"
pe "ls -al /proc/self/ns"
p "# the numbers are pointers to kernel data structure denoting the namespace we are in"
USER_NS=$(readlink /proc/self/ns/user | cut -d : -f 2)
p "# try to remember the number of the user namespace $USER_NS"
p "# let's have a look at the user mapping in our namespace"
pe "cat /proc/self/uid_map"
p "# this shows us that UID 0 in our user namespace is mapped to UID 0 in the kernel and that this linear mapping is true for the following 2^32 user ids"
p "# let's start a bash in another user namespace"
p "unshare --map-root-user --user /bin/bash"
unshare --map-root-user --user /bin/bash /tmp/_demo-02-unshare-1.sh
p "# just to remember, the number of our current PID namespace"
pe "ls -al /proc/self/ns/pid"
p "# let's start another bash, this time in a new PID namespace"
p "sudo unshare --pid --fork --mount-proc /bin/bash"
sudo unshare --pid --fork --mount-proc /bin/bash /tmp/_demo-02-unshare-2.sh
p "# and that's it about Linux namespaces"

# now clean up the mess
rm -f /tmp/_demo-02-unshare-1.sh
rm -f /tmp/_demo-02-unshare-2.sh
cd ~
