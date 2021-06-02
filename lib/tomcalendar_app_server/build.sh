#! /usr/bin/bash
# @remember: should do somehting about these directory paths

g++ -std=c++14 /var/www/cgi-bin/tom_calendar/lib/tomcalendar_app_server/src/tomcalendar_forward.cpp -o /var/www/cgi-bin/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward

sudo mv /var/www/cgi-bin/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward /usr/bin/
