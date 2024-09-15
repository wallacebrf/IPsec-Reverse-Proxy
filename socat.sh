#!/bin/bash
	
current_date=$(date '+%F %X')
echo "$current_date - socat process restarted for the day" >> /var/log/socat-500.log
echo "$current_date - socat process restarted for the day" >> /var/log/socat-4500.log
socat UDP4-LISTEN:500,reuseaddr,fork,su=nobody UDP6:ipv6.your-domain.com:500 >> /var/log/socat-500.log 2>&1 &
socat UDP4-LISTEN:4500,reuseaddr,fork,su=nobody UDP6:ipv6.yourdomain.com:4500 >> /var/log/socat-4500.log 2>&1 &
