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
if [ -d ~/bind ]; then
    if [ -d ~/bind/b ]; then
        sudo umount ~/bind/b
    fi
    rm -rf ~/bind
fi
clear


# let the fun begin
p "# let's create some directories that we use to demonstrate the bind-mount"
pe "mkdir -p ~/bind"
pe "cd ~/bind"
pe "mkdir a"
pe "mkdir b"
p "# let's put some files in them"
pe "touch a/sap"
pe "touch b/walldorf"
p "# each of these directories has exactly one file in it"
pe "ls -al a"
pe "ls -al b"
p "# let's bind-mount a on b"
pe "sudo mount -o bind a b"
p "# now what will be in b?"
pe "ls -al b"
p "# walldorf is gone and sap showed up"
p "# let's write to b"
pe "touch b/st-leon-rot"
pe "ls -al b"
p "# this file will now show up in a as well"
pe "ls -al a"
p "# thanks to the bind-mount, both directories a and b now point to the same location on the disk"
p "# everything that gets written to a shows up in b and vice versa"
p "# but the original content of b is not gone, it just no longer accessible"
p "# let's unmount"
pe "sudo umount b"
p "# the original file is still there"
pe "ls -al b"
p "# and everything we write to b during the bind-mount ended up in a"
pe "ls -al a"
# now clean up the mess
cd ~
sudo umount ~/bind/b 2>/dev/null

