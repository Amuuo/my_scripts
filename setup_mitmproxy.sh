#!/bin/bash

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A PREROUTING -s 192.168.1.3 -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8080
sudo iptables -t nat -A PREROUTING -s 192.168.1.3 -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo mitmweb --mode socks5 --ignore-hosts localhost