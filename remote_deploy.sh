#! /usr/bin/bash

date = $(date)

git add .
git status
git commit -m "remote deploy $(date)"
git push origin master

ssh ubuntu@tomcalendar.com "cd /home/ubuntu/tom_calendar && git pull origin master"

ssh ubuntu@tomcalendar.com "deploy_tom_calendar.sh"
