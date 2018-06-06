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
if [ -d ~/container101 ]; then
	if [ -d ~/container101/proc ]; then
		sudo umount ~/container101/proc
		rmdir ~/container101/proc || exit 2
	fi
	if [ -d ~/container101/dev ]; then
		sudo umount ~/container101/dev
		rmdir ~/container101/dev || exit 2
	fi
	rm -rf ~/container101
fi
clear


# let the fun begin
p "# let's create an empty directory which will become our container"
pe "mkdir -p ~/container101"
pe "cd ~/container101"
p "# of course we need to have a place to put our binaries"
pe "mkdir bin"
p "# we copy the BASH into our future container"
pe "cp /bin/bash ./bin"
p "# wait, BASH certainly needs some libraries to run"
pe "ldd bin/bash"
p "# so we copy those too"
pe "mkdir lib lib64"
pe "copywithlib.sh /bin/bash"
p "# BASH alone does not do too much, so we copy some more binaries"
pe "copywithlib.sh /bin/ls"
pe "copywithlib.sh /bin/ps"
p "# for the ps command to work, we need the /proc filesystem in our container"
pe "mkdir proc && sudo mount -t proc proc proc"

# before we chroot into the directory, we silently copy the demo-magic script over
# and create a second script to run so we can keep up our illusion
cp $dir/magic/demo-magic.sh bin
copywithlib.sh /bin/sed > /dev/null
copywithlib.sh /usr/bin/pv > /dev/null
mkdir dev && sudo mount -t devtmpfs udev dev

cat << _EOF > bin/_demo-01-chroot.sh
#!/bin/bash

source /bin/demo-magic.sh -w2
DEMO_PROMPT="${GREEN}➜ ${RED}chroot ${CYAN}\W # "
TYPE_SPEED=50

p "# now we are in our chrooted container"
p "# which directory are we in?"
pe "pwd"
p "# so which files can we see?"
pe "ls -al /"
p "# these are just the files we copied before, the rest of our system has become invisible"
pe "cd .."
pe "cd .."
pe "ls -al"
p "# we cannot break out from here as we are already at the topmost level"
p "# which processes can we see?"
pe "ps -ef"
p "# we can still see all processes, so our isolation is still incomplete"
pe "exit"
_EOF

p "# so let's chroot into the container (which we need to do with sudo)"
p "sudo chroot ."
sudo chroot . /bin/bash /bin/_demo-01-chroot.sh

# now clean up the mess
sudo umount proc
sudo umount dev
rmdir dev
cd ~
