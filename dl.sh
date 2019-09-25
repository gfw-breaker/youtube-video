#!/bin/bash
# author: gfw-breaker

video_count=6

while getopts "f:u:s:a" arg; do
	case $arg in
		f)
			folder=$OPTARG
			;;
		u)
			youtube_url=$OPTARG
			;;
		s)
			stick=$OPTARG
			;;
		a)
			get_audio=1
			;;
	esac
done

data_server=
server_port=80
video_dir=/usr/share/nginx/html/$folder
index_page=$video_dir/index.html
batch_page=$video_dir/batch.html
md_page=$video_dir/index.md

ip=$(/sbin/ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
ts=$(date '+%m%d%H')

if [ "$data_server" == "" ]; then
	data_server=$ip
fi

# download videos
mkdir -p $video_dir
cd $video_dir
echo -e "\n\n======================\n\n" >> dl.log
#youtube-dl -f 133+140 \
youtube-dl -f 18 \
	--max-downloads $video_count \
	--playlist-end 20 \
	-i $youtube_url | tee dl.log

if [ $stick ]; then
	youtube-dl -f 18 -i "https://www.youtube.com/watch?v=$stick"
	touch -- *$stick*
fi


# remove duplicated videos
rm -fr -- *.tmp
ls -t *mp4 | grep -v ^link > all.txt
while read line ; do
        vid=$(echo $line | rev | cut -c5-15 | rev )
        if [ ! -f $vid.tmp ]; then
                touch -- $vid.tmp
        else
                rm "$line"
        fi
done < all.txt


# relink
for link in $(ls link*.mp4); do
	if [ ! -f $link ]; then
		id=$(echo $link | cut -d'.' -f3)
		rm $link
		ln -s *-$id.mp4 $link
	fi
done


# remove old videos
ls -t *mp4 | grep -v ^link | sed -n '18,$p' > deleted.txt
while read v ; do
	echo "removing $v ..."
	rm "$v"
done < deleted.txt


# generate page
echo > $md_page
cat > $index_page << EOF
<html>
<head>
<meta charset="utf-8" /> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
</head>
<body>
<a href='http://$ip:10000/videos/res/hk/'><b>香港反送中</b></a> &nbsp;&nbsp;
<a href='http://$ip:10000/videos/blog/weihuo.html'><b>天安门自焚真相</b></a> &nbsp;&nbsp;
<a href='http://$ip:10000/videos/res/Organs/'><b>器官活摘</b></a> &nbsp;&nbsp;
<a href='http://$ip:10000/videos/88/'><b>8964天安门大屠杀<b></a></br></br>
<a href='http://$ip:10000/videos/res/big-shorts'><b>揭秘央视运作手法幽默讽刺剧《大裤衩》</b></a>&nbsp;&nbsp;
<a href='http://$ip:10000/videos/res/comedy/'><b>新唐人时事小品</b></a> </br></br> 

EOF

ls -t *.mp4 | grep -v ^link > list.txt

while read v; do
	vid=$(echo $v | rev | cut -c5-15 | rev)
	name="link.$ts.$vid.mp4"
	title=$(echo $v | rev | cut -c17- | rev | sed 's/法轮功/法.轮.功/g' | sed 's/退/.退./g' | sed 's/党/.党/g' | sed 's/摘/.摘/g' ) 

	# download thumbnail
	thumbnail="$vid.jpg"
	if [ ! -f $thumbnail ]; then
		wget -q "https://i.ytimg.com/vi/$vid/sddefault.jpg" -O "$thumbnail"
	fi	

	# generate page
	ln -s "$v" "$name" > /dev/null 2>&1
	echo "<a href='http://$ip:$server_port/$folder/$name.html'><b>$title</b></a></br></br>" >> $index_page
	echo "##### <a href='http://$ip:$server_port/$folder/$name.html'>$title</a>" >> $md_page

cat > $video_dir/$name.html << EOF
<html>
<head>
<title> $title </title>
<meta charset="UTF-8"> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<script src="https://cdn.bootcss.com/video.js/7.5.0/video.min.js"></script>
<script src="https://cdn.bootcss.com/videojs-contrib-hls/5.15.0/videojs-contrib-hls.min.js"></script>
<link rel='stylesheet' id='videojs-css' href='https://cdn.bootcss.com/video.js/7.5.0/video-js.min.css' type='text/css' media='all' />
<style>
h4 {
	margin-top: 20px;
}
p b {
	font-size: 15px;
}
#player {
	margin: 0 auto;
	margin-top: 20px;
	width: 100%;
	max-width: 640px;
	height: 360px;
}
.video-js .vjs-big-play-button{
    height: 2.5em;
    width: 2.5em;
    line-height: 2.5em;
    border-radius: 2.5em;
}
@media (max-width : 700px) {
	#player {
		height: 220px;
	}
}
</style>
</head>
<body>
<h4><center>$title</center></h4>
<center><span id='p' style='color:red'>微信中无法正常打开时，请点击右上角的"..."，点击"在Safari中打开"或者"在浏览器打开"，然后点击左上角"原网页"</span></center>
<center>
<video id=player class="video-js vjs-default-skin vjs-big-play-centered" controls preload="auto" autoplay poster="$thumbnail">
  <source
     src="http://$data_server:88/hls/$folder/$name/index.m3u8"
     type="application/x-mpegURL">
</video>
<script>
    var ua = navigator.userAgent.toLowerCase();
    var isWeixin = ua.indexOf('micromessenger') != -1;
    if (! isWeixin) {
		document.getElementById("p").innerHTML="";
    }
</script>
<script type="text/javascript">
    var player = videojs('player');
</script>
<span style='color:red; font-size:14px; margin-bottom:100px'>服务器被封锁越来越频繁，建议及时下载视频后观看</span>
<p>
<a href="https://github.com/gfw-breaker/guides/wiki" target="_blank"><b>手把手翻墙教程</b></a>&nbsp;&nbsp;
<a href="https://github.com/gfw-breaker/nogfw/blob/master/README.md" target="_blank"><b>翻墙软件</b></a>&nbsp;&nbsp;
<a href="https://github.com/gfw-breaker/ssr-accounts" target="_blank"><b>免费SS账号</b></a>&nbsp;&nbsp;
<a href="https://github.com/oGate2/oGate" target="_blank"><b>网门</b></a>&nbsp;&nbsp;
<a href="http://$data_server:$server_port/$folder/$name" target="_blank"><b>下载视频</b></a>&nbsp;&nbsp;
<a href="http://$data_server:$server_port/$folder/batch.html"><b>批量下载</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10080"><b>大纪元新闻网</b></a>&nbsp;&nbsp;
<a href="http://$ip:8000"><b>新唐人电视台</b></a>&nbsp;&nbsp;
<a href="http://$ip:8200"><b>希望之声</b></a>&nbsp;&nbsp;
<a href="http://$ip:10010"><b>追查国际</b></a>&nbsp;&nbsp;
<a href="http://$ip:9800"><b>自由亚洲电台</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port"><b>新唐人电视直播</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10000/videos/truth.html"><b>法轮功真相</b></a>&nbsp;&nbsp;
<a href="http://$ip:10000/videos/res/Organs/"><b>活摘器官</b></a>&nbsp;&nbsp;
<a href="http://$ip:10000/videos/709/"><b>维权律师大抓捕</b></a>&nbsp;&nbsp;
<a href="http://$ip:10000/videos/res/jiuping/"><b>《九评共产党》</b></a>&nbsp;
<a href="http://$ip:10000/videos/ccp.html"><b>共产党百年历史</b></a>&nbsp;
<br/><br/>
<a href="http://$ip:$server_port/tianliang/"><b>天亮时分</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port/wenzhao/"><b>文昭谈古论今</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port/today-in-history/"><b>历史上的今天</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port/ntdtv-comedy/"><b>大陆新闻解读</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port/ntdtv-news/"><b>中国禁闻</b></a>&nbsp;&nbsp;
<a href="http://$ip:$server_port/ntdtv-rdhd/"><b>热点互动</b></a>&nbsp;
<br/><br/>
</p>
</center>
</body>
</html>
EOF

done < list.txt

echo "</body></html>" >> $index_page

# batch page
sed 's/\.html//g' $index_page > $batch_page
sed -i 's/<body>/<body><h2>视频批量下载页面<\/h2>/g' $batch_page

# commit
plinks="##### 反向代理： [新唐人直播](http://$ip) &nbsp;|&nbsp; [Google](http://$ip:8888/search?q=425事件) &nbsp;|&nbsp; [维基百科](http://$ip:8100/wiki/喬高-麥塔斯調查報告) &nbsp;|&nbsp; [大纪元新闻网](http://$ip:10080) &nbsp;|&nbsp; [新唐人电视台](http://$ip:8000) &nbsp;|&nbsp; [我的博客](http://$ip:10000/) &nbsp;|&nbsp; [追查国际](http://$ip:10010)"
vlinks="##### 精彩视频： [《传奇时代》](http://$ip:10000/videos/legend/) | [《风雨天地行》](http://$ip:10000/videos/fytdx/) | [《九评共产党》](http://$ip:10000/videos/jiuping/) | [《漫谈党文化》](http://$ip:10000/videos/mtdwh/) | [《百年红祸》](http://$ip:10000/videos/bnhh) |&nbsp; [709维权律师](http://$ip:10000/videos/709/)"

#sed -i "4 a$vlinks" $md_page
#sed -i "4 a$plinks" $md_page


## clean up
cd $video_dir
dated=$(ls -t link*mp4 | sed -n '2000,$p')
for f in $dated; do
	echo "removing $f ..."
	rm $f
	rm $f.html
done


# push
#cd /root/$folder
#git pull 
#cat desc.md > README.md
#cat $md_page >> README.md
#cp README.md $video_dir
#git commit -a -m 'ok'
#git push


## convert audio
if [ "$get_audio" == "" ]; then
	exit
fi

cd $video_dir
while read v; do
	vid=$(echo $v | rev | cut -c5-15 | rev)
	audio="$vid.mp3"
	if [ -f "$audio" ]; then
		echo "skipping $audio ..."
		continue
	fi
	ffmpeg -i "$v" -b:a 64k -vn "$audio" </dev/null
done < list.txt


