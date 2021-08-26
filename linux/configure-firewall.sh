#!/bin/bash

# Based on: https://craftcodecrew.com/building-a-simple-domain-name-based-firewall-for-egress-filtering/

DNS_SERVER_1="8.8.8.8"
DNS_SERVER_2="8.8.8.4"

INTERFACES=(
	eth0
)

IPTABLES="/usr/sbin/iptables"
IPSET="ipset" # "/sbin/ipset" | "/usr/sbin/ipset"

FQDNS_TO_ALLOW=(
	cdn-aws.deb.debian.org
	security.debian.org
	raspbian.raspberrypi.org

)

IPS_TO_ALLOW=(
	x.x.x.x
)

set -euo pipefail

# Test an IP address for validity:
# Usage:
#	  valid_ip IP_ADDRESS
#	  if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#	  if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
function valid_ip {
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
			&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}

function disable_ipv6 {
	# Work in progress to first check if SSH is not using ipv6
	# so you wouldn't lock yourself our when disabling ipv6	
	#sshd_ipv6_config=$(grep  "AddressFamily" /etc/ssh/sshd_config)
	#ssh_ipv6_config=$(grep  "AddressFamily" /etc/ssh/ssh_config)
	#disabled_ipv6str="^\s*AddressFamily\s+inet\s*$"
	#ssh_disabled_ipv6='true'

	#if [[ ! $sshd_ipv6_config ~= "$disabled_ipv6str" ]]
	#then
	#	echo "/etc/ssh/sshd_config [$sshd_ipv6_config]"	
	#	ssh_disabled_ipv6='false'
	
	#elif [[ ! $ssh_ipv6_config ~= "$disabled_ipv6str" ]]
	#then
	#	echo "/etc/ssh/ssh_config [$ssh_ipv6_config]"
	#	ssh_disabled_ipv6='false'	
	#fi

	read -p "Please check first configs /etc/ssh/sshd_config & /etc/ssh/ssh_config, if SSH is not configured to use ipv6. Disabling ipv6 system-wide might cause it to stop working. Are you sure you would like to continue?[Yy] i" -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	
		echo >&2 "[INFO] Disable ipv6"
		echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/70-disable-ipv6.conf 
		sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
		echo "IPv6 disabled"
	fi
}

function install {
	echo >&2 "[INFO] Install dnsmasq, ipset, dnsutils"
	apt-get update
	apt-get install -y dnsmasq ipset dnsutils
}

function configure_dnsmasq {
	echo >&2 "[INFO] Configure dnsmasq"
	# civicrm.org see: https://civicrm.stackexchange.com/questions/40126/get-civicrm-working-without-internet-connection/40133#40133
	echo "no-resolv" > /etc/dnsmasq.conf
	echo "local-ttl=60" >> /etc/dnsmasq.conf
	echo "addn-hosts=/etc/dnsmasq.hosts" >> /etc/dnsmasq.conf

	echo >&2 "[INFO] Restart dnsmasq"
	systemctl restart dnsmasq

	echo >&2 "[INFO] Stop dhcpclient from modifying /etc/resolv.conf"
	echo 'make_resolv_conf() { :; }' > /etc/dhcp/dhclient-enter-hooks.d/leave_my_resolv_conf_alone
	chmod 755 /etc/dhcp/dhclient-enter-hooks.d/leave_my_resolv_conf_alone

	echo >&2 "[INFO] Setting nameserver"
	echo 'nameserver 127.0.0.1' > /etc/resolv.conf
}

function configure_iptables {
	echo >&2 "[INFO] Adjusting tcp keep alive times this is to prevent issues with too many open connections"
	echo 120 > /proc/sys/net/ipv4/tcp_keepalive_time
	echo 3 > /proc/sys/net/ipv4/tcp_keepalive_probes
	echo 10 > /proc/sys/net/ipv4/tcp_keepalive_intvl

	echo >&2 "[INFO] Configure whitelist"
	$IPSET create whitelist hash:net || true

	echo >&2 "[INFO] Configure iptables"
	

	for index in ${!INTERFACES[*]}
	do
		INT="${INTERFACES[$index]}"
		echo "Putting configuration for interface [$INT]"
		$IPTABLES -P OUTPUT ACCEPT
		$IPTABLES -F OUTPUT

		$IPTABLES -o "$INT" -I OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

		# Allow broadcasting
		$IPTABLES -o "$INT" -A OUTPUT -d 255.255.255.255 -j ACCEPT

		# Allow dhcp requests
		$IPTABLES -o "$INT" -I OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

		# Allow requests to private ip ranges
		$IPTABLES -o "$INT" -A OUTPUT -d 10.0.0.0/8  -j ACCEPT
		$IPTABLES -o "$INT" -A OUTPUT -d 172.16.0.0/12  -j ACCEPT
		$IPTABLES -o "$INT" -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
		$IPTABLES -o "$INT" -A OUTPUT -d 169.254.0.0/16 -j ACCEPT # link local

		# Allow dns requests
		$IPTABLES -o "$INT" -A OUTPUT -d $DNS_SERVER_1 -p udp --dport 53 -j ACCEPT
		$IPTABLES -o "$INT" -A OUTPUT -d $DNS_SERVER_2 -p udp --dport 53 -j ACCEPT

		# Multicast
		$IPTABLES -o "$INT" -A OUTPUT -d 224.0.0.22 -j ACCEPT
		
		# Whitelisted IPs
		for i in ${!IPS_TO_ALLOW[*]}
		do
			ip="${IPS_TO_ALLOW[$i]}"
			if valid_ip "$ip"; then
				# Add ip to whitellist
				echo >&2 "[INFO] Adding raw $ip to ip whitelist"
				$IPSET add whitelist "$ip" || true
			else
				echo >&2 "[INFO] IP is not valid $ip"
			fi
		done

		# Whitelist
		$IPTABLES -o "$INT" -A OUTPUT -m set --match-set whitelist dst -j ACCEPT
	
		# Drop all other outgoing packages
		$IPTABLES -o "$INT" -A OUTPUT -j DROP
	done
	echo >&2 "[INFO] Current iptables configuration"
	$IPTABLES -L -n
}

function refresh_ips {
	host_file=""

	for index in ${!FQDNS_TO_ALLOW[*]}
	do
		fqdn="${FQDNS_TO_ALLOW[$index]}"
		ip="$(dig +short $fqdn @$DNS_SERVER_1 @$DNS_SERVER_2 | tail -n1)"

		if valid_ip "$ip"; then
			# Add ip to whitellist
			echo >&2 "[INFO] Adding $ip for $fqdn to ip whitelist"
			$IPSET add whitelist "$ip" || true

		host_file+="${ip} ${fqdn}\n"
		else
			echo >&2 "[INFO] failed to get ip address for $fqdn"
		fi
	done

	echo >&2 "[INFO] generated new host file for dnsmasq"
	echo -n -e "$host_file" | tee /etc/dnsmasq.hosts


	echo >&2 "[INFO] reload dnsmasq"
	systemctl reload dnsmasq
}

function flush_whitelist {
	$IPSET flush whitelist
	refresh_ips
}

function configure_cronjob {
	echo >&2 "[INFO] Setting up cronjob in /etc/cron.d/firewall-startup"
	echo "@reboot root sleep 90 && $0 startup >/var/log/firewall-startup.log 2>&1" > /etc/cron.d/firewall-startup

	echo >&2 "[INFO] Setting up cronjob in /etc/cron.d/firewall-refresh-ips"
	echo "*/10 * * * * root $0 refresh_ips >/var/log/firewall-refresh-ips.log 2>&1" > /etc/cron.d/firewall-refresh-ips

	echo >&2 "[INFO] Setting up cronjob in /etc/cron.d/firewall-flush-ips"
	echo "0 4 * * * root $0 flush_whitelist >/var/log/firewall-flush-ips.log 2>&1" > /etc/cron.d/firewall-flush-ips
}

case "${1:-x}" in
	disable_ipv6) disable_ipv6 ;;
	install) install ;;
	configure_dnsmasq) configure_dnsmasq ;;
	configure_iptables) configure_iptables ;;
	configure_cronjob) configure_cronjob ;;
	refresh_ips)  refresh_ips ;;
	flush_whitelist) flush_whitelist ;;
	startup)
		configure_dnsmasq
		configure_iptables
		refresh_ips
	;;
	all)
		disable_ipv6
		install
		configure_dnsmasq
		configure_iptables
		refresh_ips
		configure_cronjob
	;;
	*)
		echo  >&2 "usage:"
		echo >&2 "$0 disable_ipv6"
		echo >&2 "$0 install"
		echo >&2 "$0 configure_dnsmasq"
		echo >&2 "$0 configure_iptables"
		echo >&2 "$0 configure_cronjob"
		echo >&2 "$0 refresh_ips"
		echo >&2 "$0 flush_whitelist"
		echo >&2 "$0 startup"
		echo >&2 "$0 all"
		exit 1
		;;
esac
