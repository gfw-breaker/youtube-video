#!/bin/bash

key=$1

if [ $# -eq 0 ]; then
	key="200"
fi

function filter(){
	grep $key /var/log/nginx/access.log	| grep -v " 200 0 "
}


c1=$(filter | grep fromvideos | grep "GET /gb/" | awk '{ print $1 }' | sort | uniq | wc -l)

c2=$(filter | egrep "singlemessage|groupmessage" | awk '{ print $1 }' | sort | uniq  | wc -l)

c3=$(filter | egrep "nsukey" | awk '{ print $1 }' | sort | uniq  | wc -l)

c4=$(filter | grep '"GET /' | grep -v '" 403 ' | awk '{ print $1 }' | sort | uniq  | wc -l)

c5=$(filter | grep -v '" 403 ' | grep -v '" 499' | grep 'GET /show.htm' | grep -v 'GET /show.aspx?name=og' | grep -v get_oopipe | wc -l)

echo "From YouTube : $c1"
echo "From WeChat  : $c2"
echo "WeChat Users : $c3"
echo "Total Users  : $c4"
echo "oGate Count  : $c5"

