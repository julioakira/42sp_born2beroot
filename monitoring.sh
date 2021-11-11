#!/bin/bash

# Architecture
OS=$(uname -o)
ARCHITECTURE=$(uname -m)
KERNEL_VERSION=$(uname -v)
# Physical CPUs
PHYSICAL_CPU=$(lscpu | sed '5q;d' | grep -P -o "\d+")
# Virtual CPUs
VIRTUAL_CPU=$(cat /proc/cpuinfo | grep processor | wc -l)
#RAM Info
TOTAL_MEM=$(awk '$3=="kB"{$2=$2/1024;$3="MB"} 1' /proc/meminfo | awk '{print $2}' | sed '1q;d')
USED_MEM=$(awk '$3=="kB"{$2=$2/1024;$3="MB"} 1' /proc/meminfo | awk '{print $2}' | sed '2q;d')
USAGE_MEM=$(echo "(($USED_MEM / $TOTAL_MEM) * 100)" | bc -l | cut -b 1-5)
# Disk Info
TOTAL_DISK=$(df -m | awk '{print $2}' | tail -n +2 | sed 's/[A-Z]//g' | awk '{s+=$1} END {print s}')
USED_DISK=$(df -m | awk '{print $3}' | tail -n +2 | awk '{s+=$1} END {print s}')
USAGE_DISK=$(echo "(($USED_DISK / $TOTAL_DISK) * 100)" | bc -l | cut -b 1-5)
# CPU Usage
USAGE_CPU=$(iostat -c | awk '{print 100 - $6}' | sed -n '4p')
# Last Reboot
LAST_REBOOT=$(who -b | awk '{print $3 " " $4}')
# Active LVM
ACTIVE_LVM=$(cat /etc/fstab | grep "mapper")
# Active Connections
ACTIVE_CONN=$(netstat -natp | grep "LISTEN\|ESTABLISHED" | wc -l)
# Active Connected Users
USERS_CONN=$(w | tail -n +3 | wc -l)
# MAC Address
MAC_ADDRESS=$(ifconfig | sed -n 's/ether//p' | sed -n 's/^[[:space:]]*//gp' | sed -n 's/[[:space:]].*//gp')
# Public and Private IP Addresses
PUBLIC_IP_ADDRESS=$(curl -s ifconfig.me)
LOCAL_IP_ADDRESS=$(hostname -I | awk '{print $1}')
# Commands ran with sudo
COUNT_SUDO=$(cat /var/log/sudo/sudo.log | grep -a "COMMAND" | wc -l)
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
if [[ $( echo "$USED_DISK == $TOTAL_DISK" | bc -l) == 1 ]]
then
	echo "#Disk Usage: ${TOTAL_DISK}MB/${USED_DISK}MB (100%)"
else
	echo "#Disk Usage: ${TOTAL_DISK}MB/${USED_DISK}MB ($USAGE_DISK%)"
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
echo "#Network: Public IP ($PUBLIC_IP_ADDRESS) Local IP ($LOCAL_IP_ADDRESS)"
echo "#MAC Address: $MAC_ADDRESS"
echo "#Sudo Count: $COUNT_SUDO"
