#!/bin/bash
set -e

apt-get update
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

# logrotate for haproxy
cat <<EOF > /etc/logrotate.d/haproxy
/var/log/haproxy.log {
    daily         # Rotate logs daily
    rotate 7      # Keep 7 rotated log files
    compress      # Compress the rotated log files
    delaycompress # Delay compression until the next rotation cycle
    missingok     # Don't exit with error if the log file is missing
    notifempty    # Don't rotate if the log file is empty
    create 0640 haproxy adm # Create a new empty log file with specified permissions and ownership
    sharedscripts # Only run postrotate script once for all log files in the block
    postrotate    # Script to run after rotation
        # Instruct rsyslogd (or syslog-ng) to reopen its log files
        # This is crucial so HAProxy starts writing to the new, empty file
        invoke-rc.d rsyslog reload >/dev/null 2>&1 || true
    endscript
}
EOF

# rsyslog for haproxy logs, becuz of to separate log system
apt-get install -y rsyslog
systemctl restart rsyslog
systemctl enable rsyslog

# haproxy service start-enable
systemctl restart haproxy
systemctl enable haproxy

