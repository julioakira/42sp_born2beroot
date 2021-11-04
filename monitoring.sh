#!/bin/bash

# Architecture
OS=$(uname -o)
ARCHITECTURE=$(uname -m)
KERNEL_VERSION=$(uname -v)
# Physical CPUs
PHYSICAL_CPU=$(lscpu | sed '5q;d' | grep -P -o "\d+")
# Virtual CPUs
VIRTUAL_CPU=$(cat /proc/cpuinfo | grep processor | wc -l)
#Memory
TOTAL_MEM=$(awk '$3=="kB"{$2=$2/1024;$3="MB"} 1' /proc/meminfo | awk '{print $2}' | sed '1q;d')
USED_MEM=$(awk '$3=="kB"{$2=$2/1024;$3="MB"} 1' /proc/meminfo | awk '{print $2}' | sed '2q;d')
USAGE_MEM=$(echo "(($USED_MEM / $TOTAL_MEM) * 100)" | bc -l | cut -b 1-5)
# CPU Usage
USAGE_CPU=$(iostat -c | awk '{print 100 - $6}' | sed -n '4p')
# Last Reboot
LAST_REBOOT=$(who -b | awk '{print $3 " " $4}')
# Active LVM
ACTIVE_LVM=$(cat /etc/fstab | grep "mapper")
# Active Connections
ACTIVE_CONN=$(sudo netstat -natp | grep "LISTEN\|ESTABLISHED" | wc -l)
# Active Connected Users
USERS_CONN=$(w | tail -n +3 | wc -l)
# IP and MAC Address
MAC_ADDRESS = $(ifconfig | sed -n 's/ether//p' | sed -n 's/^[[:space:]]*//gp' | sed -n 's/[[:space:]].*//gp')
## Outputs
echo "#Architecture: $OS $KERNEL_VERSION $ARCHITECTURE"
echo "#CPU Physical: $PHYSICAL_CPU"
echo "#vCPU: $VIRTUAL_CPU"
if [[ $( echo "$USED_MEM == $TOTAL_MEM" | bc -l) == 1 ]]
then
	echo "#Memory Usage: ${TOTAL_MEM}/${USED_MEM}MB (100%)"
else
	echo "#Memory Usage: ${TOTAL_MEM}/${USED_MEM}MB ($USAGE_MEM%)"
fi
echo "#CPU Load: $USAGE_CPU%"
echo "#Last Boot: $LAST_REBOOT"
if [[ $ACTIVE_LVM ]]
then
	echo "#Active LVM: True"
else
	echo "#Active LVM: False"
fi
echo "#Active Connections: $ACTIVE_CONN"
echo "#Users logged: $USERS_CONN"
