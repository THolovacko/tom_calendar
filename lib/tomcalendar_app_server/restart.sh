#! /usr/bin/bash

# @remember: should probably have port ranges be environment variables

sudo killall -v tomcalendar_app_server
server_count=$(tomcalendar_server_count)
start_port_range=34000
end_port_range=$((start_port_range + server_count - 1))
for (( i=34000; i<=end_port_range; i++ ))
do
  /var/www/cgi-bin/tom_calendar/lib/tomcalendar_app_server/tomcalendar_app_server $i &
done
tput setaf 2
  echo "restarted tomcalendar_app_server"
tput setaf 0
