#!/bin/bash

#clear
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

#drop
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 

#ssh
iptables -A INPUT  -i enp0s8 -s 192.168.56.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -s 192.168.56.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -s 192.168.56.0/24 -p tcp --sport 22 -j ACCEPT
iptables -A FORWARD -s 192.168.56.0/24 -p tcp --dport 22 -j ACCEPT


#http
iptables -A INPUT -i enp0s3 -p tcp --dport 80  -j ACCEPT
iptables -A OUTPUT -o enps03 -p tcp --sport 80  -j ACCEPT
iptables -A OUTPUT -o enp0s3 -p tcp --dport 443   -j ACCEPT
iptables -A INPUT -i enp0s3 -p tcp --sport 443  -j ACCEPT

#dns
iptables -A OUTPUT -p udp -o enp0s3 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i enp0s3 --sport 53 -j ACCEPT

#ftp
iptables -A INPUT -i enp0s3 -p tcp --dport 21  -j ACCEPT
iptables -A OUTPUT -o enps03 -p tcp --sport 21  -j ACCEPT

#compartilhar
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

#log
iptables -A INPUT -p tcp -m tcp --dport 23 --syn -j LOG --log-prefix "SSH connection"

#priorizar
iptables -t mangle -A OUTPUT -o enpS03 -p tcp --dport 80 -j TOS --set-tos 4

#redirecionar
iptables -t nat -A PREROUTING -p tcp -d 10.0.2.15 --dport 8080 -j DNAT --to 192.168.0.1:80

