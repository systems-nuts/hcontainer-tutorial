# Docker Migration

This guide targets a H-Containers deployment on Amazon AWS only. A future guide will address other deployments.

## Prerequisites

1. Recommended Systems/AMIs: Linux 4.15.0-1043-aws #45-Ubuntu **x86_64** and **aarch64**

2. Inorder to migrate in AWS machines, both of your machines need to have ssh-keygen setup. Since it is impossible to login to your AWS machine without public key. AWS will give you a public key, but in order to run the script successfully, higtly recomand user to set up ssh-keygen in your machines.
```bash
$ssh-keygen # keep default storage place, just keep click 'return' until done.  
#copy the content of ~/.ssh/id_rsa.pub to another machine ～/.ssh/authorizedi_keys
```

3. **The config.sh script will help you to do the following set up, with -i flag, it will compile and install criu.**
```bash
$ ./config.sh 
or
$ ./config.sh -i 
``` 

4. Install Docker (version 18.09.8). **Note: Docker version 19.03.5 checkpoint is not working.**
```bash
$ sudo apt-get update
$ sudo apt install docker.io
```

5. Verify Docker is installed correctly by running the hello-world image. (Offical instruction from Docker).
```bash
$ sudo docker run hello-world 
```

6. Turn on the Docker experimental feature and add the following (if daemon.json file does not exist, create it):
```bash
vim /etc/docker/daemon.json (docker daemon configration file)

{
	"experimental": true
}
```
7. Restart Docker
```bash
service docker restart
```

8. Place/install the following repositories in a different directory on your machine:

	a. CRIU (criu.org)
	
	i. Install CRIU dependendies:
	```bash
	$ sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler libprotobuf-dev:amd64 gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev
	```
	ii. Clone the h-containers CRIU fork (version heterogeneous-simplified GitID: 4f92d4ad):
	```bash
	$ git clone https://github.com/systems-nuts/criu.git
	```
		
	iii. Move to the heterogeneous-simplified branch 
	```bash
	$ git checkout heterogeneous-simplified
	```
		
	iv: Make CRIU (Please also see the README file inside the criu repository):
	```bash
	cd criu # (if not already there)
	make clean
	make
	make install
	?[make docker-build]
	```

	b. *popcorn-compiler* (branch: criu) - If you want to use Popcorn Compiler (harder)
	
	(Please see popcorn-compiler/README for machine prerequisites)
	
	(Please see popcorn-compiler/INSTALL for toolchain installation instructions)
	
	```bash
	$ git clone  https://github.com/systems-nuts/popcorn-compiler.git
	$ git checkout criu
	```

	c. *hcontainer-nginx* - If you want to use the Nginx instance that is already prepared for H-Containers (easier)
	```bash
	$git clone https://github.com/systems-nuts/hcontainer-nginx.git
	Please read the README file inside container-nginx repository to compile and install it
	```

## Contents (of hcontainer-docker) 
```
config.sh 					 				
popcorn.sh
scripts/
	- builder.sh
	- check.sh
	- dump.sh
	- recode.sh
	- restore.sh
redis-cli
redis-benchmark 						
helloworld/ 					
	- Dockerfile 				
	- popcorn-hello 			
	- popcorn-hello_aarch64		
	- popcorn-hello_x86-64	
popcorn-redis/
	- Dockerfile
	- redis-server
	- redis-server_aarch64
	- redis-server_x86-64
```
## Example using scripts

We provide scripts that can help you to do migration easily.
The scripts intros:
1. check.sh will help user check current Cgroup support
2. builder.sh is helper to build H-container
3. dump.sh can help you dump the container and recode image, generate the dumped images in current dir, with Container ID and executable file given 
4. recode.sh is for process dumped images and recode it
5. restore.sh is for restore Hcontainer in remote machine

popcorn.sh will call these scripts separately.  <br>
popcorn.sh takes 2 required arguments and 2 optional arguments  <br>
\<container directory\> \<target machine\> \[-p\] \[port:port\] <br>
There is more detail if you do ./popcorn.sh -h  <br>
This is a simple try of helloworld and redis:
```bash
./popcorn.sh ./helloworld x86_machine@10.10.10.10 
./popcorn.sh ./popcorn-redis arm_machine@10.10.10.10 -p 6379:6379 
```

## Example by your self

We provide examples step by step to explain different senarios, from x86 to ARM and vice versa.

1. First one is using popcorn-hello as test program. 
3. Second one is using redis-server as test program. 

### Example for popcorn-hello migration from arm to x86

In docker, the program workdir is set to /app
```bash
cp -r helloworld /app #may need sudo
```
Build a docker image. Use myhello as the image name. **(DO NOT FORGET THE DOT AFTER IMAGE NAME)**
```bash	
cd helloworld	
cp popcorn-hello_aarch64 popcorn-hello #if you are running on ARM
cp popcorn-hello_x86-64 popcorn-hello #if you are running on x86
docker build -t myhello . 
```
Create a docker container for the myhello image, the Docker Container ID will return on standard output
```bash	
docker container create myhello 
```

Enter docker container directory
```bash
cd /var/lib/docker/containers/<Docker Container ID>
```

Enter the container's configuration file
```bash	
vim hostconfig.json
```	
Change the Capability option to add all capabilities. Otherwise, popcorn(latest version compiler) aarch64 binary will not run inside docker.
Replace ```"CapAdd":null ``` with ```"CapAdd":["all"] ``` in hostconfig.json

Restart docker to store/use configration changes
```bash
service docker restart
```

Start the container:
```bash	
docker container start <Docker Container ID>
```
See if the popcorn-hello process is running inside the container:
```bash
sudo docker top <containerID> -a|grep popcorn-hello
```
Example output:
```bash
17663 ? 00:00:00 popcorn-hello
```

Notify the process (**IF /app DIRECTORY IS NOT COPIED, NOTIFY WILL FAIL**)
```bash
popcorn-notify 4573 x86-64
```

After notify succeeded, this command will create a checkpoint, name is last args (IN ALL EXAMPLES IS simple)
```bash	
docker checkpoint create a40a7eb069172dc64dc771128cce91e942656f1cfe8b4d11ac97a99b08f64fd9 simple
```
Call recode script to recode the image file, it will copy the image file to current directory. 
```bash	
./recode.sh a40a7eb069172dc64dc771128cce91e942656f1cfe8b4d11ac97a99b08f64fd9 simple x86-64
```

**recode.sh take 3 args, 1.Container Id  2.Checkpoint name  3.Target archtecture**
**recode.sh will take take the checkpoint, and the output directory will be generated in /tmp**
```bash	
scp -r /tmp/simple $target@x86_machine:~
```
Send recode checkpoint images to target machine
```bash
ssh $target@x86_machine
```
Login to target machine 
In target machine still need a same container
```bash	
cd helloworld

cp popcorn-hello_x86-64 popcorn-hello

cp -r ../helloworld /app

docker build -t myhello .

docker container create myhello

 	7637bbed740829f374c7ff365b171f387206acccb1b604af3b87ab537bbc44d2
```
```bash
cp -r ~/simple /var/lib/docker/containers/7637bbed740829f374c7ff365b171f387206acccb1b604af3b87ab537bbc44d2/checkpoints
```
Copy the checkpoint images to target machine container checkpoints directory
```bash
docker container start --checkpoint simple 7637bbed740829f374c7ff365b171f387206acccb1b604af3b87ab537bbc44d2
```
Container restart from checkpoint 
```bash
docker ps
```
If it shows running, which means migration successfully, also you can check popcorn-hello output in log file located in the container directory

```
### Example for redis migration from arm to x86
```
In Dockerfile, CMD "--protected-mode", "no" will allow redis accept test data send from benchmark.
```

```bash
cp -r popcorn-redis /app

cd popcorn-redis

cp redis-server_aarch64 redis-server

docker build -t myredis .

docker run --cap-add all -d -p 6379:6379 myredis

        4927a9ad4109ce5561f8ad346372fa11084c1fb586f0022c44d70a1d4fd048f2
```
```
Directly run docker image to create a Container of redis.

--cap-add all : it will add all capabilities, no need for change config file

-p : it allow container map it port with host port

-d: Run in background, this args cause running image will create Container
```
```bash
docker ps

ps -A | grep redis

        7438 ?        00:00:00 redis-server

```

```bash
popcorn-notify 7438 x86-64

docker checkpoint create 4927a9ad4109ce5561f8ad346372fa11084c1fb586f0022c44d70a1d4fd048f2 simple

./recode.sh 4927a9ad4109ce5561f8ad346372fa11084c1fb586f0022c44d70a1d4fd048f2 simple x86-64

scp -r simple $target@x86_machine:~

ssh $target@x86_machine

cp -r popcorn-redis /app

cd popcorn-redis

cp redis-server_x86-64 redis-server

docker build -t myredis .

docker run --cap-add all -d -p 6379:6379 myredis

	10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

docker container stop 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

cp -r ~/simple /var/liv/docker/containers/10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394/checkpoints

docker container start --checkpoint simple 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

docker ps 
```

You can also use redis-benchmark to test it
```bash
./redis-benchmark -h 127.0.0.1 -p 6379
```

 

