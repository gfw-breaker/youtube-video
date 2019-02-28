#!/bin/bash
# author: gfw-breaker

baseUrl="https://www.youtube.com"

while read line; do
	name=$(echo $line | cut -d',' -f1)
	id=$(echo $line | cut -d',' -f2)
	folder=$(echo $line | cut -d',' -f3)
	sticky=$(echo $line | cut -d',' -f4)
	channelUrl=$baseUrl/$id

	mkdir -p /root/$folder
	cd /root/$folder
	bash dl.sh -f $folder -u $channelUrl -s $sticky
done < channels.csv
