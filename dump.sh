#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020

CID=$1
TARGET_MACHINE=$2
EXE=$3
RARCH=$(ssh $TARGET_MACHINE "uname -m")
ps -A | grep $EXE
PID=$(ps -A | grep $EXE | awk '{print $1}' | sed -n '1p')
#The notify
sudo popcorn-notify $PID $RARCH
sudo docker checkpoint create $CID check_hcontainer
sudo ./recode.sh $CID check_hcontainer $RARCH
#scp -r ./check_hcontainer $TARGET_MACHINE:~
#ssh $TARGET_MACHINE "sudo mv ~/check_hcontainer /var/lib/docker/containers/$RCID/checkpoints/"

#ssh $TARGET_MACHINE "sudo docker container start --checkpoint check_hcontainer $RCID"

