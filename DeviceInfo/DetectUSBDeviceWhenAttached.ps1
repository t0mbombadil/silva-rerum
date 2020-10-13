<#
 .Synopsis
  Collects all info from WMI about newly attached USB devices

 .Description
  Collects all info from WMI about newly attached USB devices. 
  1. Start script
  2. Attach USB device when asked
  3. Wait on completition information. Then you could disconnect device
  3. Information is saved in output XML


#>

$OutputFile = "$($pwd.Path)\NewUsbdevices.xml"
$VerbosePreference = 'Continue'
$WaitSecondsToSetup = 20

$Cmd = { Get-WmiObject -class Win32_PnPEntity | foreach {
    $_ | Add-Member -NotePropertyName BusReportedDeviceDesc -NotePropertyValue $($_.GetDeviceProperties("DEVPKEY_Device_BusReportedDeviceDesc").DeviceProperties.Data)
    $_
    } 
}
 
$OldUSBDevices = Invoke-Command -ScriptBlock $Cmd
Write-Verbose "Current usb device list obtained ( $($OldUSBDevices.deviceid.Count) devices). Please attach new one"

$NewUSBDevices = $OldUSBDevices

While ($NewUSBDevices.deviceid.count -eq $OldUSBDevices.deviceid.count) {

    $NewUSBDevices = Invoke-Command -ScriptBlock $cmd
}
Write-Verbose "New devices detected. Waiting for $WaitSecondsToSetup s to setup"
# For device to be detected completly
Start-Sleep -Seconds $WaitSecondsToSetup
$Output = Invoke-Command -ScriptBlock $cmd | ? { $OldUSBDevices.deviceid -notcontains $_.deviceid } 
Write-Verbose "$($Output.deviceid.Count) new devices. Total $($NewUSBDevices.deviceid.Count) devices"

$Output | Export-Clixml -Path $OutputFile
Write-Verbose "New device information saved in $OutputFile"