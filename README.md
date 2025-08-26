# Augentix AJ HC1703L PTZ IPCam Teardown
PTZ IPCam based on SOC Augentix HC1703L teardown

This is a cheap Pan-Tilt IP Camera (sensor SC1346, 1288 (H) x 728 (V), supposedly 1080p) available on Aliexpress, Gearbest and Temu for €5~15. I bought five of them for less than €20 in an attempt to hack them as their low price is due to being locked to paid cloud services.
With limited documentation available on the Augentix SOC, a practical starting point was to attach a 3.3V UART on the [two + one pads](https://github.com/Jalecom/Augentix-HC1703L-PTZ-IPCam-Teardown/blob/main/Pictures/IMG_8248.jpeg) close to the HC1703 where 57'600bps signal is present.
The camera's behaviour appears very similar to the Goke GK7102 Cloud IP Cameras, and many of the hack are effective on the HC1703 as well. See [ant-thomas zsgx1hacks](https://github.com/ant-thomas/zsgx1hacks)

## Debug Scripts and Files

By default, the startup script `/tmp/start.sh` will try to load and run some [commands](https://github.com/Jalecom/Augentix-HC1703L-PTZ-IPCam-Teardown/blob/main/tmp/start.sh)

## Files running from SD Card

To run debug scripts, create a file named `debug_cmd.sh` on an SD card. You will then be able to execute your bash commands from it.
Note that the SD card is mounted in `/mnt` and the camera looks for `/mnt/debug_cmd.sh` while `start.sh` is running, before the WiFi drivers are loaded and before `p2pcam` binary is executed.

## Security

The security of these devices is terrible.
* DO NOT expose these cameras to the internet.
* Logs in `/tmp/augentix.log`, `/tmp/icam365.log` and `/tmp/libwebrtc.log`.
* By default the camera wants to use some app [iCam365 on Google Play](https://play.google.com/store/apps/details?id=com.tange365.icam365) or [iCam365 on AppStore](https://apps.apple.com/us/app/icam365/id1444978112)

## Hack Features

* BusyBox v1.21.1 (2013-07-08 10:20:03 CDT)
* BusyBox FTP Server
* dropbear SSH Server: root can login ssh without password
* WebUI PTZ - (http://192.168.200.1:8080/cgi-bin/webui)
* Improved terminal experience


## Installation

Current version works from microSD card and do not require installation.

* Download [the hack](https://github.com/Jalecom/AJ_HC1703L_Teardown/blob/main/HC1703L_Hack_v0.3.zip)
* Copy contents of folder ```sdcard``` to the main directory of a vfat/fat32 formatted microSD card
* To connect the camera to your WiFi edit and insert your SSID and PWD in the ```debug_cmd.sh```
* Insert microSD card into camera and reboot the device
* If no/wrong WiFi credebtial are given, the camera act as AP at address ```192.168.200.1```
* Enjoy


## ToDo

* ~~TO DO - Wi-Fi configuration without cloud account~~
* ~~TO DO - Blocking cloud hosts~~
* ~~TO DO - Fix on webui ip retrive error~~, ~~LED IR on/off button~~
* TO DO - Will be possible retrive a single current picture from the camera via webui ?

### 2025-05-21
* Found some interesting command in ```auto_test.sh```</BR>
  ```cgi_cmd() { httpclt get 'http://127.0.0.1:8001/'$1 }```</BR>
  ```cgi_cmd 'playaudio?file=/tmp/VOICE/alarm.wav' &```</BR>
  ```cgi_cmd 'buleled?mode=on'```</BR>
  ```cgi_cmd 'buleled?mode=off'```</BR>
  ```cgi_cmd 'irctrl?mode=day' ```</BR>
  ```cgi_cmd 'irctrl?mode=night'```</BR>
  ```cgi_cmd 'ircut_only?mode=day'```</BR>
  ```cgi_cmd 'ircut_only?mode=night'```</BR>
  ```cgi_cmd 'whitelight?mode=on'```</BR>
  ```cgi_cmd 'whitelight?mode=off'```</BR>
  ```cgi_cmd 'redled?mode=on'```</BR>
  ```cgi_cmd 'redled?mode=off'```</BR>
  ```cgi_cmd 'testdualsensor?mode=in'```</BR>
  ```cgi_cmd 'testdualsensor?mode=out'```</BR>
  
  Final settings after auto_test.sh:</BR> 
  ```cgi_cmd 'ircut?mode=day'```</BR>
  ```cgi_cmd 'whitelight?mode=off'```</BR>
  ```cgi_cmd 'redinfra?mode=off'```</BR> 
  ```cgi_cmd 'redled?mode=off'```</BR>
  ```cgi_cmd 'buleled?mode=on'```</BR>
  

### 2025-05-18 [HC1703L_Hack_v0.2.zip](https://github.com/Jalecom/AJ_HC1703L_Teardown/blob/main/HC1703L_Hack_v0.2.zip)
* ```wifi.sh``` can connect to your AccessPoint without clod account, i.e. without the need to expose the camera to the internet or to use the vendor app. Edit the last line of ```debug_cmd.sh``` with your credentials or call manually the script with SSID PWD from SSH 
* Removed the annoying voice WaitWifiConfig.wav
* ```wdk.sh``` is a simple Whatch Dog Kicker requested if you need to kill p2pcam and start.sh, this is not (yet) used by the hack.
* Added some lines to hosts file to prevent communication with ```host.tange365.com```
* Fixed webui ip retrive error
  

### 2025-08-23 [HC1703L_Hack_v0.3.zip](https://github.com/Jalecom/AJ_HC1703L_Teardown/blob/main/HC1703L_Hack_v0.3.zip)
* Fixed ```webui``` IR LEDs buttons (error on GPIO port, thanks to Electro-nic)   
* Fixed ```webui``` oblique direction buttons (thanks to Pawol)
* Added ```index.html``` redirecting to ```cgi-bin/webui``` (Pawol)
* Added some hidden buttons to check ```p2pcam``` function (via ip port 8001) and added White LEDs buttons (via GPIO 12) 

## Additional info


### RTSP Connection

* rtsp://admin:@192.168.200.1:554 (2304x1296 w/o audio)
* rtsp://admin:@192.168.200.1:554/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:554/0/av1 (low quality 640x368)
* rtsp://admin:@192.168.200.1:8001
* rtsp://admin:@192.168.200.1:8001/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:8001/0/av1 (low quality)


### End of Startup process

After the [boot process](https://github.com/Jalecom/AJ_HC1703L_Teardown/blob/main/AugentixFWboot_noSDcard.log), the camera retain the ```/home``` folder even after a powerdown, until the reset button is manually pressed.\
the ```/bak``` folder is mounted as ReadOnly and retain all the files requested to startup including ```start.sh``` and ```p2pcam.sqfs```.\
the ```/tmp``` folder is created at every boot and the ```start.sh``` is copied from ```/bak```; the one in ```/tmp``` is the one executed during the startup process. ```/mnt```, ```/var```, log and ini files are here.\
the ```start.sh``` load some drivers, check if a ```firmware.bin``` or a ```debug_cmd.sh``` is on the SD card and upgrade or run it, then init the sensor, ptz, voice, wifi, call ```rsyscall.hc1703``` and finally mount ```/bak/p2pcam.sqfs``` to run the p2pcam (closed source bineary), wich control all the higher function of the camera and try to connect with the cloud.\
the ```debug_cmd.sh``` open a web server for PTZ camera control on IP port 8080; add a SSH and a FTP server; overwrite temporary hosts, profile, group, passwd, and shadow file; connect with your credential to your WiFi and update via NTP the clock.


## Device Details

### Software Versions
```
$ uname -a
Linux localhost 3.18.31 #13 Wed Feb 28 01:51:17 UTC 2024 armv7l GNU/Linux

$ busybox
BusyBox v1.33.0 (2023-02-08 19:01:00 CST) multi-call binary.

Currently defined functions:
        [, [[, arch, arp, arping, ash, awk, cat, chmod, chown, clear, cp, date, dd, devmem, df, dmesg, dnsdomainname,
        echo, env, false, find, flash_eraseall, flashcp, free, getty, grep, halt, head, hostname, i2ctransfer, id,
        ifconfig, ifdown, ifup, init, insmod, kill, killall, klogd, linux32, linux64, linuxrc, ln, logger, login,
        logread, ls, lsmod, lsof, md5sum, mdev, mkdir, mkdosfs, mknod, more, mount, mv, netstat, nologin, nuke, passwd,
        ping, ping6, pipe_progress, poweroff, printenv, ps, pwd, reboot, resume, rm, rmmod, route, run-init, sed, seq,
        setpriv, sh, sleep, sort, start-stop-daemon, stty, sync, sysctl, syslogd, tail, tar, telnetd, top, touch, tr,
        true, ts, tty, udhcpc, udhcpd, uevent, umount, uname, unlzma, uptime, usleep, vi, which, xargs
```

### Hardware info
```
$ cat /bak/hardinfo.bin
<?xml version="1.0" encoding="UTF-8"?>
<DeviceInfo version="1.0">
<DeviceClass>0</DeviceClass>
<OemCode>0</OemCode>
<BoardType>2900</BoardType>
<FirmwareIdent>aj_ipc_hc2_001</FirmwareIdent>
<Manufacturer>AJ</Manufacturer>
<Model>HC1703L</Model>
<WifiChip>RTL8188</WifiChip>
<SensorPosition>1</SensorPosition>
<SupportPtz>1</SupportPtz>
<PtzMcu>0</PtzMcu>
<GPIO>
<BoardReset>6_0x00000000_0_0</BoardReset>
<SpeakerCtrl>64_0x00000000_0_0</SpeakerCtrl>
<IrFeedback>0</IrFeedback>
<BlueLed>-1</BlueLed>
<RedLed>-1</RedLed>
<IrCtrl>77_0x00000000_0_1</IrCtrl>
<IrCut1B>80_0x00000000_0_1</IrCut1B>
<IrCut2B>79_0x00000000_0_1</IrCut2B>
<ALarmLight>10_0x00000000_0_1</ALarmLight>
<WhiteLight>12_0x00000000_0_1</WhiteLight>
<CallKey>17_0x00000000_0_0</CallKey>
<SmokeAlarm>17_0x00000000_0_0</SmokeAlarm>
<WifiCtrl>-1</WifiCtrl>
</GPIO>
```

### Open ports
```
$ nmap -p- 192.168.200.1
Nmap scan report for 192.168.200.1
Host is up (0.063s latency).
Not shown: 65524 closed ports
PORT      STATE    SERVICE
21/tcp    open     ftp
22/tcp    open     ssh
53/tcp    open     domain
80/tcp    open     http
554/tcp   open     rtsp
6670/tcp  open     irc
8001/tcp  open     vcom-tunnel
8080/tcp  open     http-proxy
9000/tcp  filtered cslistener
9010/tcp  filtered sdr
20202/tcp open     ipdtp-port

Nmap done: 1 IP address (1 host up) scanned in 66.17 seconds
```

### Processor
```
$ cat /proc/cpuinfo
processor       : 0
model name      : ARMv7 Processor rev 5 (v7l)
BogoMIPS        : 20160.00
Features        : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xc07
CPU revision    : 5

Hardware        : Augentix HC1703_1723_1753_1783s family
Revision        : 0000
Serial          : 0000000000000000
$ 
```

### Memory
```
$ cat /proc/meminfo
MemTotal:          61968 kB
MemFree:            9464 kB
MemAvailable:      18188 kB
Buffers:            2324 kB
Cached:             9908 kB
SwapCached:            0 kB
Active:             8840 kB
Inactive:           8064 kB
Active(anon):       4852 kB
Inactive(anon):     1064 kB
Active(file):       3988 kB
Inactive(file):     7000 kB
Unevictable:          24 kB
Mlocked:              24 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:          4720 kB
Mapped:             6432 kB
Shmem:              1244 kB
Slab:               4428 kB
SReclaimable:        428 kB
SUnreclaim:         4000 kB
KernelStack:         800 kB
PageTables:          272 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:       30984 kB
Committed_AS:      22336 kB
VmallocTotal:     958464 kB
VmallocUsed:        9272 kB
VmallocChunk:     499700 kB
```

### /etc/passwd
(user/pass -> ```root/cxlinux```)
```
$ cat /etc/passwd
root:yi.LoBvyUCv0k:0:0:root:/root/:/bin/sh
```
The algorithm used to encode the password is DES (Data Encryption Standard), a symmetric encryption algorithm commonly used in old Unix/Linux systems to protect passwords, wich is now cosidered obsolete as can be cracked within few hours. This type of hash generated with DES crypt can store only up to 8 characters of a password, however the algorithm uses a 2-character salt (which in this case is "yi"), and the rest of the 11-character hash is the encrypted part derived from the password "cxlinux" itself.

