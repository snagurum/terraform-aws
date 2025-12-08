#!/bin/bash
# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
# Make it persistent
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Configure NAT rules
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
