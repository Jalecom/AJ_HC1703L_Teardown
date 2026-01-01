#!/bin/sh

# By ANT-THOMAS, mods and comments by Jalecom
#############################################

# include config and log in a new log.txt (if $log is not false)
. /mnt/config.txt
$log && echo "-01 debug_cmd started, config.txt loaded" > /mnt/log.txt


# and log the config.txt was acquired properly
$log && echo "-02 config.txt acquired, HACKTYPE $HACKTYPE" >> /mnt/log.txt

#############################################
#											#
#	A) check if /home folder is RW			#
#	   select the hack type and				#
#	   then run the T/P/SD script			#
#											#
#############################################

$log && echo "-03 check the HACKTYPE" >> /mnt/log.txt
if [ "$HACKTYPE" = "NO" ]; then
	# no hack defined, exit and continue with the standard boot.
	rm /home/minihack.sh
	rm /home/HACKSD
	rm /home/HACKT
	rm /home/HACKP
	exit 0
else
	# check if /home folder is writable
	ls /home/HACK* >/dev/null 2>&1 || touch /home/HACK
fi

# check the /home folder is RW before continue otherwise reboot continuously
$log && echo "-04 check the /home folder is RW" >> /mnt/log.txt
if [ ! /home/HACK* >/dev/null 2>&1 ]; then
	echo "Can't write on /home folder" > /mnt/nowrite.txt
	sleep 10
	echo "...reboot!"
	reboot
fi

# call ramhack.sh or minihack.sh and fallback on HACKSD in case of error
$log && echo "-05 check the T or P option" >> /mnt/log.txt
case "$HACKTYPE" in
	T)
		/mnt/hack/ramhack.sh && exit
		;;
	P)
		[ -f /home/minihack.sh ] && /home/minihack.sh && exit
		[ ! -f /home/minihack.sh ] && /mnt/hack/minihack.sh && exit
		;;
esac

#############################################
#											#
#	B) run the hack from SD card; exit		#
#	   from HACKT OR HACKP fallback here.	#
#											#
#############################################

# confirm hack type: it will be visible on webui
$log && echo "-06 execute the hack on the SD" >> /mnt/log.txt
[ ! -f /home/HACKSD ] && touch /home/HACKSD
rm /home/HACKT
rm /home/HACKP
rm /home/HACK

# install updated version of busybox in the exported PATH
$log && echo "-07 execute the hack on the SD" >> /mnt/log.txt
mkdir -p /tmp/busybox
mount --bind /mnt/hack/busybox /bin/busybox
/bin/busybox --install -s /tmp/busybox

# overwrite temporary the original hosts file with the new one on the SD to prevent cloud connections
$log && echo "-08 mount new hosts" >> /mnt/log.txt
mount --bind /mnt/hack/hosts.new /etc/hosts

# run httpd on SD updated busybox
# /mnt/hack/busybox httpd -p 80 -h ./tmp/mnt/hack/www
# run httpd from hack updated busybox testing several ports
$log && echo "-09 start httpd" >> /mnt/log.txt
for port in 80 8080 8090; do
    if /mnt/hack/busybox httpd -p "$port" -h "/mnt/hack/www"; then
        $log && echo "    httpd started on :$port" >> /mnt/log.txt
        break
    fi
done

# set new env
$log && echo "-10 mount profile" >> /mnt/log.txt
mount --bind /mnt/hack/profile /etc/profile

# possibly needed but may not be: the shadow file contain hash of the password cxlinux
# if you don't need a password uncomment the lines below
$log && echo "-11 then group, passwd and shadow" >> /mnt/log.txt
mount --bind /mnt/hack/group /etc/group
mount --bind /mnt/hack/passwd /etc/passwd
mount --bind /mnt/hack/shadow /etc/shadow

# setup and install dropbear ssh server - cxlinux or no password login
$log && echo "-12 start dropbear" >> /mnt/log.txt
/mnt/hack/dropbearmulti dropbear -r /mnt/hack/dropbear_ecdsa_host_key -B

# start ftp server on SD updated busybox
$log && echo "-13 start ftpd" >> /mnt/log.txt
(/mnt/hack/busybox tcpsvd -E 0.0.0.0 21 /mnt/hack/busybox ftpd -w / ) &

#################################################################################
# let the start.sh continue and run p2pcam then run with >20s delay the commands:
$log && echo "-14 waiting for silencing and wifi connection" >> /mnt/log.txt

# silence the voice WaitWifiConfig.wav copied every reboot from start.sh line 414 or 436
(sleep 25 && rm /tmp/VOICE/WaitWifiConfig.wav) &

# setup WiFi connection after 30s
# insert the SSID and PWD of your WiFi
(sleep 30 && /mnt/hack/wifi.sh $SSID $PWD && httpclt get 'http://127.0.0.1:8001/playaudio?file=/mnt/RunSD.wav') &

$log && echo "-   SSID:$SSID" >> /mnt/log.txt
$log && echo "-   PWD :$PWD" >> /mnt/log.txt
$log && echo "-15 EndOfScript" >> /mnt/log.txt

#	<EOF>

