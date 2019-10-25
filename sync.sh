#!/bin/bash
# author: gfw-breaker

channel=$1
csv=channels.csv

if [ ! -z $channel ]; then
	grep $channel $csv > tmp.csv
	csv=tmp.csv
fi

baseUrl="https://www.youtube.com"
cwd=/root/youtube-video

youtube-dl -U
git pull

cd $cwd
while read line; do
	name=$(echo $line | cut -d',' -f1)
	id=$(echo $line | cut -d',' -f2)
	folder=$(echo $line | cut -d',' -f3)
	sticky=$(echo $line | cut -d',' -f4)
	channelUrl=$baseUrl/$id
	bash $cwd/dl.sh -f $folder -u $channelUrl -s $sticky
done < $csv
