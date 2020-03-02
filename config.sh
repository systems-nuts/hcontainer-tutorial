#!/bin/bash
# Author: Tong Xing. 
# Stevens Institute of technology 2020 
# This script will help user build basic enviroment. 
set -e

help()
{
    cat <<- EOF
Desc: config is use for build pre-requisite stuff, including criu. 
Usage: ./config [-i] 
 -i: script will compile and install the criu. otherwise it only download criu. 
Author: Tong Xing
Stevens Institute of Technology 2020
EOF
    exit 0
}
install()
{
    cat <<- EOF
config will do make and install. 
EOF
}
while [ -n "$1" ];do
        case $1 in
                -h) help;; # function help is called
		-i) install;;	
                --) shift;break;; # end of options
                -*) echo "error: no such option $1."; exit 1;;
                *) break;;
esac
done
sudo apt-get install docker.io -y
sudo docker run hello-world
sudo bash -c 'echo -e "{\n\t\"experimental\": true\n}" >> /etc/docker/daemon.json'
sudo service docker restart
sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler libprotobuf-dev:amd64 gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev 1>/dev/null
sudo apt-get install python -y
sudo apt install python-pip -y
pip install ipaddress
pip install pyfastcopy
git clone https://github.com/systems-nuts/criu.git
if [ "$1" = "-i" ]
then
   
	cd criu && git checkout heterogeneous-simplified
	cpucore=sudo cat /proc/cpuinfo |grep "processor" |wc -l
	sudo make -j$cpucore
	sudo make install
fi
