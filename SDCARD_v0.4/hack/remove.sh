#!/bin/sh

# By Jalecom
###############################################
# remove permanent version from /bak folder
# and restore the original sensor.sh file
# 
# usually it is enough to set HACKTYPE=NO in config.txt
# and it is not mandatory to restore the original file 

	rm /home/minihack.sh
	rm /home/config.txt
	rm /home/HACK*
	rm /home/log.txt
	mount -o rw,remount /bak
	[ -f /bak/sensor.orig ] && chmod 777 /bak/sensor.sh && mv /bak/sensor.orig sensor.sh && echo "sensor restored"
	rm -r /bak/hack
	

#	<EOF>

