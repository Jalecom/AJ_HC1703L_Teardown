This folder is for reference only and contain the old versions of the file requested to open ssh, ftp and http to interact with the Augentix HC1703L IP camera.
Read please https://github.com/Jalecom/AJ_HC1703L_Teardown/ for more info.

### Short info ###

Enable the last line of this dedug_cmd.sh and insert your WiFi credentials or the camera will act as AP at address 192.168.200.1
The debug_cmd.sh will be called from your start.sh in the boot process, it runs off the SD card a web server on port 80 at the adress assigned by your router to the camera (192.168.200.1 if it acts as Access Point).
This is a simple version of the hack where the updated busybox is only used for httpd and ftpd; as the new busybox is not overwritten to the old one in the camera, to call the new fonction /mnt/hack/busybox have to be used.
The same hack folder of v0.4 can be used on the SD
                                                                                                                                                                            

#############################################
#
#	Connection to your WiFi
#
#	the p2pcam binary ask usually for registration to the chinese cloud then for your WiFi credential and position;
#	if you don't like it, you can connect to your WiFi using the wifi.sh script writing here below your credentials
#	and it will try to connect the SoC wlan0 interface to your WiFi automatically;
#	it request an IP to your DHCP an assign hostname:Augentix, then syncronize the clock via pool.ntp.org
#	by dafault (=without credential) no attempt to connect to the WiFi 
#	NOTE: The WiFi.sh bring down any existing connection and try to connect to your AP
#
#	You can even call it manually from SSH/telnet -> usage: wifi.sh <SSID> <PWD>
#
#
#<EOF>
