#!/bin/sh

# By ANT-THOMAS, mods and comments by Jalecom
#############################################
# HACKS HERE

# confirm hack type: it will be visible on webui
touch /home/HACKSD

# overwrite temporary the original hosts file with the new one on the SD to prevent cloud connections
mount --bind /mnt/hack/hosts.new /etc/hosts

# run httpd on SD updated busybox
/mnt/hack/busybox httpd -p 80 -h ./tmp/mnt/hack/www

# set new env
mount --bind /mnt/hack/profile /etc/profile

# possibly needed but may not be: the shadow file contain hash of the password cxlinux
# if you don't need a password uncomment the lines below
mount --bind /mnt/hack/group /etc/group
mount --bind /mnt/hack/passwd /etc/passwd
mount --bind /mnt/hack/shadow /etc/shadow

# setup and install dropbear ssh server - cxlinux or no password login
/mnt/hack/dropbearmulti dropbear -r /mnt/hack/dropbear_ecdsa_host_key -B

# start ftp server on SD updated busybox
(/mnt/hack/busybox tcpsvd -E 0.0.0.0 21 /mnt/hack/busybox ftpd -w / ) &

#################################################################################
# let the start.sh continue and run p2pcam then run with >20s delay the commands:

# copy wifi connection script on /tmp
# if [ ! -s /tmp/wdk.sh ];then cp /mnt/wdk.sh /tmp; fi
if [ ! -s /tmp/wifi.sh ];then cp /mnt/wifi.sh /tmp; fi

# silence the voice WaitWifiConfig.wav copied every reboot from start.sh line 414 or 436
(sleep 25 && rm /tmp/VOICE/WaitWifiConfig.wav) &

# setup WiFi connection after 40s
# insert the SSID and PWD of your WiFi
# (sleep 40 && /tmp/wifi.sh YourSSID YourPassword) &


