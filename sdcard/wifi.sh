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

# Chiude tutto quello che riguarda AP
echo "Stopping Access Point services..."
killall hostapd > /dev/null 2>&1
killall udhcpd > /dev/null 2>&1

# Cleanup vecchi file
rm -f /var/run/hostapd/*
rm -f $ETC/udhcpd.conf
rm -f $ETC/hostapd.conf
rm -f $ETC/udhcpd.lease

# Porta l'interfaccia WiFi DOWN per ripartire pulito
ifconfig $INTERFACE down
sleep 1

# Configura wpa_supplicant
echo "Setting up wpa_supplicant config..."
cat > $ETC/wpa_supplicant.conf <<TEXT
ctrl_interface=/var/run/wpa_supplicant
network={
    ssid="$SSID"
    psk="$PASSWORD"
}
TEXT

# Porta su l'interfaccia
ifconfig $INTERFACE up

# Avvia wpa_supplicant
echo "Connecting to $SSID..."
killall wpa_supplicant > /dev/null 2>&1
wpa_supplicant -B -i$INTERFACE -c$ETC/wpa_supplicant.conf

# Richiede un IP via DHCP ed assegna hostname Augentix
sleep 2
echo "Requesting DHCP lease..."
udhcpc -i $INTERFACE -x hostname:Augentix

# Fine
echo "Connected to $SSID!"

# Sincronizza con ntpd di busybox sulla SD
/mnt/hack/busybox ntpd -d -n -q -p pool.ntp.org
date

