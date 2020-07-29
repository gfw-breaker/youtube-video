#!/bin/bash

baseDir=/usr/share/nginx/html
page=$baseDir/share.html

egrep "singlemessage|groupmessage" /var/log/nginx/access.log  | awk '{ print $1","$11 }' | cut -d'?' -f1 | sed 's/"//g' | grep -v ',-' | sort | uniq | cut -d',' -f2 | sort | uniq -c | sort -nr > ll.txt

cat > $page << EOF
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-s">
<style>
body {
	padding: 5px;
}
th, td {
    padding: 3px;
}
</style>
<b>
开始于： $start <br/>
观看量： total_count
</b><br/><br/>
<table border='1px' cellspacing='0'>
<tr><th>频道名称</th><th>观看量</th></tr>

EOF

total=0

while read line; do
	count=$(echo $line | awk '{ print $1 }')
	key=$(echo $line | awk '{ print $2 }')
	total=$(($total + $count))

	title=$(grep $key channels.csv | cut -d',' -f1)
	echo "<tr><td><a href='./$key' target='_blank' style='text-decoration:blink;'>$titlign:right;'>$count</td></tr>" >> $page	
done < ll.txt

sed -i "s/total_count/$total/" $page


