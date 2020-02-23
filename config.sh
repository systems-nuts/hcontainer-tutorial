#!/bin/bash
# Author: Tong Xing. 
# Stevens Institute of technology 2020 
# This script will help user build basic enviroment. 
set -e

sudo apt-get update
sudo apt-get install docker.io -y
sudo docker run hello-world
sudo bash -c 'echo -e "{\n\t\"experimental\": true\n}" >> /etc/docker/daemon.json'
sudo service docker restart
sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler libprotobuf-dev:amd64 gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev 1>/dev/null

git clone https://github.com/systems-nuts/criu.git
cd criu && git checkout heterogeneous-simplified
cpucore=sudo cat /proc/cpuinfo |grep "processor" |wc -l
sudo make -j$cpucore
sudo make install
sudo apt install python-pip -y 
pip install ipaddress
pip install pyfastcopy
