#!/bin/bash

ip=104.238.184.106

page=/usr/share/nginx/html/index.html

sed -i "s#http.*m3u8#http://$ip:8009/cn/live800/playlist.m3u8#" $page


