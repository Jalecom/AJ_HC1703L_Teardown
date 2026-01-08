#!/bin/sh

# By Jalecom, thanks to Seannreynolds and Pawol
###############################################
#
#  TEMPORARY VERSION OF THE HACK -> ramhack.sh
#
# On some devices, running a binary off the SD card stops p2pcam from mounting or accessing the card properly.
# So, with this temporary option, the hack gets saved to /tmp/hack (that’s in RAM) and runs from there. 
#


Dpath="/tmp" # this folder is in RAM and it is lost every reboot

# include config
[ ! -f /home/config.txt ] && cp /mnt/config.txt /home && chmod 777 /home/config.txt
. /home/config.txt

if [ ! -d $Dpath/hack ]; then
    cp -r /mnt/hack $Dpath
	if [ $? -eq 0 ]; then
		# confirm hack type: it will be visible on webui
		[ ! -f /home/HACKT ] && touch /home/HACKT
		rm /home/HACKSD
		rm /home/HACKP
		rm /home/HACK
		rm /home/HACK_copy_error
		chmod -R 644 /tmp/hack
		chmod +x $Dpath/hack/busybox
		chmod +x $Dpath/hack/dropbearmulti
		chmod +x $Dpath/hack/wifi.sh
		chmod +x $Dpath/hack/www/cgi-bin/webui
	else
		# error on the folder copy
		touch /home/HACK_copy_error
		echo "Failed to copy the hack folder to" $Dpath
		exit 1
	fi
fi

# temporary install updated version of busybox in /tmp/busybox
mkdir -p /tmp/busybox
mount --bind /tmp/hack/busybox /bin/busybox
/bin/busybox --install -s /tmp/busybox

# overwrite temporary the original hosts file with the new one from the hack to prevent cloud connections
mount --bind $Dpath/hack/hosts.new /etc/hosts

# run httpd from hack updated busybox testing several ports
for port in 80 8080 8090; do
    if $Dpath/hack/busybox httpd -p "$port" -h "$Dpath/hack/www"; then
        $log && echo "httpd started on :$port" > /home/log.txt
        break
    fi
done

# set new env
mount --bind $Dpath/hack/profile /etc/profile

# force updated version of busybox
mount --bind $Dpath/hack/busybox /bin/busybox

# possibly needed but may not be: the shadow file contain hash of the password cxlinux
# if you don't need a password comment the lines below
mount --bind $Dpath/hack/group /etc/group
mount --bind $Dpath/hack/passwd /etc/passwd
mount --bind $Dpath/hack/shadow /etc/shadow

# setup and install dropbear ssh server - cxlinux or no password login
$Dpath/hack/dropbearmulti dropbear -r $Dpath/hack/dropbear_ecdsa_host_key -B

# start ftp server from hack updated busybox
($Dpath/hack/busybox tcpsvd -E 0.0.0.0 21 $Dpath/hack/busybox ftpd -w / ) &

#################################################################################
# let the start.sh continue and run p2pcam then run with >20s delay the commands:

# silence the voice WaitWifiConfig.wav copied every reboot from start.sh line 414 or 436
(sleep 25 && rm /tmp/VOICE/WaitWifiConfig.wav) &

# setup WiFi connection after 30s
# use the SSID and PWD of your WiFi from the config.txt
(sleep 30 && $Dpath/hack/wifi.sh $SSID $PWD) &

#	<EOF>
