// sniffer_raw.c
// Compilare: gcc -O2 -o sniffer_raw sniffer_raw.c
// Eseguirre come root: ./sniffer_raw <interface>
// Esempio: ./sniffer_raw wlan0

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>
#include <netinet/ether.h>
#include <netinet/ip.h>
#include <netinet/ip6.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <interface>\n", argv[0]);
        return 1;
    }
    const char *ifname = argv[1];
    int sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (sock < 0) { perror("socket"); return 1; }

    struct ifreq ifr;
    memset(&ifr,0,sizeof(ifr));
    strncpy(ifr.ifr_name, ifname, IFNAMSIZ-1);
    if (ioctl(sock, SIOCGIFINDEX, &ifr) == -1) { perror("ioctl SIOCGIFINDEX"); close(sock); return 1; }

    struct sockaddr_ll sll;
    memset(&sll,0,sizeof(sll));
    sll.sll_family = AF_PACKET;
    sll.sll_ifindex = ifr.ifr_ifindex;
    sll.sll_protocol = htons(ETH_P_ALL);

    if (bind(sock, (struct sockaddr*)&sll, sizeof(sll)) == -1) { perror("bind"); close(sock); return 1; }

    unsigned char buf[65536];
    while (1) {
        ssize_t len = recvfrom(sock, buf, sizeof(buf), 0, NULL, NULL);
        if (len <= 0) continue;

        if (len < (ssize_t)(sizeof(struct ether_header)+20)) continue; // too small
        struct ether_header *eth = (struct ether_header*)buf;
        if (ntohs(eth->ether_type) == ETHERTYPE_IP) {
            struct ip *iph = (struct ip*)(buf + sizeof(struct ether_header));
            char dst[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &iph->ip_dst, dst, sizeof(dst));
            int proto = iph->ip_p;
            printf("IPv4 %s proto=%d\n", dst, proto);
            fflush(stdout);
        } else if (ntohs(eth->ether_type) == ETHERTYPE_IPV6) {
            struct ip6_hdr *ip6h = (struct ip6_hdr*)(buf + sizeof(struct ether_header));
            char dst6[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, &ip6h->ip6_dst, dst6, sizeof(dst6));
            printf("IPv6 %s proto=v6\n", dst6);
            fflush(stdout);
        } else {
            // ignore non-IP
        }
    }
    close(sock);
    return 0;
}
