#!/bin/bash
# author: gfw-breaker

channel=$1
csv=videos.txt

data_server=
server_port=80
index_page=index.html
nginx_dir=/usr/share/nginx/html

if [ ! -z $channel ]; then
	grep $channel $csv > tmp.csv
	csv=tmp.csv
fi

baseUrl="https://www.youtube.com"
cwd=/root/youtube-video

cd $cwd
youtube-dl -U
git pull

ip=$(/sbin/ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
ts=$(date '+%m%d%H')

if [ "$data_server" == "" ]; then
	data_server=$ip
fi

while read line; do
	folder=$(echo $line | cut -d'|' -f1)
	id=$(echo $line | cut -d'|' -f2)
	title=$(echo $line | cut -d'|' -f3)
	
	video_dir=$nginx_dir/$folder
	mkdir -p $video_dir; cd $video_dir
	vname=_$id
	if [ -f $vname.mp4 ]; then
		echo "$vname.mp4 exists"
	else
		youtube-dl -o "_%(id)s.%(ext)s" -f 18 -- $id
		wget https://img.youtube.com/vi/$id/hqdefault.jpg -O _$id.jpg
	fi

	sed -e "s/videoFile/$vname/g" -e "s/videoFolder/$folder/g" \
		-e "s/videoTitle/$title/g" -e "s/proxy_server_ip/$ip/g" \
		 /root/youtube-video/template.html > $video_dir/$vname.html 

	grep -- $id list.txt > /dev/null 2>&1
	
	if [ $? -eq 0 ]; then
		echo 'ok'	
	else
		touch list.txt
		cat list.txt > tmp
		echo "$id|$title" > list.txt	
		cat tmp >> list.txt
	fi

done < $csv


channels=$(ls -l $nginx_dir | grep ^d | awk '{ print $9 }')

for folder in $channels; do
	video_dir=$nginx_dir/$folder

	cd $video_dir

	oldItems=$(sed -n '11,$p' list.txt | cut -d'|' -f1)
	for old in $oldItems; do
		echo "deleting : _$old.mp4"
		rm "_$old.*"
	done

	sed -i '11,$d' list.txt
	
	cat > $index_page << EOF
<html>
<head>
<meta charset="utf-8" /> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
</head>
<body>
EOF

sed "s/proxy_server_ip/$ip/g" /root/youtube-video/links.html >> $index_page

	while read video; do
			id=$(echo $video | cut -d'|' -f1)
			title=$(echo $video | cut -d'|' -f2)
			echo "<a href='http://$ip:$server_port/$folder/_$id.html'><b>$title</b></a></br></br>" >> $index_page
	done < list.txt

done

