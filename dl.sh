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
	--playlist-end $video_count \
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
cat > $index_page << EOF
<html>
<head>
<meta charset="utf-8" /> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
</head>
<body>
EOF

cat /root/youtube-video/links.html >> $index_page

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

	sed -e "s/videoFile/$name/g" -e "s/videoFolder/$folder/g" \
		-e "s/videoTitle/$title/g" -e "s/proxy_server_ip/$ip/g" \
		 /root/youtube-video/template.html > $video_dir/$name.html 

done < list.txt

echo "</body></html>" >> $index_page

# batch page
sed 's/\.html//g' $index_page > $batch_page
sed -i 's/<body>/<body><h2>视频批量下载页面<\/h2>/g' $batch_page


## clean up
cd $video_dir
dated=$(ls -t link*mp4 | sed -n '2000,$p')
for f in $dated; do
	echo "removing $f ..."
	rm $f
	rm $f.html
done


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

