<#
 .Synopsis
  Collects all info from WMI about newly attached USB devices

 .Description
  Collects all info from WMI about newly attached USB devices. 
  1. Start script
  2. Attach USB device when asked
  3. Information is saved in output CSV


#>

$OutputFile = "$($pwd.Path)\NewUsbdevices.csv"
$VerbosePreference = 'Continue'
$Cmd = { Get-WmiObject -class Win32_PnPEntity -Namespace "root\CIMV2" }
$OldUSBDevices = Invoke-Command -ScriptBlock $Cmd
Write-Verbose "Current usb device list obtained. Please attach new one"

$NewUSBDevices = $OldUSBDevices

While ($NewUSBDevices.hardwareid.count -eq $OldUSBDevices.hardwareid.count) {

    $NewUSBDevices = Invoke-Command -ScriptBlock $cmd

}
Write-Verbose "New device detected"
$Output = $NewUSBDevices | ? { $OldUSBDevices.hardwareid -notcontains $_.hardwareid }

$Output | Export-Csv -Path $OutputFile
Write-Verbose "New device information saved in $OutputFile"