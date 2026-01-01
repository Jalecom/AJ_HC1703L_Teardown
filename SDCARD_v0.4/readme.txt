This folder contain the file requested to open ssh, ftp and http to interact with the Augentix HC1703L IP camera.
Read please https://github.com/Jalecom/AJ_HC1703L_Teardown/ for more info. 

### Short info ###

Edit config.txt and insert your WiFi credentials or the camera will act as AP at address 192.168.200.1
The debug_cmd.sh will be called from your start.sh in the boot process and read the config.txt, then runs off the SD card a web server on port 80, 8080 or 8090 at the adress assigned by your router to the camera.
If you change the HACKTYPE, you can run the hack in the RAM in a non persistant way or modify the /back/sensor.sh to run the hack even without SD.
NOTE: the debug_cmd.sh is called before sensor.sh, so any different task will be executed before the hack  

Type of hack

	SD = SDcard only => the hack runs off the SD card, isn't persistent, and needs the card to stay in the camera;
		 removing the SD card and rebooting the device restores the camera to its previous settings.

	T  = Temporary => The hack gets copied to RAM (e.g. /tmp/hack) and runs from there;
		 in case of error, it continue the debug_cmd.sh as with the option SD
		 removing the SD card and rebooting the device restores the camera to its previous settings.

	P  = Permanent => a mini version of the hack is copied to /bak, on each reboot it’s copied to RAM and run from there;
		 sensor.sh is permanently modifyed to run minihack.sh, if present; 
		 it stay persistently even after pushing the factory reset button;
		 due to space availability in the /bak folder:
		 - a mini version of busybox is used
		 - telnetd is used instead dropbear ssh
		 - the start.sh check before for debug_cmd.sh and then run sensor.sh wich run the hack
		 - after the installation, the SD card is not requested anymore.

	NO = No hack => /home/minihack.sh is removed ( /bak/hack folder stays) and the script exit

	Default = SD

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
	



