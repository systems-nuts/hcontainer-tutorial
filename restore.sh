#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020

DIR=$1
TARGET_MACHINE=$2

ssh $TARGET_MACHINE "bash" < ./check.sh
RCID=$(ssh $TARGET_MACHINE "bash -s" < ./builder.sh $RDIR $EXE $WDIR)

scp -r ./$DIR $TARGET_MACHINE:~
ssh $TARGET_MACHINE "sudo mv ~/$DIR /var/lib/docker/containers/$RCID/checkpoints/"

ssh $TARGET_MACHINE "sudo docker container start --checkpoint check_hcontainer $RCID"

                                                              52,0-1        Bot

