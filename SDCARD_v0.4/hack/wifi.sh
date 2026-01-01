#!/bin/sh
#
# Connect-wifi.sh SSID PASSWORD
# Connection to WiFi as client, cleaning and shutting down exixting AP
# then syncronize clock with ntp

if [ $# -lt 2 ]; then
    echo "Usage: $0 SSID PASSWORD"
    exit 1
fi

SSID="$1"
PASSWORD="$2"
INTERFACE="wlan0"    # Change here in case of different interface
ETC=/tmp

# 1. Chiudere tutto quello che riguarda AP
echo "Stopping Access Point services..."
killall hostapd > /dev/null 2>&1
killall udhcpd > /dev/null 2>&1

# 2. Pulizia vecchi file
rm -f /var/run/hostapd/*
rm -f $ETC/udhcpd.conf
rm -f $ETC/hostapd.conf
rm -f $ETC/udhcpd.lease

# 3. Porta l'interfaccia WiFi DOWN per ripartire pulito
ifconfig $INTERFACE down
sleep 1

# 4. Configura wpa_supplicant
echo "Setting up wpa_supplicant config..."
cat > $ETC/wpa_supplicant.conf <<TEXT
ctrl_interface=/var/run/wpa_supplicant
network={
    ssid="$SSID"
    psk="$PASSWORD"
}
TEXT

# 5. Porta su l'interfaccia
ifconfig $INTERFACE up

# 6. Avvia wpa_supplicant
echo "Connecting to $SSID..."
killall wpa_supplicant > /dev/null 2>&1
wpa_supplicant -B -i$INTERFACE -c$ETC/wpa_supplicant.conf

# 7. Richiedi un IP via DHCP ed assegna hostname Augentix
sleep 2
echo "Requesting DHCP lease..."
udhcpc -i $INTERFACE -x hostname:Augentix

# 8. Fine
echo "Connected to $SSID!"

# 9. Sincronizza con ntpd di busybox sulla SD
if [ -f /home/HACKSD ]; then
	/mnt/hack/busybox ntpd -d -n -q -p pool.ntp.org
	date
else
	/tmp/hack/busybox ntpd -d -n -q -p pool.ntp.org
	date
fi

# 10. Call read ip, if present.
[ -f /mnt/hack/readip.sh ] && /mnt/hack/readip.sh

#	<EOF>

