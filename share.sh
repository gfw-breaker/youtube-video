#!/bin/bash

egrep "singlemessage|groupmessage" /var/log/nginx/access.log  | awk '{ print $11 }' | cut -d'?' -f1 | sed 's/"//g' | sort  | uniq 


