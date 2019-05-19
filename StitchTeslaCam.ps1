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

        $output = $path + $outputFolder + '\' + $folder.name

        #0.1.8
        $result = tesla_dashcam $folder.fullname --quality HIGH --layout WIDESCREEN --encoding x265 --output $output --timestamp
        #0.1.9
        #$result = .\tesla_dashcam.exe --quality HIGH --layout WIDESCREEN --encoding x265 --output $output --compression veryslow --no-notification $folder.fullname
        
        $result >> Tesla_Dashcam.log

        LogIt -message ("Tesla_Dashcam.log updated with last run") -component "tesla_dashcam" -type 2
    
        if(Test-Path "$output.mp4")
        {

            #Set the Created/Modified Date based on the filedate rather than copied date
            $file = Get-Item "$output.mp4"
            $datetime = [datetime]$folder.name.substring(0,10) + [TimeSpan]$folder.name.substring(11,8).replace('-',':')

            $file.LastWriteTime = $datetime
            $file.CreationTime = $datetime

            LogIt -message ("Deleting:  $fold") -component "Remove-Item" -type 1 
            Remove-Item -Recurse -Force $folder.fullname
        }
        else {
            LogIt -message ("Error: $output.mp4 not created, see results from tesla_dashcam") -component "Test-Path" -type 3 
        }
    }
    LogIt -message ("Completed Run") -component "Complete" -type 1 
}
else {
    LogIt -message ("$hostname is online, skipping run") -component "Test-Connection" -type 1  
}
