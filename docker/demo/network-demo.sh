#!/bin/bash
clear
echo "docker run --name nginxFixedPort -d -p 8081:80 nginx:mainline "
echo ""
docker run --name nginxFixedPort -d -p 8081:80 nginx:mainline 
echo "press enter to continue"
read

docker stop nginxFixedPort 
docker rm nginxFixedPort 
clear

echo "docker run --name nginxRandomPort -d -P nginx:mainline "
echo ""
docker run --name nginxRandomPort -d -P nginx:mainline 
echo ""
echo "docker ps"
docker ps
echo ""
echo "press enter to continue"
read

docker stop nginxRandomPort
docker rm nginxRandomPort
clear


echo "docker network create customNetwork"
echo ""
docker network create customNetwork

echo "docker run -d --name nginx --network customNetwork nginx:mainline"
echo ""
docker run -d --name nginx --network customNetwork nginx:mainline
echo "docker run -it --name helper --network customNetwork alpine:3.8"
echo ""
echo "you are inside the helper container now. Please do your tests!"
echo ""
docker run -it --name helper --network customNetwork alpine:3.8

echo "press enter to continue"
read
docker stop nginx
docker rm nginx
docker rm helper
docker network rm customNetwork
clear

echo "---- NETWORK DEMO END ----"
