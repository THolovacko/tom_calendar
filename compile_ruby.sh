#! /usr/bin/bash

for f in actions/*; do
  ./lib/compile_ruby_to_vm_bin "$f"
done
