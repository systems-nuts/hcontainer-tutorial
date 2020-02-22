#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
# This script will help user dump the docker and recode the image by using criu-het
# It will generate a directroy contains all snapshot images in current pwd.
set -x
set -e

PID=$1
CHECKPOINT_NAME=$2
TARGET=$3
mkdir /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/simple

cp /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/descriptors.json /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/simple

cd /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/; crit recode -t $TARGET -o simple

cd -

cp -r /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/simple ./$CHECKPOINT_NAME

rm -r /var/lib/docker/containers/$PID/checkpoints/$CHECKPOINT_NAME/simple
for i in ./$CHECKPOINT_NAME/core-*
do
	crit decode -i $i -o $i.dec
	sed -i 's#"seccomp_mode": "filter",# #' $i.dec
	crit encode -i $i.dec -o $i
	rm $i.dec
done



