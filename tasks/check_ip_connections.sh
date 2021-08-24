#! /usr/bin/bash

netstat -ntu|awk '{print $5}'|cut -d: -f1 -s|sort|uniq -c|sort -nk1 -r

echo 'If an IP address has a large number of instances (maybe over 100) it should probably be banned'
echo 'You can ban an IP address with the command: sudo route add ADDRESS reject'
echo 'You can monitor the network load by running the command: nload'
echo 'You can monitor process CPU and memory utilization by running the command: top'
echo 'You can monitor process CPU and memory utilization by running the command: ps aux'
echo 'You can terminate a process by running the command: sudo kill PROCESS_ID'
