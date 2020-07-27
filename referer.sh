#!/bin/bash

c1=$(grep fromvideos /var/log/nginx/access.log | grep "GET /gb/" | awk '{ print $1 }' | sort | uniq | wc -l)

c2=$(egrep "singlemessage|groupmessage" /var/log/nginx/access.log  | awk '{ print $1 }' | sort | uniq  | wc -l)

c3=$(egrep "nsukey" /var/log/nginx/access.log  | awk '{ print $1 }' | sort | uniq  | wc -l)

c4=$(grep -v '" 403 ' /var/log/nginx/access.log  | awk '{ print $1 }' | sort | uniq  | wc -l)

echo "From YouTube : $c1"
echo "From WeChat  : $c2"
echo "WeChat Users : $c3"
echo "Total Users  : $c4"

