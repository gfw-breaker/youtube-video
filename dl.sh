#!/bin/bash
# author: gfw-breaker

video_count=50

if [ $# -ne 2 ]; then
	echo "please specify folder and url. exiting ..."
	exit 1
fi

folder=$1
youtube_url=$2

video_dir=/usr/share/nginx/html/$folder
index_page=$video_dir/index.html
md_page=$video_dir/index.md

ip=$(/sbin/ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)
ts=$(date '+%m%d%H')


# download videos
mkdir -p $video_dir
cd $video_dir
youtube-dl -f 18 \
	--max-downloads $video_count \
	--playlist-end 200 \
	-i $youtube_url


# generate page
echo > $md_page
cat > $index_page << EOF
<html>
<head>
<meta charset="utf-8" /> 
</head>
<body>
EOF

ls -t *.mp4 | grep -v ^link- > list.txt

while read v; do
	vid=$(echo $v | rev | cut -c5-15)
	name="link-$vid-$ts.mp4"
	title=$(echo $v | rev | cut -c17- | rev | sed 's/法轮功/法.轮.功/g' | sed 's/退/.退./g' | sed 's/党/.党/g' | sed 's/摘/.摘/g' ) 
	
	ln -s "$v" "link-$vid-$ts.mp4" 
	echo "<a href='http://$ip/$folder/$name.html'><b>$title</b></a></br></br>" >> $index_page
	echo "##### <a href='http://$ip/$folder/$name.html'>$title</a>" >> $md_page

cat > $video_dir/$name.html << EOF
<head>
<title> $title </title>
<meta charset="UTF-8"> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<link rel='stylesheet' id='videojs-css' href='https://unpkg.com/video.js@6.7.3/dist/video-js.min.css' type='text/css' media='all' />
<style>
#player {
	margin: 0 auto;
	margin-top: 20px;
	width: 100%;
	max-width: 640px;
}
</style>
</head>
<br/>
<h4><center>$title</center></h4>
<center>
<video id="player" controls autoplay preload="auto">
	<source src="$name" type="video/mp4">
</video>
<p>
<a href="https://github.com/gfw-breaker/nogfw/blob/master/README.md" target="_blank"><b> 一键翻墙软件</b></a>&nbsp;&nbsp;
<a href="http://$ip:10080" target="_blank"><b>大纪元新闻网</b></a>&nbsp;&nbsp;
<a href="http://$ip:8000" target="_blank"><b>新唐人电视台</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10080/gb/8/11/24/n2339512.htm"><b>文昭：生活在希望中，做快乐的中国人</b></a>
<br/><br/>
<a href="http://$ip:10000/videos/blog/tuid.html"><b>三退大潮席卷全球 三亿人觉醒见证中共末日</b></a>
<br/><br/>
<a href="http://$ip:10000/videos/jiuping/index.html"><b>《九评共产党》</b></a>&nbsp;&nbsp;
<a href="http://$ip:10000/videos/mtdwh/index.html"><b>《漫谈党文化》</b></a>&nbsp;&nbsp;
<a href="http://$ip:8000/xtr/gb/prog99.html"><b>《热点互动直播》</b></a>&nbsp;&nbsp;
<a href="http://$ip:8000/xtr/gb/prog109.html"><b>《大陆新闻解读》</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10000/videos/blog/weihuo.html"><b>天安门自焚真相《伪火》</b></a>&nbsp;&nbsp;
<a href="http://$ip:10000/videos/blog/425event.html"><b>“四‧二五”中南海万人上访始末</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10000/videos/res/organs.html"><b>中共摘取活体器官（基于国内新闻报导和采访，无可辩驳！）</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10000/videos/res/DeathByChina.html"><b>中美贸易战“剧本” -《致命中国：美国如何失去制造业基础》</b></a>&nbsp;&nbsp;
<br/><br/>
<a href="http://$ip:10000/videos/res/pence.html"><b>“伐共宣言”- 美国副总统彭斯在哈德逊研究所演讲</b></a>&nbsp;&nbsp;
<br/><br/>
</p>
</center>
EOF

done < list.txt

echo "</body></html>" >> $index_page


# commit
plinks="##### 反向代理： [Google](http://$ip:8888/search?q=425事件) - [维基百科](http://$ip:8100/wiki/喬高-麥塔斯調查報告) - [大纪元新闻网](http://$ip:10080) - [新唐人电视台](http://$ip:8000) - [希望之声](http://$ip:8200) - [神韵艺术团](http://$ip:8000/xtr/gb/prog673.html) - [我的博客](http://$ip:10000/)"
vlinks="##### 精彩视频： [《时事小品》](https://github.com/gfw-breaker/ntdtv-comedy/blob/master/README.md) - [《传奇时代》](http://$ip:10000/videos/legend/) - [《风雨天地行》](http://$ip:10000/videos/fytdx/) - [《九评共产党》](http://$ip:10000/videos/jiuping/) - [《漫谈党文化》](http://$ip:10000/videos/mtdwh/) - [709维权律师](http://$ip:10000/videos/709/)"

sed -i "3 a$vlinks" $md_page
sed -i "3 a$plinks" $md_page


