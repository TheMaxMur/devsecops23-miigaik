#!/bin/sh

# Update suricata rules
#suricata-update
#SAsdaasd
echo "ss"
# Start cron
crond
# Add cronjob
crontab /etc/crontabs/suricata-update-cron
iptables -t mangle -I PREROUTING -p tcp -m tcp -m mark ! --mark 0x1/0x1 -j NFQUEUE --queue-num 0 --queue-bypass
iptables -I INPUT -j NFQUEUE --queue-bypass
iptables -I OUTPUT -j NFQUEUE --queue-bypass
# Started suricata
#rm -r /etc/suricata/rules/
exec /bin/sh -c "/usr/bin/suricata -c /etc/suricata/suricata.yaml -q 0 -v"

