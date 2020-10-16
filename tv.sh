#!/bin/bash


ip=$(/sbin/ifconfig eth0 | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
if [ -z $ip ]; then
	ip=$(/sbin/ifconfig eth0 | grep "broadcast" | awk '{print $2}')
fi


#ip=141.164.45.19

page=/usr/share/nginx/html/index.html
yt=/usr/share/nginx/html/youtube.html

#sed -i "s#http.*m3u8#http://$ip:8009/cn/live800/playlist.m3u8#" $page

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
<a href='http://$ip:11000/show.aspx?name=ogHome'>网门免翻墙，一键浏览全球精粹资源 头条、影视、音乐、书刊、直播</a><br/>

EOF

#<a href='http://$ip:10000/videos/res2/djy-news/'>大紀元新聞網YouTube频道</a><br/>
#<a href='http://$ip:10000/videos/res2/ntd-news/'>新唐人電視臺YouTube频道</a><br/>
#<a href='http://$ip:10000/videos/res2/soh-news/'>希望之聲時事熱點YouTube频道</a><br/>

ts=$(date "+%m%d%H%m")

while read line ; do
	title=$(echo $line | cut -d',' -f1)
	folder=$(echo $line | cut -d',' -f3)
	echo "<a href='/$folder/?ts=$ts'>$title</a><br/>" >> $yt
done < channels.csv


serverName=$(hostname)

wget https://raw.githubusercontent.com/gfw-breaker/banned-news3/master/pages/link5.md -O target.md

targetIp=$(cat target.md  | sed -n 5p | awk -F'/' '{ print $3 }' | cut -d':' -f1)
redirectIp=$(cat redirect)

echo $ip , $targetIp , $redirectIp

if [[ $targetIp == $ip ]]; then
	echo "not target server"
	exit
fi

if [[ $serverName =~ 'ogate' ]]; then
	cd /root/open-proxy
	./redirect.sh $redirectIp
fi


