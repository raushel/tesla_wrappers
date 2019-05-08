$ErrorActionPreference = "Stop"

. $PSScriptRoot\CMTraceLogger.ps1
. $PSScriptRoot\VarLibrary.ps1

#Var
$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

#C:\Python37\python.exe -m pip install --upgrade pip
#pip install tesla_dashcam==0.1.8
#pip install tesla_dashcam --upgrade

if(!(Test-Connection $hostname -quiet))
{
    LogIt -message ("$hostname is offline, starting run") -component "Test-Connection" -type 1 
    $dir = get-childitem -path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue  | Where-Object {$_.Name -ne $outputFolder} | Select-Object Name,FullName
    $count = ($dir).count
    LogIt -message ("Folders to Process: $count") -component "Test-Connection" -type 2 

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
        
        #Set the Created/Modified Date based on the filedate rather than copied date
        $file = Get-Item "$output.mp4"
        $datetime = [datetime]$output.substring(0,10) + [TimeSpan]$output.substring(11,8).replace('-',':')

        $file.LastWriteTime = $datetime
        $file.CreationTime = $datetime
    
        #0.1.8 only
        if(Test-Path $Output)
        {
            LogIt -message ("Deleting:  $fold") -component "Remove-Item" -type 1 
            Remove-Item -Recurse -Force $folder.fullname
        }
        else {
            LogIt -message ("Error:  $fold not deleted, $Output.mp4 not created") -component "Remove-Item" -type 3 
        }
    }
    LogIt -message ("Completed Run") -component "Complete" -type 1 
}
else {
    LogIt -message ("$hostname is online, skipping run") -component "Test-Connection" -type 1  
}