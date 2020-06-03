#!/bin/bash
# Author: Tong Xing. 
# Stevens Institute of technology 2020 
# This script will help user build basic enviroment. 
#set -x

help()
{
    cat <<- EOF
Desc: config is use for build pre-requisite stuff, including criu. 
Usage: ./config [-i] 
 -i: script will install and compile and install the criu-het 
Author: Tong Xing
Stevens Institute of Technology 2020
EOF
    exit 0
}
install()
{
    cat <<- EOF
CRIU-HET will download and compile and install. 
EOF
    sudo apt-get update
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]
    then
	    sudo add-apt-repository \
		    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   		    $(lsb_release -cs) \
   		    stable"
    else
	    sudo add-apt-repository \
            "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   	    $(lsb_release -cs) \
   	    stable"
    fi
    sudo apt-get update
    sudo apt-get install docker-ce=5:18.09.6~3-0~ubuntu-bionic docker-ce-cli=5:18.09.6~3-0~ubuntu-bionic containerd.io 
    sudo docker run hello-world
    sudo bash -c 'echo -e "{\n\t\"experimental\": true\n}" >> /etc/docker/daemon.json'
    sudo service docker restart
    sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev 1>/dev/null
    sudo apt-get install python -y
    sudo apt install python-pip -y
    pip install ipaddress
    pip install pyfastcopy
    git clone https://github.com/systems-nuts/criu.git
    cd criu && git checkout heterogeneous-simplified
    cpucore=sudo cat /proc/cpuinfo |grep "processor" |wc -l
    sudo make -j$cpucore
    sudo make install
    exit 0
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
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]
    then
            sudo add-apt-repository \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                    $(lsb_release -cs) \
                    stable"
    else
            sudo add-apt-repository \
            "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
    fi
    sudo apt-get update
    sudo apt-get install docker-ce=5:18.09.6~3-0~ubuntu-bionic docker-ce-cli=5:18.09.6~3-0~ubuntu-bionic containerd.io -y
sudo docker run hello-world
sudo bash -c 'echo -e "{\n\t\"experimental\": true\n}" >> /etc/docker/daemon.json'
sudo service docker restart
sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev 1>/dev/null
sudo apt-get install python -y
sudo apt install python-pip -y
pip install ipaddress
pip install pyfastcopy
