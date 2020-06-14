[More information can be found on the Wiki](../../wiki)

<p align="center"><img src="http://www.popcornlinux.org/images/images/hcont_logo.png" width="200px"/></p>

## H-Container -- A project to migrate containers among heterogeneous-ISA machines

H-Container enables containerized applications, natively compiled for a specific ISA, to runtime migrate (similar to VM migration) across compute nodes featuring CPUs of different ISAs, such as ARM and x86. 
H-Container takes a natively compiled binary (for Linux) and transforms it into a natively compiled set of binaries, one per ISA. Once a binary is started and checkpointed on a machine, it can be restarted on a machine with a different ISA. Thus, enabling runtime migration of applications (note that live-migration is also supported). H-Container supports not just single applications but also entire containers.

H-Container fully integrates with [Docker](www.docker.com). However, at least at the time of writing, Docker supports container checkpoint/restart (with CRIU) on a single machine only, checkpoint/restart among different (heterogeneous-ISA) machines is completely manual. This repository provides the tools and instructions to enable Docker container migration.

## Content

This repository includes tools and instructions (refer to the [Wiki](../../wiki)) to test H-Container container migration with and without Docker, on yuor own machine (embedded board, laptop, desktop, server), as well as in the cloud (AWS). The following content is included:

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

## Getting Started with H-Container

H-Containers enables container migration (checkpoint/restart and live-migation), with and without Docker, among any pair of machines (of any ISA, including ARM and x86), running Linux, with **identical** kernel Cgroup configuration. Note that AWS provides kernel images for different ISAs with the same kernel Cgroup configuration.

The github Wiki includes instructions to setup several examples on AWS. The same examples works on bare-metal, and on QEMU, with and without Docker.

## Examples

This repository includes the following examples:

* Hello World Docker, migration from ARM to x86
* Redis Server Dokcer, migration from x86 to ARM
* Nginx Server Docker, migration from x86 to ARM


