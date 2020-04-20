$ErrorActionPreference = "Stop"

. $PSScriptRoot\CMTraceLogger.ps1
. $PSScriptRoot\VarLibrary.ps1

#Var
$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

$Files = Get-ChildItem "$outputfolder", "$DCROOT_FOLDER\$IP_1_PATH",  "$DCROOT_FOLDER\$IP_2_PATH", "$DCROOT_FOLDER\$IP_3_PATH", "$DCROOT_FOLDER\$IP_4_PATH", "$DCROOT_FOLDER\$IP_5_PATH" -ErrorAction SilentlyContinue
$OldFiles = $Files | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$retDays)}

if($oldfiles)
{
    $oldCount = $oldfiles.Count
    $oldSize = [Math]::Round(($oldfiles | Measure-Object -Sum Length).Sum / 1GB)
    LogIt -message ("Files to Delete: $oldCount, $oldSize GB") -component 'Count/Size' -type 3

    foreach($oldfile in $oldfiles.FullName) 
    {
        Try{
            Remove-Item -Force $oldfile
            #LogIt -message ("Deleting  $oldfile") -component 'Remove-Item' -Type 1
        }
        Catch
        {
            LogIt -message ("$_") -component "Remove-Item" -type 3
        }
    }
}
else {
    LogIt -Message ("No files to Delete") -component 'Remove-Item' -Type 2
}

LogIt -message ("Recording Cleanup Complete") -component 'Cleanup' -Type 3
