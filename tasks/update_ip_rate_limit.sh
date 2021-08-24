#! /usr/bin/bash

# limit conections per second per ip address

TIME_PERIOD_SECONDS=60
MAX_CONNECTIONS=100

sudo iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 80 -i eth0 -m state --state NEW -m recent --update --seconds $TIME_PERIOD_SECONDS --hitcount $MAX_CONNECTIONS -j REJECT --reject-with icmp-host-prohibited
sudo iptables -A INPUT -p tcp --dport 443 -i eth0 -m state --state NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 443 -i eth0 -m state --state NEW -m recent --update --seconds $TIME_PERIOD_SECONDS --hitcount $MAX_CONNECTIONS -j REJECT --reject-with icmp-host-prohibited
