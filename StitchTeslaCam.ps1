$ErrorActionPreference = "Stop"

. $PSScriptRoot\CMTraceLogger.ps1
. $PSScriptRoot\VarLibrary.ps1

#Var
$Global:LogFile = $PSScriptRoot.ToString() + '\' + ($MyInvocation.MyCommand.Name).Replace('.ps1','.log')
$Global:ScriptName = $MyInvocation.MyCommand.ToString()

$Script:FileCount = 0

C:\Python37\python.exe -m pip install --upgrade pip
#pip install ffmpeg --upgrade
pip install tesla_dashcam==0.1.11
#pip install tesla_dashcam --upgrade

#Only needed on first run
#Install-PackageProvider NuGet -Force
#Install-Module posh-ssh -force

$online = Test-Connection $hostname -quiet

#Check if sync is already complete
if($online)
{
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $usbname, (ConvertTo-SecureString $usbpw -AsPlainText -Force)
    $sess = New-SFTPSession -computername $hostname -credential $cred -AcceptKey
    $cam = Get-SFTPChildItem -sessionid $sess.SessionId -path '/mnt/cam'
}

#Only run if offline or if cam has completed sync
if(!$online -or $cam.count -eq 2)
{
    LogIt -message ("$hostname is offline/synced, starting run") -component "Test-Connection" -type 1 
    $dir = get-childitem -path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue  | Where-Object {$_.Name -ne $outputFolder} | Select-Object Name,FullName
    $dirs = $dir | Measure-Object
    $count = ($dirs).count

    if($count -gt 0) {$type = 3}
    else {$type = 2}
    LogIt -message ("Folders to Process: $count") -component "Test-Connection" -type $type 
    
    $i = 1

    foreach($folder in $dir) 
    {
        $foldername = $folder.fullname
        $fold = $folder.name
        LogIt -message ("Starting:  $foldername ($i / $count)") -component "tesla_dashcam" -type 1
        $i++

        if((Get-ChildItem $foldername | Measure-Object).Count -eq 0)
        {
            LogIt -message ("Folder is empty, removing $foldername") -component "tesla_dashcam" -type 3
            Try {
                Remove-Item $foldername
            }
            Catch {
                LogIt -message ("$_") -component "tesla_dashcam" -type 3
            }
            Continue
        }

        #0.1.10
        #Force output back to folder instead of new default: Videos\Tesla_Dashcam (Windows)
        $output = $foldername + '\' + $fold + '.mp4'
        $dest = $path + '\' + $outputFolder + '\' + $fold + '.mp4'
        Try {
            $result = tesla_dashcam --quality HIGH --layout WIDESCREEN --rear --encoding x265 --no-notification --output $output $foldername --no-check_for_update #--no-timestamp
        }
        Catch {
            LogIt -message ("$_") -component "tesla_dashcam" -type 3
        }
        #$result >> Tesla_Dashcam.log
        $result | Out-File -Append -Encoding UTF8 -FilePath ("filesystem::{0}" -f $Global:LogFile)

        #0.1.9 changed --output to also store the temp files in target directory, moving it after completion to avoid Plex issues
        try {
            if(!((Get-Item "$output") -is [System.IO.DirectoryInfo]))
            {
                Move-Item -Path "$output" -Destination "$dest"
                LogIt -message ("Moved $output to $dest") -component "Move-Item" -type 2
            }
            else{
                LogIt -message ("$Output is Directory") -component "Move-Item" -Type 3
                #Remove-Item "$output"
                Write-Error "$Output is Directory"
            }
        }
        catch {
            LogIt -message ("$_") -component "Move-Item" -Type 3
        }
    
        if(Test-Path "$dest")
        {
            #Set the Created/Modified Date based on the filedate rather than copied date
            $file = Get-Item "$dest"
            $datetime = [datetime]$fold.substring(0,10) + [TimeSpan]$fold.substring(11,8).replace('-',':')

            $file.LastWriteTime = $datetime
            $file.CreationTime = $datetime
            $Script:FileCount++

            try{
                Remove-Item -Recurse -Force $foldername
                LogIt -message ("Deleted: $fold") -component "Remove-Item" -type 1 
            }
            catch {
                Logit -message ("$_") -component "Remove-Item" -Type 3
            }
        }
        else {
            LogIt -message ("Error: $output not created, see results from tesla_dashcam") -component "Test-Path" -type 3 
        }
        LogIt -message ("StitchTeslaCam: $Script:FileCount Processed") -component "Complete" -type 3
    }
    LogIt -message ("Completed Run") -component "Complete" -type 1
}
else {
    LogIt -message ("$hostname is online, skipping run") -component "Test-Connection" -type 1  
}
