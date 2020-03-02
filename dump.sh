#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
set -e
CID=$1
TARGET_MACHINE=$2
EXE=$3

help()
{
    cat <<- EOF
Desc: dump.sh can help you dump the container and recode image, generate the dumped images in current dir, with Container ID and executable file given 
Usage: ./dump.sh <Container ID> <TARGET Machine> <Executable file>
      - Container ID is the Container ID
      - TARGET Machine is the target machine you ready to migrate, for example: popcorn@10.40.10.10
      - Executable file is the prefix of the binary files that popcorn compiler compiled
Example: ./dump.sh "Container ID" popcorn@10.4.4.4 popcorn_hello
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




RARCH=$(ssh $TARGET_MACHINE "uname -m")
ps -A | grep $EXE
PID=$(ps -A | grep $EXE | awk '{print $1}' | sed -n '1p')
#The notify
sudo popcorn-notify $PID $RARCH
sudo docker checkpoint create $CID check_hcontainer
sudo ./recode.sh $CID check_hcontainer $RARCH

