#!/bin/bash


# Author Tong Xing 
# Stevens Institute of Technology
# This script will build a container  
set -x
DIR=$1
PORT_FLAG=$2
PORT_BIND=$3
help()
{
    cat <<- EOF
Desc: Build is a helper function to help build a H-container
Usage: ./builder.sh <Container DIR> [Port_Flage] [PORT:PORT]
    - Container DIR is the directory store the Dockerfile to build a docker image
    - with -p as flag, indicate a port mapping with host and container 
Example: ./builder.sh ./helloworld popcorn-hello
Author: Tong Xing
Stevens Institute of Technology 2020
EOF
    exit 0
}
while [ -n "$1" ];do
        case $1 in
                -h) help;; # function help is called
                --) shift;break;; # end of options
                -*) echo "error: no such option $1."; exit 1;;
                *) break;;
esac
done
if [ $# != 1 -a $# != 3 ]
then
    help
fi
HOST_PORT=${PORT_BIND%%:*}
CONTAINER_PORT=${PORT_BIND##*:}
BIN=$(ls $DIR | grep aarch64)
EXE=$(echo ${BIN%_*})
WDIR=$(cat $DIR/Dockerfile | grep WORKDIR | awk '{print $2}' | sed -n '1p')
sudo cp -r $DIR $WDIR
arch=$(uname -m)
if [ "$arch" = "x86_64" ]
then
	arch="x86-64"
else 
	arch="aarch64"
fi
cd $DIR  && cp $EXE'_'$arch $EXE 	&& sudo docker build -t hcontainer . 1>/dev/null 2>&1
CID=$(sudo docker container create hcontainer)
sudo sed -i 's/"CapAdd":null/"CapAdd":["all"]/' /var/lib/docker/containers/$CID/hostconfig.json
if [ "$2" = "-p" ]
then
	sudo sed -i "s/\"PortBindings\":{}/\"PortBindings\":{\"$CONTAINER_PORT\/tcp\":[{\"HostIp\":\"\",\"HostPort\":\"$HOST_PORT\"}]}/" /var/lib/docker/containers/$CID/hostconfig.json
	sudo sed -i "s/\"SecurityOpt\":null/\"SecurityOpt\":[\"seccomp=unconfined\"]/" /var/lib/docker/containers/$CID/hostconfig.json
	sudo sed -i "s/\"AttachStderr\":false,/\"AttachStderr\":false,\"ExposedPorts\":{\"$CONTAINER_PORT\/tcp\":{}},/" /var/lib/docker/containers/$CID/config.v2.json
	sudo sed -i "s/\"AttachStderr\":true,/\"AttachStderr\":false,\"ExposedPorts\":{\"$CONTAINER_PORT\/tcp\":{}},/" /var/lib/docker/containers/$CID/config.v2.json
	sudo sed -i "s/\"Ports\":{}/\"Ports\":{\"$CONTAINER_PORT\/tcp\":[{\"HostIp\":\"0.0.0.0\",\"HostPort\":\"$HOST_PORT\"}]}/" /var/lib/docker/containers/$CID/config.v2.json
	sudo sed -i "s/\"SeccompProfile\":\"\"/\"SeccompProfile\":\"unconfined\"/" /var/lib/docker/containers/$CID/config.v2.json
fi
sudo service docker restart 1>/dev/null 2>&1 
echo $CID

