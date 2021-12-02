# Overview

Commands to gather logs on different systems

# Windows 

## Event log

```powershell
(Get-EventLog -List).Log | % { Get-EventLog -LogName $_ -After $((Get-Date -Date "2021-11-18 10:00:00Z)").ToUniversalTime()) -ErrorAction SilentlyContinue } | Export-Csv "C:\temp\AllEventLogs.csv"

```
