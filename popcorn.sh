#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e
set -x

DIR=$1
RDIR=$2
TARGET_MACHINE=$3
EXE=$4
WDIR=$(cat $DIR/Dockerfile | grep WORKDIR | awk '{print $2}' | sed -n '1p')  






if [ -f "./check.sh" ]
then
        sudo bash -c "./check.sh"
else
	echo "check.sh can't find..." || exit 1
fi

if [ -f "./builder.sh" ]
then
	CID=$(sudo bash -c "./builder.sh $DIR $EXE $WDIR")
else
        echo  "builder.sh can't find..." || exit 1
fi


echo CHECK REMOTE MACHINE CGROUP

ssh $TARGET_MACHINE "bash" < ./check.sh 
RCID=$(ssh $TARGET_MACHINE "bash -s" < ./builder.sh $RDIR $EXE $WDIR) 



sudo docker container start $CID
RARCH=$(ssh $TARGET_MACHINE "uname -m")
ps -A | grep $EXE
PID=$(ps -A | grep $EXE | awk '{print $1}' | sed -n '1p')
sudo popcorn-notify $PID $RARCH 
sudo docker checkpoint create $CID check_hcontainer
sudo ./recode.sh $CID check_hcontainer $RARCH
scp -r ./check_hcontainer $TARGET_MACHINE:~
ssh $TARGET_MACHINE "sudo mv ~/check_hcontainer /var/lib/docker/containers/$RCID/checkpoints/"

ssh $TARGET_MACHINE "sudo docker container start --checkpoint check_hcontainer $RCID"

