#!/bin/bash

port=81
videoHome=/usr/share/nginx/html

yum install -y qrencode

ip=$(/sbin/ifconfig eth0 | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
if [ -z $ip ]; then
	ip=$(/sbin/ifconfig eth0 | grep "broadcast" | awk '{print $2}')
fi

cd /root/youtube-video

ts=$(date "+%m%d%H%m")

while read line ; do
	title=$(echo $line | cut -d',' -f1)
	folder=$(echo $line | cut -d',' -f3)
	url="http://$ip:$port/$folder/?t=$ts"
	path=$videoHome/$folder/qr.png
	qrencode -o $path -s8 $url
	echo $url
done < channels.csv


