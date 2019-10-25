#!/bin/bash

channel=$1
vid=$2
fname=$3

youtube-dl -f 18 --restrict-filenames $vid

mv *.mp4 "$fname-$vid.mp4"

mv "$fname-$vid.mp4" /usr/share/nginx/html/$channel

ls -lh /usr/share/nginx/html/$channel/*-$vid.mp4


