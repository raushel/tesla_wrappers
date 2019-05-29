$ErrorActionPreference = "Stop"

. $PSScriptRoot\CMTraceLogger.ps1
. $PSScriptRoot\VarLibrary.ps1

#Var
$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

$Files = Get-ChildItem "$DCROOT_FOLDER\$IP_1_PATH", "$path\$outputfolder"
$OldFiles = $Files | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$retDays)}

if($OldFiles)
{
    $oldCount = $oldfiles.Count
    $oldSize = [Math]::Round(($oldfiles | Measure-Object -Sum Length).Sum / 1GB)
    LogIt -message ("Files to Delete: $oldCount") -component 'Count' -type 3
    LogIt -message ("Size to Delete: $oldSize GB") -component 'Sum' -type 1
    foreach($oldfile in $oldfiles.FullName) 
    {
        Remove-Item -Force $oldfile
        LogIt -message ("Deleting $oldfile") -component 'Remove-Item' -Type 1
    }
}
else {
    LogIt -Message ("No files to Delete") -component 'Remove-Item' -Type 2
}

LogIt -message ("Recording Cleanup Complete") -component 'Cleanup' -Type 3