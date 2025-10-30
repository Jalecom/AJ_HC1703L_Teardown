#!/bin/sh
# sniff.sh - Top destination IPs sniffer

# Controllo argomenti e impostazione default
[ ! -f ./sniffer_raw ] && echo "sniffer_raw binary not found, exit" && exit 1
if [ -z "$1" ] && [ -z "$2" ]; then
    echo "Usage: $0 [packet_number] [number_of_destinations]"
    echo "default loaded: sniff 50 20"
    PACKETS=50
    TOPN=20
else
    PACKETS=$1
    TOPN=$2
fi

./sniffer_raw wlan0 | awk -v PACKETS="$PACKETS" -v TOPN="$TOPN" '
# Funzione per descrivere multicast comuni
function describe(ip) {
    # IPv4 multicast
    if (ip == "192.168.1.255") return " (all nodes LAN)"
    if (ip == "224.0.0.1") return " (all nodes LAN)"
    if (ip == "224.0.0.251") return " (mDNS / Bonjour / Avahi)"
    if (ip == "224.0.0.252") return " (mDNS / LLMNR)"
    if (ip == "239.255.255.250") return " (SSDP / UPnP)"
    # IPv6 multicast
    if (ip == "ff02::1") return " (all nodes link-local)"
    if (ip == "ff02::c") return " (DHCPv6 clients)"
    if (ip == "ff02::fb") return " (mDNS / Bonjour)"
    if (ip == "ff02::123") return " (NTPv6)"
    # Default: niente descrizione
    return ""
}

{
    count[$2]++
    total++
    if (total % PACKETS == 0) {
        print "----- Top " TOPN " destinazioni -----"
        n = 0
        for (ip in count) { n++; ips[n] = ip }
        # Ordinamento manuale decrescente
        for (i = 1; i <= n-1; i++) {
            for (j = i+1; j <= n; j++) {
                if (count[ips[i]] < count[ips[j]]) {
                    tmp = ips[i]; ips[i] = ips[j]; ips[j] = tmp
                }
            }
        }
        for (i = 1; i <= TOPN && i <= n; i++) {
            desc = describe(ips[i])
            printf "%5d %s%s\n", count[ips[i]], ips[i], desc
        }
        print "-------------------------------"
    }
}
'

# <EOF>

