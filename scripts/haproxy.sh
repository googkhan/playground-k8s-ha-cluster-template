#!/bin/bash
set -e

apt-get install -y haproxy

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    maxconn 2048

defaults
    log global
    mode tcp
    timeout connect 10s
    timeout client 1m
    timeout server 1m

frontend kubernetes
    bind 192.168.56.10:6443
    default_backend kubernetes-masters

backend kubernetes-masters
    balance roundrobin
    server cp1 192.168.56.11:6443 check
    server cp2 192.168.56.12:6443 check
    server cp3 192.168.56.13:6443 check
EOF

systemctl restart haproxy
systemctl enable haproxy

