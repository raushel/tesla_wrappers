#Logging

$VerboseLogging = "true"
[bool]$Global:Verbose = [System.Convert]::ToBoolean($VerboseLogging)
$Global:MaxLogSizeInKB = 5120
$Global:ScriptStatus = 'Success'

#Var to populate in script
$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

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
    Remove-Item ($log.Replace(".log", ".lo_")) -ErrorAction SilentlyContinue
    Rename-Item $Global:LogFile ($log.Replace(".log", ".lo_")) -Force
  }
} 

function GetScriptDirectory
{
  $invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $invocation.MyCommand.Path
}