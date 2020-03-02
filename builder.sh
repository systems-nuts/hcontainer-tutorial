#!/bin/bash


# Author Tong Xing 
# Stevens Institute of Technology
# This script will build a container  
#set -x
DIR=$1

help()
{
    cat <<- EOF
Desc: Build is a helper function to help build a H-container
Usage: ./builder.sh <Container DIR> <Work DIR>
    - Container DIR is the directory store the Dockerfile to build a docker image
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
if [ $# != 1 ]
then
    help
fi

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
sudo service docker restart 1>/dev/null 2>&1 
echo $CID

