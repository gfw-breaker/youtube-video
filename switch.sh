#!/bin/bash

real=/usr/bin/youtube-dl
fake=/usr/bin/youtube-dll

if [ -f $real ]; then
	mv $real $fake
	echo "disable youtube-dl"
else
	mv $fake $real
	echo "enable youtube-dl"
fi
	
