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
<title> YouTube 热门节目 </title>
<style>
.channel {
    border-bottom: #80808038;
    height: 40px;
    border-bottom-style: groove;
    margin-bottom: 1px;
	font-size: large;
}

.icon {
	height: 40px;
	float: left;
}

.desc {
	padding-left: 10px;
	height: 40px;
	line-height: 40px;
	float: left;
}
img {
	height: 40px;
	width: 40px;
}
</style>
</head>
EOF

#<a href='http://$ip:10000/videos/res2/djy-news/'>大紀元新聞網YouTube频道</a><br/>
#<a href='http://$ip:10000/videos/res2/ntd-news/'>新唐人電視臺YouTube频道</a><br/>
#<a href='http://$ip:10000/videos/res2/soh-news/'>希望之聲時事熱點YouTube频道</a><br/>

ts=$(date "+%m%d%H%m")

while read line ; do
	title=$(echo $line | cut -d',' -f1)
	folder=$(echo $line | cut -d',' -f3)
	#echo "<a href='/$folder/?ts=$ts'>$title</a><br/>" >> $yt
cat >> $yt <<EOF
<div class="channel">
	<a href="/$folder/?ts=$ts">
		<div class="icon"><img src="/$folder/index.jpg"/></div>
		<div class="desc">$title</div>
	</a>
</div>
EOF
done < channels.csv

echo "<br/><br/><br/><br/>" >> $yt

