#!/bin/bash


# Author Tong Xing 
# Stevens Institute of Technology
# This script will build a container  
set -x
DIR=$1
EXE=$2
WDIR=$3
sudo cp -r $DIR $WDIR
arch=$(uname -m)
if [ $arch="x86_64" ];then
	arch="x86-64"
fi
cd $DIR  && cp $EXE'_'$arch $EXE 	&& sudo docker build -t hcontainer . 1>/dev/null 2>&1
CID=$(sudo docker container create hcontainer)
sudo sed -i 's/"CapAdd":null/"CapAdd":["all"]/' /var/lib/docker/containers/$CID/hostconfig.json
sudo service docker restart 1>/dev/null 2>&1 
echo $CID

