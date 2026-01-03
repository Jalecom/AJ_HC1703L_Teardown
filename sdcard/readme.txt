This folder is for reference only and contains old versions of the files used to open SSH, FTP, and HTTP to interact with the Augentix HC1703L IP camera
Read please https://github.com/Jalecom/AJ_HC1703L_Teardown/ for more info.

### Short info ###

Enable the last line of debug_cmd.sh and insert your Wi-Fi credentials; otherwise, the camera will act as an access point at address 192.168.200.1.
The debug_cmd.sh script is called from start.sh during the boot process. It runs, from the SD card, a web server on port 80 at the address assigned by your router to the camera (192.168.200.1 if it acts as an access point).
This is a simple version of the hack in which the updated BusyBox is used only for httpd and ftpd. Since the new BusyBox does not overwrite the original one on the camera, the new functions must be called using /mnt/hack/busybox.
The same hack folder from version v0.4 can be used on the SD card.
                                                                                                                                                                            

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
