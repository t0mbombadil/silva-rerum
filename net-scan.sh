#!/bin/bash
#
# Author: TomBombadil

print_help()
{
 help_str=(
	'Usage:'
	'./net-scan.sh -n <network_ip>/<submask>'
	'Example /net-scan.sh -n 10.182.0.0/16'
	''
	'Basic: Will scan network for live hosts (save it to $host_file)'
	'Then run port scan and run given NSE scripts againt results'
	'Vulners & Vulscan will give you info about known vulnerabilities'
	'From CVE databases (online for Vulners, possible offline for Vulnscan)'
	'smtp-open-relay will detect open relay mails servers'
	''
	''
	'./net-scan.sh -n <net>/<submask> -h <host_file>'
	'Example: ./net-scan.sh -n 10.182.0.0/16 -h .live_hosts'
	''
	'Host file: It will skip live host detection and start port and vulnerability scan'
	'on hosts from host file (this file is by default saved on every scan)'
	''
	''
	'./net-scan.sh -n <net_ip> -c <crontab_value>'
	'Example: ./net-scan.sh -n 10.182.0.0/16 -c "*/5 * * * *"'
	''
	'Reoccuring scan: This will schedule reocuring cron job, so script will scan given'
	'network within given period of time (in example every 5 minutes)'
	'Results of script in $workdir'
	''
	''
	'Description:'
 	'This script is scanning given network, first for live hosts'
	'Then it s running port scan againsta all hosts, and detects'
	'known vulnerabilities, giving appropriate CVE link'
 	'It will also detect SMTP open-relay servers in network'
	''
 )
	printf '%s\n' "${help_str[@]}" 
}
if [ $# -eq 0 ];then
	print_help
	exit 0
fi
printf "Run script with no parameters to get option decription\n\n"

# VARS
# -------------------------------
host_file=".live_hosts"
host_scan_skip='false'
script_url=(
	'https://svn.nmap.org/nmap/scripts/vulners.nse'
	'https://svn.nmap.org/nmap-exp/jiayi/scripts/vulscan.nse'
	'https://svn.nmap.org/nmap/scripts/smtp-open-relay.nse'	
)
vuln_scanner=$(for i in ${script_url[@]}; do basename $i;done)
timestamp=""
workdir="$( cd "$(dirname "$0")" ; pwd -P )"

# Requied by cron
PATH="/usr/local/bin:/usr/bin:/bin"

nmap_script_dir="/usr/share/nmap/scripts" # Default Linux
case "$(uname -s)" in
    Linux*)    printf "Linux detected. Downloading not present scripts might require root" ;;
    Darwin*)   
	nmap_script_dir='/usr/local/share/nmap/scripts' 
	printf "Mac detected. " 
	;;
    *)         printf "Unknown machine. Nmap script folder set for linux. This might not work\n"
	;;	
esac
printf "Nmap script path set to [$nmap_script_dir]\n"


# OPTIONS 
# ------------------------------

while getopts ":n:h:c:t" opt; do
  case $opt in
    n) 
	# network arg is obligatory - ... -n 192.168.0.0/24
	network=$OPTARG
	;;
    h)
	# If host file specified, live host in network would be read from it
	# Format of file is IP per line - ... -h .live_hosts
	# This file is saved by default after every scan

	echo "Reading from host file [$host_file]" >&2
	host_scan_skip='true'

	host_file=$OPTARG	
	;;
    c)
	# Setup of crontab entry to run script with given schedule 
	# Finding script absolute path might nor work in all conditions
	# For example when you are calling file as symlink
	# Network parameter need to be called first 
	# Use invocation - ./net-scan.sh -n <net_ip> -c <your_cron>
	# To run at every 5 minute - ./net-scan.sh -n <net_ip> -c '*/5 * * * *'

	if [ -z "$network" ]; then
		printf "Network not specified\n"
		exit 1
	fi

	SCRIPTNAME="$(basename ${BASH_SOURCE[0]})"
	script="$workdir/$SCRIPTNAME"	
	echo "Script location: $SCRIPTPATH | $SCRIPTNAME | $network" 
	crontab -l | { cat; echo "$OPTARG cd $workdir; ./$SCRIPTNAME -n $network -t"; } | crontab -
	exit 0
	;;
    t)
	# Sets timestamp for output file
	timestamp="_$(date +%F_%T)"
	;;
    \?)
	echo "Invalid option: -$OPTARG" >&2
	exit 1
	;;
  esac
done


# Arg check
# --------------------------------------
if [ -z "$network" ]; then
	printf "Network not specified\n"
	exit 1
fi

# Setup 
# --------------------------------------
if [ ! -d $nmap_script_dir ]; then
	printf "Local nmap share folder doesn't exist. $nmap_script_dir"
	printf "Please create it, or update script to right folder\n"
	exit 1
	#sudo mkdir -p $nmap_script_dir
	#sudo chmod 
fi
printf "Checking $nmap_script_dir for script availability..."
for i in ${script_url[@]}; do
	nscript_path="$nmap_script_dir/$(basename $i)"
	if [ ! -f $nscript_path ]; then
		printf "Didn't found $nscript_path. Downloading"
		wget -O $nscript_path $i
	fi
done
printf "Ok\n"

# MAIN
# --------------------------------------

if [ "$host_scan_skip" == 'false' ]; then
	printf "Scaning [$network] for live hosts\n"
	nmap -sn -T5 --min-parallelism 100 --max-parallelism 256 $network | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" 2>&1 | tee "$workdir/$host_file" 
fi

out_file="_result_scan_$(printf "$network" | cut -f1 -d/)$timestamp"

options=('-sV' '-T5' '-F' '--min-hostgroup 10' '--max-hostgroup 50') 
scripts=$(echo "${vuln_scanner[@]}" | tr '\n' ',' | sed 's/.$//')

printf "Using vulnerability scanners: $scripts \n" 
nmap -iL "$workdir/$host_file" --script $scripts ${options[@]} 2>&1 | tee "$workdir/$out_file"
