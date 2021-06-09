#! /usr/bin/bash

#rm /home/ubuntu/tom_calendar/actions/*.rvmbin
for f in /home/ubuntu/tom_calendar/actions/*; do
  /home/ubuntu/tom_calendar/lib/compile_ruby_to_vm_bin "$f" > /dev/null
done
