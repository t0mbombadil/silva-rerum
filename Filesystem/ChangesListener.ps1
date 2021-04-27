<#
 .Synopsis
  Listen file changes on folder

 .Description
  Listen file changes on folder with hashes. Writes changes to log file
  Tested on Windows 10

 .Notes
    Based on: http://www.mobzystems.com/code/using-a-filesystemwatcher-from-powershell/
    Author: TomasBombadil
#>
Function Start-FileSystemWatcher {

    [cmdletbinding()]
    Param (
  
      [parameter()]
      [string]$Path,
  
      [parameter()]
      [ValidateSet('Changed', 'Created', 'Deleted', 'Renamed')]
      [string[]]$EventName,
  
      [parameter()]
      [string]$Filter,
  
      [parameter()]
      [System.IO.NotifyFilters]$NotifyFilter,
  
      [parameter()]
      [switch]$Recurse,
  
      [parameter()]
      [scriptblock]$Action,
  
      [switch]$Force, # Removes conflicting listeners silently,
  
      [string]$LogFile = "ChangeListener.log"
    )
  
    #region Build  FileSystemWatcher
  
    $FileSystemWatcher = New-Object  System.IO.FileSystemWatcher
  
    If (-NOT $PSBoundParameters.ContainsKey('Path')) {
  
      $Path = $PWD
    }
  
    $FileSystemWatcher.Path = $Path
  
    If ($PSBoundParameters.ContainsKey('Filter')) {
  
      $FileSystemWatcher.Filter = $Filter
    }
  
    If ($PSBoundParameters.ContainsKey('NotifyFilter')) {
  
      $FileSystemWatcher.NotifyFilter = $NotifyFilter
    }
  
    If ($PSBoundParameters.ContainsKey('Recurse')) {
  
      $FileSystemWatcher.IncludeSubdirectories = $True
    }
  
    If (-NOT $PSBoundParameters.ContainsKey('EventName')) {
  
      $EventName = 'Changed', 'Created', 'Deleted', 'Renamed'
    }
  
    If (-NOT $PSBoundParameters.ContainsKey('Action')) {
  
      $Action = {
        $Filename = $Event.SourceArgs[-1].FullPath
        $FileHash = Get-FileHash -Path "$Filename"
        $FileHashMsg = "[$FileHash]`n"
  
        $OldPathInfo = if($Event.SourceArgs[-1].OldFullPath) { "[$($Event.SourceArgs[-1].OldFullPath)] ->" }
  
        $Object = "[{0}] [{1}] {2} [{3}]`n{4}" -f `
          $Event.SourceEventArgs.ChangeType,
          $Event.TimeGenerated,
          $OldPathInfo, # Show only at RENAMED event
          $Event.SourceEventArgs.FullPath,
          $FileHashMsg
  
        $WriteHostParams = @{
  
          ForegroundColor = 'Green'
          BackgroundColor = 'Black'
          Object          = $Object
        }
  
        Write-Host  @WriteHostParams
        $log = $Event.MessageData.LogFile
        if($log) {
          Write-Verbose "Writing to log file [$log]"
          Write-Output $Object | Out-File -FilePath $log -Append -Encoding utf8
        }
      }
    }
    #endregion  Build FileSystemWatcher
    #region  Initiate Jobs for FileSystemWatcher
  
    $ObjectEventParams = @{
      InputObject = $FileSystemWatcher
      Action = $Action
    }
  
    if($LogFile) {
      $enc = 'utf8'
      Write-Output "Writing to log file [$LogFile]"
      Write-Output "Listening changes on [$Path] started. [$EventName] [$(get-date -Format s)]`nStarting state:`n" | Out-File -FilePath $LogFile -Encoding $enc
  
      $currentState = Get-ChildItem c:\temp | foreach { 
          $Hash = Get-FileHash -path $_.FullName
          $_ |  Add-Member -MemberType NoteProperty -Name "Algorithm" -Value "$($Hash.Algorithm)"
          $_ |  Add-Member -MemberType NoteProperty -Name "Hash" -Value "$($Hash.Hash)"
          $_ |  Add-Member -MemberType NoteProperty -Name "Path" -Value "$($Hash.Path)"
          Write-Output $_
      } | select Mode, LastWriteTime, Length, Name, Algorithm, Hash, Path | Format-Table -AutoSize
  
      $currentState | Out-File -FilePath $LogFile -Append -Encoding $enc
    }
    ForEach ($Item in  $EventName) {
  
      Get-EventSubscriber -SourceIdentifier "File.$($Item)" -ErrorAction SilentlyContinue | Unregister-Event -Confirm:$(! $Force.IsPresent) -Force:$($Force.IsPresent)
  
      $ObjectEventParams.EventName = $Item
      $ObjectEventParams.SourceIdentifier = "File.$($Item)"
      
      Write-Verbose  "Starting watcher for Event: $($Item)"
      $Null = Register-ObjectEvent  @ObjectEventParams -MessageData $([pscustomobject]@{ LogFile = $LogFile })
    }
    #endregion  Initiate Jobs for FileSystemWatcher
    try{
        Write-Output "Press Ctrl-C to exit. This will end listening for changes in folder"
        while($true) {              
                Start-Sleep -Milliseconds 500
        }
    }
    finally {
        ForEach ($Item in  $EventName) {
            Write-Host "Deleting event listener [File.$($Item)]"
            Get-EventSubscriber -SourceIdentifier "File.$($Item)" -ErrorAction SilentlyContinue | Unregister-Event -Force      
        }
    }
  } 
  Start-FileSystemWatcher -Path "C:\temp" -EventName Created,Changed,Renamed,Deleted -Force
        Write-Verbose "--- START [$($e.EventIdentifier)] $changeType $name $timeStamp"
  