#! /usr/bin/bash

#rm /home/ubuntu/tom_calendar/actions/*.rvmbin
#rm /home/ubuntu/tom_calendar/tasks/*.rvmbin
for f in /home/ubuntu/tom_calendar/actions/*; do
  /home/ubuntu/tom_calendar/tasks/compile_ruby_to_vm_bin "$f" > /dev/null
done
for f in /home/ubuntu/tom_calendar/background_tasks/*; do
  /home/ubuntu/tom_calendar/tasks/compile_ruby_to_vm_bin "$f" > /dev/null
done
