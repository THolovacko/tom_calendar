#! /usr/bin/bash
# @remember: should do somehting about these directory paths

g++ -std=c++14 -pthread /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_start.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_start
g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_get.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_get
g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_set.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_set
g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_stop.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_stop
g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tom_memcache/src/tom_memcache_info.cpp -o /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_info

sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_start /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_get /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_set /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_stop /usr/bin/
sudo mv /home/ubuntu/tom_calendar/lib/tom_memcache/tom_memcache_info /usr/bin/
