#! /usr/bin/bash
# @remember: should do somehting about these directory paths

g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/src/tomcalendar_forward.cpp -o /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward.tomexe
g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/src/get_tomcalendar_server_count.cpp -o /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_server_count

sudo mv /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_server_count /usr/bin/
