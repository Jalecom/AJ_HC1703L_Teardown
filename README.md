# Augentix AJ HC1703L PTZ IPCam Teardown
PTZ IPCam based on SOC Augentix HC1703L teardown

This is a cheap Pan-Tilt IP Camera (supposedly 1080p) available on Aliexpress, Gearbest and Temu for €5~15. I bought five of them for less than €20 in an attempt to hack them as their low price is due to being locked to paid cloud services.
With limited documentation available on the Augentix SOC, a practical starting point was to attach a 3.3V UART on the [two + one pads](https://github.com/Jalecom/Augentix-HC1703L-PTZ-IPCam-Teardown/blob/main/Pictures/IMG_8248.jpeg) close to the HC1703 where 57'600bps signal is present.
The camera's behaviour appears very similar to the Goke GK7102 Cloud IP Cameras, and many of the hack are effective on the HC1703 as well. See [ant-thomas zsgx1hacks](https://github.com/ant-thomas/zsgx1hacks)

## Debug Scripts and Files

By default, the startup script ```/tmp/start.sh``` will try to load and run some [commands](https://github.com/Jalecom/Augentix-HC1703L-PTZ-IPCam-Teardown/blob/main/tmp/start.sh)

## Files running from SD Card

To run debug scripts create a file ```debug_cmd.sh``` on an SD card and you will be able to execute bash commands from it.
Note the SD card is mounted in /mnt and the camera looks for /mnt/debug_cmd.sh

## Security

The security of these devices is terrible.
* DO NOT expose these cameras to the internet.
* Logs in /tmp/augentix.log
* By default the camera wants to use some app [iCam365 on Google Play](https://play.google.com/store/apps/details?id=com.tange365.icam365) or [iCam365 on AppStore](https://apps.apple.com/us/app/icam365/id1444978112)

## Hack Features

* BusyBox v1.33.0
* BusyBox FTP Server
* dropbear SSH Server: root can login ssh without password
* WebUI PTZ - (http://192.168.200.1:8080/cgi-bin/webui)
* Improved terminal experience


## Installation

Current version works from microSD card and do not require installation.

* Download the hack
* Copy contents of folder ```sdcard``` to the main directory of a vfat/fat32 formatted microSD card
* Insert microSD card into camera and reboot the device
* Enjoy


## ToDo

* TO DO - Wi-Fi configuration without cloud account
* TO DO - Blocking cloud hosts
* TO DO - Fix on webui ip retrive error, LED IR on/off button

## Additional info


### RTSP Connection

* rtsp://admin:@192.168.200.1:554
* rtsp://admin:@192.168.200.1:554/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:554/0/av1 (low quality)
* rtsp://admin:@192.168.200.1:8001
* rtsp://admin:@192.168.200.1:8001/0/av0 (with audio)
* rtsp://admin:@192.168.200.1:8001/0/av1 (low quality)


### Debug Scripts and Files

By default, the startup script ```/home/start.sh``` will try to load and run some commands

### Files running from SD Card

To run debug scripts create a file ```debug_cmd.sh``` on an SD card and you will be able to execute bash commands from it.


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

