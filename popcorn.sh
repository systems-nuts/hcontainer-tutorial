#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e
#set -x

DIR=$1
TARGET_MACHINE=$2
EXE=$3

help()
{
    cat <<- EOF
Desc: Popcorn is for migrate container cross ISAs
Usage: ./popcorn.sh <Container DIR> <TARGET Machine> <Exectutable Binary>
    - Container DIR is the directory store the Dockerfile to build a docker image
    - TARGET Machine is the target machine user@ip. example: popcorn@10.4.4.111
    - Exectutable Binary is the popcorn compiled binary file pre-fix (w/o _x86-64 or _aarch64)
Example: ./popcorn.sh ./helloworld ubuntu@172.31.23.242 popcorn-hello
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
if [ $# != 3 ]
then 
    help
fi
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
RDIR=/tmp/h_container_remote
scp -r $DIR $TARGET_MACHINE:$RDIR
ssh $TARGET_MACHINE "bash" < ./check.sh 
RCID=$(ssh $TARGET_MACHINE "bash -s" < ./builder.sh $RDIR $EXE $WDIR) 



sudo docker container start $CID
RARCH=$(ssh $TARGET_MACHINE "uname -m")
ps -A | grep $EXE
PID=$(ps -A | grep $EXE | awk '{print $1}' | sed -n '1p')
#The notify 
sudo popcorn-notify $PID $RARCH 
sudo docker checkpoint create $CID check_hcontainer
sudo ./recode.sh $CID check_hcontainer $RARCH
scp -r ./check_hcontainer $TARGET_MACHINE:~
sudo rm -r ./check_hcontainer
ssh $TARGET_MACHINE "sudo mv ~/check_hcontainer /var/lib/docker/containers/$RCID/checkpoints/"

ssh $TARGET_MACHINE "sudo docker container start --checkpoint check_hcontainer $RCID"

