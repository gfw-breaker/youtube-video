#!/bin/bash

egrep "singlemessage|groupmessage" /var/log/nginx/access.log  | awk '{ print $1","$11 }' | cut -d'?' -f1 | sed 's/"//g' | grep -v ',-' | sort | uniq | cut -d',' -f2 | sort | uniq -c | sort -n

