$ErrorActionPreference = "Stop"
#Logging
function LogIt
{
  param (
  [Parameter(Mandatory=$true)]
  $message,
  [Parameter(Mandatory=$true)]
  $component,
  [Parameter(Mandatory=$true)]
  $type )

  switch ($type)
  {
    1 { $type = "Info" }
    2 { $type = "Warning" }
    3 { $type = "Error" }
    4 { $type = "Verbose" }
  }

  if (($type -eq "Verbose") -and ($Global:Verbose))
  {
    $toLog = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($type + ":" + $message), ($Global:ScriptName + ":" + $component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    $toLog | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $Global:LogFile)
    Write-Host $message
  }
  elseif ($type -ne "Verbose")
  {
    $toLog = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($type + ":" + $message), ($Global:ScriptName + ":" + $component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    $toLog | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $Global:LogFile)
    Write-Host $message
  }
  if (($type -eq 'Warning') -and ($Global:ScriptStatus -ne 'Error')) { $Global:ScriptStatus = $type }
  if ($type -eq 'Error') { $Global:ScriptStatus = $type }

  if ((Get-Item $Global:LogFile).Length/1KB -gt $Global:MaxLogSizeInKB)
  {
    $log = $Global:LogFile
    Remove-Item ($log.Replace(".log", ".lo_"))
    Rename-Item $Global:LogFile ($log.Replace(".log", ".lo_")) -Force
  }
} 

function GetScriptDirectory
{
  $invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $invocation.MyCommand.Path
} 

$VerboseLogging = "true"
[bool]$Global:Verbose = [System.Convert]::ToBoolean($VerboseLogging)
$Global:LogFile = Join-Path (GetScriptDirectory) 'TeslaCam.log' 
$Global:MaxLogSizeInKB = 5120
$Global:ScriptName = 'Stitched.ps1'
$Global:ScriptStatus = 'Success'
$Global:hostname = 'teslausb'
$Global:path = 'C:\ServerFolders\Pictures\TeslaCam\'
$Global:outputFolder = 'Stitched'

C:\Python37\python.exe -m pip install --upgrade pip
pip install tesla_dashcam==0.1.8
#pip install tesla_dashcam --upgrade

if(!(Test-Connection $hostname -quiet))
{
    LogIt -message ("$hostname is offline, starting run") -component "Test-Connection" -type 1 
    $dir = get-childitem -path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue  | Where-Object {$_.Name -ne $outputFolder} | Select-Object Name,FullName
    $count = ($dir).count
    LogIt -message ("Folders to Process: $count") -component "Test-Connection" -type 1 
    #write-host "Folders to Process: " $count

    foreach($folder in $dir) 
    {
        $foldername = $folder.fullname
        $fold = $folder.name
        LogIt -message ("Starting:  $foldername") -component "tesla_dashcam" -type 1 
        #write-host "Starting: " $folder.fullname
        $output = $path + $outputFolder + '\' + $folder.name

        #0.1.8
        tesla_dashcam $folder.fullname --quality HIGH --layout WIDESCREEN --encoding x265 --output $output --timestamp
        #0.1.9
        #tesla_dashcam $folder.fullname --quality HIGH --layout WIDESCREEN --encoding x265 --output $output --timestamp --delete_source true --complression veryslow
        
        #0.1.8 only
        #Write-Host "Cleaning up " $folderpath
        LogIt -message ("Deleting:  $fold") -component "Remove-Item" -type 1 
        Remove-Item -Recurse -Force $folder.fullname
    }
    LogIt -message ("Completed Run") -component "Complete" -type 1 
}
else {
    LogIt -message ("$hostname is online, skipping run") -component "Test-Connection" -type 1  
}