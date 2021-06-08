#! /usr/bin/bash

sudo killall -v tomcalendar_app_server
/var/www/cgi-bin/tom_calendar/lib/tomcalendar_app_server/tomcalendar_app_server 34000 &
tput setaf 2
  echo "restarted tomcalendar_app_server"
tput setaf 0
