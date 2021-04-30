#! /usr/bin/bash

/home/ubuntu/tom_calendar/lib/tom_memcache/build.sh
tom_memcache_stop > /dev/null
tom_memcache_start &
tput setaf 2
  echo "restarted tom_memcache"
tput setaf 0
