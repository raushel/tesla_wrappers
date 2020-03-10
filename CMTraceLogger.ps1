#Logging
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

  if (($type -eq "Verbose") -and ($Global:Verbose) -and ($Global:file_log_enabled))
  {
    $toLog = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($type + ":" + $message), ($Global:ScriptName + ":" + $component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    $toLog | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $Global:LogFile)
    Write-Host $message
  }
  elseif ($type -ne "Verbose" -and ($Global:file_log_enabled))
  {
    $toLog = "{0} `$$<{1}><{2} {3}><thread={4}>" -f ($type + ":" + $message), ($Global:ScriptName + ":" + $component), (Get-Date -Format "MM-dd-yyyy"), (Get-Date -Format "HH:mm:ss.ffffff"), $pid
    $toLog | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $Global:LogFile)
    Write-Host $message
  }
  if (($type -eq 'Warning') -and ($Global:ScriptStatus -ne 'Error')) { $Global:ScriptStatus = $type }
  if ($type -eq 'Error') 
  { 
    $Global:ScriptStatus = $type
    
    if($Global:pushover_enabled)
    {
      $parameters = @{
        token = $Global:pushover_app_key
        user = $Global:pushover_user_key
        message = "$component : $message"
      }
      $uri = "https://api.pushover.net/1/messages.json"
      
      $parameters | Invoke-RestMethod -Uri $uri -Method Post
    }

    if($Global:ifttt_enabled)
    {
        $body = @{
          value1 = $component
          value2 = $message
        }
      
      $ifttt_uri = "https://maker.ifttt.com/trigger/{0}/with/key/{1}" -f $Global:ifttt_event, $Global:ifttt_key

      Invoke-RestMethod -Method Get -Uri $ifttt_uri -Body $body
    }
  }

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