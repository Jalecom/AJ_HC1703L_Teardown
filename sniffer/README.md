# Lightweight raw socket packet sniffer

The `sniffer_raw` is a minimal network monitoring tool that captures outgoing and incoming packets directly from a specified network interface using a PF_PACKET raw socket.
It operates at the Ethernet layer, decoding both IPv4 and IPv6 frames, and prints the destination IP address together with the transport protocol (TCP, UDP, or other).

The program is intentionally simple and dependency-free — ideal for embedded systems or diagnostic use on devices running BusyBox or other lightweight Linux environments.

## How it works:

Opens a raw socket (AF_PACKET, SOCK_RAW, ETH_P_ALL) to receive all Ethernet frames.
Binds the socket to the chosen network interface (e.g. wlan0 or eth0).

For each packet received:
Checks whether it contains an IPv4 or IPv6 header.
Extracts and prints the destination IP address.
Displays the protocol number (e.g. 6 for TCP, 17 for UDP).
Non-IP frames (ARP, etc.) are ignored.

## Compile:
Use the command `arm-linux-gnueabi-gcc -O2 -static -o sniffer_raw sniffer_raw.c` if you need to recompile your version or use the binary ready here

## Usage:
Capy on your SoC, change the permission and specify the interface:
```
chmod +x ./sniffer_raw
./sniffer_raw wlan0
```

Or use it with `sniffer.sh` which is a top 20 destination ip helper, easy to understand and modify.
