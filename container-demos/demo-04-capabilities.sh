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

DOCKER_IMG="debian:8-demo-1"

# clean up to have a green field
docker image rm $DOCKER_IMG
[ -d ${dir}/dbuild ] && rm -rf ${dir}/dbuild
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

p "# so we are in a Docker container"
sleep 2
p "# who are we"
sleep 2
pe "whoami"
sleep 2
pe "id -u"
p "# so we are root"
sleep 2
p "# what is our hostname"
sleep 2
pe "hostname"
sleep 2
p "# that is a stupid hostname, let's change it"
sleep 2
pe "hostname kuala-lumpur"
sleep 2
p "# what? we ARE root, aren't we?"
sleep 2
p "# Docker by default deprives root of his ability to change hostnames, date/time, etc."
sleep 2
p "# so yes, we are root but we no longer can do everything"
sleep 2
pe "exit"
_EOF

cat << '_EOF' > ${dir}/dbuild/_demo02.sh
#!/bin/bash

source /bin/demo-magic.sh -w2
DEMO_PROMPT="${GREEN}➜ ${RED}container ${CYAN}\W # "
TYPE_SPEED=50

p "# this time we explicitly added the capability SYS_ADMIN to this container"
sleep 2
p "# what is our hostname this time?"
sleep 2
pe "hostname"
sleep 2
p "# still not great, let's try and change it again"
sleep 2
pe "hostname kuala-lumpur"
sleep 2
p "# no error, so did it work?"
sleep 2
pe "hostname"
sleep 2
p "# it did indeed work"
p "# so with CAP_SYS_ADMIN, root got one of his super-powers back"
sleep 2
pe "exit"
_EOF

chmod +x ${dir}/dbuild/_demo*.sh

cat << '_EOF' > ${dir}/dbuild/Dockerfile
FROM debian:jessie
COPY demo-magic.sh /bin
COPY pv /bin
COPY _demo01.sh /bin
COPY _demo02.sh /bin
_EOF

docker build -t $DOCKER_IMG ${dir}/dbuild
clear

# let the fun begin

p "# we all know: root can do everything, non-root may do nothing"
p "# to have a look at capabilities, we spin up a container with Debian 8.1 in it"
p "docker run debian:jessie"
docker run --name cap-demo1 $DOCKER_IMG /bin/_demo01.sh
p "# so now we start the container again but this time adding a capability"
p "docker run --cap-add=SYS_ADMIN debian:jessie"
docker run --name cap-demo2 --cap-add=SYS_ADMIN $DOCKER_IMG /bin/_demo02.sh
p "# if you need to know more about capabilities: man capabilities"

# now clean up the mess
docker rm cap-demo1 cap-demo2 > /dev/null 2>&1
docker image rm $DOCKER_IMG > /dev/null 2>&1
rm -rf ${dir}/dbuild
cd ~
