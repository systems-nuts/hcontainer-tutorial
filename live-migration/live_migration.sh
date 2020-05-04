#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
#set -e
#set -x

TARGET_MACHINE=$1
help()
{
    cat <<- EOF
Desc: live_migration is a live migration script.(this is for redis example script)
Usage: ./live_migration <user@ip>
    - TARGET Machine is the target machine user@ip. example: popcorn@10.4.4.111
Example: ./live_migration.sh  ubuntu@172.31.23.242 
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
sudo rm -rf /tmp/live-redis /tmp/predump /tmp/realdump
ssh $TARGET_MACHINE "sudo rm -rf /tmp/live-redis /tmp/predump /tmp/realdump"
RPID=$(ssh $TARGET_MACHINE "ps -A | grep redis-server")
ssh $TARGET_MACHINE "sudo kill -9 $RPID" 1>/dev/null 2>&1
sudo cp -r live-redis /tmp
sudo cp redis-cli redis-benchmark /tmp
PID=$(ps -A | grep redis-server | awk '{print $1}' | sed -n '1p')
sudo kill -9 $PID 1>/dev/null 2>&1 
cd /tmp/live-redis ; sudo ./redis-server --daemonize yes 1>/dev/null 2>&1
wait
sudo /tmp/redis-cli set migration successfully  1>/dev/null 2>&1
sudo /tmp/redis-cli config set save ""  1>/dev/null 2>&1
PID=$(ps -A | grep redis-server | awk '{print $1}' | sed -n '1p')
sudo mkdir /tmp/predump /tmp/realdump
cd /tmp/
echo start redis benchmark
sudo /tmp/redis-benchmark -t set -n 1000000 -r 10000000  1>/dev/null 2>&1 
wait

echo predump
sudo criu-het pre-dump --arch aarch64  -t $PID --images-dir predump  --track-mem --shell-job --tcp-established  1>/dev/null 2>&1
scp -r live-redis $TARGET_MACHINE:/tmp  1>/dev/null 2>&1
echo precopy
scp -r predump $TARGET_MACHINE:/tmp  1>/dev/null 2>&1

start_tm=`date +%s%N`;

echo real dump
sudo criu-het dump --arch aarch64 -j -t $PID --images-dir realdump/  --track-mem --shell-job --tcp-established --prev-images-dir ../predump  1>/dev/null 2>&1
sudo rm -r /tmp/predump
sudo rm -r /tmp/realdump/parent
echo real copy
sudo scp -r /tmp/realdump $TARGET_MACHINE:/tmp  1>/dev/null 2>&1
ssh $TARGET_MACHINE "cp /tmp/live-redis/redis-server_aarch64 /tmp/live-redis/redis-server"
ssh $TARGET_MACHINE "cd /tmp/realdump/ ; ln -s ../predump/ parent"
echo restore
ssh $TARGET_MACHINE "cd /tmp; sudo criu-het restore -j --tcp-established --images-dir realdump/ &" &

end_tm=`date +%s%N`;
use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`
echo $use_tm
sleep 3 
ssh $TARGET_MACHINE "ps -A | grep redis-server"
echo redis is running 
