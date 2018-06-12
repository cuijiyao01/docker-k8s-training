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

# check the prerequisites
DOCKER=$(which docker)
if [ -z "$DOCKER" ]; then
	echo -e "${RED}For this demo, we will need Docker but the docker executable could not be found."
	echo "Please install and set-up Docker before running this command."
	exit 1
fi

_DOCKERINFO=$(docker info)
if [ $? -ne 0 -o -z "$_DOCKERINFO" ]; then
	echo -e "${RED}For this demo we will need Docker but 'docker info' did not work."
	echo "Please install and set up Docker before running this demo."
	exit 1
fi

GO=$(which go)
if [ -z $GO ]; then
	echo -e "${RED}For this demo, we will need the GO programming language but it could not be found."
	echo "Please install the golang packages before running this script."
	exit 1
fi

_GOVERSION=$(go version)
if [ $? -ne 0 -o -z "$_GOVERSION" ]; then
	echo -e "${RED}For this demo we will need the GO programming language but 'go versin' did not work."
	echo "Please install and set up golang before running this demo."
	exit 1
fi


DOCKER_IMG="debian:8-demo-seccomp"

# clean up to have a green field
docker image rm $DOCKER_IMG
[ -d ${dir}/dbuild ] && rm -rf ${dir}/dbuild
[ -d ${dir}/seccomp ] && rm -rf ${dir}/seccomp
rm -f ${dir}/helloworld.go ${dir}/helloworld
clear

# do some preparation
echo -e "\033[1;32mfor this demo, we will need to prepare some Docker images"
echo -e "Please wait a moment...$COLOR_RESET\n"

mkdir ${dir}/dbuild
cp /usr/bin/pv ${dir}/dbuild
cp $dir/magic/demo-magic.sh ${dir}/dbuild

cat << '_EOF' > ${dir}/dbuild/_demo01.sh
#!/bin/bash

source /bin/demo-magic.sh -w2
DEMO_PROMPT="${GREEN}➜ ${RED}container ${CYAN}\W # "
TYPE_SPEED=50

p "# so here we are in our Docker container"
sleep 2
p "# who are we"
sleep 2
pe "whoami"
sleep 2
pe "id -u"
p "# we are root"
sleep 2
p "# we can do whatever we want"
sleep 2
p "# run commands"
sleep 2
pe "echo Hello World"
sleep 2
p "# touch files"
sleep 2
pe "touch /tmp/myfile"
sleep 2
p "# write to files"
sleep 2
pe "echo 'I was here' > /usr/share/nonsense"
sleep 2
p "# read from files"
sleep 2
pe "cat /usr/share/nonsense"
sleep 2
p "# we can even delete files"
sleep 2
pe "rm -f /usr/share/nonsense"
sleep 2
p "# or remove directories"
sleep 2
pe "ls -ald /tmp/_delete_me"
sleep 2
pe "rmdir /tmp/_delete_me"
sleep 2
pe "ls -ald /tmp/_delete_me"
sleep 2
p "# but there are two things we cannot do..."
sleep 2
p "# that would be creating directories"
sleep 2
pe "mkdir /tmp/mydir"
sleep 2
p "# or even changing directories"
sleep 2
pe "cd /usr/lib"
sleep 2
p "# the Linux kernel intercepts the system calls mkdir(2) and chdir(2) and denies them"
sleep 2
pe "exit"
_EOF

chmod +x ${dir}/dbuild/_demo*.sh

cat << '_EOF' > ${dir}/dbuild/Dockerfile
FROM debian:jessie
COPY demo-magic.sh /bin
COPY pv /bin
COPY _demo01.sh /bin
RUN mkdir /tmp/_delete_me
_EOF

docker build -t $DOCKER_IMG ${dir}/dbuild

cat << '_EOF' > ${dir}/helloworld.go
package main

import (
	"fmt"
)

func main() {
	fmt.Println("Hello World")
}
_EOF

mkdir ${dir}/seccomp
cat << '_EOF' > ${dir}/seccomp/deny-dir.json
{
	"defaultAction": "SCMP_ACT_ALLOW",
	"architectures": [
		"SCMP_ARCH_X86_64",
		"SCMP_ARCH_X86",
		"SCMP_ARCH_X32"
	],
	"syscalls": [
		{
			"name": "mkdir",
			"action": "SCMP_ACT_ERRNO",
			"args": []
		},
		{
			"name": "chdir",
			"action": "SCMP_ACT_ERRNO",
			"args": []
		}
	]
}
_EOF

cd ${dir}
clear

# let the fun begin

p "# with seccomp, we can allow, deny or trap individual system calls"
p "# in case you do not know what system calls are: with them programs interact with the operating system"
p "# Linux has around 340 system calls"
p "# let's have a look at a simple \"hello world\" program"
pe "go build helloworld.go"
pe "./helloworld"
p "# we can use strace to see the system calls this program performs"
pe "strace -c ./helloworld"
p "# you can see one call to write(2) which is responsible for writing the message to the screen"
p "# of course, a shell like this can and will fire hundreds of system calls"
p "# we will now start a shell in a Docker container"
p "# that container will run with a seccomp profile which will block two of those many system calls"
p "docker run --security-opt seccomp=seccomp/deny-dir.json --security-opt=\"no-new-privileges\" debian:jessie"
docker run --name seccomp-demo --security-opt seccomp=${dir}/seccomp/deny-dir.json --security-opt="no-new-privileges" $DOCKER_IMG /bin/_demo01.sh
p "# if you want to know how that seccomp profile looked like, have a look at the file ${dir}/seccomp/deny-dir.json"

# now clean up the mess
docker rm seccomp-demo > /dev/null 2>&1
docker image rm $DOCKER_IMG > /dev/null 2>&1
rm -rf ${dir}/dbuild
rm -f ${dir}/helloworld.go ${dir}/helloworld
cd ~
