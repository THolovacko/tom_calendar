#! /usr/bin/bash

g++ -std=c++11 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_daemon.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_daemon
g++ -std=c++11 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_get.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_get
g++ -std=c++11 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_set.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_set
g++ -std=c++11 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_stop.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_stop

sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_daemon /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_get /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_set /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_stop /usr/bin/

#tput setaf 2
#echo "sudo mv ./tom_memcache_daemon /usr/bin/"
#echo "sudo mv ./tom_memcache_get /usr/bin/"
#echo "sudo mv ./tom_memcache_set /usr/bin/"
#echo "sudo mv ./tom_memcache_stop /usr/bin/"
#tput setaf 0
