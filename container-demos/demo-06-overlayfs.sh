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
if [ -d ~/overlay ]; then
    if [ -d ~/overlay/merged ]; then
        sudo umount ~/overlay/merged
    fi
    rm -rf ~/overlay
fi
clear


# let the fun begin
p "# let's create some directories that we will merge using the overlay filesystem"
pe "mkdir -p ~/overlay"
pe "cd ~/overlay"
pe "mkdir ro1"
pe "mkdir ro2"
pe "mkdir ro3"
p "# these directories become our read-only lower layers"
p "# let's put some files in them"
pe "touch ro1/bayern"
pe "touch ro2/muenchen"
pe "touch ro3/beckenbauer"
p "# each of these directories has exactly one file in it"
p "# we now need the uppermost layer in our directory stack - the one that will be writable"
pe "mkdir rw"
p "# we also need a workdir (required by the overlay fs)..."
pe "mkdir work"
p "# ... and a mountpoint of course"
pe "mkdir merged"
p "# we now mount all the directories together into one overlay stack"
pe "sudo mount -t overlay overlay -o lowerdir=ro3:ro2:ro1,upperdir=rw,workdir=work merged"
p "# in merged, we should now see the files from ALL the directories"
pe "ls -al merged"
p "# let's create and delete files"
pe "touch merged/hoeness"
pe "rm -f merged/beckenbauer"
pe "ls -al merged"
p "# so beckenbauer left and hoeness came"
p "# we were able to write into the merged directory, these changes will end up in the upperdir (the read-write layer)"
pe "sudo umount merged"
pe "ls -al ro3"
p "# beckenbauer is still in the lower layer as it was read-only"
pe "ls -al rw"
p "# the new file hoeness went into the this directory"
p "# in addition, a character special device beckenbauer was created"
p "# this is how a file from the lower layers will be marked as deleted"

# now clean up the mess
cd ~
sudo umount ~/overlay/merged 2>/dev/null

