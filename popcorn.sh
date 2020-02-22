#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e

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

ssh $TARGET_MACHINE -C "/bin/bash" < ./builder.sh $RDIR $EXE $WDIR

echo CHECK REMOTE MACHINE CGROUP

ssh $TARGET_MACHINE -C "/bin/bash" < ./check.sh 


