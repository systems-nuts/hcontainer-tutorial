#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
#set -e
#set -x

TARGET_MACHINE=$1
help()
{
    cat <<- EOF
Desc: migration is a normal migration script. from x86 to arm(this is for redis example script)
Usage: ./migration <user@ip>
    - TARGET Machine is the target machine user@ip. example: popcorn@10.4.4.111
Example: ./migration.sh  ubuntu@172.31.23.242 
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
sudo rm -rf /tmp/redis /tmp/realdump 
ssh $TARGET_MACHINE "sudo rm -rf /tmp/redis /tmp/realdump "
RPID=$(ssh $TARGET_MACHINE "ps -A | grep redis-server")
ssh $TARGET_MACHINE "sudo kill -9 $RPID" 1>/dev/null 2>&1
sudo cp -r redis /tmp
PID=$(ps -A | grep redis-server | awk '{print $1}' | sed -n '1p')
sudo kill -9 $PID 1>/dev/null 2>&1 
cd /tmp/redis ; sudo ./redis-server --daemonize yes 1>/dev/null 2>&1
wait
PID=$(ps -A | grep redis-server | awk '{print $1}' | sed -n '1p')
echo redis server is online , PID is $PID
mkdir /tmp/realdump
cd /tmp/

echo dump the redis server
sudo criu-het dump --arch aarch64 -j -t $PID --images-dir realdump/  --track-mem --shell-job --tcp-established  1>/dev/null 2>&1
wait
echo send the dump image and source code to the target machine
sudo scp -r /tmp/redis $TARGET_MACHINE:/tmp  1>/dev/null 2>&1
sudo scp -r /tmp/realdump $TARGET_MACHINE:/tmp  1>/dev/null 2>&1
wait
ssh $TARGET_MACHINE "cp /tmp/redis/redis-server_aarch64 /tmp/redis/redis-server"

echo restore in target machine
ssh $TARGET_MACHINE "cd /tmp; sudo criu-het restore -j --tcp-established --images-dir realdump/ &" &

sleep 3 
ssh $TARGET_MACHINE "ps -A | grep redis-server"
echo redis is running in taget machine 
