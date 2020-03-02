#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e
#set -x

DIR=$1
TARGET_MACHINE=$2

help()
{
    cat <<- EOF
Desc: Popcorn is for migrate container cross ISAs
Usage: ./popcorn.sh <Container DIR> <TARGET Machine>
    - Container DIR is the directory store the Dockerfile to build a docker image
    - TARGET Machine is the target machine user@ip. example: popcorn@10.4.4.111
Example: ./popcorn.sh ./helloworld ubuntu@172.31.23.242
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
if [ $# != 2 ]
then 
    help
fi
WDIR=$(cat $DIR/Dockerfile | grep WORKDIR | awk '{print $2}' | sed -n '1p')
echo check cgroup
if [ -f "./check.sh" ]
then
        sudo bash -c "./check.sh"
else
	echo "check.sh can't find..." || exit 1
fi

BIN=$(ls $DIR | grep aarch64)
EXE=$(echo ${BIN%_*})
echo EXE


if [ -f "./builder.sh" ]
then
	CID=$(sudo bash -c "./builder.sh $DIR")
else
        echo  "builder.sh can't find..." || exit 1
fi

echo start run container in host
sudo docker container start $CID
echo wait 60 sec for host running 
sleep 60s
bash -c "sudo cat /var/lib/docker/containers/$CID/$CID-json.log"
echo start dump
if [ -f "./dump.sh" ]
then
        bash -c "./dump.sh $CID $TARGET_MACHINE $EXE"
else
        echo  "dump.sh can't find..." || exit 1
fi
CHECKPOINT="./check_hcontainer"
echo start restore
if [ -f "./restore.sh" ]
then
        bash -c "./restore.sh $DIR $TARGET_MACHINE $CHECKPOINT"
else
        echo  "restore.sh can't find..." || exit 1
fi
