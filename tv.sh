#!/bin/bash


ip=$(/sbin/ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
if [ -z $ip ]; then
	ip=$(/sbin/ifconfig | grep "broadcast" | awk '{print $2}')
fi


#ip=141.164.45.19

page=/usr/share/nginx/html/index.html
yt=/usr/share/nginx/html/youtube.html

sed -i "s#http.*m3u8#http://$ip:8009/cn/live800/playlist.m3u8#" $page

cd /root/youtube-video

cat > $yt << EOF
<html>
<head>
<meta charset="utf-8" /> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title> YouTube 节目列表 </title>
<style>
a {
	margin: 60px;
	line-height: 160%;
}
</style>
</head>
<body>
<br/>
<b>
<a href='/'>新唐人电视直播</a><br/>
EOF

while read line ; do
	title=$(echo $line | cut -d',' -f1)
	folder=$(echo $line | cut -d',' -f3)
	echo "<a href='/$folder/'>$title</a><br/>" >> $yt
done < channels.csv

