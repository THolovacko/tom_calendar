#! /usr/bin/bash

grep -Er '@remember|@optimize|@test|@refactor' --color -n --exclude-dir=html --exclude=todo.sh
grep -Er '@current' --color -n --exclude-dir=html --exclude=todo.sh
