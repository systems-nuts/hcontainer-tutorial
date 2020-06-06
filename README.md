# Docker Migration

This guide targets a H-Containers deployment on Amazon AWS, or any pair machine with identical kernel Cgroup configuration. A future guide will address other deployments.

## Prerequisites

1. Recommended Systems/AMIs: Linux 4.15.0-1043-aws #45-Ubuntu **x86_64** and **aarch64**  **Note: For Ubuntu 20.04 user, the pre-requites packege of CRIU-HET is different, please following this** [wiki](https://github.com/systems-nuts/criu-het/wiki/CRIUHET-Installation) 

2. Inorder to migrate in AWS machines, both of your machines need to have ssh-keygen setup. Since it is impossible to login to your AWS machine without public key. AWS will give you a public key, but in order to run the script successfully, higtly recomand user to set up ssh-keygen in your machines.
```bash
$ssh-keygen # keep default storage place, just keep click 'return' until done.  
#copy the content of ~/.ssh/id_rsa.pub to another machine ～/.ssh/authorizedi_keys
```

3. **The config.sh script will help you to do all following set-ups, with -i flag, it will compile and install criu.**
```bash
$ ./config.sh 
or
$ ./config.sh -i 
``` 

4. Install Docker (version 18.09). **Note: Docker version in both machine should be identical**
```bash
#x86
sudo add-apt-repository \
		    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   		    $(lsb_release -cs) \
   		    stable"
#ARM
sudo add-apt-repository \
            	    "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   	   	    $(lsb_release -cs) \
   	            stable"
	    
	    
sudo apt-get update
sudo apt-get install docker-ce=5:18.09.6~3-0~ubuntu-bionic docker-ce-cli=5:18.09.6~3-0~ubuntu-bionic containerd.io -y
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
	$ sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor libnet1-dev
	```
	ii. Clone the h-containers CRIU fork (version heterogeneous-simplified GitID: 4f92d4ad):
	```bash
	$ git clone https://github.com/systems-nuts/criu-het.git
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

## Contents (of hcontainer-docker script migration) 
```
config.sh 					 				
popcorn.sh
scripts/
	- builder.sh
	- check.sh
	- dump.sh
	- recode.sh
	- restore.sh						
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
test-nginx/
	- Dockerfile
	- popcorn-nginx
	- popcorn-nginx_aarch64
	- popcorn-nginx_x86-64
nginx/ # nginx configuration dir, including log and default webpage
       # host machine may already have it if it had install nginx before, 
       # Nginx running inside Docker need map this configuration in host machine.
live-migration/ # criu live migration test script
non-docker-migration/ # H-container normal migration script 

```
## Example of using scripts

We provide scripts that can help you to do migration easily. **Nginx is not support by script**
The scripts intros:
1. check.sh will help user check current Cgroup support
2. builder.sh is helper to build H-container
3. dump.sh can help you dump the container and recode image, generate the dumped images in current dir, with Container ID and executable file given 
4. recode.sh is for process dumped images and recode it **this is needed also for manually Docker migrate**
5. restore.sh is for restore Hcontainer in remote machine

**popcorn.sh** will call these scripts separately.  <br>
popcorn.sh takes **2 <required arguments\>** and **[2 optional arguments]**  <br>
**\<container directory\> \<target machine\> \[-p\] \[port:port\]** <br>
There is more detail if you do **./popcorn.sh -h**  <br>
This is a simple try of helloworld and redis:
```bash
./popcorn.sh ./helloworld x86_machine@10.10.10.10 
./popcorn.sh ./popcorn-redis arm_machine@10.10.10.10 -p 6379:6379 
```

## Example by your self

We provide examples step by step to explain different senarios, from x86 to ARM and vice versa.

1. First one is using popcorn-hello as test program. 
3. Second one is using redis-server as test program. 

### Example for popcorn-hello migration from ARM to x86

In docker, the program workdir is set to /app **This is important for popcorn-notify**
```bash
cp helloworld/popcorn-hello_aarch64 helloworld/popcorn-hello

cp -r helloworld /app #may need sudo
```
Pull the Popcorn helloworld image from Docker hub
```bash
docker pull 123toorc/hcontainer-helloworld:hcontainer
```

Run docker image, the Docker Container ID will return on standard output, ARM need add capabilities
```bash	
docker run --cap-add all -d 083c6d4dfcb3  
```
**(SKIP)If migration is from x86 to ARM, either run with "cap-add all" and stop container then restore the container, or create a container and change the capabilities in hostconfig.json file**
```bash	
vim hostconfig.json
#Change the Capability option to add all capabilities. Otherwise, popcorn(latest version compiler) aarch64 binary will not run inside docker.

#Replace "CapAdd":null with "CapAdd":["all"] in hostconfig.json

#Restart docker to store/use configration changes

service docker restart
```

Start the container (if using docker run --cap-add all -d %IMAGE_ID, please ignore this step, because the Container is running as detached):
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
cd scripts/
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
In target machine still need a same container **Noticed: if migration is from x86->ARM, after create a Container, user must go to the container dir to change the hostconfig.json to add capabilites. Or instead of create a container, just do '$docker run --cap-add all -d 0beb2a3a9474' then stop the container before restore.**

```bash	
docker pull 123toorc/hcontainer-helloworld:hcontainer

docker container create 0beb2a3a9474

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

### Example for redis migration from x86 to ARM

In Dockerfile, CMD "--protected-mode", "no" will allow redis accept test data send from benchmark.

```bash
cd popcorn-redis

cp redis-server_x86-64 redis-server

cp -r ../popcorn-redis /app

docker pull 123toorc/hcontainer-redis:hcontainer

docker run --cap-add all -d -p 6379:6379 155fea01651c

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
popcorn-notify 7438 aarch64

docker checkpoint create 4927a9ad4109ce5561f8ad346372fa11084c1fb586f0022c44d70a1d4fd048f2 simple

./scripts/recode.sh 4927a9ad4109ce5561f8ad346372fa11084c1fb586f0022c44d70a1d4fd048f2 simple aarch64

scp -r /tmp/simple $target@arm_machine:~

ssh $target@arm_machine

cd popcorn-redis

cp redis-server_aarch64 redis-server

cp -r ../popcorn-redis /app

docker pull 123toorc/hcontainer-redis:hcontainer

# Instead, you also can use '$docker container create 0f548727d566' and alter in hostconfig file to add capabilities and config.v2.json to add port mapping, please have look of scripts/builder.sh

docker run --cap-add all -d -p 6379:6379 0f548727d566

	10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

# Stop the running container then we restore it.

docker container stop 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

cp -r /tmp/simple /var/liv/docker/containers/10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394/checkpoints

docker container start --checkpoint simple 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394

docker ps 
```

You can also use redis-benchmark to test it
```bash
./redis-benchmark -h 127.0.0.1 -p 6379
```

### Example for nginx migration from x86 to ARM
```
In Dockerfile, the CMD ["./popcorn-nginx","-g","daemon off;"].

Because in Container, nginx is process 1, docker will exit when nginx initilazation is over

In order to keep container running, it needs args '-g daemon off;' to force it hang on.	
```
```bash
cp -r nginx /usr/local 
	
cd test_nginx

cp popcorn-nginx_x86-64 popcorn-nginx

cp -r ../test_nginx /app	

docker build -t mynginx .

docker run --cap-add all -d -v /usr/local/nginx/logs/:/usr/local/nginx/logs/ -v /usr/local/nginx/conf/:/usr/local/nginx/conf/ mynginx

 	4e6f433906d85a874acdc1b3138ffc9389e74e7120e11f5e0aa25dd08d3270f4
```
Directly run docker image to create a Container of nginx. 

--cap-add all : it will add all capabilities, no need for change config file

```text
-v: volumn to mount system file system with docker file system.(**THIS IS RESON WHY NGINX DOCKERFILE NEED UBUNTU IMAGE LOAD**)

/usr/local/nginx/logs: Nginx needs error.log to run   

/user/local/nginx/conf: Nginx needs nginx.conf to run

-d: Run in background, this args cause running image will create Container 
```

```bash
docker ps

ps -A | grep nginx
	
	755 ?        00:00:00 popcorn-nginx
	756 ?        00:00:00 popcorn-nginx
```
```bash
popcorn-notify 755 aarch64

popcorn-notify 756 aarch64

docker checkpoint create 4e6f433906d85a874acdc1b3138ffc9389e74e7120e11f5e0aa25dd08d3270f4 simple

./scripts/recode.sh 4e6f433906d85a874acdc1b3138ffc9389e74e7120e11f5e0aa25dd08d3270f4 simple aarch64

scp -r simple $target@x86_machine:~

ssh $target@ARM_machine

cp -r test_nginx /app

cd test_nginx

cp popcorn-nginx_aarch64 popcorn-nginx

docker build -t mynginx

# Likewise the capabilities and volumn mapping and port mapping can be done in hostconfig and config.v2.json file. 
docker run --cap-add all -d -v /usr/local/nginx/logs/:/usr/local/nginx/logs/ -v /usr/local/nginx/conf/:/usr/local/nginx/conf/ mynginx
	
	10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394
```
```bash
docker container stop 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394
```
Since we run image to create a container, so this time, we need stop it first.
```bash
cp -r ~/simple /var/lib/docker/containers/10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394/checkpoints

docker container start --checkpoint simple 10877d6d99969b4bdc0a4fc1dc144615cb1e0d1bbbb727324adc7538f473b394 

docker ps
```

