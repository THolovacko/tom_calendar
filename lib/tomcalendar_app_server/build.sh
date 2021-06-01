#! /usr/bin/bash
# @remember: should do somehting about these directory paths

g++ -std=c++14 /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/src/tomcalendar_forward.cpp -o /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward

sudo cp /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward /home/ubuntu/tom_calendar/actions/test_forward
sudo mv /home/ubuntu/tom_calendar/lib/tomcalendar_app_server/tomcalendar_forward /usr/bin/
