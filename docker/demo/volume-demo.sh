#!/bin/bash
clear
echo "docker run -it -v /home/vagrant:/mnt/home alpine:3.8"
echo ""
docker run -it --name demo -v /home/vagrant:/mnt/home alpine:3.8
echo "press enter to continue"
read
docker rm demo
clear

echo "docker run -it -v /home/vagrant:/etc alpine:3.8"
echo ""
docker run -it --name demo -v /home/vagrant:/etc alpine:3.8
echo "press enter to continue"
read
docker rm demo
clear


echo "Now something security relevant"
echo "docker run -it -v /etc:/hostetc alpine:3.8"
echo ""
echo "We mount host etc into our pod, and due to root rights in it we can e.g. see the shadow"
docker run -it --name hackerpod -v /etc:/hostetc alpine:3.8
echo "press enter to continue"
read
docker rm demo
clear

echo "docker run -d -p 8081:8080 --name jenkins -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-alpine"
echo ""
docker run -d -p 8081:8080  --name jenkins -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-alpine
echo ""
echo "Waiting 30 sec for jenkins to start!"
sleep 5
echo ""
echo "Waiting 25 sec for jenkins to start!"
sleep 5
echo ""
echo "Waiting 20 sec for jenkins to start!"
sleep 5
echo ""
echo "Waiting 15 sec for jenkins to start!"
sleep 5
echo ""
echo "Waiting 10 sec for jenkins to start!"
sleep 5
echo ""
echo "Waiting 5 sec for jenkins to start!"
sleep 5
clear
echo "printing logs!"
docker logs jenkins

echo "press any key to continue"
read
docker stop jenkins

clear
echo "Remove the container:"
echo "docker rm jenkins"
docker rm jenkins
docker ps -a
echo ""
echo "List volumes with: docker volume ls"
echo ""
docker volume ls
echo ""
echo "press any key to continue"
read
clear
echo "Recreate same jenkins with same volume name!"
echo "docker run -d -p 8081:8080 --name jenkins -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-alpine"
echo ""
docker run -d -p 8081:8080 --name jenkins -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-alpine


echo "press any key to continue"
read

docker stop jenkins
docker rm jenkins
docker volume rm jenkins_home