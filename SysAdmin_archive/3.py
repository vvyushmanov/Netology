#!/bin/env python3

import os
import sys

# set current directory as default value if no arguments given
if len(sys.argv) == 1:
    path = os.getcwd()
    print('No directory provided - checking current')
else:
    path = sys.argv[1]

bash_command = ["cd " + path, "git status 2>&1"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('fatal: not a git repository (or any parent up to mount point /)') == 0:
        print('Selected directory is not a git repository!')
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.getcwd() + '/' + prepare_result)