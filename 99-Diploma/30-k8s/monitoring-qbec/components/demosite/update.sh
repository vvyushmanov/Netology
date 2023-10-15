#!/bin/bash

mv demosite.tgz demosite.tgz.bak
helm pull demosite/demosite && mv ./demosite*.tgz ./demosite.tgz