#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e
#set -x

DIR=$1
TARGET_MACHINE=$2
PORT_FLAG=$3
PORT_BIND=$4
help()
{
    cat <<- EOF
Desc: Popcorn is for migrate container cross ISAs
Usage: ./popcorn.sh <Container DIR> <TARGET Machine> [-p] [PORT:PORT]
    - Container DIR is the path of directory store the Dockerfile to build a docker image
    - TARGET Machine is the target machine user@ip. example: popcorn@10.4.4.111
    - PORT FLAG is -p to indicate port is mapping by host:guest 
Example: ./popcorn.sh ./helloworld ubuntu@172.31.23.242 [-p] [1111:1111]
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
if [ $# != 2 -a $#!=4]
then 
    help
fi
DIR=$(bash -c "echo $(cd $DIR ; pwd)")
WDIR=$(cat $DIR/Dockerfile | grep WORKDIR | awk '{print $2}' | sed -n '1p')
if [ -d $WDIR ];
then
	sudo rm -r $WDIR
else
	echo problem! please remove /app or any workdir
fi
if [ -f "./scripts/check.sh" ]
then
	echo local cgroup..........
        bash -c "./scripts/check.sh"
	echo remote cgroup.........
	ssh $TARGET_MACHINE "bash" < ./scripts/check.sh
else
	echo "check.sh can't find..." || exit 1
fi

BIN=$(ls $DIR | grep aarch64)
EXE=$(echo ${BIN%_*})
echo $PORT_FLAG $PORT_BIND


if [ -f "./scripts/builder.sh" ]
then
	CID=$(sudo bash -c "./scripts/builder.sh $DIR $PORT_FLAG $PORT_BIND")
else
        echo  "builder.sh can't find..." || exit 1
fi

echo start run container in host
sudo docker container start $CID
echo wait 5 sec for host running, you can config yourself.
sleep 5s
echo start dump
if [ -f "./scripts/dump.sh" ]
then
        bash -c "cd scripts ; ./dump.sh $CID $TARGET_MACHINE $EXE;cd -"
else
        echo  "dump.sh can't find..." || exit 1
fi
CHECKPOINT="/tmp/check_hcontainer"
echo start restore
if [ -f "./scripts/restore.sh" ]
then
        bash -c "cd scripts; ./restore.sh $DIR $TARGET_MACHINE $CHECKPOINT $PORT_FLAG $PORT_BIND"
else
        echo  "restore.sh can't find..." || exit 1
fi
