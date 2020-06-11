[More information can be found on the Wiki](https://github.com/systems-nuts/hcontainer-tutorial/wiki)

<p align="center"><img src="http://www.popcornlinux.org/images/images/hcont_logo.png" width="256px"/></p>

### H-Container -- A project to migrate containers among heterogeneous-ISA computers (using Docker)

# Docker Migration



This guide targets a H-Containers deployment on Amazon AWS, or any pair machine with identical kernel Cgroup configuration. A future guide will address other deployments. 

## Prerequisites

1. Recommended Systems/AMIs: Linux 4.15.0-1043-aws #45-Ubuntu 18.04 LTS **x86_64** and **aarch64**  **Note: For Ubuntu 20.04 LTS user, the pre-requites packege of CRIU-HET is different, please following this** [wiki](https://github.com/systems-nuts/criu-het/wiki/CRIUHET-Installation) 

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

## Contents (of hcontainer-tutorial script migration) 
```
config.sh 					 				
popcorn.sh
docker-popcorn-notify.sh
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
redis/
	- Dockerfile
	- redis-server
	- redis-server_aarch64
	- redis-server_x86-64
nginx-bin/
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

## Example by your self

We provide examples step by step to explain different senarios, from x86 to ARM and vice versa.

[Hello World Docker](https://github.com/systems-nuts/hcontainer-tutorial/wiki/Hello-World-Docker) : Migration from ARM to x86

[Redis Server Dokcer](https://github.com/systems-nuts/hcontainer-tutorial/wiki/Redis-Server-Docker) : Migration from x86 to ARM

[Nginx Server Docker](https://github.com/systems-nuts/hcontainer-tutorial/wiki/Nginx-Server-Docker) : Migration from x86 to ARM

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

## More

Popcorn Linux [Demo](https://www.youtube.com/watch?v=Gj9L169hg50) on Youtube
