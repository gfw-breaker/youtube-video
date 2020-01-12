#!/bin/bash

ip=$1
base=/usr/share/nginx/html

while read line; do
	folder=$(echo $line | cut -d',' -f3)
	cat > $base/$folder/index.html << EOF
<meta charset="utf-8" /> 
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<meta http-equiv="refresh" content="0; url='http://$ip/home.html'">
稍等片刻 ......

EOF

done < channels.csv

