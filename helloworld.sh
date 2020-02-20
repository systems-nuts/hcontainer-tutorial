#!/bin/bash


# Author Tong Xing 
# Stevens Institute of Technology
set -x
set -e

sudo cp -r helloworld /app
arch=$(uname -m)
if [ $arch="x86_64" ];then
	arch="x86-64"
fi
echo current is on $arch
cd helloworld  && cp popcorn-hello_$arch popcorn-hello 	&& sudo docker build -t myhello .
CID=$(sudo docker container create myhello)
sudo sed -i 's/"CapAdd":null/"CapAdd":["all"]/' /var/lib/docker/containers/$CID/hostconfig.json
sudo service docker restart 
sudo docker container start $CID



