#! /usr/bin/bash


rsync -avzhe ssh ../tom_calendar/ ubuntu@tomcalendar.com:/home/ubuntu/

ssh ubuntu@tomcalendar.com "deploy_tom_calendar.sh"
