#!/bin/bash

#ip=104.238.184.106
#ip=95.179.231.95
ip=45.76.133.116

page=/usr/share/nginx/html/index.html

sed -i "s#http.*m3u8#http://$ip:8009/cn/live800/playlist.m3u8#" $page


