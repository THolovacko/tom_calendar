#! /usr/bin/bash

/home/ubuntu/tom_calendar/lib/tom_memcache/build.sh
tom_memcache_stop
tom_memcache_start &
