#!/bin/bash
# Author: Tong Xing
# Stevens Institute of Technology 2020
# This script will help user check current Cgroup support
# Recompile the kernel incase some cgroup not support. 
echo check cgroup subsystem....
if [ -d "/sys/fs/cgroup/blkio" ]
then
	echo "blkio checked!"
else  
	echo "blkio unsupport! --> CONFIG_BLK_CGROUP is not set"
fi
if [ -d "/sys/fs/cgroup/cpuset" ]
then
        echo "cpuset checked!"
else
        echo "cpuset unsupport! --> CONFIG_CPUSETS is not set"
fi
if [ -d "/sys/fs/cgroup/freezer" ]
then
        echo "freezer checked!"
else
        echo "freezer unsupport! --> CONFIG_CGROUP_FREEZER is not set"
fi
if [ -d "/sys/fs/cgroup/memory" ]
then
        echo "memory checked!"
else
        echo "memory unsupport! --> CONFIG_MEMCG is not set"
fi
if [ -d "/sys/fs/cgroup/perf_event" ]
then
        echo "perf_event checked!"
else
        echo "perf_event unsupport! --> CONFIG_CGROUP_PERF is not set"
fi
if [ -d "/sys/fs/cgroup/cpu" ]
then
        echo "cpu checked!"
else
        echo "cpu unsupport! --> CONFIG_CGROUP_SCHED is not set"
fi
if [ -d "/sys/fs/cgroup/cpuacct" ]
then
        echo "cpuacct checked!"
else
        echo "cpuacct unsupport! --> CONFIG_CGROUP_CPUACCT is not set"
fi
if [ -d "/sys/fs/cgroup/devices" ]
then
        echo "devices checked!"
else
        echo "devices unsupport! --> CONFIG_CGROUP_DEVICE is not set"
fi
if [ -d "/sys/fs/cgroup/hugetlb" ]
then
        echo "hugetlb checked!"
else
        echo "hugetlb unsupport! --> CONFIG_CGROUP_HUGETLB is not set"
fi
if [ -d "/sys/fs/cgroup/net_cls" ]
then
        echo "net_cls checked!"
else
        echo "net_cls unsupport! --> CONFIG_CGROUP_NET_CLASSID is not set"
fi
if [ -d "/sys/fs/cgroup/net_prio" ]
then
        echo "net_prio checked!"
else
        echo "net_prio unsupport! --> CONFIG_CGROUP_NET_PRIO is not set"
fi
if [ -d "/sys/fs/cgroup/pids" ]
then
        echo "pids checked!"
else
        echo "pids unsupport! --> CONFIG_CGROUP_PIDS is not set"
fi
if [ -d "/sys/fs/cgroup/rdma" ]
then
        echo "rdma checked!"
else
        echo "rdma unsupport! --> CONFIG_CGROUP_RDMA is not set"
fi
